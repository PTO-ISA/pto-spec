<!-- GENERATED FROM: asl/tile/model/capacity/local.asl -->
# Local

**Normative ASL source:** `asl/tile/model/capacity/local.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-CAPACITY-LOCAL}

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/capacity/local.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-CAPACITY-LOCAL","surface":"tile","classification":["model","capacity","local"],"depends_on":["PTO-TILE-MODEL-STATE-SHARED-REGISTERS"]}
readonly func TileCapacityLimitBytes() => integer {0..262144}
begin
    assert UInt(_SystemRegisters.tile_capacity) <=
        PTO_MODEL_MAX_TILE_CAPACITY_BYTES;
    return UInt(_SystemRegisters.tile_capacity) as integer {0..262144};
end;

readonly func TileCapacityInUseExcept(excluded: TileIndex) => integer
begin
    var total: integer = 0;
    for index = 0 to PTO_TILE_REGISTER_COUNT - 1 do
        if index != excluded && _Tiles[[index]].allocated then
            total = total + TileCoreAllocationBytes(
                _TileAllocationMasks[[index]],
                _Tiles[[index]].capacity_bytes);
        end;
    end;
    return total;
end;

readonly func TileCapacityInUseForPE(
    pe_identity: integer {0..3}) => integer
begin
    var total: integer = 0;
    let mask_bit = PTOPEMaskBitOfPEIdentity(pe_identity);
    for index = 0 to PTO_TILE_REGISTER_COUNT - 1 do
        if _Tiles[[index]].allocated &&
           _TileAllocationMasks[[index]][mask_bit] == '1' then
            total = total + _Tiles[[index]].capacity_bytes;
        end;
    end;
    return total;
end;

readonly func TileCapacityInUseExceptForPE(
    excluded: TileIndex, pe_identity: integer {0..3}) => integer
begin
    var total: integer = 0;
    let mask_bit = PTOPEMaskBitOfPEIdentity(pe_identity);
    for index = 0 to PTO_TILE_REGISTER_COUNT - 1 do
        if index != excluded && _Tiles[[index]].allocated &&
           _TileAllocationMasks[[index]][mask_bit] == '1' then
            total = total + _Tiles[[index]].capacity_bytes;
        end;
    end;
    return total;
end;

readonly func LocalTileAllocationFitsExcept(
    excluded: TileIndex, pe_mask: bits(4), per_pe_bytes: integer) => boolean
begin
    for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        let mask_bit = PTOPEMaskBitOfPEIdentity(pe);
        if pe_mask[mask_bit] == '1' &&
           TileCapacityInUseExceptForPE(excluded, pe) + per_pe_bytes >
               TileCapacityLimitBytes() then
            return FALSE;
        end;
    end;
    return TRUE;
end;

readonly func LocalTileAllocationFits(
    pe_mask: bits(4), per_pe_bytes: integer) => boolean
begin
    for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        let mask_bit = PTOPEMaskBitOfPEIdentity(pe);
        if pe_mask[mask_bit] == '1' &&
           TileCapacityInUseForPE(pe) + per_pe_bytes >
               TileCapacityLimitBytes() then
            return FALSE;
        end;
    end;
    return TRUE;
end;

readonly func TileCapacityInUse() => integer
begin
    var total: integer = 0;
    for index = 0 to PTO_TILE_REGISTER_COUNT - 1 do
        if _Tiles[[index]].allocated then
            total = total + TileCoreAllocationBytes(
                _TileAllocationMasks[[index]],
                _Tiles[[index]].capacity_bytes);
        end;
    end;
    return total;
end;
```
<!-- GENERATED-ASL-END: unit -->

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
