// PTO-UNIT: {"id":"PTO-TILE-MODEL-MEMORY-SHARED-MOVEMENT","surface":"tile","classification":["model","memory","shared-movement"],"depends_on":["PTO-TILE-MODEL-STATE-SHARED-REGISTERS","PTO-SCALAR-MODEL-AGU-MEMORY","PTO-ARCH-MEMORY-MODEL-GLOBAL-MEMORY-ACCESS"]}
// PTO-REQ-TLSU-001, PTO-REQ-MEMORY-COMPLETION-001,
// PTO-REQ-MEMORY-TSO-001: precise, restartable direct
// TLOAD/TSTORE/MGATHER/MSCATTER and destination-free TPREFETCH.

type ScatterLaneOrder of array [[PTO_MODEL_TILE_ELEMENTS]] of Word;

readonly func SharedTileElementRegion(tile: TileInfo,
                                  element: ModelTileElementIndex)
                                  => integer {0..3}
begin
    let bit_offset: integer = element * TileElementBits(tile.data_type);
    let byte_offset: integer = bit_offset DIVRM 8;
    assert byte_offset < tile.capacity_bytes;
    return ((byte_offset * 4) DIVRM tile.capacity_bytes)
        as integer {0..3};
end;

func SharedTileFromLocal(source: TileIndex,
                         capacity_bytes: integer {128,256,512,1024,2048,4096,8192})
                         => TileInfo
begin
    let source_tile = _Tiles[[source]];
    assert source_tile.allocated && source_tile.contents_defined;
    assert source_tile.capacity_bytes == capacity_bytes;
    var result = source_tile;
    result.location = TileLocation_Any;
    return result;
end;

func TMOVLocalToShared(shared_id: bits(8), source: TileIndex,
                       size_code: integer {1..7}, pe_mask: bits(4))
begin
    if pe_mask == Zeros{4} then return; end;
    let capacity_bytes = TileSizeCodeBytes(size_code);
    let shared_tile = SharedTileFromLocal(source, capacity_bytes);
    let updated = AtomicUpdateSharedTile(shared_id, shared_tile, pe_mask);
    if !updated then SetFault(Fault_TileLegality, ReadTPC()); end;
end;

func TMOVSharedToLocal(destination: TileIndex, shared_id: bits(8),
                       pe_mask: bits(4))
begin
    if pe_mask == Zeros{4} then return; end;
    let shared = SharedTileRecord(shared_id);
    let destination_tile = _Tiles[[destination]];
    assert SharedTileDescriptorLegal(shared_id);
    assert destination_tile.capacity_bytes == shared.tile.capacity_bytes;
    assert destination_tile.rows == shared.tile.rows &&
           destination_tile.columns == shared.tile.columns &&
           destination_tile.valid_rows == shared.tile.valid_rows &&
           destination_tile.valid_columns == shared.tile.valid_columns &&
           destination_tile.data_type == shared.tile.data_type &&
           destination_tile.layout == shared.tile.layout;
    for element = 0 to shared.tile.rows * shared.tile.columns - 1
        looplimit 4096 do
        let region = SharedTileElementRegion(shared.tile,
            element as ModelTileElementIndex);
        if pe_mask[region] == '1' then
            _Tiles[[destination]].payload[[element]] = ReadSharedTileWord(
                shared_id, element as ModelTileElementIndex);
            _Tiles[[destination]].defined_elements[element] = '1';
        end;
    end;
    _Tiles[[destination]].contents_defined = pe_mask == '1111';
    if pe_mask == '1111' then MarkTileValidRegionDefined(destination); end;
end;

func TLOADShared(shared_id: bits(8), base_addresses: CorePEWords,
                 row_stride_elements: CorePEWords,
                 size_code: integer {1..7},
                 rows: integer {1..65535}, columns: integer {1..65535},
                 valid_rows: integer {1..65535},
                 valid_columns: integer {1..65535},
                 data_type: TileDataType, layout: TileLayout,
                 pe_mask: bits(4))
