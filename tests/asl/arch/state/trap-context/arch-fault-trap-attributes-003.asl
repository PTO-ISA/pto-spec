// PTO-TEST: {"id":"PTO-AVS-ARCH-TRAP-ATTRIBUTES-FAULT-003","source":"asl/arch/state/trap-context.asl","requirements":[],"kind":"fault","summary":"trap recovery restores attributes, queues, and predicates","pass_condition":"attribute, queue, and predicate leaves recover exactly","related_sources":[]}
func TestTrapAttributeLeafRecovery()
begin
    ResetProfileState();
    SetCurrentACR(15);
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
    // TRAP_CONTEXT_RECOVER_CALL
    let recovered_all_leaf_context = RecoverTrapContext(1);
    assert recovered_all_leaf_context;
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
end;
func main() => integer
begin
    ResetProfileState();
    TestTrapAttributeLeafRecovery();
    return 0;
end;
