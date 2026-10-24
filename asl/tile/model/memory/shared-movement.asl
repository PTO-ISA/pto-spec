// PTO-UNIT: {"id":"PTO-TILE-MODEL-MEMORY-SHARED-MOVEMENT","surface":"tile","classification":["model","memory","shared-movement"],"depends_on":["PTO-TILE-MODEL-MEMORY-SHARED-MOVEMENT-TYPES","PTO-TILE-MODEL-MEMORY-SHARED-MOVEMENT-VALUES","PTO-TILE-MODEL-STATE-SHARED-REGISTERS","PTO-SCALAR-MODEL-AGU-MEMORY","PTO-ARCH-MEMORY-MODEL-GLOBAL-MEMORY-ACCESS","PTO-TILE-MODEL-EXECUTION-MASK-STATE","PTO-TILE-MODEL-LEGALITY-EXECUTION-MASK-SOURCE-SCHEMA","PTO-TILE-MODEL-STATE-TYPES"]}
// PTO-REQ-TLSU-001, PTO-REQ-MEMORY-COMPLETION-001,
// PTO-REQ-MEMORY-RC-001: precise, restartable direct
// TLOAD/TSTORE/MGATHER/MSCATTER and destination-free TPREFETCH.

func SharedTileFromLocal(source: TileIndex,
                         capacity_bytes: integer {128,256,512,1024,2048,4096,8192,
                                                  16384,32768,65536,131072,
                                                  262144})
                         => TileInfo
begin
    let source_tile = _Tiles[[source]];
    assert source_tile.allocated && source_tile.contents_defined;
    assert source_tile.capacity_bytes == capacity_bytes;
    var result = source_tile;
    return result;
end;

func TMOVLocalToShared(shared_tile_id: SharedTileID, source: TileIndex,
                       size_code: integer {1..12}, pe_mask: bits(4),
                       publish: boolean)
begin
    if pe_mask == Zeros{4} then return; end;
    let capacity_bytes = TileSizeCodeBytes(size_code);
    let shared_tile = SharedTileFromLocal(source, capacity_bytes);
    if publish && !SharedTileProspectiveFullyInitialized(
            shared_tile_id, shared_tile, pe_mask) then
        SetFault(Fault_TileLegality, ReadTPC());
        return;
    end;
    let updated = AtomicUpdateSharedTileWithPublication(
        shared_tile_id, shared_tile, pe_mask, publish);
    if !updated then SetFault(Fault_TileLegality, ReadTPC()); end;
end;

func TMOVSharedToLocal(destination: TileIndex, shared_tile_id: SharedTileID,
                       shared_tile: TileInfo, pe_mask: bits(4))
begin
    if pe_mask == Zeros{4} then return; end;
    let destination_tile = _Tiles[[destination]];
    assert destination_tile.capacity_bytes == shared_tile.capacity_bytes;
    assert destination_tile.rows == shared_tile.rows &&
           destination_tile.columns == shared_tile.columns &&
           destination_tile.valid_rows == shared_tile.valid_rows &&
           destination_tile.valid_columns == shared_tile.valid_columns &&
           destination_tile.data_type == shared_tile.data_type &&
           destination_tile.layout == shared_tile.layout;
    // PE_MASK selects consumer PEs, not payload quarters. Every participating
    // consumer observes the same complete published parent when no B.SUBVIEW
    // narrows the source range.
    for element = 0 to shared_tile.rows * shared_tile.columns - 1
        looplimit 524288 do
        _Tiles[[destination]] = TileInfoWithLogicalElement(
            _Tiles[[destination]], element as PackedTileElementIndex,
            ReadSharedTileWord(shared_tile_id,
                element as PackedTileElementIndex));
    end;
    _Tiles[[destination]].contents_defined = TRUE;
    MarkTileValidRegionDefined(destination);
end;

func TLOADShared(shared_tile_id: SharedTileID, base_addresses: CorePEWords,
                 row_stride_bytes: CorePEWords,
                 size_code: integer {1..12},
                 rows: integer {1..65535}, columns: integer {1..65535},
                 valid_rows: integer {1..65535},
                 valid_columns: integer {1..65535},
                 data_type: TileDataType, layout: TileLayout,
                 pe_mask: bits(4))
