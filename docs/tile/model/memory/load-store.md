<!-- GENERATED FROM: asl/tile/model/memory/load-store.asl -->
# Load Store

**Normative ASL source:** `asl/tile/model/memory/load-store.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-MEMORY-LOAD-STORE}

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/memory/load-store.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-MEMORY-LOAD-STORE","surface":"tile","classification":["model","memory","load-store"],"depends_on":["PTO-TILE-MODEL-MEMORY-STRIDE","PTO-ARCH-MEMORY-MODEL-FAULT-PRECISION"]}
pure func DecodeTileMemoryElementRaw(raw: Word,
                                     data_type: TileDataType,
                                     high_nibble: boolean) => Word
begin
    let element_bytes = TileMemoryElementBytes(data_type);
    if TileDataTypeIsFourBit(data_type) then
        if high_nibble then
            return ZeroExtend{PTO_XLEN}(raw[7:4]);
        else
            return ZeroExtend{PTO_XLEN}(raw[3:0]);
        end;
    else
        return NormalizeLoadedValue(raw, element_bytes,
            TileDataTypeIsSigned(data_type));
    end;
end;

readonly func LoadTileMemoryElement(translated_address: Word,
                                    data_type: TileDataType,
                                    high_nibble: boolean) => Word
begin
    let element_bytes = TileMemoryElementBytes(data_type);
    let raw = LoadTranslatedUnsigned(translated_address, element_bytes);
    return DecodeTileMemoryElementRaw(raw, data_type, high_nibble);
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

func TLOAD(destination: TileIndex, base_address: Word,
           row_stride_elements: Word)
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
            let memory_index = TileMemoryStridedIndex(
                row as integer {0..65535}, column as integer {0..65535},
                row_stride_elements);
            let address = TileMemoryIndexedAddress(base_address, memory_index,
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
            let memory_index = TileMemoryStridedIndex(
                row as integer {0..65535}, column as integer {0..65535},
                row_stride_elements);
            let high_nibble = TileMemoryIndexedHighNibble(memory_index,
                tile.data_type);
            let raw = LoadTranslatedUnsigned(translated_addresses[[element]],
                TileMemoryElementBytes(tile.data_type));
            RecordLoadEvent(translated_addresses[[element]],
                TileMemoryElementBytes(tile.data_type), raw,
                CurrentBundleMemoryOrder());
            _Tiles[[destination]].payload[[element]] =
                DecodeTileMemoryElementRaw(
                    raw, tile.data_type, high_nibble);
        end;
    end;
    MarkTileValidRegionDefined(destination);
end;

func TSTORE(base_address: Word, row_stride_elements: Word, source: TileIndex)
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
            let memory_index = TileMemoryStridedIndex(
                row as integer {0..65535}, column as integer {0..65535},
                row_stride_elements);
            let address = TileMemoryIndexedAddress(base_address, memory_index,
                tile.data_type);
            let probe = ProbeTileMemoryAccess(address, tile.data_type, TRUE);
            if RaiseDataAccessFault(probe, address) then return; end;
            original_addresses[[element]] = address;
            translated_addresses[[element]] = probe.translated_address;
            high_nibbles[element] = if TileMemoryIndexedHighNibble(
                memory_index, tile.data_type) then '1' else '0';
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
```
<!-- GENERATED-ASL-END: unit -->

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
