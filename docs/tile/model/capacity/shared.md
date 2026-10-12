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

This unit measures the Core-wide Shared Tile pool and reports combined Tile usage. `SharedTileCapacityCharge` isolates the charge for one Shared register so allocation, replacement, source retirement and open assembly use the same accounting.

- `SharedTileCapacityInUse` sums per-register charges.
- `SharedTileCapacityCharge` compares live payload with a pending parent reservation.
- `SharedTileCapacityLimitBytes` supplies the separate Shared limit.
- `CoreTileCapacityInUse` reports Local plus Shared usage.

<!-- PTO-READER-BLOCK: tile-model-capacity-shared-concepts role=concepts-state -->
## Concepts and visible state

A Shared Tile register is one of S0 to S63 in `_SharedTiles`. It belongs to the Core, not to a PE, and all four PEs address the same 64 records.

A valid descriptor alone does not charge payload capacity. The charge is the larger of live payload bytes and `reserved_capacity_bytes` for an open assembly. Thus consuming an old payload does not lend a pending parent’s reserved space to another Shared register.

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

S4 has a live 128 KiB payload and S9 has a live 64 KiB payload, so the initial charge is 196608 bytes. If S4 opens a same-size assembly, its charge remains 128 KiB. Retiring S4’s old source still leaves that reservation charged until publication or abort.

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
        total = total + SharedTileCapacityCharge(
            (Zeros{6} + index) as SharedTileID);
    end;
    return total;
end;

readonly func SharedTileCapacityCharge(shared_tile_id: SharedTileID) => integer
begin
    let index = UInt(shared_tile_id) as SharedTileIndex;
    let live_bytes = if _SharedTiles[[index]].descriptor_valid &&
        _SharedTiles[[index]].payload_live then
        _SharedTiles[[index]].tile.capacity_bytes else 0;
    let reserved_bytes = _SharedTiles[[index]].reserved_capacity_bytes;
    return if live_bytes > reserved_bytes then live_bytes else reserved_bytes;
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
