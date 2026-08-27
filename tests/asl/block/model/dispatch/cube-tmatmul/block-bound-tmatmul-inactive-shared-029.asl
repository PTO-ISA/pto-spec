// PTO-TEST: {"id":"PTO-AVS-BLOCK-TMATMUL-INACTIVE-SHARED-029","source":"asl/block/model/dispatch/cube-tmatmul.asl","requirements":["PTO-B-SHARED-WHOLE-PARENT-READY-001","PTO-CUBE-GROUP-M-DISTRIBUTION-001"],"kind":"boundary","summary":"Inactive cooperative PEs retain no-fault Shared readiness preflight.","pass_condition":"A zero-row PE with structurally present invalid Local mappings waits for an unpublished Shared B before every Local dependency allocation generation payload numeric-status or fault effect.","related_sources":["asl/block/model/dispatch/shared-cube-matrix.asl","asl/block/model/dispatch/tile-execution.asl"]}

func main() => integer
begin
    ResetProfileState();
    SelectMemoryEventAgent(1);
    let status_before = NumericStatusFlags();

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

    let completed = ExecuteBundleTileOperation();
    assert !completed && _LastFault == Fault_None;
    assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;
    assert !_BundleSharedBindings[[0]].consumed;
    assert !SharedTileRecord((Zeros{6} + 51) as SharedTileID).descriptor_valid;
    assert !_Tiles[[62]].allocated;
    assert CoreTileCapacityInUse() == 0;
    assert NumericStatusFlags() == status_before;
    return 0;
end;
