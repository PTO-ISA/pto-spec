// PTO-REQ-TMA-001, PTO-REQ-MEMORY-COMPLETION-001,
// PTO-REQ-MEMORY-TSO-001: precise, restartable direct
// TLOAD/TSTORE/MGATHER/MSCATTER and destination-free TPREFETCH.

type ScatterLaneOrder of array [[PTO_MODEL_TILE_ELEMENTS]]
    of Word;

func TMOV(destination: TileIndex, source: TileIndex)
begin
    let source_tile = _Tiles[[source]];
    assert source_tile.allocated;
    assert TileShapesMatch(_Tiles[[destination]], source_tile);
    _Tiles[[destination]].payload = source_tile.payload;
    _Tiles[[destination]].contents_defined = source_tile.contents_defined;
end;

func TPUSH(destination: TileIndex, source: TileIndex)
begin
    let source_tile = _Tiles[[source]];
    assert source_tile.allocated;
    _Tiles[[destination]] = source_tile;
end;

func TPOP(destination: TileIndex, source: TileIndex)
begin
    let source_tile = _Tiles[[source]];
    assert source_tile.allocated;
    _Tiles[[destination]] = source_tile;
end;

func TALLOC(destination: TileIndex, capacity_bytes: integer {0..262144},
            rows: integer {1..65535}, columns: integer {1..65535},
            valid_rows: integer {0..65535}, valid_columns: integer {0..65535},
            data_type_code: Word, implementation_defined_layout: boolean)
begin
    assert TileDataTypeEncodingValid(data_type_code);
    if TileCapacityInUseExcept(destination) + capacity_bytes >
       TileCapacityLimitBytes() then
        SetFault(Fault_TileAllocation, ReadTPC());
        return;
    end;
    let layout = if implementation_defined_layout then
        TileLayout_ImplementationDefined else TileLayout_RowMajor;
    ConfigureTile(destination, capacity_bytes as integer {0..262144},
        rows as integer {0..65535}, columns as integer {0..65535},
        valid_rows, valid_columns, TileDataTypeFromEncoding(data_type_code),
        layout, TileLocation_Any);
end;

func TFREE(destination: TileIndex)
begin
    ConfigureTile(destination, 0, 0, 0, 0, 0, TileDataType_U8,
        TileLayout_RowMajor, TileLocation_Any);
end;

func TLOAD(destination: TileIndex, base_address: Word)
begin
    let tile = _Tiles[[destination]];
    assert tile.allocated;
    let element_bytes = TileElementBytes(tile.data_type);
    var translated_addresses: TilePayload;
    // Instruction-wide preflight makes tile memory faults precise and
    // restartable: no payload element changes until every access succeeds.
    for row = 0 to tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to tile.valid_columns - 1 looplimit 65536 do
            let element = TileLinearIndex(tile,
                row as integer {0..65535}, column as integer {0..65535});
            let offset = (element * element_bytes) as integer {0..262144};
            let address = base_address + NaturalToWord(offset);
            let probe = ProbeDataAccess(
                address, element_bytes, element_bytes, FALSE);
            if RaiseDataAccessFault(probe, address) then return; end;
            translated_addresses[[element]] = probe.translated_address;
        end;
    end;
    let event_count = (tile.valid_rows * tile.valid_columns) as
        integer {0..PTO_MODEL_TILE_ELEMENTS};
    if !MemoryEventCapacityAvailable(event_count) then
        SetFault(Fault_TileLegality, ReadTPC());
        return;
    end;
    for row = 0 to tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to tile.valid_columns - 1 looplimit 65536 do
            let element = TileLinearIndex(tile,
                row as integer {0..65535}, column as integer {0..65535});
            let value = LoadTranslatedUnsigned(
                translated_addresses[[element]], element_bytes);
            _Tiles[[destination]].payload[[element]] = NormalizeLoadedValue(
                value, element_bytes, TileDataTypeIsSigned(tile.data_type));
            let offset = (element * element_bytes) as integer {0..262144};
            RecordCompletedLoadEvent(base_address + NaturalToWord(offset),
                element_bytes, value, CurrentBlockMemoryOrder());
        end;
    end;
    _Tiles[[destination]].contents_defined = TRUE;
