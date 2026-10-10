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

Every PE has its own Local pool. Capacity follows live payload backing, independently of the descriptor and relative name that can remain after last-use.

The helpers read descriptors in `_Tiles` and the separate `_TilePayloadLiveMasks`. An allocated descriptor may survive after its payload charge is gone. `PTOPEMaskBitOfPEIdentity` maps PE0 to the high mask bit; independent execution uses each PE’s actual bank rather than treating peer bits in the current bank as peer storage.

<!-- PTO-READER-BLOCK: tile-model-capacity-local-rules role=rules-interactions -->
## Rules and interactions

`TileCapacityInUseForPE` measures live payload in the requested PE bank. The `Except` variant excludes one physical slot for replacement checks. Aggregate verification without an active PE context retains its mask-based representation.

In independent execution, allocation checks concern the executing selected PE’s pool. `LocalTileAllocationFitsExcept` excludes the replacement slot from that pool before adding the requested bytes. An unadvanced peer’s full pool cannot reject an allocation into the current PE’s separate bank.

Design point: the check is per PE, not per Core. One PE's Local allocations never consume another PE's pool, so a program can fill PE0's 256 KiB without affecting PE3.

Design point: the allocation transitions use the `Except` form with the register being configured. Reconfiguring a register therefore replaces its old charge rather than counting it twice.

`TileCapacityInUse` reports the sum of actual PE banks when contexts are active. Its aggregate verification path retains `TileCoreAllocationBytes` and the existing mask-population accounting.

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
// PTO-UNIT: {"id":"PTO-TILE-MODEL-CAPACITY-LOCAL","surface":"tile","classification":["model","capacity","local"],"depends_on":["PTO-ARCH-STATE-PE-EXECUTION-CONTEXT","PTO-TILE-MODEL-STATE-SHARED-REGISTERS"]}
readonly func TileCapacityLimitBytes() => integer {0..262144}
begin
    assert UInt(_SystemRegisters.tile_capacity) <=
        PTO_MODEL_MAX_TILE_CAPACITY_BYTES;
    return UInt(_SystemRegisters.tile_capacity) as integer {0..262144};
end;

