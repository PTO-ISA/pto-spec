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
                         capacity_bytes: integer {512,1024,2048,4096,8192,16384,32768})
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

func TLOADShared(shared_id: bits(8), base_address: Word,
                 size_code: integer {1..7},
                 rows: integer {1..65535}, columns: integer {1..65535},
                 valid_rows: integer {1..65535},
                 valid_columns: integer {1..65535},
                 data_type: TileDataType, layout: TileLayout,
                 pe_mask: bits(4))
begin
    if pe_mask == Zeros{4} then return; end;
    let capacity_bytes = TileSizeCodeBytes(size_code);
    assert valid_rows <= rows && valid_columns <= columns;
    assert rows * columns <= PTO_MODEL_TILE_ELEMENTS;
    assert TileStorageFitsCapacity(rows, columns, data_type, capacity_bytes);
    var tile: TileInfo;
    tile.allocated = TRUE;
    tile.contents_defined = FALSE;
    tile.defined_elements = Zeros{PTO_MODEL_TILE_ELEMENTS};
    tile.defined_valid_elements = 0;
    tile.capacity_bytes = capacity_bytes;
    tile.rows = rows;
    tile.columns = columns;
    tile.valid_rows = valid_rows;
    tile.valid_columns = valid_columns;
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
                let address = TileMemoryElementAddress(base_address, element,
                    tile.data_type);
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
                let high_nibble = TileMemoryElementHighNibble(element,
                    tile.data_type);
                let raw = LoadTranslatedUnsigned(translated_addresses[[element]],
                    TileMemoryElementBytes(tile.data_type));
                RecordLoadEvent(translated_addresses[[element]],
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
            (tile.valid_rows * tile.valid_columns) as integer {0..4096};
        tile.contents_defined = TRUE;
    end;
    let updated = AtomicUpdateSharedTile(shared_id, tile, pe_mask);
    assert updated;
end;

func TSTOREShared(base_address: Word, shared_id: bits(8),
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
                let address = TileMemoryElementAddress(base_address, element,
                    tile.data_type);
                let probe = ProbeTileMemoryAccess(address, tile.data_type, TRUE);
                if RaiseDataAccessFault(probe, address) then return; end;
                original_addresses[[element]] = address;
                translated_addresses[[element]] = probe.translated_address;
                high_nibbles[element] = if TileMemoryElementHighNibble(
                    element, tile.data_type) then '1' else '0';
            end;
        end;
    end;
    for row = 0 to tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to tile.valid_columns - 1 looplimit 65536 do
            let element = TileLinearIndex(tile,
                row as integer {0..65535}, column as integer {0..65535});
            let selected = pe_mask[SharedTileElementRegion(tile, element)] == '1';
            if selected then
                let stored_value = StoreTileMemoryElement(
                    original_addresses[[element]],
                    translated_addresses[[element]], tile.data_type,
                    high_nibbles[element] == '1',
                    ReadSharedTileWord(shared_id, element));
                RecordStoreEvent(translated_addresses[[element]],
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

pure func TileMemoryElementBytes(data_type: TileDataType) => integer {1,2,4,8}
begin
    // PTO-v0 TLSU exposes four-bit elements through byte-sized containing
    // accesses. Tile capacity remains packed in TileInfo.
    if TileDataTypeIsFourBit(data_type) then return 1;
    else return TileElementBytes(data_type);
    end;
end;

readonly func TileMemoryElementAddress(base_address: Word,
                                       element: ModelTileElementIndex,
                                       data_type: TileDataType) => Word
begin
    if TileDataTypeIsFourBit(data_type) then
        let offset = (element DIVRM 2) as integer {0..262144};
        return base_address + NaturalToWord(offset);
    else
        let element_bytes = TileElementBytes(data_type);
        let offset = (element * element_bytes) as integer {0..262144};
        return base_address + NaturalToWord(offset);
    end;
end;

readonly func TileMemoryIndexedAddress(base_address: Word,
                                       index_value: Word,
                                       data_type: TileDataType) => Word
begin
    if TileDataTypeIsFourBit(data_type) then
        return base_address + ZeroExtend{PTO_XLEN}(index_value[63:1]);
    else
        let element_bytes = TileElementBytes(data_type);
        let byte_width = NaturalToWord(element_bytes as integer {0..262144});
        return base_address + MultiplyWord(index_value, byte_width);
    end;
end;

readonly func TileMemoryElementHighNibble(element: ModelTileElementIndex,
                                          data_type: TileDataType) => boolean
begin
    return TileDataTypeIsFourBit(data_type) && element MOD 2 == 1;
end;

readonly func TileMemoryIndexedHighNibble(index_value: Word,
                                          data_type: TileDataType) => boolean
begin
    return TileDataTypeIsFourBit(data_type) && index_value[0] == '1';
end;

readonly func LoadTileMemoryElement(translated_address: Word,
                                    data_type: TileDataType,
                                    high_nibble: boolean) => Word
begin
    let element_bytes = TileMemoryElementBytes(data_type);
    let raw = LoadTranslatedUnsigned(translated_address, element_bytes);
    if TileDataTypeIsFourBit(data_type) then
        if high_nibble then return ZeroExtend{PTO_XLEN}(raw[7:4]);
        else return ZeroExtend{PTO_XLEN}(raw[3:0]);
        end;
    else
        return NormalizeLoadedValue(raw, element_bytes,
            TileDataTypeIsSigned(data_type));
    end;
end;

func StoreTileMemoryElement(original_address: Word,
                            translated_address: Word,
                            data_type: TileDataType,
                            high_nibble: boolean,
                            value: Word) => Word
begin
    let element_bytes = TileMemoryElementBytes(data_type);
    if TileDataTypeIsFourBit(data_type) then
        let old_byte = LoadTranslatedUnsigned(translated_address, 1);
        var stored_byte: Byte = old_byte[7:0];
        if high_nibble then stored_byte[7:4] = value[3:0];
        else stored_byte[3:0] = value[3:0];
        end;
        let stored_value = ZeroExtend{PTO_XLEN}(stored_byte);
        StoreTranslated(original_address, translated_address, 1, stored_value);
        return stored_value;
    else
        let stored_value = NormalizeMemoryAccessValue(value, element_bytes);
        StoreTranslated(original_address, translated_address, element_bytes,
            stored_value);
        return stored_value;
    end;
end;

func ProbeTileMemoryAccess(address: Word, data_type: TileDataType,
                           write: boolean) => DataAccessProbe
begin
    let element_bytes = TileMemoryElementBytes(data_type);
    return ProbeDataAccess(address, element_bytes, element_bytes, write);
end;

func TLOAD(destination: TileIndex, base_address: Word)
begin
    let tile = _Tiles[[destination]];
    assert tile.allocated;
    var translated_addresses: TilePayload;
    // Instruction-wide preflight makes tile memory faults precise and
    // restartable: no payload element changes until every access succeeds.
    for row = 0 to tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to tile.valid_columns - 1 looplimit 65536 do
            let element = TileLinearIndex(tile,
                row as integer {0..65535}, column as integer {0..65535});
            let address = TileMemoryElementAddress(base_address, element,
                tile.data_type);
            let probe = ProbeTileMemoryAccess(address, tile.data_type, FALSE);
            if RaiseDataAccessFault(probe, address) then return; end;
            translated_addresses[[element]] = probe.translated_address;
        end;
    end;
    for row = 0 to tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to tile.valid_columns - 1 looplimit 65536 do
            let element = TileLinearIndex(tile,
                row as integer {0..65535}, column as integer {0..65535});
            let high_nibble = TileMemoryElementHighNibble(element,
                tile.data_type);
            let raw = LoadTranslatedUnsigned(translated_addresses[[element]],
                TileMemoryElementBytes(tile.data_type));
            RecordLoadEvent(translated_addresses[[element]],
                TileMemoryElementBytes(tile.data_type), raw,
                CurrentBundleMemoryOrder());
            _Tiles[[destination]].payload[[element]] =
                LoadTileMemoryElement(translated_addresses[[element]],
                    tile.data_type, high_nibble);
        end;
    end;
    MarkTileValidRegionDefined(destination);
end;

func TSTORE(base_address: Word, source: TileIndex)
begin
    let tile = _Tiles[[source]];
    assert tile.allocated && tile.contents_defined;
    let payload = tile.payload;
    var original_addresses: TilePayload;
    var translated_addresses: TilePayload;
    var high_nibbles: bits(PTO_MODEL_TILE_ELEMENTS);
    for row = 0 to tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to tile.valid_columns - 1 looplimit 65536 do
            let element = TileLinearIndex(tile,
                row as integer {0..65535}, column as integer {0..65535});
            let address = TileMemoryElementAddress(base_address, element,
                tile.data_type);
            let probe = ProbeTileMemoryAccess(address, tile.data_type, TRUE);
            if RaiseDataAccessFault(probe, address) then return; end;
            original_addresses[[element]] = address;
            translated_addresses[[element]] = probe.translated_address;
            high_nibbles[element] =
                if TileMemoryElementHighNibble(element, tile.data_type) then
                    '1' else '0';
        end;
    end;
    for row = 0 to tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to tile.valid_columns - 1 looplimit 65536 do
            let element = TileLinearIndex(tile,
                row as integer {0..65535}, column as integer {0..65535});
            let stored_value = StoreTileMemoryElement(
                original_addresses[[element]], translated_addresses[[element]],
                tile.data_type, high_nibbles[element] == '1',
                payload[[element]]);
            RecordStoreEvent(translated_addresses[[element]],
                TileMemoryElementBytes(tile.data_type), stored_value,
                CurrentBundleMemoryOrder());
        end;
    end;
end;

func MGATHER(destination: TileIndex, base_address: Word, indices: TileIndex)
begin
    let destination_tile = _Tiles[[destination]];
    let index_tile = _Tiles[[indices]];
    assert destination_tile.allocated;
    assert index_tile.allocated && index_tile.contents_defined;
    assert destination_tile.valid_rows == index_tile.valid_rows;
    assert destination_tile.valid_columns == index_tile.valid_columns;
    let index_payload = index_tile.payload;
    var translated_addresses: TilePayload;
    var high_nibbles: bits(PTO_MODEL_TILE_ELEMENTS);
    for row = 0 to destination_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to destination_tile.valid_columns - 1 looplimit 65536 do
            let element = TileLinearIndex(destination_tile,
                row as integer {0..65535}, column as integer {0..65535});
            let address = TileMemoryIndexedAddress(base_address,
                index_payload[[element]], destination_tile.data_type);
            let probe = ProbeTileMemoryAccess(address,
                destination_tile.data_type, FALSE);
            if RaiseDataAccessFault(probe, address) then return; end;
            translated_addresses[[element]] = probe.translated_address;
            high_nibbles[element] =
                if TileMemoryIndexedHighNibble(index_payload[[element]],
                    destination_tile.data_type) then '1' else '0';
        end;
    end;
    for row = 0 to destination_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to destination_tile.valid_columns - 1 looplimit 65536 do
            let element = TileLinearIndex(destination_tile,
                row as integer {0..65535}, column as integer {0..65535});
            let raw = LoadTranslatedUnsigned(translated_addresses[[element]],
                TileMemoryElementBytes(destination_tile.data_type));
            RecordLoadEvent(translated_addresses[[element]],
                TileMemoryElementBytes(destination_tile.data_type), raw,
                CurrentBundleMemoryOrder());
            _Tiles[[destination]].payload[[element]] =
                LoadTileMemoryElement(translated_addresses[[element]],
                    destination_tile.data_type, high_nibbles[element] == '1');
        end;
    end;
    MarkTileValidRegionDefined(destination);
end;

func CommitScatterLanes(source_tile: TileInfo,
                        source_payload: TilePayload,
                        lane_order: ScatterLaneOrder,
                        lane_count: integer {0..PTO_MODEL_TILE_ELEMENTS},
                        original_addresses: TilePayload,
                        translated_addresses: TilePayload,
                        high_nibbles: bits(PTO_MODEL_TILE_ELEMENTS))
begin
    // Non-atomic duplicate-address lanes have an unspecified winner. Atomic
    // bundle execution retains descriptor order and contributes ordered events.
    var commit_order = lane_order;
    if lane_count > 0 then
        for position = 0 to lane_count - 1
            looplimit PTO_MODEL_TILE_ELEMENTS do
            var selected_position:
                integer {0..PTO_MODEL_TILE_ELEMENTS-1} =
                    position as integer {0..PTO_MODEL_TILE_ELEMENTS-1};
            if !CurrentBundleAtomic() then
                var selected = FALSE;
                for candidate_position = position to lane_count - 1
                    looplimit PTO_MODEL_TILE_ELEMENTS do
                    if !selected then
                        if ARBITRARY: boolean then
                            selected_position = candidate_position as
                                integer {0..PTO_MODEL_TILE_ELEMENTS-1};
                            selected = TRUE;
                        end;
                    end;
                end;
            end;
            let selected_element = commit_order[[selected_position]];
            commit_order[[selected_position]] = commit_order[[position]];
            commit_order[[position]] = selected_element;
            let element = UInt(commit_order[[position]]) as
                ModelTileElementIndex;
            let stored_value = StoreTileMemoryElement(
                original_addresses[[element]], translated_addresses[[element]],
                source_tile.data_type, high_nibbles[element] == '1',
                source_payload[[element]]);
            RecordStoreEvent(translated_addresses[[element]],
                TileMemoryElementBytes(source_tile.data_type), stored_value,
                CurrentBundleMemoryOrder());
        end;
    end;
end;

func MSCATTER(base_address: Word, source: TileIndex, indices: TileIndex)
begin
    let source_tile = _Tiles[[source]];
    let index_tile = _Tiles[[indices]];
    assert source_tile.allocated && source_tile.contents_defined;
    assert index_tile.allocated && index_tile.contents_defined;
    assert source_tile.valid_rows == index_tile.valid_rows;
    assert source_tile.valid_columns == index_tile.valid_columns;
    let source_payload = source_tile.payload;
    let index_payload = index_tile.payload;
    var lane_order: ScatterLaneOrder;
    var lane_count: integer {0..PTO_MODEL_TILE_ELEMENTS} = 0;
    var original_addresses: TilePayload;
    var translated_addresses: TilePayload;
    var high_nibbles: bits(PTO_MODEL_TILE_ELEMENTS);
    for row = 0 to source_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to source_tile.valid_columns - 1 looplimit 65536 do
            let element = TileLinearIndex(source_tile,
                row as integer {0..65535}, column as integer {0..65535});
            let address = TileMemoryIndexedAddress(base_address,
                index_payload[[element]], source_tile.data_type);
            let probe = ProbeTileMemoryAccess(address,
                source_tile.data_type, TRUE);
            if RaiseDataAccessFault(probe, address) then return; end;
            original_addresses[[element]] = address;
            translated_addresses[[element]] = probe.translated_address;
            high_nibbles[element] =
                if TileMemoryIndexedHighNibble(index_payload[[element]],
                    source_tile.data_type) then '1' else '0';
            lane_order[[lane_count]] =
                NaturalToWord(element as integer {0..262144});
            lane_count = (lane_count + 1) as
                integer {0..PTO_MODEL_TILE_ELEMENTS};
        end;
    end;
    CommitScatterLanes(source_tile, source_payload, lane_order, lane_count,
        original_addresses, translated_addresses, high_nibbles);
end;

func TPREFETCH(base_address: Word, byte_count: integer {0..262144})
begin
    // Probe each original byte before recording any event so the first failing
    // address is precise and a failed footprint has no partial event prefix.
    for byte_index = 0 to byte_count - 1 looplimit 262144 do
        let address = base_address +
            NaturalToWord(byte_index as integer {0..262144});
        let probe = ProbeDataAccess(address, 1, 1, FALSE);
        if RaiseDataAccessFault(probe, address) then return; end;
    end;
    for byte_index = 0 to byte_count - 1 looplimit 262144 do
        let address = base_address +
            NaturalToWord(byte_index as integer {0..262144});
        let probe = ProbeDataAccess(address, 1, 1, FALSE);
        assert probe.fault == Fault_None;
        let value = LoadTranslatedUnsigned(probe.translated_address, 1);
        RecordLoadEvent(probe.translated_address, 1, value,
            CurrentBundleMemoryOrder());
    end;
end;

func MGATHER_MASK(destination: TileIndex, base_address: Word, indices: TileIndex,
                  mask: TileIndex, pad_value: TilePadValue)
begin
    let destination_tile = _Tiles[[destination]];
    let index_tile = _Tiles[[indices]];
    let mask_payload = _Tiles[[mask]].payload;
    assert destination_tile.allocated;
    assert index_tile.allocated && index_tile.contents_defined;
    assert _Tiles[[mask]].allocated && _Tiles[[mask]].contents_defined;
    assert destination_tile.valid_rows == index_tile.valid_rows;
    assert destination_tile.valid_columns == index_tile.valid_columns;
    let index_payload = index_tile.payload;
    var translated_addresses: TilePayload;
    var high_nibbles: bits(PTO_MODEL_TILE_ELEMENTS);
    for row = 0 to destination_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to destination_tile.valid_columns - 1 looplimit 65536 do
            let element = TileLinearIndex(destination_tile,
                row as integer {0..65535}, column as integer {0..65535});
            if !IsZero(mask_payload[[element]]) then
                let address = TileMemoryIndexedAddress(base_address,
                    index_payload[[element]], destination_tile.data_type);
                let probe = ProbeTileMemoryAccess(address,
                    destination_tile.data_type, FALSE);
                if RaiseDataAccessFault(probe, address) then return; end;
                translated_addresses[[element]] = probe.translated_address;
                high_nibbles[element] =
                    if TileMemoryIndexedHighNibble(index_payload[[element]],
                        destination_tile.data_type) then '1' else '0';
            end;
        end;
    end;
    for row = 0 to destination_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to destination_tile.valid_columns - 1 looplimit 65536 do
            let element = TileLinearIndex(destination_tile,
                row as integer {0..65535}, column as integer {0..65535});
            if !IsZero(mask_payload[[element]]) then
                let raw = LoadTranslatedUnsigned(translated_addresses[[element]],
                    TileMemoryElementBytes(destination_tile.data_type));
                RecordLoadEvent(translated_addresses[[element]],
                    TileMemoryElementBytes(destination_tile.data_type), raw,
                    CurrentBundleMemoryOrder());
                _Tiles[[destination]].payload[[element]] =
                    LoadTileMemoryElement(translated_addresses[[element]],
                        destination_tile.data_type,
                        high_nibbles[element] == '1');
            else
                _Tiles[[destination]].payload[[element]] =
                    TilePadValueForDataType(
                        pad_value, destination_tile.data_type);
            end;
        end;
    end;
    MarkTileValidRegionDefined(destination);
end;

func MSCATTER_MASK(base_address: Word, source: TileIndex, indices: TileIndex,
                   mask: TileIndex)
begin
    let source_tile = _Tiles[[source]];
    let index_tile = _Tiles[[indices]];
    let mask_payload = _Tiles[[mask]].payload;
    assert source_tile.allocated && source_tile.contents_defined;
    assert index_tile.allocated && index_tile.contents_defined;
    assert _Tiles[[mask]].allocated && _Tiles[[mask]].contents_defined;
    assert source_tile.valid_rows == index_tile.valid_rows;
    assert source_tile.valid_columns == index_tile.valid_columns;
    let source_payload = source_tile.payload;
    let index_payload = index_tile.payload;
    var lane_order: ScatterLaneOrder;
    var lane_count: integer {0..PTO_MODEL_TILE_ELEMENTS} = 0;
    var original_addresses: TilePayload;
    var translated_addresses: TilePayload;
    var high_nibbles: bits(PTO_MODEL_TILE_ELEMENTS);
    for row = 0 to source_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to source_tile.valid_columns - 1 looplimit 65536 do
            let element = TileLinearIndex(source_tile,
                row as integer {0..65535}, column as integer {0..65535});
            if !IsZero(mask_payload[[element]]) then
                let address = TileMemoryIndexedAddress(base_address,
                    index_payload[[element]], source_tile.data_type);
                let probe = ProbeTileMemoryAccess(address,
                    source_tile.data_type, TRUE);
                if RaiseDataAccessFault(probe, address) then return; end;
                original_addresses[[element]] = address;
                translated_addresses[[element]] = probe.translated_address;
                high_nibbles[element] =
                    if TileMemoryIndexedHighNibble(index_payload[[element]],
                        source_tile.data_type) then '1' else '0';
                lane_order[[lane_count]] =
                    NaturalToWord(element as integer {0..262144});
                lane_count = (lane_count + 1) as
                    integer {0..PTO_MODEL_TILE_ELEMENTS};
            end;
        end;
    end;
    CommitScatterLanes(source_tile, source_payload, lane_order, lane_count,
        original_addresses, translated_addresses, high_nibbles);
end;

func MGATHER_CAS(destination: TileIndex, base_address: Word, indices: TileIndex,
                 expected: TileIndex, replacement: TileIndex)
begin
    let destination_tile = _Tiles[[destination]];
    let index_tile = _Tiles[[indices]];
    let expected_payload = _Tiles[[expected]].payload;
    let replacement_payload = _Tiles[[replacement]].payload;
    assert destination_tile.allocated;
    assert index_tile.allocated && index_tile.contents_defined;
    assert _Tiles[[expected]].allocated && _Tiles[[expected]].contents_defined;
    assert _Tiles[[replacement]].allocated &&
        _Tiles[[replacement]].contents_defined;
    assert destination_tile.valid_rows == index_tile.valid_rows;
    assert destination_tile.valid_columns == index_tile.valid_columns;
    let index_payload = index_tile.payload;
    var original_addresses: TilePayload;
    var translated_addresses: TilePayload;
    var write_translated_addresses: TilePayload;
    var high_nibbles: bits(PTO_MODEL_TILE_ELEMENTS);
    for row = 0 to destination_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to destination_tile.valid_columns - 1 looplimit 65536 do
            let element = TileLinearIndex(destination_tile,
                row as integer {0..65535}, column as integer {0..65535});
            let address = TileMemoryIndexedAddress(base_address,
                index_payload[[element]], destination_tile.data_type);
            let read_probe = ProbeTileMemoryAccess(address,
                destination_tile.data_type, FALSE);
            if RaiseDataAccessFault(read_probe, address) then return; end;
            let write_probe = ProbeTileMemoryAccess(address,
                destination_tile.data_type, TRUE);
            if RaiseDataAccessFault(write_probe, address) then return; end;
            if read_probe.translated_address != write_probe.translated_address then
                SetFault(Fault_DataPage, address);
                return;
            end;
            original_addresses[[element]] = address;
            translated_addresses[[element]] = read_probe.translated_address;
            write_translated_addresses[[element]] =
                write_probe.translated_address;
            high_nibbles[element] =
                if TileMemoryIndexedHighNibble(index_payload[[element]],
                    destination_tile.data_type) then '1' else '0';
        end;
    end;
    for row = 0 to destination_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to destination_tile.valid_columns - 1 looplimit 65536 do
            let element = TileLinearIndex(destination_tile,
                row as integer {0..65535}, column as integer {0..65535});
            let old_raw = LoadTranslatedUnsigned(
                translated_addresses[[element]],
                TileMemoryElementBytes(destination_tile.data_type));
            let high_nibble = high_nibbles[element] == '1';
            let old_value = LoadTileMemoryElement(
                translated_addresses[[element]], destination_tile.data_type,
                high_nibble);
            _Tiles[[destination]].payload[[element]] = old_value;
            let succeeds = old_value == expected_payload[[element]];
            var write_value = replacement_payload[[element]];
            if TileDataTypeIsFourBit(destination_tile.data_type) then
                let old_byte = LoadTranslatedUnsigned(
                    write_translated_addresses[[element]], 1);
                var candidate_byte: Byte = old_byte[7:0];
                if high_nibble then
                    candidate_byte[7:4] = replacement_payload[[element]][3:0];
                else
                    candidate_byte[3:0] = replacement_payload[[element]][3:0];
                end;
                write_value = ZeroExtend{PTO_XLEN}(candidate_byte);
            else
                write_value = NormalizeMemoryAccessValue(
                    replacement_payload[[element]],
                    TileMemoryElementBytes(destination_tile.data_type));
            end;
            if succeeds then
                - = StoreTileMemoryElement(original_addresses[[element]],
                    write_translated_addresses[[element]],
                    destination_tile.data_type, high_nibble,
                    replacement_payload[[element]]);
            end;
            RecordAtomicEvent(write_translated_addresses[[element]],
                TileMemoryElementBytes(destination_tile.data_type), old_raw,
                write_value, CurrentBundleMemoryOrder(), succeeds);
        end;
    end;
    MarkTileValidRegionDefined(destination);
end;