end;

func TSTORE(base_address: Word, source: TileIndex)
begin
    let tile = _Tiles[[source]];
    assert tile.allocated;
    let element_bytes = TileElementBytes(tile.data_type);
    let payload = tile.payload;
    var original_addresses: TilePayload;
    var translated_addresses: TilePayload;
    for row = 0 to tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to tile.valid_columns - 1 looplimit 65536 do
            let element = TileLinearIndex(tile,
                row as integer {0..65535}, column as integer {0..65535});
            let offset = (element * element_bytes) as integer {0..262144};
            let address = base_address + NaturalToWord(offset);
            let probe = ProbeDataAccess(
                address, element_bytes, element_bytes, TRUE);
            if RaiseDataAccessFault(probe, address) then return; end;
            original_addresses[[element]] = address;
            translated_addresses[[element]] = probe.translated_address;
        end;
    end;
    let event_count = (tile.valid_rows * tile.valid_columns) as
        integer {0..PTO_MODEL_TILE_ELEMENTS};
    if !MemoryEventCapacityAvailable(event_count) then
        SetFault(Fault_TileLegality, ReadTPC());
        return;
    end;
    for row = 0 to tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to tile.valid_columns - 1 looplimit 65536 do
            let element = TileLinearIndex(tile,
                row as integer {0..65535}, column as integer {0..65535});
            StoreTranslated(original_addresses[[element]],
                translated_addresses[[element]], element_bytes,
                payload[[element]]);
            RecordCompletedStoreEvent(original_addresses[[element]],
                element_bytes, payload[[element]], CurrentBlockMemoryOrder());
        end;
    end;
end;

func MGATHER(destination: TileIndex, base_address: Word, indices: TileIndex)
begin
    let destination_tile = _Tiles[[destination]];
    let index_tile = _Tiles[[indices]];
    assert destination_tile.valid_rows == index_tile.valid_rows;
    assert destination_tile.valid_columns == index_tile.valid_columns;
    let index_payload = index_tile.payload;
    let element_bytes = TileElementBytes(destination_tile.data_type);
    let byte_width = NaturalToWord(element_bytes as integer {0..262144});
    var original_addresses: TilePayload;
    var translated_addresses: TilePayload;
    for row = 0 to destination_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to destination_tile.valid_columns - 1 looplimit 65536 do
            let element = TileLinearIndex(destination_tile,
                row as integer {0..65535}, column as integer {0..65535});
            let address = base_address + MultiplyWord(index_payload[[element]], byte_width);
            let probe = ProbeDataAccess(
                address, element_bytes, element_bytes, FALSE);
            if RaiseDataAccessFault(probe, address) then return; end;
            original_addresses[[element]] = address;
            translated_addresses[[element]] = probe.translated_address;
        end;
    end;
    let event_count = (destination_tile.valid_rows *
        destination_tile.valid_columns) as
        integer {0..PTO_MODEL_TILE_ELEMENTS};
    if !MemoryEventCapacityAvailable(event_count) then
        SetFault(Fault_TileLegality, ReadTPC());
        return;
    end;
    for row = 0 to destination_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to destination_tile.valid_columns - 1 looplimit 65536 do
            let element = TileLinearIndex(destination_tile,
                row as integer {0..65535}, column as integer {0..65535});
            let value = LoadTranslatedUnsigned(
                translated_addresses[[element]], element_bytes);
            _Tiles[[destination]].payload[[element]] = NormalizeLoadedValue(
                value, element_bytes,
                TileDataTypeIsSigned(destination_tile.data_type));
            RecordCompletedLoadEvent(original_addresses[[element]],
                element_bytes, value, CurrentBlockMemoryOrder());
        end;
    end;
    _Tiles[[destination]].contents_defined = TRUE;