readonly func TileCapacityInUseExcept(excluded: TileIndex) => integer
begin
    if _CurrentPEContextValid then
        var bank_total: integer = 0;
        for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
            bank_total = bank_total +
                TileCapacityInUseExceptForPE(excluded, pe);
        end;
        return bank_total;
    end;
    var total: integer = 0;
    for index = 0 to PTO_TILE_REGISTER_COUNT - 1 do
        if index != excluded && _Tiles[[index]].allocated then
            total = total + TileCoreAllocationBytes(
                _TilePayloadLiveMasks[[index]],
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
    if !_CurrentPEContextValid || pe_identity == _CurrentMemoryAgent then
        for index = 0 to PTO_TILE_REGISTER_COUNT - 1 do
            if _Tiles[[index]].allocated &&
               _TilePayloadLiveMasks[[index]][mask_bit] == '1' then
                total = total + _Tiles[[index]].capacity_bytes;
            end;
        end;
        return total;
    end;
    let core = _CurrentModelCore;
    if _PEContextBankValid[[core]][pe_identity] == '1' then
        for index = 0 to PTO_TILE_REGISTER_COUNT - 1 do
            if _PEExecutionContexts[[core]][[pe_identity]].tiles[[index]].allocated &&
               _PEExecutionContexts[[core]][[pe_identity]]
                   .tile_payload_live_masks[[index]][mask_bit] == '1' then
                total = total + _PEExecutionContexts[[core]][[pe_identity]]
                    .tiles[[index]].capacity_bytes;
            end;
        end;
    else
        for index = 0 to PTO_TILE_REGISTER_COUNT - 1 do
            if _DefaultPEExecutionContext.tiles[[index]].allocated &&
               _DefaultPEExecutionContext.tile_payload_live_masks[[index]]
                   [mask_bit] == '1' then
                total = total + _DefaultPEExecutionContext.tiles[[index]]
                    .capacity_bytes;
            end;
        end;
    end;
    return total;
end;

readonly func TileCapacityInUseExceptForPE(
    excluded: TileIndex, pe_identity: integer {0..3}) => integer
begin
    var total: integer = 0;
    let mask_bit = PTOPEMaskBitOfPEIdentity(pe_identity);
    if !_CurrentPEContextValid || pe_identity == _CurrentMemoryAgent then
        for index = 0 to PTO_TILE_REGISTER_COUNT - 1 do
            if index != excluded && _Tiles[[index]].allocated &&
               _TilePayloadLiveMasks[[index]][mask_bit] == '1' then
                total = total + _Tiles[[index]].capacity_bytes;
            end;
        end;
        return total;
    end;
    let core = _CurrentModelCore;
    if _PEContextBankValid[[core]][pe_identity] == '1' then
        for index = 0 to PTO_TILE_REGISTER_COUNT - 1 do
            if index != excluded &&
               _PEExecutionContexts[[core]][[pe_identity]].tiles[[index]].allocated &&
               _PEExecutionContexts[[core]][[pe_identity]]
                   .tile_payload_live_masks[[index]][mask_bit] == '1' then
                total = total + _PEExecutionContexts[[core]][[pe_identity]]
                    .tiles[[index]].capacity_bytes;
            end;
        end;
    else
        for index = 0 to PTO_TILE_REGISTER_COUNT - 1 do
            if index != excluded &&
               _DefaultPEExecutionContext.tiles[[index]].allocated &&
               _DefaultPEExecutionContext.tile_payload_live_masks[[index]]
                   [mask_bit] == '1' then
                total = total + _DefaultPEExecutionContext.tiles[[index]]
                    .capacity_bytes;
            end;
        end;
    end;
    return total;
end;

readonly func LocalTileAllocationFitsExcept(
    excluded: TileIndex, pe_mask: bits(4), per_pe_bytes: integer) => boolean
begin
    if _CurrentPEContextValid then
        let pe = _CurrentMemoryAgent;
        let mask_bit = PTOPEMaskBitOfPEIdentity(pe);
        return pe_mask[mask_bit] == '0' ||
            TileCapacityInUseExceptForPE(excluded, pe) + per_pe_bytes <=
                TileCapacityLimitBytes();
    end;
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
    if _CurrentPEContextValid then
        let pe = _CurrentMemoryAgent;
        let mask_bit = PTOPEMaskBitOfPEIdentity(pe);
        return pe_mask[mask_bit] == '0' ||
            TileCapacityInUseForPE(pe) + per_pe_bytes <=
                TileCapacityLimitBytes();
    end;
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

readonly func LocalTileAllocationGroupFits(
    additional0: integer, additional1: integer,
    additional2: integer, additional3: integer) => boolean
begin
    if _CurrentPEContextValid then
        case _CurrentMemoryAgent of
            when 0 => return TileCapacityInUseForPE(0) + additional0 <=
                TileCapacityLimitBytes();
            when 1 => return TileCapacityInUseForPE(1) + additional1 <=
                TileCapacityLimitBytes();
            when 2 => return TileCapacityInUseForPE(2) + additional2 <=
                TileCapacityLimitBytes();
            when 3 => return TileCapacityInUseForPE(3) + additional3 <=
                TileCapacityLimitBytes();
        end;
    end;
    return TileCapacityInUseForPE(0) + additional0 <=
               TileCapacityLimitBytes() &&
           TileCapacityInUseForPE(1) + additional1 <=
               TileCapacityLimitBytes() &&
           TileCapacityInUseForPE(2) + additional2 <=
               TileCapacityLimitBytes() &&
           TileCapacityInUseForPE(3) + additional3 <=
               TileCapacityLimitBytes();
end;

readonly func TileCapacityInUse() => integer
begin
    if _CurrentPEContextValid then
        var bank_total: integer = 0;
        for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
            bank_total = bank_total + TileCapacityInUseForPE(pe);
        end;
        return bank_total;
    end;
    var total: integer = 0;
    for index = 0 to PTO_TILE_REGISTER_COUNT - 1 do
        if _Tiles[[index]].allocated then
            total = total + TileCoreAllocationBytes(
                _TilePayloadLiveMasks[[index]],
                _Tiles[[index]].capacity_bytes);
        end;
    end;
    return total;
end;
```
<!-- GENERATED-ASL-END: unit -->
