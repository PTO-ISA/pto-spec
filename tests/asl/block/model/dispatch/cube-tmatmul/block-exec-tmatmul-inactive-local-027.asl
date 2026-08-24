// PTO-TEST: {"id":"PTO-AVS-BLOCK-TMATMUL-INACTIVE-LOCAL-027","source":"asl/block/model/dispatch/cube-tmatmul.asl","requirements":["PTO-CUBE-GROUP-M-DISTRIBUTION-001","PTO-B-ASSEMBLE-CONSUMER-READINESS-001"],"kind":"execution","summary":"A zero-row cooperative PE ignores every compute-only Local mapping and generation.","pass_condition":"A structurally complete Local-A/Shared-B block with unallocated Local source and destination plus subview and assemble carriers succeeds for an inactive PE without dependency, materialization, allocation, generation, payload, or fault effects.","related_sources":["asl/block/model/operands/subview-descriptor.asl","asl/block/model/operands/local-generation.asl"]}

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
    AddBundleTileBinding(
        TRUE, 0, 1, '1111', TRUE, FALSE, 62, 0, TRUE);
    _BundleTileBindings[[0]].source0_subview.valid = TRUE;
    _BundleTileBindings[[0]].source0_subview.size_code = 1;
    _BundleTileBindings[[0]].source0_subview.offset = Zeros{PTO_XLEN};
    _BundleTileBindings[[0]].destination_assemble.valid = TRUE;
    _BundleTileBindings[[0]].destination_assemble.init = TRUE;
    _BundleTileBindings[[0]].destination_assemble.last = TRUE;
    _BundleTileBindings[[0]].destination_assemble.size_code = 1;

    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
    assert !_BundleTileBindings[[0]].source0_subview.derived.valid;
    assert !_BundleTileBindings[[0]].source0_subview.materialized;
    assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;
    assert !_LocalGenerations[[BundleLocalGenerationSlot(0, '1111')]].open;
    assert CoreTileCapacityInUse() == shared_capacity;
    return 0;
end;