end;

func CommitScatterLanes(source: TileIndex, lane_order: ScatterLaneOrder,
                        lane_count: integer {0..PTO_MODEL_TILE_ELEMENTS},
                        original_addresses: TilePayload,
                        translated_addresses: TilePayload,
                        element_bytes: integer {1,2,4,8})
begin
    // Every active lane commits exactly once, but portable semantics impose no
    // lane priority.  An arbitrary permutation therefore leaves the winner at
    // a duplicate address unspecified while retaining every lane's memory
    // event.  Preflight has completed for the full lane set before entry.
    var commit_order = lane_order;
    if !MemoryEventCapacityAvailable(lane_count) then
        SetFault(Fault_TileLegality, ReadTPC());
        return;
    end;
    if lane_count > 0 then
        for position = 0 to lane_count - 1
            looplimit PTO_MODEL_TILE_ELEMENTS do
            var selected_position:
                integer {0..PTO_MODEL_TILE_ELEMENTS-1} =
                    position as integer {0..PTO_MODEL_TILE_ELEMENTS-1};
            if !CurrentBlockAtomic() then
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
            StoreTranslated(original_addresses[[element]],
                translated_addresses[[element]], element_bytes,
                _Tiles[[source]].payload[[element]]);
            RecordCompletedStoreEvent(original_addresses[[element]],
                element_bytes, _Tiles[[source]].payload[[element]],
                CurrentBlockMemoryOrder());
        end;
    end;
end;

func MSCATTER(base_address: Word, source: TileIndex, indices: TileIndex)
begin
    let source_tile = _Tiles[[source]];
    let index_tile = _Tiles[[indices]];
    assert source_tile.valid_rows == index_tile.valid_rows;
    assert source_tile.valid_columns == index_tile.valid_columns;
    let index_payload = index_tile.payload;
    let element_bytes = TileElementBytes(source_tile.data_type);
    let byte_width = NaturalToWord(element_bytes as integer {0..262144});
    var lane_order: ScatterLaneOrder;
    var lane_count: integer {0..PTO_MODEL_TILE_ELEMENTS} = 0;
    var original_addresses: TilePayload;
    var translated_addresses: TilePayload;
    for row = 0 to source_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to source_tile.valid_columns - 1 looplimit 65536 do
            let element = TileLinearIndex(source_tile,
                row as integer {0..65535}, column as integer {0..65535});
            let address = base_address + MultiplyWord(index_payload[[element]], byte_width);
            let probe = ProbeDataAccess(
                address, element_bytes, element_bytes, TRUE);
            if RaiseDataAccessFault(probe, address) then return; end;
            original_addresses[[element]] = address;
            translated_addresses[[element]] = probe.translated_address;
            lane_order[[lane_count]] = NaturalToWord(
                element as integer {0..262144});
            lane_count = (lane_count + 1) as
                integer {0..PTO_MODEL_TILE_ELEMENTS};
        end;
    end;
    CommitScatterLanes(source, lane_order, lane_count, original_addresses,
        translated_addresses, element_bytes);
end;

func MGATHER_MASK(destination: TileIndex, base_address: Word, indices: TileIndex,
                  mask: TileIndex, pad_value: TilePadValue)
