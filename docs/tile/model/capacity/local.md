<!-- GENERATED FROM: asl/tile/model/capacity/local.asl -->
# Local

**Normative ASL source:** `asl/tile/model/capacity/local.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-CAPACITY-LOCAL}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-capacity-local-purpose role=purpose-scope -->
## Purpose and scope

This unit measures Local Tile capacity. It answers two questions: what is the per-PE Local limit, and does a new Local allocation fit in every PE it names.

It defines `TileCapacityLimitBytes`, the per-PE usage helpers, the fit checks `LocalTileAllocationFits` and `LocalTileAllocationFitsExcept`, and the core-wide Local total `TileCapacityInUse`.

<!-- PTO-READER-BLOCK: tile-model-capacity-local-concepts role=concepts-state -->
## Concepts and visible state

The limit is the value of the read-only `TILE_CAPACITY` system register. `TileCapacityLimitBytes` asserts that it is at most `PTO_MODEL_MAX_TILE_CAPACITY_BYTES`, which is 262144 bytes (256 KiB), and reset sets the register to that value.

Every PE has its own Local pool of that size. A Local object charges its full `capacity_bytes` to each PE whose bit is set in its allocation mask.

The helpers read two pieces of state: the `allocated` flag and `capacity_bytes` in `_Tiles`, and the masks in `_TileAllocationMasks`. Mask bits map to PEs through `PTOPEMaskBitOfPEIdentity`, which puts PE0 in the high bit.

<!-- PTO-READER-BLOCK: tile-model-capacity-local-rules role=rules-interactions -->
## Rules and interactions

`TileCapacityInUseForPE` sums `capacity_bytes` over allocated registers whose mask includes that PE. The `Except` variant skips one register.

`LocalTileAllocationFitsExcept(excluded, pe_mask, per_pe_bytes)` returns FALSE if any PE in `pe_mask` would exceed the limit after adding `per_pe_bytes`, ignoring the excluded register's current use. `LocalTileAllocationFits` performs the same check without an exclusion.

Design point: the check is per PE, not per Core. One PE's Local allocations never consume another PE's pool, so a program can fill PE0's 256 KiB without affecting PE3.

Design point: the allocation transitions use the `Except` form with the register being configured. Reconfiguring a register therefore replaces its old charge rather than counting it twice.

`TileCapacityInUse` sums over the whole Core with `TileCoreAllocationBytes`, which multiplies the per-PE bytes by the number of PEs in the mask.

<!-- PTO-READER-BLOCK: tile-model-capacity-local-boundaries role=boundaries -->
## Architectural boundaries

This unit does not limit the size of one object. The 128-byte granule and the 64 KiB single Local object cap are enforced by `TileCapacityIsLegal` in the descriptor unit. Several Local objects may together fill the 256 KiB pool.

Local and Shared pools are independent. The Shared pool is measured by a separate owner.

`PTO_MODEL_MEMORY_AGENTS` is 4, so the fit checks iterate over PE0 to PE3.

<!-- PTO-READER-BLOCK: tile-model-capacity-local-example role=example-usage -->
## Non-normative reading example

Suppose PE0 and PE1 each already hold three 64 KiB Local objects, allocated with mask `1100`. Each of those two PEs has 196608 bytes in use.

- A new 64 KiB object with mask `1100` fits: 196608 + 65536 = 262144, which equals the limit.
- A second such object does not fit, because 262144 + 65536 exceeds the limit on both PE0 and PE1.
- A 64 KiB object with mask `0011` still fits, because PE2 and PE3 have 0 bytes in use.

`TileCapacityInUse` after the first new object reports 4 x 2 x 65536 = 524288 bytes across the Core.

<!-- PTO-READER-BLOCK: tile-model-capacity-local-related role=related-owners-navigation -->
## Related owners

- [Shared capacity](shared.md) owns the separate Core-wide Shared pool.
- [Descriptors](../state/descriptors.md) owns the object size rule `TileCapacityIsLegal`.
- [Allocation](../state/allocation.md) calls the fit check before writing state.
- [PE mask legality](../legality/pe-mask.md) defines `TileCoreAllocationBytes`.
- [Tile allocation feature](../../../arch/features/tile-allocation.md) states the architectural pool sizes.
<!-- SUPPLEMENTARY-END -->

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
