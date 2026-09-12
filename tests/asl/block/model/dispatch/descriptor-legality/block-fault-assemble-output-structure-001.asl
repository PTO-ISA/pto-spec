// PTO-TEST: {"id":"PTO-AVS-BLOCK-ASSEMBLE-OUTPUT-STRUCTURE-001","source":"asl/block/model/dispatch/descriptor-legality.asl","requirements":["PTO-B-ASSEMBLE-RANGE-001","PTO-B-ASSEMBLE-LOCAL-GENERATION-001","PTO-B-ASSEMBLE-SHARED-GENERATION-001"],"kind":"fault","summary":"A continuation has exactly one reused Local or Shared output, capacity-bound ordinary sources, and no additional allocating output.","pass_condition":"Decoded Local ParentRef plus Shared reused-destination and Shared reused-destination-plus-Local-destination bundles reject with Fault_BundleControl before resolution or allocation; one ordinary TADDS source plus ParentRef satisfies the complete operation destination contract; 7+ParentRef Local and 3 ordinary plus reused-destination Shared boundaries are structurally legal; 8+ParentRef Local rejects and a fourth Shared ordinary append rejects with Fault_BundleControl before effects.","related_sources":["asl/block/model/operands/tile-bindings.asl","asl/block/model/operands/shared-bindings.asl"]}
func InstallAssembleStructureOperation()
begin
    var instruction = Zeros{64} + 0x00019181;
    instruction[26:25] = '01';
    instruction[24:20] = Zeros{5};
    instruction[31:27] = Zeros{5} + 24;
    let started = ExecuteCommandInstruction(instruction, 32);
    assert started == CommandExecution_Executed;
end;

func InstallLocalParentRef()
begin
    SetBundleTileBinding(0, FALSE, 0, 0, '1111', FALSE, FALSE, 0, 0,
        TRUE);
    _BundleTileBindings[[0]].parent_ref_valid = TRUE;
    _BundleTileBindings[[0]].parent_ref_relative = FALSE;
    _BundleTileBindings[[0]].parent_ref = 0;
    _BundleTileBindings[[0]].destination_assemble.valid = TRUE;
    _BundleTileBindings[[0]].destination_assemble.init = FALSE;
    _BundleTileBindings[[0]].destination_assemble.last = TRUE;
end;

func InstallSharedContinuationDestination()
begin
    BindBundleSharedIO((Zeros{6} + 1) as SharedTileID, 0, '1111');
    _BundleSharedBindings[[0]].destination_assemble.valid = TRUE;
    _BundleSharedBindings[[0]].destination_assemble.init = FALSE;
    _BundleSharedBindings[[0]].destination_assemble.last = TRUE;
end;

func TestLocalParentRefAndSharedDestinationFaultBeforeEffects()
begin
    ResetProfileState();
    InstallAssembleStructureOperation();
    InstallLocalParentRef();
    InstallSharedContinuationDestination();
    let operation = DecodeTileOperation(TileDecode_TEPL, Zeros{12} + 0x20)
        as integer {0..PTO_TILE_OPERATION_COUNT-1};
    assert !BundleOperationBindingsComplete(operation);
    let completed = ExecuteBundleTileOperation();
    assert !completed;
    assert _LastFault == Fault_BundleControl;
    assert !_Tiles[[0]].allocated;
end;

func TestSharedContinuationRejectsLocalDestination()
begin
    ResetProfileState();
    InstallAssembleStructureOperation();
    SetBundleTileBinding(0, TRUE, 0, 1, '1111', FALSE, FALSE, 0, 0,
        TRUE);
    InstallSharedContinuationDestination();
    let operation = DecodeTileOperation(TileDecode_TEPL, Zeros{12} + 0x20)
        as integer {0..PTO_TILE_OPERATION_COUNT-1};
    assert !BundleOperationBindingsComplete(operation);
    let completed = ExecuteBundleTileOperation();
    assert !completed;
    assert _LastFault == Fault_BundleControl;
    assert !_Tiles[[0]].allocated;
end;

func InstallLocalContinuationCapacityBoundary()
begin
    SetBundleTileBinding(0, FALSE, 0, 0, '1111', TRUE, TRUE, 0, 0, FALSE);
    SetBundleTileBinding(1, FALSE, 0, 0, '1111', TRUE, TRUE, 0, 0, FALSE);
    SetBundleTileBinding(2, FALSE, 0, 0, '1111', TRUE, TRUE, 0, 0, FALSE);
    SetBundleTileBinding(3, FALSE, 0, 0, '1111', TRUE, FALSE, 0, 0, FALSE);
    SetBundleTileBinding(4, FALSE, 0, 0, '1111', FALSE, FALSE, 0, 0, TRUE);
    _BundleTileBindings[[4]].parent_ref_valid = TRUE;
    _BundleTileBindings[[4]].parent_ref = 0;
    _BundleTileBindings[[4]].destination_assemble.valid = TRUE;
    _BundleTileBindings[[4]].destination_assemble.init = FALSE;
    _BundleTileBindings[[4]].destination_assemble.last = TRUE;
