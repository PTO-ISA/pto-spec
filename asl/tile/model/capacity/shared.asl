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