begin
    let destination_tile = _Tiles[[destination]];
    let index_tile = _Tiles[[indices]];
    assert destination_tile.valid_rows == index_tile.valid_rows;
    assert destination_tile.valid_columns == index_tile.valid_columns;
    let element_bytes = TileElementBytes(destination_tile.data_type);
    let byte_width = NaturalToWord(element_bytes as integer {0..262144});
    // Snapshot active lanes during preflight.  This both prevents an aliasing
    // destination from changing the mask during commit and makes the masked
    // lane rule explicit: an inactive lane never reads its index element and
    // never performs address formation, translation, or permission checks.
    var active_lanes: TilePayload;
    var active_count: integer {0..PTO_MODEL_TILE_ELEMENTS} = 0;
    var original_addresses: TilePayload;
    var translated_addresses: TilePayload;
    for row = 0 to destination_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to destination_tile.valid_columns - 1 looplimit 65536 do
            let element = TileLinearIndex(destination_tile,
                row as integer {0..65535}, column as integer {0..65535});
            let active = !IsZero(_Tiles[[mask]].payload[[element]]);
            active_lanes[[element]] = if active then Ones{PTO_XLEN}
                                      else Zeros{PTO_XLEN};
            if active then
                active_count = (active_count + 1) as
                    integer {0..PTO_MODEL_TILE_ELEMENTS};
                let address = base_address + MultiplyWord(
                    _Tiles[[indices]].payload[[element]], byte_width);
                let probe = ProbeDataAccess(
                    address, element_bytes, element_bytes, FALSE);
                if RaiseDataAccessFault(probe, address) then return; end;
                original_addresses[[element]] = address;
                translated_addresses[[element]] = probe.translated_address;
            end;
        end;
    end;
    if !MemoryEventCapacityAvailable(active_count) then
        SetFault(Fault_TileLegality, ReadTPC());
        return;
    end;
    for row = 0 to destination_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to destination_tile.valid_columns - 1 looplimit 65536 do
            let element = TileLinearIndex(destination_tile,
                row as integer {0..65535}, column as integer {0..65535});
            if !IsZero(active_lanes[[element]]) then
                let value = LoadTranslatedUnsigned(
                    translated_addresses[[element]], element_bytes);
                _Tiles[[destination]].payload[[element]] = NormalizeLoadedValue(
                    value, element_bytes,
                    TileDataTypeIsSigned(destination_tile.data_type));
                RecordCompletedLoadEvent(original_addresses[[element]],
                    element_bytes, value, CurrentBlockMemoryOrder());
            else
                // Inactive lanes are committed from B.DATR PadValue without
                // observing the corresponding index or memory location.
                _Tiles[[destination]].payload[[element]] =
                    TilePadValueForDataType(
                        pad_value, destination_tile.data_type);
            end;
        end;
    end;
    _Tiles[[destination]].contents_defined = TRUE;
end;

func MSCATTER_MASK(base_address: Word, source: TileIndex, indices: TileIndex,
                   mask: TileIndex)
begin
    let source_tile = _Tiles[[source]];
    let index_tile = _Tiles[[indices]];
    assert source_tile.valid_rows == index_tile.valid_rows;
    assert source_tile.valid_columns == index_tile.valid_columns;
    let element_bytes = TileElementBytes(source_tile.data_type);
    let byte_width = NaturalToWord(element_bytes as integer {0..262144});
    // Inactive lanes read neither index nor source payload and produce no
    // memory access.  Snapshotting the predicate also keeps the preflight and
    // commit lane sets identical when operand tiles alias.
    var lane_order: ScatterLaneOrder;
    var lane_count: integer {0..PTO_MODEL_TILE_ELEMENTS} = 0;
    var original_addresses: TilePayload;
    var translated_addresses: TilePayload;
    for row = 0 to source_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to source_tile.valid_columns - 1 looplimit 65536 do
            let element = TileLinearIndex(source_tile,
                row as integer {0..65535}, column as integer {0..65535});
            let active = !IsZero(_Tiles[[mask]].payload[[element]]);
            if active then
                let address = base_address + MultiplyWord(
                    _Tiles[[indices]].payload[[element]], byte_width);
                let probe = ProbeDataAccess(
                    address, element_bytes, element_bytes, TRUE);
                if RaiseDataAccessFault(probe, address) then return; end;
                original_addresses[[element]] = address;
                translated_addresses[[element]] = probe.translated_address;
                lane_order[[lane_count]] = NaturalToWord(
                    element as integer {0..262144});
                lane_count = (lane_count + 1) as
                    integer {0..PTO_MODEL_TILE_ELEMENTS};
            end;
        end;
    end;
    CommitScatterLanes(source, lane_order, lane_count, original_addresses,
        translated_addresses, element_bytes);
