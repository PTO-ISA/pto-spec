// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-ARCH-TESTTRAPCONTEXTALLLEAFRECOVERYEVIDENCE-FAULT-001","source":"asl/arch/state/trap-context.asl","requirements":[],"kind":"fault","summary":"Covers Trap Context All Leaf Recovery Evidence.","pass_condition":"TestTrapContextAllLeafRecoveryEvidence completes without assertion failure","related_sources":[]}
func TestTrapContextAllLeafRecoveryEvidence()
begin
    ResetProfileState();
    SetCurrentACR(15);
    _SystemRegisters.core_state = Zeros{PTO_XLEN} + 0xabc0;
    SetCurrentACR(15);
    WriteTPC(Zeros{PTO_XLEN} + 0x1200);
    WriteBPC(Zeros{PTO_XLEN} + 0x2200);
    _BundleArgument = Zeros{PTO_XLEN} + 0x3300;
    _CommitArgument = Zeros{PTO_XLEN} + 0x4400;
    _BundleActive = TRUE;
    _BundleBodyActive = TRUE;
    _BARG.block_type = BundleKind_TileMatrix;
    _BARG.transfer_type = BundleTransfer_Conditional;
    _BARG.taken = FALSE;
    _BARG.bpcn = Zeros{PTO_XLEN} + 0x5500;
    _BundleSequentialPC = Zeros{PTO_XLEN} + 0x6600;
    _FrameStackReturnTarget = Zeros{PTO_XLEN} + 0x7700;
    _ReturnAddress = Zeros{PTO_XLEN} + 0x8800;
    _BundleArgumentKind = Zeros{3} + 5;
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
    SetBundleControlAttributeState(TRUE, TRUE, TRUE, FALSE, TRUE, FALSE);
    _BundleDataAttributes.data_type = Zeros{5} + 0x11;
    _BundleDataAttributes.data_layout = Zeros{5};
    _BundleDataAttributes.pad_value = Zeros{2} + 0x2;
    _BundleDataAttributes.comparison_mode = Zeros{3} + 0x3;
    _BundleDataAttributes.rounding_mode = Zeros{3} + 0x4;
    _BundleDataAttributes.saturating = TRUE;
    _BundleDataAttributes.canonicalize = TRUE;
    _BundleFixedPointAttributes.valid = TRUE;
    _BundleFixedPointAttributes.pre_quant_mode = '000011';
    _BundleFixedPointAttributes.relu_mode = '010';
    _BundleFixedPointAttributes.group_n_code = '0001';
    _BundleFixedPointAttributes.row_max_en = TRUE;
    _BundleFixedPointAttributes.group_max_en = TRUE;
    _BundleFixedPointAttributes.row_max_init = TRUE;
    _BundleFixedPointAttributes.max_abs_en = TRUE;
    for index = 0 to PTO_TEMPORARY_QUEUE_DEPTH - 1 do
        _TQueue[[index]] = Zeros{PTO_XLEN} + 0x900 + index;
        _UQueue[[index]] = Zeros{PTO_XLEN} + 0xa00 + index;
    end;
    _PredicateRegisters[[1]] = Zeros{PTO_PREDICATE_WIDTH} + 0x1111;
    _PredicateRegisters[[7]] = Zeros{PTO_PREDICATE_WIDTH} + 0x7777;
    SetFault(Fault_DataPage, Zeros{PTO_XLEN} + 0xdead);
    assert CurrentACR() == 1;
    assert _ACRTrapNumber[[1]] == Zeros{6} + 35;
    assert _ACRTrapArgument0[[1]] == Zeros{PTO_XLEN} + 0xdead;
    // TRAP_CONTEXT_PHASE_SAVE_BEGIN
    assert _TrapContexts[[1]].valid;
    assert _TrapContexts[[1]].source_acr == 15;
    assert _TrapContexts[[1]].tpc == Zeros{PTO_XLEN} + 0x1200;
    assert _TrapContexts[[1]].bpc == Zeros{PTO_XLEN} + 0x2200;
    assert _TrapContexts[[1]].core_state[3:0] == '1111';
    assert _TrapContexts[[1]].bundle_argument ==
        Zeros{PTO_XLEN} + 0x3300;
    assert _TrapContexts[[1]].commit_argument ==
        Zeros{PTO_XLEN} + 0x4400;
    assert _TrapContexts[[1]].bundle_active;
    assert _TrapContexts[[1]].bundle_body_active;
    assert _TrapContexts[[1]].barg.block_type == BundleKind_TileMatrix;
    assert _TrapContexts[[1]].barg.transfer_type ==
        BundleTransfer_Conditional;
    assert !_TrapContexts[[1]].barg.taken;
    assert _TrapContexts[[1]].barg.bpcn ==
        Zeros{PTO_XLEN} + 0x5500;
    assert _TrapContexts[[1]].bundle_sequential_pc ==
        Zeros{PTO_XLEN} + 0x6600;
    assert _TrapContexts[[1]].frame_stack_return_target ==
        Zeros{PTO_XLEN} + 0x7700;
    assert _TrapContexts[[1]].return_address ==
        Zeros{PTO_XLEN} + 0x8800;
    assert _TrapContexts[[1]].bundle_argument_kind == Zeros{3} + 5;
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
    assert _TrapContexts[[1]].bundle_control_attributes.trap_enabled;
    assert _TrapContexts[[1]].bundle_control_attributes.atomic;
    assert _TrapContexts[[1]].bundle_control_attributes.acquire;
    assert !_TrapContexts[[1]].bundle_control_attributes.release;
    assert _TrapContexts[[1]].bundle_control_attributes.far;
    assert _TrapContexts[[1]].bundle_control_attributes.present;
    assert !_TrapContexts[[1]].bundle_control_attributes.dimension_reduction;
    assert _TrapContexts[[1]].bundle_data_attributes.data_type ==
        Zeros{5} + 0x11;
    assert _TrapContexts[[1]].bundle_data_attributes.data_layout == Zeros{5};
    assert _TrapContexts[[1]].bundle_data_attributes.pad_value ==
        Zeros{2} + 0x2;
    assert _TrapContexts[[1]].bundle_data_attributes.comparison_mode ==
        Zeros{3} + 0x3;
    assert _TrapContexts[[1]].bundle_data_attributes.rounding_mode ==
        Zeros{3} + 0x4;
    assert _TrapContexts[[1]].bundle_data_attributes.saturating;
    assert _TrapContexts[[1]].bundle_data_attributes.canonicalize;
    assert _TrapContexts[[1]].bundle_fixed_point_attributes.valid;
    assert _TrapContexts[[1]].bundle_fixed_point_attributes.pre_quant_mode == '000011';
    assert _TrapContexts[[1]].bundle_fixed_point_attributes.relu_mode == '010';
    assert _TrapContexts[[1]].bundle_fixed_point_attributes.group_n_code == '0001';
    assert _TrapContexts[[1]].bundle_fixed_point_attributes.row_max_en;
    assert _TrapContexts[[1]].bundle_fixed_point_attributes.group_max_en;
    assert _TrapContexts[[1]].bundle_fixed_point_attributes.row_max_init;
    assert _TrapContexts[[1]].bundle_fixed_point_attributes.max_abs_en;
    assert _TrapContexts[[1]].t_queue[[0]] == Zeros{PTO_XLEN} + 0x900;
    assert _TrapContexts[[1]].t_queue[[3]] == Zeros{PTO_XLEN} + 0x903;
    assert _TrapContexts[[1]].u_queue[[0]] == Zeros{PTO_XLEN} + 0xa00;
    assert _TrapContexts[[1]].u_queue[[3]] == Zeros{PTO_XLEN} + 0xa03;
    assert _TrapContexts[[1]].predicates[[1]] ==
        Zeros{PTO_PREDICATE_WIDTH} + 0x1111;
    assert _TrapContexts[[1]].predicates[[7]] ==
        Zeros{PTO_PREDICATE_WIDTH} + 0x7777;
    // TRAP_CONTEXT_PHASE_SAVE_END

    // Every live counterpart is changed after the save. Recovery assertions
    // below bind each evidence row to the same location and saved value.
    // TRAP_CONTEXT_PHASE_MUTATE_BEGIN
    SetCurrentACR(0);
    WriteTPC(Zeros{PTO_XLEN});
    WriteBPC(Zeros{PTO_XLEN});
    _SystemRegisters.core_state = Zeros{PTO_XLEN};
    _BundleArgument = Zeros{PTO_XLEN};
    _CommitArgument = Zeros{PTO_XLEN};
    _BundleActive = FALSE;
    _BundleBodyActive = FALSE;
    _BARG.block_type = BundleKind_Standard;
    _BundleArgumentKind = Zeros{3};
    _BARG.transfer_type = BundleTransfer_Fallthrough;
    _BARG.taken = TRUE;
    _BARG.bpcn = Zeros{PTO_XLEN};
    _BundleSequentialPC = Zeros{PTO_XLEN};
    _FrameStackReturnTarget = Zeros{PTO_XLEN};
    _ReturnAddress = Zeros{PTO_XLEN};
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
    _BundleControlAttributes.trap_enabled = FALSE;
    _BundleControlAttributes.atomic = FALSE;
    _BundleControlAttributes.acquire = FALSE;
    _BundleControlAttributes.release = TRUE;
    _BundleControlAttributes.far = FALSE;
    _BundleControlAttributes.present = TRUE;
    _BundleControlAttributes.dimension_reduction = TRUE;
    _BundleDataAttributes.data_type = Zeros{5};
    _BundleDataAttributes.data_layout = Zeros{5} + 1;
    _BundleDataAttributes.pad_value = Zeros{2};
    _BundleDataAttributes.comparison_mode = Zeros{3};
    _BundleDataAttributes.rounding_mode = Zeros{3};
    _BundleDataAttributes.saturating = FALSE;
    _BundleDataAttributes.canonicalize = FALSE;
    _BundleFixedPointAttributes.valid = FALSE;
    _BundleFixedPointAttributes.pre_quant_mode = Zeros{6};
    _BundleFixedPointAttributes.relu_mode = Zeros{3};
    _BundleFixedPointAttributes.group_n_code = Zeros{4};
    _BundleFixedPointAttributes.row_max_en = FALSE;
    _BundleFixedPointAttributes.group_max_en = FALSE;
    _BundleFixedPointAttributes.row_max_init = FALSE;
    _BundleFixedPointAttributes.max_abs_en = FALSE;
    _TQueue[[3]] = Zeros{PTO_XLEN};
    _UQueue[[3]] = Zeros{PTO_XLEN};
    _PredicateRegisters[[7]] = Zeros{PTO_PREDICATE_WIDTH};
    // Each row proves that its live counterpart no longer has the saved value.
    // The evidence checker derives these assertions from the recovery ledger.
    assert CurrentACR() != 15;
    assert ReadTPC() != Zeros{PTO_XLEN} + 0x1200;
    assert ReadBPC() != Zeros{PTO_XLEN} + 0x2200;
    assert _SystemRegisters.core_state[3:0] != '1111';
    assert _BundleArgument != Zeros{PTO_XLEN} + 0x3300;
    assert _CommitArgument != Zeros{PTO_XLEN} + 0x4400;
    assert !_BundleActive;
    assert !_BundleBodyActive;
    assert _BARG.block_type != BundleKind_TileMatrix;
    assert _BARG.transfer_type != BundleTransfer_Conditional;
    assert _BARG.taken;
    assert _BARG.bpcn != Zeros{PTO_XLEN} + 0x5500;
    assert _BundleSequentialPC != Zeros{PTO_XLEN} + 0x6600;
    assert _FrameStackReturnTarget != Zeros{PTO_XLEN} + 0x7700;
    assert _ReturnAddress != Zeros{PTO_XLEN} + 0x8800;
    assert _BundleArgumentKind != Zeros{3} + 5;
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
    assert !_BundleControlAttributes.trap_enabled;
    assert !_BundleControlAttributes.atomic;
    assert !_BundleControlAttributes.acquire;
    assert _BundleControlAttributes.release;
    assert !_BundleControlAttributes.far;
    assert _BundleControlAttributes.present;
    assert _BundleControlAttributes.dimension_reduction;
    assert _BundleDataAttributes.data_type != Zeros{5} + 0x11;
    assert _BundleDataAttributes.data_layout != Zeros{5};
    assert _BundleDataAttributes.pad_value != Zeros{2} + 0x2;
    assert _BundleDataAttributes.comparison_mode != Zeros{3} + 0x3;
    assert _BundleDataAttributes.rounding_mode != Zeros{3} + 0x4;
    assert !_BundleDataAttributes.saturating;
    assert !_BundleDataAttributes.canonicalize;
    assert _TQueue[[3]] != Zeros{PTO_XLEN} + 0x903;
    assert _UQueue[[3]] != Zeros{PTO_XLEN} + 0xa03;
    assert _PredicateRegisters[[7]] !=
        Zeros{PTO_PREDICATE_WIDTH} + 0x7777;
    // TRAP_CONTEXT_PHASE_MUTATE_END

    // TRAP_CONTEXT_RECOVER_CALL
    let recovered_all_leaf_context = RecoverTrapContext(1);
    assert recovered_all_leaf_context;
    // TRAP_CONTEXT_PHASE_RECOVER_BEGIN
    assert CurrentACR() == 15;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x1200;
    assert ReadBPC() == Zeros{PTO_XLEN} + 0x2200;
    assert _SystemRegisters.core_state[3:0] == '1111';
    assert _BundleArgument == Zeros{PTO_XLEN} + 0x3300;
    assert _CommitArgument == Zeros{PTO_XLEN} + 0x4400;
    assert _BundleActive;
    assert _BundleBodyActive;
    assert _BARG.block_type == BundleKind_TileMatrix;
    assert _BARG.transfer_type == BundleTransfer_Conditional;
    assert !_BARG.taken;
    assert _BARG.bpcn == Zeros{PTO_XLEN} + 0x5500;
    assert _BundleSequentialPC == Zeros{PTO_XLEN} + 0x6600;
    assert _FrameStackReturnTarget == Zeros{PTO_XLEN} + 0x7700;
    assert _ReturnAddress == Zeros{PTO_XLEN} + 0x8800;
    assert _BundleArgumentKind == Zeros{3} + 5;
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
    assert _BundleControlAttributes.trap_enabled;
    assert _BundleControlAttributes.atomic;
    assert _BundleControlAttributes.acquire;
    assert !_BundleControlAttributes.release;
    assert _BundleControlAttributes.far;
    assert _BundleControlAttributes.present;
    assert !_BundleControlAttributes.dimension_reduction;
    assert _BundleDataAttributes.data_type == Zeros{5} + 0x11;
    assert _BundleDataAttributes.data_layout == Zeros{5};
    assert _BundleDataAttributes.pad_value == Zeros{2} + 0x2;
    assert _BundleDataAttributes.comparison_mode == Zeros{3} + 0x3;
    assert _BundleDataAttributes.rounding_mode == Zeros{3} + 0x4;
    assert _BundleDataAttributes.saturating;
    assert _BundleDataAttributes.canonicalize;
    assert _BundleFixedPointAttributes.valid;
    assert _BundleFixedPointAttributes.pre_quant_mode == '000011';
    assert _BundleFixedPointAttributes.relu_mode == '010';
    assert _BundleFixedPointAttributes.group_n_code == '0001';
    assert _BundleFixedPointAttributes.row_max_en;
    assert _BundleFixedPointAttributes.group_max_en;
    assert _BundleFixedPointAttributes.row_max_init;
    assert _BundleFixedPointAttributes.max_abs_en;
    assert _TQueue[[3]] == Zeros{PTO_XLEN} + 0x903;
    assert _UQueue[[3]] == Zeros{PTO_XLEN} + 0xa03;
    assert _PredicateRegisters[[1]] ==
        Zeros{PTO_PREDICATE_WIDTH} + 0x1111;
    assert _PredicateRegisters[[7]] ==
        Zeros{PTO_PREDICATE_WIDTH} + 0x7777;
    // TRAP_CONTEXT_PHASE_RECOVER_END
    // TRAP_CONTEXT_PHASE_INVALIDATE_BEGIN
    assert !_TrapContexts[[1]].valid;
    // TRAP_CONTEXT_PHASE_INVALIDATE_END

    // Execute the portable default helper directly even under the PTO v0
    // profile, so the concrete override cannot hide default-path drift.
    ResetProfileState();
    SetCurrentACR(15);
    _BundleArgument = Zeros{PTO_XLEN} + 0x1110;
    _CommitArgument = Zeros{PTO_XLEN} + 0x2220;
    _FrameStackReturnTarget = Zeros{PTO_XLEN} + 0x3330;
    _ReturnAddress = Zeros{PTO_XLEN} + 0x4440;
    _BundleArgumentKind = Zeros{3} + 6;
    SavePortableTrapContext(2, 15);
    _BundleArgument = Zeros{PTO_XLEN};
    _CommitArgument = Zeros{PTO_XLEN};
    _FrameStackReturnTarget = Zeros{PTO_XLEN};
    _ReturnAddress = Zeros{PTO_XLEN};
    _BundleArgumentKind = Zeros{3};
    let recovered_portable_context = RecoverPortableTrapContext(2);
    assert recovered_portable_context;
    assert _BundleArgument == Zeros{PTO_XLEN} + 0x1110;
    assert _CommitArgument == Zeros{PTO_XLEN} + 0x2220;
    assert _FrameStackReturnTarget == Zeros{PTO_XLEN} + 0x3330;
    assert _ReturnAddress == Zeros{PTO_XLEN} + 0x4440;
    assert _BundleArgumentKind == Zeros{3} + 6;

    ResetProfileState();
end;
func main() => integer
begin
    ResetProfileState();
    TestTrapContextAllLeafRecoveryEvidence();
    return 0;
end;
