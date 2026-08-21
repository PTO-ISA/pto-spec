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
           row_stride_bytes: Word)
begin
    let tile = _Tiles[[destination]];
    assert tile.allocated;
    if TileLayoutIsCube(tile.layout) then
        assert TileCubeDescriptorLegal(tile);
    end;
    // Complete packed carriers make the maximum U4 shape representable, but
    // an interpreter-sized translated-address array is still only a carrier
    // cache.  The fast case is limited to ordinary reset-backed zero-stride
    // packed loads and retains the normal translated probe/fault path.
    var packed_zero_fast = PackedTileDataTypeIsFourBit(tile.data_type) &&
        !TileLayoutIsCube(tile.layout) &&
        !_MemoryEventCaptureEnabled &&
        tile.defined_valid_elements == 0 &&
        row_stride_bytes == Zeros{PTO_XLEN} &&
        tile.valid_rows == tile.rows &&
        tile.valid_columns == tile.columns &&
        tile.rows * tile.columns ==
            PackedTileLogicalCapacity(tile.capacity_bytes, tile.data_type);
    if packed_zero_fast then
        for column = 0 to tile.valid_columns - 1 looplimit 65536 do
            let address = TileMemoryStridedByteAddress(base_address,
                0, column as integer {0..65535}, row_stride_bytes,
                tile.data_type);
            let probe = ProbeTileMemoryAccess(address, tile.data_type, FALSE);
            if RaiseDataAccessFault(probe, address) then return; end;
            if LoadTranslatedUnsigned(probe.translated_address,
                   TileMemoryElementBytes(tile.data_type)) !=
                   Zeros{PTO_XLEN} then
                packed_zero_fast = FALSE;
            end;
        end;
    end;
    if packed_zero_fast then
        _Tiles[[destination]] = TileWithPackedZeroValidRegionDefined(tile);
        return;
    end;
    var result = tile;
    // Instruction-wide preflight makes tile memory faults precise and
    // restartable: no payload element changes until every access succeeds.
    for row = 0 to tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to tile.valid_columns - 1 looplimit 65536 do
            let element = TileLogicalLinearIndex(tile,
                row as integer {0..65535}, column as integer {0..65535});
            let address = TileMemoryStridedByteAddress(base_address,
                row as integer {0..65535}, column as integer {0..65535},
                row_stride_bytes, tile.data_type);
            let probe = ProbeTileMemoryAccess(address, tile.data_type, FALSE);
            if RaiseDataAccessFault(probe, address) then return; end;
        end;
    end;
    for row = 0 to tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to tile.valid_columns - 1 looplimit 65536 do
            let element = TileLogicalLinearIndex(tile,
                row as integer {0..65535}, column as integer {0..65535});
            let address = TileMemoryStridedByteAddress(base_address,
                row as integer {0..65535}, column as integer {0..65535},
                row_stride_bytes, tile.data_type);
            let translated = ProbeTileMemoryAccess(address, tile.data_type,
                FALSE).translated_address;
            let high_nibble = TileMemoryStridedByteHighNibble(
                column as integer {0..65535}, tile.data_type);
            let raw = LoadTranslatedUnsigned(translated,
                TileMemoryElementBytes(tile.data_type));
            RecordLoadEvent(translated,
                TileMemoryElementBytes(tile.data_type), raw,
                CurrentBundleMemoryOrder());
            result = TileInfoWithLogicalElement(result, element,
                DecodeTileMemoryElementRaw(raw, tile.data_type, high_nibble));
        end;
    end;
    result = TileWithValidRegionDefined(result);
    if TileLayoutIsCube(result.layout) then
        result = TileWithPadding(result, CurrentBundlePadValue());
    end;
    _Tiles[[destination]] = result;
end;

func TSTORE(base_address: Word, row_stride_bytes: Word, source: TileIndex)
begin
    let tile = _Tiles[[source]];
    assert tile.allocated && tile.contents_defined;
    if TileLayoutIsCube(tile.layout) then
        assert TileCubeDescriptorLegal(tile);
    end;
    for row = 0 to tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to tile.valid_columns - 1 looplimit 65536 do
            let element = TileLogicalLinearIndex(tile,
                row as integer {0..65535}, column as integer {0..65535});
            let address = TileMemoryStridedByteAddress(base_address,
                row as integer {0..65535}, column as integer {0..65535},
                row_stride_bytes, tile.data_type);
            let probe = ProbeTileMemoryAccess(address, tile.data_type, TRUE);
            if RaiseDataAccessFault(probe, address) then return; end;
        end;
    end;
    for row = 0 to tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to tile.valid_columns - 1 looplimit 65536 do
            let element = TileLogicalLinearIndex(tile,
                row as integer {0..65535}, column as integer {0..65535});
            let address = TileMemoryStridedByteAddress(base_address,
                row as integer {0..65535}, column as integer {0..65535},
                row_stride_bytes, tile.data_type);
            let translated = ProbeTileMemoryAccess(address, tile.data_type,
                TRUE).translated_address;
            let stored_value = StoreTileMemoryElement(
                address, translated, tile.data_type,
                TileMemoryStridedByteHighNibble(
                    column as integer {0..65535}, tile.data_type),
                TileReadLogicalElement(tile, element));
            RecordStoreEvent(translated,
                TileMemoryElementBytes(tile.data_type), stored_value,
                CurrentBundleMemoryOrder());
        end;
    end;
end;
```
<!-- GENERATED-ASL-END: unit -->

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
