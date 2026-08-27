// PTO-TEST: {"id":"PTO-AVS-TILE-SHARED-CAPACITY-ISOLATION-002","source":"asl/tile/model/capacity/shared.asl","requirements":["PTO-TILE-CAPACITY-PER-PE"],"kind":"boundary","summary":"The Core-wide Shared pool is independent of every Local PE pool.","pass_condition":"One 256 KiB Shared object coexists with four legal 64 KiB Local Tiles in each of PE0 and PE1, while a second Shared allocation is rejected regardless of its PE mask.","related_sources":["asl/tile/model/state/shared-registers.asl","asl/tile/model/state/allocation.asl"]}
func main() => integer
begin
    ResetProfileState();
    let shared_tile = MaterializeSharedTileForReadSchemaAtCapacity(
        Zeros{6} as SharedTileID, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor, 262144);
    InstallSharedTile(Zeros{6} as SharedTileID, shared_tile, '1111');
    assert TileCapacityInUseForPE(0) == 0;
    assert SharedTileCapacityInUse() == 262144;
    assert CoreTileCapacityInUse() == 262144;

    for index = 0 to 3 do
        ConfigureTileForMask(index as TileIndex, 65536, 8192, 1, 1, 1,
            TileDataType_U64, TileLayout_RowMajor, TileLocation_Any, '1000');
    end;
    assert TileCapacityInUseForPE(0) == 262144;
    assert SharedTileCapacityInUse() == 262144;
    assert CoreTileCapacityInUse() == 524288;

    for index = 4 to 7 do
        ConfigureTileForMask(index as TileIndex, 65536, 8192, 1, 1, 1,
            TileDataType_U64, TileLayout_RowMajor, TileLocation_Any, '0100');
    end;
    assert !LocalTileAllocationFits('0100', 128);
    assert TileCapacityInUseForPE(1) == 262144;
    assert SharedTileCapacityInUse() == 262144;
    assert CoreTileCapacityInUse() == 786432;

    let second_shared = MaterializeSharedTileForReadSchemaAtCapacity(
        (Zeros{6} + 1) as SharedTileID, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor, 262144);
    assert !SharedTileUpdateCompatible(
        (Zeros{6} + 1) as SharedTileID, second_shared, '1000');
    assert !SharedTileUpdateCompatible(
        (Zeros{6} + 1) as SharedTileID, second_shared, '1111');
    assert !SharedTileRecord((Zeros{6} + 1) as SharedTileID)
        .descriptor_valid;
    return 0;
end;
