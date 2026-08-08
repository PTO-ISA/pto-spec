// PTO-UNIT: {"id":"PTO-TILE-MODEL-MEMORY-ATOMICS","surface":"tile","classification":["model","memory","atomics"],"depends_on":["PTO-TILE-MODEL-MEMORY-GATHER-SCATTER","PTO-ARCH-MEMORY-MODEL-ATOMICITY"]}
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
