<!-- GENERATED FROM: asl/tile/model/capacity/shared.asl -->
# Shared

**Normative ASL source:** `asl/tile/model/capacity/shared.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-CAPACITY-SHARED}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-capacity-shared-purpose role=purpose-scope -->
## Purpose and scope

This unit measures the Core-wide Shared Tile pool and reports the combined Tile usage of a Core. It is three helpers long:

- `SharedTileCapacityInUse` sums the capacity of every Shared register that has a descriptor.
- `SharedTileCapacityLimitBytes` returns the Shared pool size.
- `CoreTileCapacityInUse` adds Local and Shared usage.

<!-- PTO-READER-BLOCK: tile-model-capacity-shared-concepts role=concepts-state -->
## Concepts and visible state

A Shared Tile register is one of S0 to S63 in `_SharedTiles`. It belongs to the Core, not to a PE, and all four PEs address the same 64 records.

A Shared register uses capacity when its `descriptor_valid` flag is set. Its charge is the `capacity_bytes` of the wrapped `TileInfo`, counted once.

The limit is `PTO_SHARED_TILE_MAX_ALLOCATION_BYTES`, which is 262144 bytes (256 KiB).

<!-- PTO-READER-BLOCK: tile-model-capacity-shared-rules role=rules-interactions -->
## Rules and interactions

`SharedTileUpdateCompatible` in the Shared register unit uses these helpers. When the target register has no descriptor yet, the update is accepted only if current Shared use plus the new capacity stays within `SharedTileCapacityLimitBytes`.

Design point: a Shared parent is charged once, regardless of how many PEs participate. The allocation mask of a Shared record controls participation, not the charge, so a four-PE Shared parent of 256 KiB uses exactly the whole Shared pool.

Design point: the Shared pool is separate from the Local pools. `SharedTileCapacityInUse` reads only `_SharedTiles`, and the Local fit checks read only the Local register state and the `TILE_CAPACITY` limit, so neither kind of allocation can fail because of the other.

`CoreTileCapacityInUse` is a reporting sum of `TileCapacityInUse` and `SharedTileCapacityInUse`. Because Local usage is multiplied by the PE count of each mask and Shared usage is not, the sum is the total bytes held across the Core.

<!-- PTO-READER-BLOCK: tile-model-capacity-shared-boundaries role=boundaries -->
## Architectural boundaries

The limit is fixed. Unlike the Local limit, it does not read the `TILE_CAPACITY` system register.

Object legality, including the 128-byte granule, is checked by `SharedTileCapacityIsLegal` in the descriptor unit. This unit only sums usage.

`CoreTileCapacityInUse` is not a legality check: no allocation compares it against a combined budget.

<!-- PTO-READER-BLOCK: tile-model-capacity-shared-example role=example-usage -->
## Non-normative reading example

S4 holds a 128 KiB descriptor and S9 holds a 64 KiB descriptor. `SharedTileCapacityInUse` is 131072 + 65536 = 196608 bytes.

- A new 64 KiB Shared parent in an empty register fits: 196608 + 65536 = 262144.
- A new 128 KiB parent does not fit, because the sum would be 327680.
- Updating S4 itself is not charged again, because its descriptor already exists; the update must instead be compatible with the existing descriptor.

<!-- PTO-READER-BLOCK: tile-model-capacity-shared-related role=related-owners-navigation -->
## Related owners

- [Local capacity](local.md) owns the per-PE Local pools.
- [Shared registers](../state/shared-registers.md) calls the Shared limit during updates.
- [Descriptors](../state/descriptors.md) owns `SharedTileCapacityIsLegal`.
- [Shared tile state](../../../arch/features/shared-tile-state.md) gives the architectural Shared model.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/capacity/shared.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-CAPACITY-SHARED","surface":"tile","classification":["model","capacity","shared"],"depends_on":["PTO-TILE-MODEL-CAPACITY-LOCAL"]}
readonly func SharedTileCapacityInUse() => integer
begin
    var total: integer = 0;
    for index = 0 to PTO_SHARED_TILE_COUNT - 1 do
        if _SharedTiles[[index]].descriptor_valid then
            total = total + _SharedTiles[[index]].tile.capacity_bytes;
        end;
    end;
    return total;
end;

pure func SharedTileCapacityLimitBytes() => integer
begin
    return PTO_SHARED_TILE_MAX_ALLOCATION_BYTES;
end;

readonly func CoreTileCapacityInUse() => integer
begin
    return TileCapacityInUse() + SharedTileCapacityInUse();
end;
```
<!-- GENERATED-ASL-END: unit -->