begin
    if pe_mask == Zeros{4} then return; end;
    let capacity_bytes = TileSizeCodeBytes(size_code);
    if rows < valid_rows || rows >
           DerivedTileRows(capacity_bytes, columns, data_type) ||
       !TileDescriptorShapeLegal(capacity_bytes, columns, valid_rows,
           valid_columns, data_type) then
        SetFault(Fault_TileLegality, ReadTPC());
        return;
    end;
    let derived_rows = DerivedTileRows(capacity_bytes, columns, data_type);
    if derived_rows * columns > PTO_MODEL_TILE_ELEMENTS then
        SetFault(Fault_TileLegality, ReadTPC());
        return;
    end;
    var tile: TileInfo;
    tile.allocated = TRUE;
    tile.contents_defined = FALSE;
    tile.defined_elements = Zeros{PTO_MODEL_TILE_ELEMENTS};
    tile.defined_valid_elements = 0;
    tile.capacity_bytes = capacity_bytes;
    tile.rows = derived_rows;
    tile.columns = columns;
    tile.valid_rows = valid_rows;
    tile.valid_columns = valid_columns;
    tile.storage_rows = derived_rows;
    tile.storage_columns = columns;
    tile.storage_bytes = TileStorageBytes(derived_rows, columns, data_type)
        as integer {0..262144};
    tile.cube_k_repeat = 0;
    tile.cube_n_repeat = 0;
    tile.cube_cell_count = 0;
    tile.data_type = data_type;
    tile.layout = layout;
    tile.location = TileLocation_Any;
    if !SharedTileUpdateCompatible(shared_id, tile, pe_mask) then
        SetFault(Fault_TileLegality, ReadTPC());
        return;
    end;
    var translated_addresses: TilePayload;
    for row = 0 to tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to tile.valid_columns - 1 looplimit 65536 do
            let element = TileLinearIndex(tile,
                row as integer {0..65535}, column as integer {0..65535});
            let region = SharedTileElementRegion(tile, element);
            if pe_mask[region] == '1' then
                let agent = region as MemoryAgentId;
                let memory_index = TileMemoryStridedIndex(
                    row as integer {0..65535},
                    column as integer {0..65535},
                    row_stride_elements[[agent]]);
                let address = TileMemoryIndexedAddress(
                    base_addresses[[agent]], memory_index, tile.data_type);
                let probe = ProbeTileMemoryAccess(address, tile.data_type, FALSE);
                if RaiseDataAccessFault(probe, address) then return; end;
                translated_addresses[[element]] = probe.translated_address;
            end;
        end;
    end;
    for row = 0 to tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to tile.valid_columns - 1 looplimit 65536 do
            let element = TileLinearIndex(tile,
                row as integer {0..65535}, column as integer {0..65535});
            let region = SharedTileElementRegion(tile, element);
            if pe_mask[region] == '1' then
                let agent = region as MemoryAgentId;
                let memory_index = TileMemoryStridedIndex(
                    row as integer {0..65535},
                    column as integer {0..65535},
                    row_stride_elements[[agent]]);
                let high_nibble = TileMemoryIndexedHighNibble(
                    memory_index, tile.data_type);
                let raw = LoadTranslatedUnsigned(translated_addresses[[element]],
                    TileMemoryElementBytes(tile.data_type));
                RecordLoadEventForAgent(agent,
                    translated_addresses[[element]],
                    TileMemoryElementBytes(tile.data_type), raw,
                    CurrentBundleMemoryOrder());
                tile.payload[[element]] = LoadTileMemoryElement(
                    translated_addresses[[element]], tile.data_type, high_nibble);
                tile.defined_elements[element] = '1';
            end;
        end;
    end;
    if pe_mask == '1111' then
        tile.defined_valid_elements =
            (tile.valid_rows * tile.valid_columns)
                as integer {0..16384};
        tile.contents_defined = TRUE;
    end;
    let updated = AtomicUpdateSharedTile(shared_id, tile, pe_mask);
    assert updated;
