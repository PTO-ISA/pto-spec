// PTO-TEST: {"id":"PTO-AVS-ARCH-TRAP-BINDINGS-FAULT-002","source":"asl/arch/state/trap-context.asl","requirements":[],"kind":"fault","summary":"trap recovery restores operation descriptors and operand bindings","pass_condition":"descriptor, dimension, scalar, Tile, and shared bindings recover exactly","related_sources":[]}
func TestTrapBindingLeafRecovery()
begin
    ResetProfileState();
    SetCurrentACR(15);
    _BundleActive = TRUE;
    _BundleBodyActive = TRUE;
    InstallBundleOperationDescriptor(BundleOperationDescriptor {
        valid = TRUE,
        form_identity = Zeros{7} + 0x45,
        operation_class = BundleOperation_TileMatrix,
        selector_valid = TRUE,
        selector = Zeros{10} + 0x155,
        data_type_valid = TRUE,
        data_type = Zeros{5} + 0x11,
        mode_valid = TRUE,
        mode = Zeros{2} + 0x2,
        branch_type_valid = TRUE,
        branch_type = Zeros{3} + 0x5
    });
    SetBundleDimension(0, Zeros{PTO_XLEN} + 0x101);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 0x102);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 0x103);
    SetBundleScalarBinding(0, 31, 24, 25, 26, 3);
    SetBundleScalarBinding(31, 23, 1, 2, 3, 2);
    SetBundleTileBinding(0, TRUE, 2, 7, '1111', TRUE, TRUE, 40, 41,
        FALSE);
    SetBundleTileBinding(15, TRUE, 3, 7, '1111', TRUE, FALSE, 63, 0,
        TRUE);
    BindBundleSharedIO(Zeros{8} + 0x12, 0, '1111');
    BindBundleSharedIO(Zeros{8} + 0x34, 7, '1111');
    _BundleSharedBindings[[0]].consumed = TRUE;
    assert _BundleSharedBindings[[0]].valid;
    assert _BundleSharedBindings[[0]].shared_id == Zeros{8} + 0x12;
    assert _BundleSharedBindings[[0]].size_code == 0;
    assert _BundleSharedBindings[[0]].pe_mask == '1111';
    assert _BundleSharedBindings[[0]].consumed;
    SetFault(Fault_DataPage, Zeros{PTO_XLEN} + 0xdead);
    assert CurrentACR() == 1;
    assert _ACRTrapNumber[[1]] == Zeros{6} + 35;
    assert _ACRTrapArgument0[[1]] == Zeros{PTO_XLEN} + 0xdead;
    assert _TrapContexts[[1]].bundle_operation.valid;
    assert _TrapContexts[[1]].bundle_operation.form_identity ==
        Zeros{7} + 0x45;
    assert _TrapContexts[[1]].bundle_operation.operation_class ==
        BundleOperation_TileMatrix;
    assert _TrapContexts[[1]].bundle_operation.selector_valid;
    assert _TrapContexts[[1]].bundle_operation.selector == Zeros{10} + 0x155;
    assert _TrapContexts[[1]].bundle_operation.data_type_valid;
    assert _TrapContexts[[1]].bundle_operation.data_type == Zeros{5} + 0x11;
    assert _TrapContexts[[1]].bundle_operation.mode_valid;
    assert _TrapContexts[[1]].bundle_operation.mode == Zeros{2} + 0x2;
    assert _TrapContexts[[1]].bundle_operation.branch_type_valid;
    assert _TrapContexts[[1]].bundle_operation.branch_type == Zeros{3} + 0x5;
    assert _TrapContexts[[1]].bundle_dimensions[[0]] ==
        Zeros{PTO_XLEN} + 0x101;
    assert _TrapContexts[[1]].bundle_dimensions[[2]] ==
        Zeros{PTO_XLEN} + 0x103;
    assert _TrapContexts[[1]].bundle_scalar_bindings[[0]].valid;
    assert _TrapContexts[[1]].bundle_scalar_bindings[[0]].destination == 31;
    assert _TrapContexts[[1]].bundle_scalar_bindings[[0]].source0 == 24;
    assert _TrapContexts[[1]].bundle_scalar_bindings[[0]].source1 == 25;
    assert _TrapContexts[[1]].bundle_scalar_bindings[[0]].source2 == 26;
    assert _TrapContexts[[1]].bundle_scalar_bindings[[0]].source_count == 3;
    assert _TrapContexts[[1]].bundle_scalar_bindings[[31]].valid;
    assert _TrapContexts[[1]].bundle_tile_bindings[[0]].valid;
    assert _TrapContexts[[1]].bundle_tile_bindings[[0]].destination_valid;
    assert _TrapContexts[[1]].bundle_tile_bindings[[0]].destination == 2;
    assert _TrapContexts[[1]].bundle_tile_bindings[[0]].destination_hand ==
        Zeros{2} + 2;
    assert !_TrapContexts[[1]].bundle_tile_bindings[[0]].destination_allocated_by_bundle;
    assert _TrapContexts[[1]].bundle_tile_bindings[[0]].destination_size == 7;
    assert _TrapContexts[[1]].bundle_tile_bindings[[0]].pe_mask == '1111';
    assert _TrapContexts[[1]].bundle_tile_bindings[[0]].source0_valid;
    assert _TrapContexts[[1]].bundle_tile_bindings[[0]].source1_valid;
    assert _TrapContexts[[1]].bundle_tile_bindings[[0]].source0 == 40;
    assert _TrapContexts[[1]].bundle_tile_bindings[[0]].source1 == 41;
    assert !_TrapContexts[[1]].bundle_tile_bindings[[0]].last;
    assert _TrapContexts[[1]].bundle_tile_bindings[[15]].valid;
    assert _TrapContexts[[1]].bundle_shared_bindings[[0]].valid;
    assert _TrapContexts[[1]].bundle_shared_bindings[[0]].shared_id ==
        Zeros{8} + 0x12;
    assert _TrapContexts[[1]].bundle_shared_bindings[[0]].size_code == 0;
    assert _TrapContexts[[1]].bundle_shared_bindings[[0]].pe_mask == '1111';
    assert _TrapContexts[[1]].bundle_shared_bindings[[0]].consumed;
    _BundleOperation.valid = FALSE;
    _BundleOperation.form_identity = Zeros{7};
    _BundleOperation.operation_class = BundleOperation_Control;
    _BundleOperation.selector_valid = FALSE;
    _BundleOperation.selector = Zeros{10};
    _BundleOperation.data_type_valid = FALSE;
    _BundleOperation.data_type = Zeros{5};
    _BundleOperation.mode_valid = FALSE;
    _BundleOperation.mode = Zeros{2};
    _BundleOperation.branch_type_valid = FALSE;
    _BundleOperation.branch_type = Zeros{3};
    _BundleDimensions[[2]] = Zeros{PTO_XLEN};
    _BundleScalarBindings[[0]].valid = FALSE;
    _BundleScalarBindings[[0]].destination = 0;
    _BundleScalarBindings[[0]].source0 = 0;
    _BundleScalarBindings[[0]].source1 = 0;
    _BundleScalarBindings[[0]].source2 = 0;
    _BundleScalarBindings[[0]].source_count = 0;
    _BundleTileBindings[[0]].valid = FALSE;
    _BundleTileBindings[[0]].destination_valid = FALSE;
    _BundleTileBindings[[0]].destination = 0;
    _BundleTileBindings[[0]].destination_hand = Zeros{2};
    _BundleTileBindings[[0]].destination_allocated_by_bundle = TRUE;
    _BundleTileBindings[[0]].destination_size = 0;
    _BundleTileBindings[[0]].pe_mask = Zeros{4};
    _BundleTileBindings[[0]].source0_valid = FALSE;
    _BundleTileBindings[[0]].source1_valid = FALSE;
    _BundleTileBindings[[0]].source0 = 0;
    _BundleTileBindings[[0]].source1 = 0;
    _BundleTileBindings[[0]].last = TRUE;
    _BundleSharedBindings[[0]].valid = FALSE;
    _BundleSharedBindings[[0]].shared_id = Zeros{8};
    _BundleSharedBindings[[0]].size_code = 3;
    _BundleSharedBindings[[0]].pe_mask = '0101';
    _BundleSharedBindings[[0]].consumed = FALSE;
    assert !_BundleOperation.valid;
    assert _BundleOperation.form_identity != Zeros{7} + 0x45;
    assert _BundleOperation.operation_class != BundleOperation_TileMatrix;
    assert !_BundleOperation.selector_valid;
    assert _BundleOperation.selector != Zeros{10} + 0x155;
    assert !_BundleOperation.data_type_valid;
    assert _BundleOperation.data_type != Zeros{5} + 0x11;
    assert !_BundleOperation.mode_valid;
    assert _BundleOperation.mode != Zeros{2} + 0x2;
    assert !_BundleOperation.branch_type_valid;
    assert _BundleOperation.branch_type != Zeros{3} + 0x5;
    assert _BundleDimensions[[2]] != Zeros{PTO_XLEN} + 0x103;
    assert !_BundleScalarBindings[[0]].valid;
    assert _BundleScalarBindings[[0]].destination != 31;
    assert _BundleScalarBindings[[0]].source0 != 24;
    assert _BundleScalarBindings[[0]].source1 != 25;
    assert _BundleScalarBindings[[0]].source2 != 26;
    assert _BundleScalarBindings[[0]].source_count != 3;
    assert !_BundleTileBindings[[0]].valid;
    assert !_BundleTileBindings[[0]].destination_valid;
    assert _BundleTileBindings[[0]].destination != 2;
    assert _BundleTileBindings[[0]].destination_hand != Zeros{2} + 2;
    assert _BundleTileBindings[[0]].destination_allocated_by_bundle;
    assert _BundleTileBindings[[0]].destination_size != 7;
    assert _BundleTileBindings[[0]].pe_mask != '1111';
    assert !_BundleTileBindings[[0]].source0_valid;
    assert !_BundleTileBindings[[0]].source1_valid;
    assert _BundleTileBindings[[0]].source0 != 40;
    assert _BundleTileBindings[[0]].source1 != 41;
    assert _BundleTileBindings[[0]].last;
    assert !_BundleSharedBindings[[0]].valid;
    assert _BundleSharedBindings[[0]].shared_id != Zeros{8} + 0x12;
    assert _BundleSharedBindings[[0]].size_code != 0;
    assert _BundleSharedBindings[[0]].pe_mask != '1111';
    assert !_BundleSharedBindings[[0]].consumed;
    // TRAP_CONTEXT_RECOVER_CALL
    let recovered_all_leaf_context = RecoverTrapContext(1);
    assert recovered_all_leaf_context;
    assert _BundleOperation.valid;
    assert _BundleOperation.form_identity == Zeros{7} + 0x45;
    assert _BundleOperation.operation_class == BundleOperation_TileMatrix;
    assert _BundleOperation.selector_valid;
    assert _BundleOperation.selector == Zeros{10} + 0x155;
    assert _BundleOperation.data_type_valid;
    assert _BundleOperation.data_type == Zeros{5} + 0x11;
    assert _BundleOperation.mode_valid;
    assert _BundleOperation.mode == Zeros{2} + 0x2;
    assert _BundleOperation.branch_type_valid;
    assert _BundleOperation.branch_type == Zeros{3} + 0x5;
    assert _BundleDimensions[[2]] == Zeros{PTO_XLEN} + 0x103;
    assert _BundleScalarBindings[[0]].valid;
    assert _BundleScalarBindings[[0]].destination == 31;
    assert _BundleScalarBindings[[0]].source0 == 24;
    assert _BundleScalarBindings[[0]].source1 == 25;
    assert _BundleScalarBindings[[0]].source2 == 26;
    assert _BundleScalarBindings[[0]].source_count == 3;
    assert _BundleTileBindings[[0]].valid;
    assert _BundleTileBindings[[0]].destination_valid;
    assert _BundleTileBindings[[0]].destination == 2;
    assert _BundleTileBindings[[0]].destination_hand == Zeros{2} + 2;
    assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;
    assert _BundleTileBindings[[0]].destination_size == 7;
    assert _BundleTileBindings[[0]].pe_mask == '1111';
    assert _BundleTileBindings[[0]].source0_valid;
    assert _BundleTileBindings[[0]].source1_valid;
    assert _BundleTileBindings[[0]].source0 == 40;
    assert _BundleTileBindings[[0]].source1 == 41;
    assert !_BundleTileBindings[[0]].last;
    assert _BundleSharedBindings[[0]].valid;
    assert _BundleSharedBindings[[0]].shared_id == Zeros{8} + 0x12;
    assert _BundleSharedBindings[[0]].size_code == 0;
    assert _BundleSharedBindings[[0]].pe_mask == '1111';
    assert _BundleSharedBindings[[0]].consumed;
    // TRAP_CONTEXT_PHASE_INVALIDATE_BEGIN
    assert !_TrapContexts[[1]].valid;
    // TRAP_CONTEXT_PHASE_INVALIDATE_END
end;
func main() => integer
begin
    ResetProfileState();
    TestTrapBindingLeafRecovery();
    return 0;
end;
