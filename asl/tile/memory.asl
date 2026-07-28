// PTO-REQ-TMA-001: direct TLOAD/TSTORE/TMOV and destination-free TPREFETCH.

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
    for row = 0 to tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to tile.valid_columns - 1 looplimit 65536 do
            let element = TileLinearIndex(tile,
                row as integer {0..65535}, column as integer {0..65535});
            let offset = (element * element_bytes) as integer {0..262144};
            let address = base_address + NaturalToWord(offset);
            if TileDataTypeIsSigned(tile.data_type) then
                _Tiles[[destination]].payload[[element]] = LoadSigned(address, element_bytes);
            else
                _Tiles[[destination]].payload[[element]] = LoadUnsigned(address, element_bytes);
            end;
        end;
    end;
end;

func TSTORE(base_address: Word, source: TileIndex)
begin
    let tile = _Tiles[[source]];
    assert tile.allocated;
    let element_bytes = TileElementBytes(tile.data_type);
    let payload = tile.payload;
    for row = 0 to tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to tile.valid_columns - 1 looplimit 65536 do
            let element = TileLinearIndex(tile,
                row as integer {0..65535}, column as integer {0..65535});
            let offset = (element * element_bytes) as integer {0..262144};
            let address = base_address + NaturalToWord(offset);
            Store(address, element_bytes, payload[[element]]);
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
    for row = 0 to destination_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to destination_tile.valid_columns - 1 looplimit 65536 do
            let element = TileLinearIndex(destination_tile,
                row as integer {0..65535}, column as integer {0..65535});
            let address = base_address + MultiplyWord(index_payload[[element]], byte_width);
            if TileDataTypeIsSigned(destination_tile.data_type) then
                _Tiles[[destination]].payload[[element]] = LoadSigned(address, element_bytes);
            else
                _Tiles[[destination]].payload[[element]] = LoadUnsigned(address, element_bytes);
            end;
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
    for row = 0 to source_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to source_tile.valid_columns - 1 looplimit 65536 do
            let element = TileLinearIndex(source_tile,
                row as integer {0..65535}, column as integer {0..65535});
            let address = base_address + MultiplyWord(index_payload[[element]], byte_width);
            Store(address, element_bytes, source_payload[[element]]);
        end;
    end;
end;

func TPREFETCH(base_address: Word, byte_count: integer {0..262144})
begin
    // Architecturally destination-free. It performs the same translation and
    // legality checks as a load but allocates and writes no tile state.
    if byte_count > 0 then
        let access_size = byte_count as integer {1..262144};
        let translated_address = TranslateDataAddress(
            base_address, access_size, FALSE);
        if !DataAccessPermitted(translated_address, access_size, FALSE) ||
           UInt(translated_address) + byte_count > PTO_MODEL_MEMORY_BYTES then
            SetFault(Fault_DataPage, base_address);
        end;
    end;
end;
