// PTO-REQ-TMA-001, PTO-REQ-MEMORY-COMPLETION-001,
// PTO-REQ-MEMORY-TSO-001: precise, restartable direct
// TLOAD/TSTORE/MGATHER/MSCATTER and destination-free TPREFETCH.

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

func TPUSH(destination: TileIndex, source: TileIndex)
begin
    let source_tile = _Tiles[[source]];
    assert destination != source;
    assert !_Tiles[[destination]].allocated;
    assert source_tile.allocated && source_tile.contents_defined;
    assert TileCapacityInUseExcept(destination) + source_tile.capacity_bytes <=
        TileCapacityLimitBytes();
    _Tiles[[destination]] = source_tile;
end;

func TPOP(destination: TileIndex, source: TileIndex)
begin
    let source_tile = _Tiles[[source]];
    assert destination != source;
    assert TileShapesMatch(_Tiles[[destination]], source_tile);
    assert _Tiles[[destination]].layout == source_tile.layout;
    assert source_tile.allocated && source_tile.contents_defined;
    _Tiles[[destination]].payload = source_tile.payload;
    _Tiles[[destination]].defined_elements = source_tile.defined_elements;
    _Tiles[[destination]].defined_valid_elements =
        source_tile.defined_valid_elements;
    _Tiles[[destination]].contents_defined = source_tile.contents_defined;
    ReleaseTile(source);
end;

func TALLOC(destination: TileIndex, capacity_bytes: integer {0..262144},
            rows: integer {1..65535}, columns: integer {1..65535},
            valid_rows: integer {0..65535}, valid_columns: integer {0..65535},
            data_type_code: Word, implementation_defined_layout: boolean)
begin
    assert TileDataTypeEncodingValid(data_type_code);
    let layout = if implementation_defined_layout then
        TileLayout_ImplementationDefined else TileLayout_RowMajor;
    ConfigureTile(destination, capacity_bytes as integer {0..524288},
        rows as integer {0..65535}, columns as integer {0..65535},
        valid_rows, valid_columns, TileDataTypeFromEncoding(data_type_code),
        layout, TileLocation_Any);
end;

func TFREE(destination: TileIndex)
begin
    ReleaseTile(destination);
end;

pure func TileMemoryElementBytes(data_type: TileDataType) => integer {1,2,4,8}
begin
    // PTO-v0 TMA exposes four-bit elements through byte-sized containing
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
                MemoryOrder_Relaxed);
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
                MemoryOrder_Relaxed);
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
                MemoryOrder_Relaxed);
            _Tiles[[destination]].payload[[element]] =
                LoadTileMemoryElement(translated_addresses[[element]],
                    destination_tile.data_type, high_nibbles[element] == '1');
        end;
    end;
    MarkTileValidRegionDefined(destination);
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
        end;
    end;
    for row = 0 to source_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to source_tile.valid_columns - 1 looplimit 65536 do
            let element = TileLinearIndex(source_tile,
                row as integer {0..65535}, column as integer {0..65535});
            let stored_value = StoreTileMemoryElement(
                original_addresses[[element]], translated_addresses[[element]],
                source_tile.data_type, high_nibbles[element] == '1',
                source_payload[[element]]);
            RecordStoreEvent(translated_addresses[[element]],
                TileMemoryElementBytes(source_tile.data_type), stored_value,
                MemoryOrder_Relaxed);
        end;
    end;
end;

func MGATHER_MASK(destination: TileIndex, base_address: Word, indices: TileIndex,
                  mask: TileIndex)
begin
    let destination_tile = _Tiles[[destination]];
    let index_tile = _Tiles[[indices]];
    let mask_payload = _Tiles[[mask]].payload;
    assert destination_tile.allocated && destination_tile.contents_defined;
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
                    MemoryOrder_Relaxed);
                _Tiles[[destination]].payload[[element]] =
                    LoadTileMemoryElement(translated_addresses[[element]],
                        destination_tile.data_type,
                        high_nibbles[element] == '1');
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
            end;
        end;
    end;
    for row = 0 to source_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to source_tile.valid_columns - 1 looplimit 65536 do
            let element = TileLinearIndex(source_tile,
                row as integer {0..65535}, column as integer {0..65535});
            if !IsZero(mask_payload[[element]]) then
                let stored_value = StoreTileMemoryElement(
                    original_addresses[[element]],
                    translated_addresses[[element]], source_tile.data_type,
                    high_nibbles[element] == '1', source_payload[[element]]);
                RecordStoreEvent(translated_addresses[[element]],
                    TileMemoryElementBytes(source_tile.data_type),
                    stored_value, MemoryOrder_Relaxed);
            end;
        end;
    end;
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
                write_value, MemoryOrder_Relaxed, succeeds);
        end;
    end;
    MarkTileValidRegionDefined(destination);
end;

func TPREFETCH(base_address: Word, byte_count: integer {0..262144})
begin
    // Unlike scalar prefetch, tile prefetch is a faulting, restartable
    // footprint read. Preflight the complete footprint before recording any
    // byte access so a fault contributes no partial event prefix.
    if byte_count > 0 then
        let access_size = byte_count as integer {1..262144};
        let probe = ProbeDataAccess(base_address, access_size, 1, FALSE);
        if RaiseDataAccessFault(probe, base_address) then return; end;
        for byte_index = 0 to byte_count - 1 looplimit 262145 do
            let translated_address = probe.translated_address +
                NaturalToWord(byte_index as integer {0..262144});
            let value = LoadTranslatedUnsigned(translated_address, 1);
            RecordLoadEvent(translated_address, 1, value,
                MemoryOrder_Relaxed);
        end;
    end;
end;