end;

func MGATHER_CAS(destination: TileIndex, base_address: Word, indices: TileIndex,
                 expected: TileIndex, replacement: TileIndex)
begin
    let destination_tile = _Tiles[[destination]];
    let index_tile = _Tiles[[indices]];
    let expected_payload = _Tiles[[expected]].payload;
    let replacement_payload = _Tiles[[replacement]].payload;
    assert destination_tile.valid_rows == index_tile.valid_rows;
    assert destination_tile.valid_columns == index_tile.valid_columns;
    let index_payload = index_tile.payload;
    let element_bytes = TileElementBytes(destination_tile.data_type);
    let byte_width = NaturalToWord(element_bytes as integer {0..262144});
    var original_addresses: TilePayload;
    var translated_addresses: TilePayload;
    for row = 0 to destination_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to destination_tile.valid_columns - 1 looplimit 65536 do
            let element = TileLinearIndex(destination_tile,
                row as integer {0..65535}, column as integer {0..65535});
            let address = base_address + MultiplyWord(index_payload[[element]], byte_width);
            let read_probe = ProbeDataAccess(
                address, element_bytes, element_bytes, FALSE);
            if RaiseDataAccessFault(read_probe, address) then return; end;
            let write_probe = ProbeDataAccess(
                address, element_bytes, element_bytes, TRUE);
            if RaiseDataAccessFault(write_probe, address) then return; end;
            original_addresses[[element]] = address;
            translated_addresses[[element]] = read_probe.translated_address;
        end;
    end;
    let event_count = (destination_tile.valid_rows *
        destination_tile.valid_columns) as
        integer {0..PTO_MODEL_TILE_ELEMENTS};
    if !MemoryEventCapacityAvailable(event_count) then
        SetFault(Fault_TileLegality, ReadTPC());
        return;
    end;
    for row = 0 to destination_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to destination_tile.valid_columns - 1 looplimit 65536 do
            let element = TileLinearIndex(destination_tile,
                row as integer {0..65535}, column as integer {0..65535});
            let old_value = NormalizeLoadedValue(
                LoadTranslatedUnsigned(translated_addresses[[element]], element_bytes),
                element_bytes, TileDataTypeIsSigned(destination_tile.data_type));
            _Tiles[[destination]].payload[[element]] = old_value;
            var committed_value = old_value;
            if old_value == expected_payload[[element]] then
                committed_value = NormalizeAtomicUnsigned(
                    replacement_payload[[element]], element_bytes);
                StoreTranslated(original_addresses[[element]],
                    translated_addresses[[element]], element_bytes,
                    committed_value);
            end;
            RecordCompletedAtomicEvent(original_addresses[[element]],
                element_bytes, old_value, committed_value,
                CurrentBlockMemoryOrder());
        end;
    end;
    _Tiles[[destination]].contents_defined = TRUE;
end;

func TPREFETCH(base_address: Word, byte_count: integer {0..262144})
begin
    // Architecturally destination-free. It performs the same translation and
    // permission checks as a load but allocates and writes no tile state.
    // Probe in original-address order so a range crossing a translation or
    // protection boundary reports the first failing architectural byte rather
    // than the range base.  Since TPREFETCH has no commit effects, returning on
    // that first fault is also fully restartable.
    for byte_index = 0 to byte_count - 1 looplimit 262144 do
        let address = base_address +
            NaturalToWord(byte_index as integer {0..262144});
        let probe = ProbeDataAccess(address, 1, 1, FALSE);
        if RaiseDataAccessFault(probe, address) then return; end;
    end;
end;
