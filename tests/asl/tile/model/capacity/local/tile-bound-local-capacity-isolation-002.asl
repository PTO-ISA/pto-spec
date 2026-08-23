// PTO-TEST: {"id":"PTO-AVS-TILE-LOCAL-CAPACITY-ISOLATION-002","source":"asl/tile/model/capacity/local.asl","requirements":["PTO-TILE-CAPACITY-PER-PE"],"kind":"boundary","summary":"Local capacity accumulates independently in each PE pool.","pass_condition":"Two 128 KiB allocations fill PE0, a 256 KiB allocation independently fills PE1, and releasing one PE0 object restores exactly 128 KiB there without changing PE1.","related_sources":["asl/tile/model/state/allocation.asl","asl/tile/model/state/descriptors.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTileForMask(0, 131072, 16384, 1, 1, 1,
        TileDataType_U64, TileLayout_RowMajor, TileLocation_Any, '1000');
    ConfigureTileForMask(1, 131072, 16384, 1, 1, 1,
        TileDataType_U64, TileLayout_RowMajor, TileLocation_Any, '1000');
    assert TileCapacityInUseForPE(0) == 262144;
    assert TileCapacityInUseForPE(1) == 0;
    assert !LocalTileAllocationFits('1000', 128);
    assert LocalTileAllocationFits('0100', 262144);

    ConfigureTileForMask(2, 262144, 32768, 1, 1, 1,
        TileDataType_U64, TileLayout_RowMajor, TileLocation_Any, '0100');
    assert TileCapacityInUseForPE(0) == 262144;
    assert TileCapacityInUseForPE(1) == 262144;
    assert !LocalTileAllocationFits('1100', 128);
    assert LocalTileAllocationFits('0010', 262144);

    ReleaseTile(0);
    assert TileCapacityInUseForPE(0) == 131072;
    assert TileCapacityInUseForPE(1) == 262144;
    assert LocalTileAllocationFits('1000', 131072);
    assert !LocalTileAllocationFits('1000', 262144);
    assert !LocalTileAllocationFits('0100', 128);
    return 0;
end;
