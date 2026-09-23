<!-- GENERATED FROM: asl/tile/model/capacity/shared.asl -->
# Shared

**Normative ASL source:** `asl/tile/model/capacity/shared.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-CAPACITY-SHARED}

<!-- SUPPLEMENTARY-BEGIN -->

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
