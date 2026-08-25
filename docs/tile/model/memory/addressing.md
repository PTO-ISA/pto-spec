<!-- GENERATED FROM: asl/tile/model/memory/addressing.asl -->
# Addressing

**Normative ASL source:** `asl/tile/model/memory/addressing.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-MEMORY-ADDRESSING}

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/memory/addressing.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-MEMORY-ADDRESSING","surface":"tile","classification":["model","memory","addressing"],"depends_on":["PTO-TILE-MODEL-MEMORY-SHARED-MOVEMENT"]}
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

pure func TileIndexByteDisplacement(index_value: Word,
                                    index_data_type: TileDataType) => Word
begin
    assert TileDataTypeIsInteger(index_data_type);
    case index_data_type of
        when TileDataType_S4X2 =>
            return SignExtend{PTO_XLEN}(index_value[3:0]);
        when TileDataType_S8 =>
            return SignExtend{PTO_XLEN}(index_value[7:0]);
        when TileDataType_S16 =>
            return SignExtend{PTO_XLEN}(index_value[15:0]);
        when TileDataType_S32 =>
            return SignExtend{PTO_XLEN}(index_value[31:0]);
        when TileDataType_S64 => return index_value;
        when TileDataType_U4X2 =>
            return ZeroExtend{PTO_XLEN}(index_value[3:0]);
        when TileDataType_U8 =>
            return ZeroExtend{PTO_XLEN}(index_value[7:0]);
        when TileDataType_U16 =>
            return ZeroExtend{PTO_XLEN}(index_value[15:0]);
        when TileDataType_U32 =>
            return ZeroExtend{PTO_XLEN}(index_value[31:0]);
        when TileDataType_U64 => return index_value;
        otherwise => unreachable;
    end;
end;

pure func TileMemoryByteDisplacementAddress(
    base_address: Word, index_value: Word,
    index_data_type: TileDataType) => Word
begin
    return base_address +
        TileIndexByteDisplacement(index_value, index_data_type);
end;
```
<!-- GENERATED-ASL-END: unit -->