begin
    let zero_packed_tile_elements = ZeroPackedTileDefinedElements();
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
    if derived_rows * columns >
           TileLogicalElementCapacity(capacity_bytes, data_type) then
        SetFault(Fault_TileLegality, ReadTPC());
        return;
    end;
    var tile: TileInfo;
    tile.allocated = TRUE;
    tile.contents_defined = FALSE;
    tile.defined_elements = Zeros{PTO_MODEL_TILE_ELEMENTS};
    tile.defined_valid_elements = 0;
    tile.packed_defined_elements = zero_packed_tile_elements;
    tile.capacity_bytes = capacity_bytes;
    tile.rows = derived_rows;
    tile.columns = columns;
    tile.valid_rows = valid_rows;
    tile.valid_columns = valid_columns;
    tile.data_type = data_type;
    tile.predicate_basis_type = data_type;
    tile.layout = layout;
    tile.cube_k_repeat = 0;
    tile.cube_n_repeat = 0;
    tile.cube_cell_count = 0;
    tile.cube_storage_bytes = 0;
    if !SharedTileUpdateCompatible(shared_tile_id, tile, pe_mask) then
        SetFault(Fault_TileLegality, ReadTPC());
        return;
    end;
    let single_issuer = PEMaskPopulation(pe_mask) == 1;
    let actual_pe_assembly = _CurrentPEContextValid &&
        _BundleSharedBindings[[0]].valid &&
        _BundleSharedBindings[[0]].destination_assemble.valid &&
        _BundleSharedBindings[[0]].destination_assemble.init;
    var range_payload_elements: integer {0..524288} = 0;
    var actual_pe_source_offset_elements: integer {0..524287} = 0;
    if actual_pe_assembly then
        let assemble = _BundleSharedBindings[[0]].destination_assemble;
        let writer_size = assemble.size_code as integer {1..12};
        let writer_cells = ((TileSizeCodeBytes(writer_size) DIVRM
            PTO_TILE_CELL_BYTES) * 4) as integer {4..8192};
        let element_bits = TileElementBits(data_type)
            as integer {1..64};
        let writer_payload_elements = ((writer_cells * 32 * 8) DIVRM
            element_bits) as integer {1..524288};
        range_payload_elements = if single_issuer then
            TileLogicalElementCapacity(tile.capacity_bytes, tile.data_type)
            else writer_payload_elements;
        // The PE's logical source stripe follows the retained PE_MASK shape.
        // B.ASSEMBLE.offset is a destination range and is applied later by the
        // Shared candidate owner; it does not change which GM elements this PE
        // reads or the local index of that source fragment.
        let elements_per_pe_region = (TileLogicalElementCapacity(
            tile.capacity_bytes, tile.data_type) DIVRM 4)
                as integer {0..131072};
        // A singleton issuer retains PTO-TLOAD-MEMORY-001's whole-parent
        // source range even when it uses B.ASSEMBLE for the destination.
        // Only a multi-PE assembly maps each executing PE to its own logical
        // source stripe; the explicit B.ASSEMBLE offset remains destination
        // range metadata in either case.
        actual_pe_source_offset_elements = if single_issuer then 0 else
            ((_CurrentMemoryAgent as integer {0..3}) *
             elements_per_pe_region) as integer {0..524287};
    end;
    var single_agent: MemoryAgentId = 0;
    if single_issuer then
        for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
            let agent = pe as MemoryAgentId;
            if pe_mask[PTOPEMaskBitOfPEIdentity(agent)] == '1' then
                single_agent = agent;
            end;
        end;
    end;
    // The maximum packed witness uses zero byte stride and a fresh Shared
    // record. Check every participating issuer through the ordinary
    // translated probe before publishing the complete carrier state.
    var packed_zero_fast = PackedTileDataTypeIsFourBit(tile.data_type) &&
        !actual_pe_assembly &&
        !_MemoryEventCaptureEnabled &&
        !SharedTileRecord(shared_tile_id).descriptor_valid &&
        tile.valid_rows == tile.rows &&
        tile.valid_columns == tile.columns &&
        tile.rows * tile.columns ==
            PackedTileLogicalCapacity(tile.capacity_bytes, tile.data_type) &&
        tile.capacity_bytes == 262144;
    if packed_zero_fast then
        for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
            let agent = pe as MemoryAgentId;
            if pe_mask[PTOPEMaskBitOfPEIdentity(agent)] == '1' &&
               (base_addresses[[agent]] != Zeros{PTO_XLEN} ||
                row_stride_bytes[[agent]] != Zeros{PTO_XLEN}) then
                packed_zero_fast = FALSE;
            end;
        end;
    end;
    if packed_zero_fast then
        for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
            let agent = pe as MemoryAgentId;
            if pe_mask[PTOPEMaskBitOfPEIdentity(agent)] == '1' then
                for column = 0 to tile.valid_columns - 1 looplimit 65536 do
                    let address = TileMemoryStridedByteAddress(
                        base_addresses[[agent]], 0,
                        column as integer {0..65535},
                        row_stride_bytes[[agent]], tile.data_type);
                    let probe = ProbeTileMemoryAccess(address,
                        tile.data_type, FALSE);
                    if RaiseDataAccessFault(probe, address) then return; end;
                    if LoadTranslatedUnsigned(probe.translated_address,
                           TileMemoryElementBytes(tile.data_type)) !=
                           Zeros{PTO_XLEN} then
                        packed_zero_fast = FALSE;
                    end;
                end;
            end;
        end;
    end;
    if packed_zero_fast then
        let payload_mask = if single_issuer then '1111' else pe_mask;
        tile = TileWithPackedZeroSelectedMaxRegionDefined(tile, payload_mask);
        let updated = AtomicUpdateSharedTile(shared_tile_id, tile, pe_mask);
        assert updated;
        return;
    end;
    for row = 0 to tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to tile.valid_columns - 1 looplimit 65536 do
            let element = TileLogicalLinearIndex(tile,
                row as integer {0..65535}, column as integer {0..65535});
            let element_index = element as integer {0..524287};
            let region = SharedTileElementRegion(tile, element);
            let actual_pe = _CurrentMemoryAgent as integer {0..3};
            let in_actual_pe_source_range = !actual_pe_assembly ||
                (element_index >= actual_pe_source_offset_elements &&
                 element_index < actual_pe_source_offset_elements +
                     range_payload_elements);
            let selected = if _CurrentPEContextValid then
                (single_issuer ||
                 (region == actual_pe &&
                  pe_mask[PTOPEMaskBitOfPEIdentity(actual_pe)] == '1')) &&
                in_actual_pe_source_range
                else single_issuer ||
                    pe_mask[PTOPEMaskBitOfPEIdentity(region)] == '1';
            if selected then
                let agent = if _CurrentPEContextValid then
                    _CurrentMemoryAgent
                    else if single_issuer then single_agent
                    else region as MemoryAgentId;
                let high_nibble = TileMemoryStridedByteHighNibble(
                    column as integer {0..65535}, tile.data_type);
                let address = TileMemoryStridedByteAddress(
                    base_addresses[[agent]], row as integer {0..65535},
                    column as integer {0..65535},
                    row_stride_bytes[[agent]], tile.data_type);
                let probe = ProbeTileMemoryAccess(address,
                    tile.data_type, FALSE);
                if RaiseDataAccessFault(probe, address) then
                    let updated = AtomicUpdateSharedTile(shared_tile_id,
                        tile, pe_mask);
                    assert updated;
                    return;
                end;
                let translated = probe.translated_address;
                let raw = LoadTranslatedUnsigned(translated,
                    TileMemoryElementBytes(tile.data_type));
                RecordLoadEventForAgent(agent, translated,
                    TileMemoryElementBytes(tile.data_type), raw,
                    CurrentBundleMemoryOrder());
                let destination_element = if actual_pe_assembly then
                    (element_index - actual_pe_source_offset_elements)
                        as PackedTileElementIndex
                    else element;
                tile = TileInfoWithLogicalElement(tile, destination_element,
                    LoadTileMemoryElement(translated, tile.data_type,
                        high_nibble));
                tile.defined_valid_elements =
                    (tile.defined_valid_elements + 1)
                        as integer {0..524288};
            end;
        end;
    end;
    if !actual_pe_assembly && (single_issuer || pe_mask == '1111') then
        tile.defined_valid_elements =
            (tile.valid_rows * tile.valid_columns) as integer {0..524288};
        tile.contents_defined = TRUE;
    end;
    let updated = AtomicUpdateSharedTile(shared_tile_id, tile, pe_mask);
    assert updated;
