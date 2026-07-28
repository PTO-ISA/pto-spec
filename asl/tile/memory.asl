// PTO-REQ-TMA-001, PTO-REQ-MEMORY-COMPLETION-001,
// PTO-REQ-MEMORY-TSO-001: precise, restartable direct
// TLOAD/TSTORE/MGATHER/MSCATTER and destination-free TPREFETCH.

func TMOV(destination: TileIndex, source: TileIndex)
begin
    let source_tile = _Tiles[[source]];
    assert source_tile.allocated;
    assert TileShapesMatch(_Tiles[[destination]], source_tile);
    _Tiles[[destination]].payload = source_tile.payload;
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
    for row = 0 to tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to tile.valid_columns - 1 looplimit 65536 do
            let element = TileLinearIndex(tile,
                row as integer {0..65535}, column as integer {0..65535});
            let value = LoadTranslatedUnsigned(
                translated_addresses[[element]], element_bytes);
            _Tiles[[destination]].payload[[element]] = NormalizeLoadedValue(
                value, element_bytes, TileDataTypeIsSigned(tile.data_type));
        end;
    end;
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
    for row = 0 to tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to tile.valid_columns - 1 looplimit 65536 do
            let element = TileLinearIndex(tile,
                row as integer {0..65535}, column as integer {0..65535});
            StoreTranslated(original_addresses[[element]],
                translated_addresses[[element]], element_bytes,
                payload[[element]]);
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
    var translated_addresses: TilePayload;
    for row = 0 to destination_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to destination_tile.valid_columns - 1 looplimit 65536 do
            let element = TileLinearIndex(destination_tile,
                row as integer {0..65535}, column as integer {0..65535});
            let address = base_address + MultiplyWord(index_payload[[element]], byte_width);
            let probe = ProbeDataAccess(
                address, element_bytes, element_bytes, FALSE);
            if RaiseDataAccessFault(probe, address) then return; end;
            translated_addresses[[element]] = probe.translated_address;
        end;
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
        end;
    end;
end;

func MSCATTER(base_address: Word, source: TileIndex, indices: TileIndex)
begin
    let source_tile = _Tiles[[source]];
    let index_tile = _Tiles[[indices]];
    assert source_tile.valid_rows == index_tile.valid_rows;
    assert source_tile.valid_columns == index_tile.valid_columns;
    let source_payload = source_tile.payload;
    let index_payload = index_tile.payload;
    let element_bytes = TileElementBytes(source_tile.data_type);
    let byte_width = NaturalToWord(element_bytes as integer {0..262144});
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
        end;
    end;
    for row = 0 to source_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to source_tile.valid_columns - 1 looplimit 65536 do
            let element = TileLinearIndex(source_tile,
                row as integer {0..65535}, column as integer {0..65535});
            StoreTranslated(original_addresses[[element]],
                translated_addresses[[element]], element_bytes,
                source_payload[[element]]);
        end;
    end;
end;

func TPREFETCH(base_address: Word, byte_count: integer {0..262144})
begin
    // Architecturally destination-free. It performs the same translation and
    // legality checks as a load but allocates and writes no tile state.
    if byte_count > 0 then
        let access_size = byte_count as integer {1..262144};
        let probe = ProbeDataAccess(base_address, access_size, 1, FALSE);
        - = RaiseDataAccessFault(probe, base_address);
    end;
end;
