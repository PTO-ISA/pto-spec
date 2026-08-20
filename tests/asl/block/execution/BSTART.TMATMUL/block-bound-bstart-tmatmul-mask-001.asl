// PTO-TEST: {"id":"PTO-AVS-BLOCK-TMATMUL-MASK-001","source":"asl/block/execution/BSTART.TMATMUL.asl","requirements":["PTO-TMATMUL-CONTRACT-001","PTO-CUBE-SHARED-TRANSPOSE-001"],"kind":"boundary","summary":"TMATMUL distinguishes strict zero participation from legal partial participation","pass_condition":"a zero-mask block has no effects while a nonzero partial mask allocates and publishes only the selected destination producers","related_sources":["asl/block/model/dispatch/cube-tmatmul.asl"]}
func main() => integer
begin
    ResetProfileState();
    var start: bits(64) = Zeros{64} + 0x00031181;
    start[31:27] = Zeros{5} + 4;
    let zero_started = ExecuteCommandInstruction(start, 32);
    assert zero_started == CommandExecution_Executed;
    AddBundleTileBinding(TRUE, 0, 1, '0000', TRUE, TRUE, 62, 63, TRUE);
    let zero_completed = ExecuteBundleTileOperation();
    assert zero_completed;
    assert _LastFault == Fault_None;
    assert CoreTileCapacityInUse() == 0;

    ResetProfileState();
    let cube_configuration_1 = ConfigureCubeTileForMask(1, 128, 1, 1,
        TileDataType_FP16, TileLayout_CUBE_M16,
        TileLocation_Matrix, '1111');
    assert cube_configuration_1;
    let cube_configuration_2 = ConfigureCubeTileForMask(2, 128, 1, 1,
        TileDataType_FP16, TileLayout_CUBE_N8,
        TileLocation_Matrix, '1111');
    assert cube_configuration_2;
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 2);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 3);
    let partial_started = ExecuteCommandInstruction(start, 32);
    assert partial_started == CommandExecution_Executed;
    SetBundleFixedPointAttributeState(
        Zeros{6}, Zeros{3}, Zeros{4},
        FALSE, FALSE, FALSE, FALSE);
    AddBundleTileBinding(TRUE, 0, 1, '0011', TRUE, TRUE, 1, 2, TRUE);
    let partial_completed = ExecuteBundleTileOperation();
    assert partial_completed;
    assert _LastFault == Fault_None;
    assert _BundleTileBindings[[0]].destination_allocated_by_bundle;
    let destination = _BundleTileBindings[[0]].destination;
    assert _TileAllocationMasks[[destination]] == '0011';
    return 0;
end;