end;

func TSTOREShared(base_addresses: CorePEWords,
                  row_stride_bytes: CorePEWords,
                  shared_tile_id: SharedTileID,
                  tile: TileInfo,
                  pe_mask: bits(4))
begin
    if pe_mask == Zeros{4} then return; end;
    assert tile.allocated;
    // PE_MASK selects consumer PEs. The first fault stops the request and
    // stores completed before it remain visible.
    var first_pe : integer {0..3} = 0;
    var last_pe : integer {0..3} = 3;
    if _CurrentPEContextValid then
        first_pe = _CurrentMemoryAgent as integer {0..3};
        last_pe = first_pe;
    end;
    for pe = first_pe to last_pe do
        let agent = pe as MemoryAgentId;
        if pe_mask[PTOPEMaskBitOfPEIdentity(agent)] == '1' then
            for row = 0 to tile.valid_rows - 1 looplimit 65536 do
                for column = 0 to tile.valid_columns - 1 looplimit 65536 do
                    let element = TileLogicalLinearIndex(tile,
                        row as integer {0..65535},
                        column as integer {0..65535});
                    let address = TileMemoryStridedByteAddress(
                        base_addresses[[agent]], row as integer {0..65535},
                        column as integer {0..65535},
                        row_stride_bytes[[agent]], tile.data_type);
                    let probe = ProbeTileMemoryAccess(address,
                        tile.data_type, TRUE);
                    if RaiseDataAccessFault(probe, address) then return; end;
                    let translated = probe.translated_address;
                    let stored_value = StoreTileMemoryElement(
                        address, translated, tile.data_type,
                        TileMemoryStridedByteHighNibble(
                            column as integer {0..65535}, tile.data_type),
                        TileReadLogicalElement(tile, element));
                    RecordStoreEventForAgent(agent, translated,
                        TileMemoryElementBytes(tile.data_type), stored_value,
                        CurrentBundleMemoryOrder());
                end;
            end;
        end;
    end;