end;

func TestLocalContinuationCapacityBoundary()
begin
    ResetProfileState();
    InstallAssembleStructureOperation();
    InstallLocalContinuationCapacityBoundary();
    assert BundleAssembleOutputStructureLegal();
end;

func TestLocalContinuationSatisfiesOperationDestination()
begin
    ResetProfileState();
    InstallAssembleStructureOperation();
    SetBundleTileBinding(0, FALSE, 0, 0, '1111', TRUE, FALSE, 0, 0,
        TRUE);
    _BundleTileBindings[[0]].parent_ref_valid = TRUE;
    _BundleTileBindings[[0]].parent_ref_relative = FALSE;
    _BundleTileBindings[[0]].parent_ref = 0;
    _BundleTileBindings[[0]].destination_assemble.valid = TRUE;
    _BundleTileBindings[[0]].destination_assemble.init = FALSE;
    _BundleTileBindings[[0]].destination_assemble.last = TRUE;
    let operation = DecodeTileOperation(TileDecode_TEPL, Zeros{12} + 0x20)
        as integer {0..PTO_TILE_OPERATION_COUNT-1};
    assert BundleAssembleOutputStructureLegal();
    assert BundleOperationBindingsComplete(operation);
end;

func InstallLocalContinuationOverflow()
begin
    SetBundleTileBinding(0, FALSE, 0, 0, '1111', TRUE, TRUE, 0, 0, FALSE);
    SetBundleTileBinding(1, FALSE, 0, 0, '1111', TRUE, TRUE, 0, 0, FALSE);
    SetBundleTileBinding(2, FALSE, 0, 0, '1111', TRUE, TRUE, 0, 0, FALSE);
    SetBundleTileBinding(3, FALSE, 0, 0, '1111', TRUE, TRUE, 0, 0, FALSE);
    SetBundleTileBinding(4, FALSE, 0, 0, '1111', FALSE, FALSE, 0, 0, TRUE);
    _BundleTileBindings[[4]].parent_ref_valid = TRUE;
    _BundleTileBindings[[4]].parent_ref = 0;
    _BundleTileBindings[[4]].destination_assemble.valid = TRUE;
    _BundleTileBindings[[4]].destination_assemble.init = FALSE;
    _BundleTileBindings[[4]].destination_assemble.last = TRUE;
end;

func TestLocalContinuationOverflowFaultsBeforeEffects()
begin
    ResetProfileState();
    InstallAssembleStructureOperation();
    InstallLocalContinuationOverflow();
    assert !BundleAssembleOutputStructureLegal();
    let completed = ExecuteBundleTileOperation();
    assert !completed;
    assert _LastFault == Fault_BundleControl;
end;

func InstallSharedContinuationCapacityBoundary()
begin
    BindBundleSharedIO((Zeros{6} + 1) as SharedTileID, 0, '1111');
    BindBundleSharedIO((Zeros{6} + 2) as SharedTileID, 0, '1111');
    BindBundleSharedIO((Zeros{6} + 3) as SharedTileID, 0, '1111');
    BindBundleSharedIO((Zeros{6} + 4) as SharedTileID, 0, '1111');
    _BundleSharedBindings[[3]].destination_assemble.valid = TRUE;
    _BundleSharedBindings[[3]].destination_assemble.init = FALSE;
    _BundleSharedBindings[[3]].destination_assemble.last = TRUE;
end;

func TestSharedContinuationCapacityBoundary()
begin
    ResetProfileState();
    InstallAssembleStructureOperation();
    InstallSharedContinuationCapacityBoundary();
    assert BundleAssembleOutputStructureLegal();
    assert BundleSharedBindingCount() == 3;
    assert BundleSharedBindingPhysicalCount() == 4;
    assert BundleSharedReusedDestinationCount() == 1;
    assert BundleSharedReusedDestinationIsFinal();
end;

func TestSharedContinuationRejectsFourthOrdinaryAppend()
begin
    ResetProfileState();
    InstallAssembleStructureOperation();
    InstallSharedContinuationCapacityBoundary();
    assert BundleAssembleOutputStructureLegal();
    BindBundleSharedIO((Zeros{6} + 5) as SharedTileID, 0, '1111');
    assert _LastFault == Fault_BundleControl;
    assert BundleSharedBindingPhysicalCount() == 4;
    assert BundleSharedBindingIsReusedDestination(3);
    assert !_Tiles[[0]].allocated;
end;

func main() => integer
begin
    TestLocalParentRefAndSharedDestinationFaultBeforeEffects();
    TestSharedContinuationRejectsLocalDestination();
    TestLocalContinuationCapacityBoundary();
    TestLocalContinuationSatisfiesOperationDestination();
    TestLocalContinuationOverflowFaultsBeforeEffects();
    TestSharedContinuationCapacityBoundary();
    TestSharedContinuationRejectsFourthOrdinaryAppend();
    return 0;
end;