end;

func TSTOREShared(base_addresses: CorePEWords,
                  row_stride_elements: CorePEWords,
                  shared_id: bits(8),
                  pe_mask: bits(4))
begin
    if pe_mask == Zeros{4} then return; end;
    let shared = SharedTileRecord(shared_id);
    assert SharedTileDescriptorLegal(shared_id);
    let tile = shared.tile;
    var original_addresses: TilePayload;
    var translated_addresses: TilePayload;
    var high_nibbles: bits(PTO_MODEL_TILE_ELEMENTS);
    for row = 0 to tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to tile.valid_columns - 1 looplimit 65536 do
            let element = TileLinearIndex(tile,
                row as integer {0..65535}, column as integer {0..65535});
            let selected = pe_mask[SharedTileElementRegion(tile, element)] == '1';
            if selected then
                let agent = SharedTileElementRegion(tile, element)
                    as MemoryAgentId;
                let memory_index = TileMemoryStridedIndex(
                    row as integer {0..65535},
                    column as integer {0..65535},
                    row_stride_elements[[agent]]);
                let address = TileMemoryIndexedAddress(
                    base_addresses[[agent]], memory_index, tile.data_type);
                let probe = ProbeTileMemoryAccess(address, tile.data_type, TRUE);
                if RaiseDataAccessFault(probe, address) then return; end;
                original_addresses[[element]] = address;
                translated_addresses[[element]] = probe.translated_address;
                high_nibbles[element] = if TileMemoryIndexedHighNibble(
                    memory_index, tile.data_type) then '1' else '0';
            end;
        end;
    end;
    for row = 0 to tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to tile.valid_columns - 1 looplimit 65536 do
            let element = TileLinearIndex(tile,
                row as integer {0..65535}, column as integer {0..65535});
            let selected = pe_mask[SharedTileElementRegion(tile, element)] == '1';
            if selected then
                let agent = SharedTileElementRegion(tile, element)
                    as MemoryAgentId;
                let stored_value = StoreTileMemoryElement(
                    original_addresses[[element]],
                    translated_addresses[[element]], tile.data_type,
                    high_nibbles[element] == '1',
                    ReadSharedTileWord(shared_id, element));
                RecordStoreEventForAgent(agent,
                    translated_addresses[[element]],
                    TileMemoryElementBytes(tile.data_type), stored_value,
                    CurrentBundleMemoryOrder());
            end;
        end;
    end;
end;

func TMOV(destination: TileIndex, source: TileIndex)
begin
    let source_tile = _Tiles[[source]];
    assert source_tile.allocated;
    assert TileShapesMatch(_Tiles[[destination]], source_tile);
    _Tiles[[destination]].payload = source_tile.payload;
    _Tiles[[destination]].defined_elements = source_tile.defined_elements;
    _Tiles[[destination]].defined_valid_elements =
        source_tile.defined_valid_elements;
    _Tiles[[destination]].contents_defined = source_tile.contents_defined;
end;

// The direct-operation carrier binds source to the fragment already resolved
// from peer_tid by the Core4 collective front end.  This keeps the one-level
// ASL model explicit: GMOV copies that read-old snapshot into the local tile.
func GMOV(destination: TileIndex, source: TileIndex, peer_tid: Word)
begin
    assert UInt(peer_tid) < 4;
    let source_tile = _Tiles[[source]];
    let source_payload = source_tile.payload;
    _Tiles[[destination]].payload = source_payload;
    _Tiles[[destination]].defined_elements = source_tile.defined_elements;
    _Tiles[[destination]].defined_valid_elements =
        source_tile.defined_valid_elements;
    _Tiles[[destination]].contents_defined = source_tile.contents_defined;
end;
