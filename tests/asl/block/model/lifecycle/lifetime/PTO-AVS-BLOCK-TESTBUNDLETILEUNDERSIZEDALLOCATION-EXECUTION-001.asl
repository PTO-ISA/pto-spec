// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-BLOCK-TESTBUNDLETILEUNDERSIZEDALLOCATION-EXECUTION-001","source":"asl/block/model/lifecycle/lifetime.asl","requirements":[],"kind":"execution","summary":"migrated independent behavior point for TestBundleTileUndersizedAllocation","pass_condition":"TestBundleTileUndersizedAllocation completes without assertion failure","related_sources":[]}
func TestBundleTileUndersizedAllocation()
begin
    ResetProfileState();
    ConfigureTile(16, 1024, 128, 1, 128, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    for row = 0 to 127 do
        WriteTileElement(16, row as integer {0..65535}, 0,
            Zeros{PTO_XLEN} + row);
    end;
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
    AddBundleTileBinding(TRUE, 0, 1, '1111', TRUE, FALSE, 16, 0, TRUE);
    ClearFault();
    let undersized_resolved = ResolveBundleTileDestinations();
    assert !undersized_resolved;
    assert _LastFault == Fault_TileAllocation;
    assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;
    assert _Tiles[[16]].allocated;
    assert ReadTileElement(16, 127, 0) == Zeros{PTO_XLEN} + 127;
    for candidate = 0 to 15 do
        assert !_Tiles[[candidate]].allocated;
    end;

    // A non-power-of-two physical Col rejects before Local destination
    // allocation. LB0/LB1 remain the valid columns/rows; LB2 is physical Col.
    ResetProfileState();
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
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 3);
    AddBundleTileBinding(TRUE, 0, 1, '1111', TRUE, FALSE, 0, 0, TRUE);
    ClearFault();
    let non_power_columns_resolved = ResolveBundleTileDestinations();
    assert !non_power_columns_resolved;
    assert _LastFault == Fault_TileAllocation;
    assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;
    for candidate = 0 to 15 do
        assert !_Tiles[[candidate]].allocated;
    end;
end;
func main() => integer
begin
    ResetProfileState();
    TestBundleTileUndersizedAllocation();
    return 0;
end;
