// PTO-TEST: {"id":"PTO-AVS-TILE-SHARED-CAPACITY-ISOLATION-002","source":"asl/tile/model/capacity/shared.asl","requirements":["PTO-TILE-CAPACITY-PER-PE"],"kind":"boundary","summary":"The Core-wide Shared pool is independent of every Local PE pool.","pass_condition":"One 256 KiB Shared object coexists with independent 256 KiB Local allocations in PE0 and PE1, while a second Shared allocation is rejected regardless of its PE mask.","related_sources":["asl/tile/model/state/shared-registers.asl","asl/tile/model/state/allocation.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTileForMask(0, 262144, 32768, 1, 1, 1,
        TileDataType_U64, TileLayout_RowMajor, TileLocation_Any, '1000');
    InstallSharedTile(Zeros{6} as SharedTileID, _Tiles[[0]], '1111');
    assert TileCapacityInUseForPE(0) == 262144;
    assert SharedTileCapacityInUse() == 262144;
    assert CoreTileCapacityInUse() == 524288;

    assert LocalTileAllocationFits('0100', 262144);
    ConfigureTileForMask(1, 262144, 32768, 1, 1, 1,
        TileDataType_U64, TileLayout_RowMajor, TileLocation_Any, '0100');
    assert TileCapacityInUseForPE(1) == 262144;
    assert SharedTileCapacityInUse() == 262144;
    assert CoreTileCapacityInUse() == 786432;

    assert !SharedTileUpdateCompatible(
        (Zeros{6} + 1) as SharedTileID, _Tiles[[1]], '1000');
    assert !SharedTileUpdateCompatible(
        (Zeros{6} + 1) as SharedTileID, _Tiles[[1]], '1111');
    assert !SharedTileRecord((Zeros{6} + 1) as SharedTileID)
        .descriptor_valid;
    return 0;
end;
