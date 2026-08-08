// PTO-UNIT: {"id":"PTO-TILE-MODEL-MEMORY-GATHER-SCATTER","surface":"tile","classification":["model","memory","gather-scatter"],"depends_on":["PTO-TILE-MODEL-MEMORY-LOAD-STORE"]}
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

