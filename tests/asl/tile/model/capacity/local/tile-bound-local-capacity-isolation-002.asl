// PTO-TEST: {"id":"PTO-AVS-TILE-LOCAL-CAPACITY-ISOLATION-002","source":"asl/tile/model/capacity/local.asl","requirements":["PTO-TILE-CAPACITY-PER-PE"],"kind":"boundary","summary":"Local capacity accumulates independently in each PE pool.","pass_condition":"Four legal 64 KiB Tiles fill PE0, four more independently fill PE1, and releasing one PE0 object restores exactly 64 KiB there without changing PE1.","related_sources":["asl/tile/model/state/allocation.asl","asl/tile/model/state/descriptors.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTileForMask(0, 65536, 8192, 1, 1, 1,
        TileDataType_U64, TileLayout_RowMajor, TileLocation_Any, '1000');
    ConfigureTileForMask(1, 65536, 8192, 1, 1, 1,
        TileDataType_U64, TileLayout_RowMajor, TileLocation_Any, '1000');
    ConfigureTileForMask(2, 65536, 8192, 1, 1, 1,
        TileDataType_U64, TileLayout_RowMajor, TileLocation_Any, '1000');
    ConfigureTileForMask(3, 65536, 8192, 1, 1, 1,
        TileDataType_U64, TileLayout_RowMajor, TileLocation_Any, '1000');
    assert TileCapacityInUseForPE(0) == 262144;
    assert TileCapacityInUseForPE(1) == 0;
    assert !LocalTileAllocationFits('1000', 128);
    assert LocalTileAllocationFits('0100', 65536);

    ConfigureTileForMask(4, 65536, 8192, 1, 1, 1,
        TileDataType_U64, TileLayout_RowMajor, TileLocation_Any, '0100');
    ConfigureTileForMask(5, 65536, 8192, 1, 1, 1,
        TileDataType_U64, TileLayout_RowMajor, TileLocation_Any, '0100');
    ConfigureTileForMask(6, 65536, 8192, 1, 1, 1,
        TileDataType_U64, TileLayout_RowMajor, TileLocation_Any, '0100');
    ConfigureTileForMask(7, 65536, 8192, 1, 1, 1,
        TileDataType_U64, TileLayout_RowMajor, TileLocation_Any, '0100');
    assert TileCapacityInUseForPE(0) == 262144;
    assert TileCapacityInUseForPE(1) == 262144;
    assert !LocalTileAllocationFits('1100', 128);
    assert LocalTileAllocationFits('0010', 65536);

    ReleaseTile(0);
    assert TileCapacityInUseForPE(0) == 196608;
    assert TileCapacityInUseForPE(1) == 262144;
    assert LocalTileAllocationFits('1000', 65536);
    assert !LocalTileAllocationFits('0100', 128);
    return 0;
end;
