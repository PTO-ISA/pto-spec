// PTO-TEST: {"id":"PTO-AVS-BLOCK-TMATMUL-INACTIVE-STRUCTURAL-028","source":"asl/block/model/dispatch/cube-tmatmul.asl","requirements":["PTO-CUBE-GROUP-M-DISTRIBUTION-001"],"kind":"fault","summary":"Inactive cooperative PEs still require a structurally complete binder schema.","pass_condition":"A zero-row PE with a valid Shared B but missing encoded Local A and D roles raises TileLegality before allocation or payload effects.","related_sources":["asl/block/model/dispatch/tile-schema.asl"]}

func main() => integer
begin
    ResetProfileState();
    SelectMemoryEventAgent(1);
    ConfigureTileForMask(10, 128, 128, 1, 1, 1,
        TileDataType_U8, TileLayout_RowMajor,
        TileLocation_Matrix, '1111');
    WriteTileElement(10, 0, 0, Zeros{PTO_XLEN} + 3);
    InstallSharedTile((Zeros{6} + 51) as SharedTileID,
        _Tiles[[10]], '1111');
    let shared_capacity = CoreTileCapacityInUse();

    var start: bits(64) = Zeros{64} + 0x00031181;
    start[31:27] = Zeros{5} + 26;
    let started = ExecuteCommandInstruction(start, 32);
    assert started == CommandExecution_Executed;
    SetBundleDataAttributeState(
        Zeros{5} + 27, Zeros{5}, Zeros{2}, Zeros{3}, Zeros{3},
        FALSE, FALSE);
    _BundleDataAttributesPresent = TRUE;
    SetBundleFixedPointAttributeState(
        Zeros{6}, Zeros{3}, Zeros{4}, FALSE, FALSE, FALSE, FALSE);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    BindBundleSharedIO((Zeros{6} + 51) as SharedTileID, 0, '1111');

    let completed = ExecuteBundleTileOperation();
    assert !completed && _LastFault == Fault_TileLegality;
    assert CoreTileCapacityInUse() == shared_capacity;
    return 0;
end;