end;


func TMOVSharedToLocalPerPE(destination: TileIndex,
                           per_pe_tiles: CorePETileInfos,
                           pe_mask: bits(4))
begin
    if pe_mask == Zeros{4} then return; end;
    // A real PE request may materialize all peers' eligible descriptors for
    // preflight, but it writes only its own private Local bank. The contextless
    // aggregate helper retains its established all-selected batch behavior.
    var first_pe : integer {0..3} = 0;
    var last_pe : integer {0..3} = 3;
    if _CurrentPEContextValid then
        first_pe = _CurrentMemoryAgent as integer {0..3};
        last_pe = first_pe;
    end;
    for pe = first_pe to last_pe do
        let agent = pe as MemoryAgentId;
        if pe_mask[PTOPEMaskBitOfPEIdentity(agent)] == '1' then
            let source_tile = per_pe_tiles[[agent]];
            let destination_tile = _Tiles[[destination]];
            assert source_tile.allocated && source_tile.contents_defined;
            assert destination_tile.capacity_bytes == source_tile.capacity_bytes;
            assert destination_tile.rows == source_tile.rows &&
                   destination_tile.columns == source_tile.columns &&
                   destination_tile.valid_rows == source_tile.valid_rows &&
                   destination_tile.valid_columns == source_tile.valid_columns &&
                   destination_tile.data_type == source_tile.data_type &&
                   destination_tile.layout == source_tile.layout;
            for element = 0 to source_tile.rows * source_tile.columns - 1
                looplimit 524288 do
                let value = TileReadLogicalElement(source_tile,
                    element as PackedTileElementIndex);
                _Tiles[[destination]] = TileInfoWithLogicalElement(
                    _Tiles[[destination]],
                    element as PackedTileElementIndex, value);
            end;
        end;
    end;
    _Tiles[[destination]].contents_defined = pe_mask == '1111';
    if pe_mask == '1111' then MarkTileValidRegionDefined(destination); end;
end;

