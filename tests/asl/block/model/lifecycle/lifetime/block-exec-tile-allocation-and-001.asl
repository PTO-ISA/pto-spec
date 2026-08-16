// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-BLOCK-TESTBUNDLETILEALLOCATIONANDLIFETIME-EXECUTION-001","source":"asl/block/model/lifecycle/lifetime.asl","requirements":[],"kind":"execution","summary":"Covers Bundle Tile Allocation And Lifetime.","pass_condition":"TestBundleTileAllocationAndLifetime completes without assertion failure","related_sources":[]}
func BundleTestConfigureTile(index: TileIndex, data_type: TileDataType)
begin
    ConfigureTile(index, 256, 1, 1, 1, 1, data_type,
        TileLayout_RowMajor, TileLocation_Any);
end;

func TestBundleTileAllocationAndLifetime()
begin
    ResetProfileState();
    BundleTestConfigureTile(0, TileDataType_U64);
    BundleTestConfigureTile(1, TileDataType_U64);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 7);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 9);
    InstallBundleOperationDescriptor(BundleOperationDescriptor {
        valid = TRUE,
        form_identity = Zeros{7},
        operation_class = BundleOperation_TileElement,
        selector_valid = TRUE,
        selector = Zeros{10},
        data_type_valid = TRUE,
        data_type = Zeros{5} + 24,
        mode_valid = FALSE,
        mode = Zeros{2},
        branch_type_valid = FALSE,
        branch_type = Zeros{3}
    });
    AddBundleTileBinding(TRUE, 0, 3, '1111', TRUE, TRUE, 0, 1, TRUE);
    assert _LastFault == Fault_None;
    assert BundleTileDestinationSizeLegal(0);
    assert BundleTileDestinationSizeBytes(0) == 512;
    assert TileCapacityInUse() == 512;

    // Allocation makes the selected destination undefined. Rejection rolls
    // back both the allocation and the pending source lifetime transition.
    let rejected_resolved = ResolveBundleTileDestinations();
    assert rejected_resolved;
    let rejected_destination = _BundleTileBindings[[0]].destination;
    assert rejected_destination == 2;
    assert _Tiles[[rejected_destination]].allocated;
    assert _TileAllocationMasks[[rejected_destination]] == '1111';
    assert TileCapacityInUse() == 2560;
    assert !_Tiles[[rejected_destination]].contents_defined;
    FinalizeBundleTileAttempt(TileExecution_Rejected);
    RollBackBundleTileDestinations();
    assert !_Tiles[[rejected_destination]].allocated;
    assert TileCapacityInUse() == 512;
    assert _Tiles[[0]].allocated;
    assert _Tiles[[1]].allocated;

    // A successful attempt retains the destination. B.IOT Last terminates the
    // binding sequence; it does not consume either source lifetime.
    let committed_resolved = ResolveBundleTileDestinations();
    assert committed_resolved;
    let committed_destination = _BundleTileBindings[[0]].destination;
    FinalizeBundleTileAttempt(TileExecution_Executed);
    assert _Tiles[[committed_destination]].allocated;
    assert _TileAllocationMasks[[committed_destination]] == '1111';
    assert TileCapacityInUse() == 2560;
    assert _Tiles[[0]].allocated;
    assert _Tiles[[1]].allocated;

    ResetBundleControlState();
    ClearFault();
    AddBundleTileBinding(TRUE, 0, 0, '1111', FALSE, FALSE, 0, 0, TRUE);
    assert _LastFault == Fault_TileLegality;
end;
func main() => integer
begin
    ResetProfileState();
    TestBundleTileAllocationAndLifetime();
    return 0;
end;