func TSTORESharedPerPE(base_addresses: CorePEWords,
                       row_stride_bytes: CorePEWords,
                       per_pe_tiles: CorePETileInfos,
                       pe_mask: bits(4))
begin
    if pe_mask == Zeros{4} then return; end;
    var first_pe : integer {0..3} = 0;
    var last_pe : integer {0..3} = 3;
    if _CurrentPEContextValid then
        first_pe = _CurrentMemoryAgent as integer {0..3};
        last_pe = first_pe;
    end;
    for pe = first_pe to last_pe do
        let agent = pe as MemoryAgentId;
        if pe_mask[PTOPEMaskBitOfPEIdentity(agent)] == '1' then
            let tile = per_pe_tiles[[agent]];
            assert tile.allocated && tile.contents_defined;
            for row = 0 to tile.valid_rows - 1 looplimit 65536 do
                for column = 0 to tile.valid_columns - 1 looplimit 65536 do
                    let address = TileMemoryStridedByteAddress(
                        base_addresses[[agent]], row as integer {0..65535},
                        column as integer {0..65535},
                        row_stride_bytes[[agent]], tile.data_type);
                    let probe = ProbeTileMemoryAccess(address,
                        tile.data_type, TRUE);
                    if RaiseDataAccessFault(probe, address) then return; end;
                    let translated = probe.translated_address;
                    let stored_value = StoreTileMemoryElement(
                        address, translated, tile.data_type,
                        TileMemoryStridedByteHighNibble(
                            column as integer {0..65535}, tile.data_type),
                        TileReadLogicalElement(tile,
                            TileLogicalLinearIndex(tile,
                                row as integer {0..65535},
                                column as integer {0..65535})));
                    RecordStoreEventForAgent(agent, translated,
                        TileMemoryElementBytes(tile.data_type), stored_value,
                        CurrentBundleMemoryOrder());
                end;
            end;
        end;
    end;
end;

func TMOV(destination: TileIndex, source: TileIndex)
begin
    let source_tile = _Tiles[[source]];
    assert source_tile.allocated;
    assert TileShapesMatch(_Tiles[[destination]], source_tile);
    if _BundleExecutionMask.valid then
        assert TileElementwiseSourceContentsDefined(source);
    end;
    _Tiles[[destination]].payload = source_tile.payload;
    _Tiles[[destination]].defined_elements = source_tile.defined_elements;
    _Tiles[[destination]].packed_defined_elements =
        source_tile.packed_defined_elements;
    _Tiles[[destination]].defined_valid_elements =
        source_tile.defined_valid_elements;
    _Tiles[[destination]].contents_defined = source_tile.contents_defined;
    if _BundleExecutionMask.valid then
        var result = _Tiles[[destination]];
        for row = 0 to result.valid_rows - 1 looplimit 65536 do
            for column = 0 to result.valid_columns - 1 looplimit 65536 do
                if !BundleExecutionMaskActiveAt(
                       result.layout, row as integer {0..65535},
                       column as integer {0..65535}) then
                    let element = TileLogicalLinearIndex(result,
                        row as integer {0..65535},
                        column as integer {0..65535});
                    result = TileInfoWithLogicalElementAndDefined(
                        result, element,
                        BundleExecutionMaskDestinationValue(
                            result.layout, row as integer {0..65535},
                            column as integer {0..65535}, Zeros{PTO_XLEN}),
                        TRUE);
                end;
            end;
        end;
        result = TileWithValidRegionDefined(result);
        _Tiles[[destination]] = result;
    end;
end;

// The direct-operation carrier binds source to the Core4 snapshot already
// resolved from the four PE-private peer_tid values.  The bundle dispatcher
// performs collective readiness and peer-range preflight before this read-old,
// write-new local copy.  No Shared register or global-memory event is involved.
func GMOVFromSourceTile(destination: TileIndex, source_tile: TileInfo)
begin
    let target = TileOutputValueTarget {
        destination = destination,
        value = _Tiles[[destination]]
    };
    _Tiles[[destination]] = GMOVFromSourceTileToValue(target, source_tile);
end;

func GMOV(destination: TileIndex, source: TileIndex, peer_tid: Word)
begin
    assert UInt(peer_tid) < 4;
    GMOVFromSourceTile(destination, _Tiles[[source]]);
end;
