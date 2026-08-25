<!-- GENERATED FROM: asl/block/model/lifecycle/reset.asl -->
# Reset

**Normative ASL source:** `asl/block/model/lifecycle/reset.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-LIFECYCLE-RESET}

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/lifecycle/reset.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-LIFECYCLE-RESET","surface":"block","classification":["model","lifecycle","reset"],"depends_on":["PTO-BLOCK-MODEL-STATE-BINDING-STATE","PTO-BLOCK-MODEL-STATE-SHARED-GENERATION"]}
func ResetBundleControlState()
begin
    _BundleActive = FALSE;
    _BundleBodyActive = FALSE;
    _BundleCommitTargetSet = FALSE;
    _BundleConditionSet = FALSE;
    _SystemBlockTerminalPending = FALSE;
    _BARG.block_type = BundleKind_Standard;
    _BARG.transfer_type = BundleTransfer_Fallthrough;
    _BARG.taken = FALSE;
    _BARG.bpcn = Zeros{PTO_XLEN};
    _BundleSequentialPC = Zeros{PTO_XLEN};
    _FrameStackReturnTarget = Zeros{PTO_XLEN};
    _BundleArgument = Zeros{PTO_XLEN};
    _BundleArgumentKind = Zeros{3};
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
    for index = 0 to PTO_BUNDLE_DIMENSION_COUNT - 1 do
        _BundleDimensions[[index]] = Zeros{PTO_XLEN};
        _BundleDimensionPresent[[index]] = FALSE;
    end;
    for index = 0 to PTO_BUNDLE_SCALAR_BINDING_COUNT - 1 do
        _BundleScalarBindings[[index]].valid = FALSE;
        _BundleScalarBindings[[index]].destination = 0;
        _BundleScalarBindings[[index]].source0 = 0;
        _BundleScalarBindings[[index]].source1 = 0;
        _BundleScalarBindings[[index]].source2 = 0;
        _BundleScalarBindings[[index]].source_count = 0;
    end;
    for index = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        _BundleTileBindings[[index]].valid = FALSE;
        _BundleTileBindings[[index]].destination_valid = FALSE;
        _BundleTileBindings[[index]].destination = 0;
        _BundleTileBindings[[index]].destination_hand = Zeros{2};
        _BundleTileBindings[[index]].destination_allocated_by_bundle = FALSE;
        _BundleTileBindings[[index]].destination_reused_by_generation = FALSE;
        _BundleTileBindings[[index]].destination_size = 0;
        _BundleTileBindings[[index]].pe_mask = Zeros{4};
        _BundleTileBindings[[index]].source0_valid = FALSE;
        _BundleTileBindings[[index]].source1_valid = FALSE;
        _BundleTileBindings[[index]].source0 = 0;
        _BundleTileBindings[[index]].source1 = 0;
        _BundleTileBindings[[index]].last = FALSE;
        _BundleTileBindings[[index]].source0_subview.valid = FALSE;
        _BundleTileBindings[[index]].source0_subview.reg_src = 0;
        _BundleTileBindings[[index]].source0_subview.uimm11 = Zeros{11};
        _BundleTileBindings[[index]].source0_subview.size_code = 0;
        _BundleTileBindings[[index]].source0_subview.offset = Zeros{PTO_XLEN};
        _BundleTileBindings[[index]].source0_subview.init = FALSE;
        _BundleTileBindings[[index]].source0_subview.last = FALSE;
        _BundleTileBindings[[index]].source0_subview.derived.valid = FALSE;
        _BundleTileBindings[[index]].source0_subview.materialized = FALSE;
        _BundleTileBindings[[index]].source0_subview.materialized_index = 0;
        _BundleTileBindings[[index]].source1_subview.valid = FALSE;
        _BundleTileBindings[[index]].source1_subview.reg_src = 0;
        _BundleTileBindings[[index]].source1_subview.uimm11 = Zeros{11};
        _BundleTileBindings[[index]].source1_subview.size_code = 0;
        _BundleTileBindings[[index]].source1_subview.offset = Zeros{PTO_XLEN};
        _BundleTileBindings[[index]].source1_subview.init = FALSE;
        _BundleTileBindings[[index]].source1_subview.last = FALSE;
        _BundleTileBindings[[index]].source1_subview.derived.valid = FALSE;
        _BundleTileBindings[[index]].source1_subview.materialized = FALSE;
        _BundleTileBindings[[index]].source1_subview.materialized_index = 0;
        _BundleTileBindings[[index]].destination_assemble.valid = FALSE;
        _BundleTileBindings[[index]].destination_assemble.reg_src = 0;
        _BundleTileBindings[[index]].destination_assemble.uimm11 = Zeros{11};
        _BundleTileBindings[[index]].destination_assemble.size_code = 0;
        _BundleTileBindings[[index]].destination_assemble.offset = Zeros{PTO_XLEN};
        _BundleTileBindings[[index]].destination_assemble.init = FALSE;
        _BundleTileBindings[[index]].destination_assemble.last = FALSE;
        _BundleTileBindings[[index]].destination_assemble.derived.valid = FALSE;
        _BundleTileBindings[[index]].destination_assemble.materialized = FALSE;
        _BundleTileBindings[[index]].destination_assemble.materialized_index = 0;
    end;
    for index = 0 to 3 do
        _BundleSharedBindings[[index]].valid = FALSE;
        _BundleSharedBindings[[index]].shared_tile_id =
            Zeros{6} as SharedTileID;
        _BundleSharedBindings[[index]].size_code = 0;
        _BundleSharedBindings[[index]].pe_mask = Zeros{4};
        _BundleSharedBindings[[index]].consumed = FALSE;
        _BundleSharedBindings[[index]].source0_subview.valid = FALSE;
        _BundleSharedBindings[[index]].source0_subview.reg_src = 0;
        _BundleSharedBindings[[index]].source0_subview.uimm11 = Zeros{11};
        _BundleSharedBindings[[index]].source0_subview.size_code = 0;
        _BundleSharedBindings[[index]].source0_subview.offset = Zeros{PTO_XLEN};
        _BundleSharedBindings[[index]].source0_subview.init = FALSE;
        _BundleSharedBindings[[index]].source0_subview.last = FALSE;
        _BundleSharedBindings[[index]].source0_subview.derived.valid = FALSE;
        _BundleSharedBindings[[index]].source0_subview.materialized = FALSE;
        _BundleSharedBindings[[index]].source0_subview.materialized_index = 0;
        _BundleSharedBindings[[index]].destination_assemble.valid = FALSE;
        _BundleSharedBindings[[index]].destination_assemble.reg_src = 0;
        _BundleSharedBindings[[index]].destination_assemble.uimm11 = Zeros{11};
        _BundleSharedBindings[[index]].destination_assemble.size_code = 0;
        _BundleSharedBindings[[index]].destination_assemble.offset = Zeros{PTO_XLEN};
        _BundleSharedBindings[[index]].destination_assemble.init = FALSE;
        _BundleSharedBindings[[index]].destination_assemble.last = FALSE;
        _BundleSharedBindings[[index]].destination_assemble.derived.valid = FALSE;
        _BundleSharedBindings[[index]].destination_assemble.materialized = FALSE;
        _BundleSharedBindings[[index]].destination_assemble.materialized_index = 0;
    end;
    _BundleRangeGroup.open = FALSE;
    _BundleRangeGroup.zero_mode = FALSE;
    _BundleRangeGroup.kind = BundleRangeGroup_None;
    _BundleRangeGroup.tile_binding = 0;
    _BundleRangeGroup.shared_binding = 0;
    _BundleRangeGroup.source0_allowed = FALSE;
    _BundleRangeGroup.source1_allowed = FALSE;
    _BundleRangeGroup.destination_allowed = FALSE;
    _BundleRangeGroup.source0_seen = FALSE;
    _BundleRangeGroup.source1_seen = FALSE;
    _BundleRangeGroup.destination_seen = FALSE;
    _BundleZeroParticipationSeen = FALSE;
    for generation = 0 to 63 do
        ClearBundleLocalGenerationState(generation);
    end;
    ResetBundleSharedGenerationState();
    _BundleExecutionDomainToken = 0;
    _NextBundleExecutionDomainToken = 1;
    _BundleControlAttributes.present = FALSE;
    _BundleControlAttributes.trap_enabled = FALSE;
    _BundleControlAttributes.atomic = FALSE;
    _BundleControlAttributes.acquire = FALSE;
    _BundleControlAttributes.release = FALSE;
    _BundleControlAttributes.far = FALSE;
    _BundleControlAttributes.dimension_reduction = FALSE;
    _BundleDataAttributes.data_type_present = FALSE;
    _BundleDataAttributes.data_type = DTYPE_NONE;
    _BundleDataAttributes.data_layout = Zeros{5};
    _BundleDataAttributes.pad_value = '11';
    _BundleDataAttributes.comparison_mode = Zeros{3};
    _BundleDataAttributes.rounding_mode = Zeros{3};
    _BundleDataAttributes.saturating = FALSE;
    _BundleDataAttributes.canonicalize = FALSE;
    _BundleDataAttributesPresent = FALSE;
    _BundleHint.present = FALSE;
    _BundleHint.trace = FALSE;
    _BundleHint.trace_end = FALSE;
    _BundleHint.branch_valid = FALSE;
    _BundleHint.branch_likely = FALSE;
    _BundleHint.temperature = Zeros{2};
    _BundleHint.prefetch_size = Zeros{12};
    _BundleFixedPointAttributes.valid = FALSE;
    _BundleFixedPointAttributes.pre_quant_mode = Zeros{6};
    _BundleFixedPointAttributes.relu_mode = Zeros{3};
    _BundleFixedPointAttributes.group_n_code = Zeros{4};
    _BundleFixedPointAttributes.row_max_en = FALSE;
    _BundleFixedPointAttributes.group_max_en = FALSE;
    _BundleFixedPointAttributes.row_max_init = FALSE;
    _BundleFixedPointAttributes.max_abs_en = FALSE;
    _BundleFixedPointAttributes.trans_a = FALSE;
    _BundleFixedPointAttributes.trans_b = FALSE;
    _BundleFixedPointAttributes.c_scale_en = FALSE;
    _MemoryCopyTemplate.active = FALSE;
    _MemoryCopyTemplate.instruction_pc = Zeros{PTO_XLEN};
    _MemoryCopyTemplate.destination = Zeros{PTO_XLEN};
    _MemoryCopyTemplate.source = Zeros{PTO_XLEN};
    _MemoryCopyTemplate.length = Zeros{PTO_XLEN};
    _MemoryCopyTemplate.progress = Zeros{PTO_XLEN};
    _FrameTemplate.active = FALSE;
    _FrameTemplate.kind = FrameTemplate_Entry;
    _FrameTemplate.instruction_pc = Zeros{PTO_XLEN};
    _FrameTemplate.begin_reg = 2;
    _FrameTemplate.end_reg = 2;
    _FrameTemplate.register_count = 0;
    _FrameTemplate.frame_size = Zeros{PTO_XLEN};
    _FrameTemplate.caller_sp = Zeros{PTO_XLEN};
    _FrameTemplate.stack_adjusted = FALSE;
    _FrameTemplate.progress = 0;
    _FrameTemplate.return_target = Zeros{PTO_XLEN};
    _FrameTemplate.return_target_valid = FALSE;
    for frame_index = 0 to 21 do
        _FrameTemplate.source_values[[frame_index]] = Zeros{PTO_XLEN};
    end;
    _TileDataLayoutCapabilities = Zeros{32};
    _TileDataLayoutCapabilities[0] = '1';
    for ring = 0 to PTO_ACR_COUNT - 1 do
        _TrapContexts[[ring]].valid = FALSE;
        _TrapContexts[[ring]].source_acr = 0;
        _TrapContexts[[ring]].tpc = Zeros{PTO_XLEN};
        _TrapContexts[[ring]].bpc = Zeros{PTO_XLEN};
        _TrapContexts[[ring]].core_state = Zeros{PTO_XLEN};
        _TrapContexts[[ring]].bundle_argument = Zeros{PTO_XLEN};
        _TrapContexts[[ring]].commit_argument = Zeros{PTO_XLEN};
        _TrapContexts[[ring]].bundle_active = FALSE;
        _TrapContexts[[ring]].bundle_body_active = FALSE;
        _TrapContexts[[ring]].bundle_commit_target_set = FALSE;
        _TrapContexts[[ring]].bundle_condition_set = FALSE;
        _TrapContexts[[ring]].system_block_terminal_pending = FALSE;
        _TrapContexts[[ring]].barg = _BARG;
        _TrapContexts[[ring]].bundle_sequential_pc = Zeros{PTO_XLEN};
        _TrapContexts[[ring]].frame_stack_return_target = Zeros{PTO_XLEN};
        _TrapContexts[[ring]].return_address = Zeros{PTO_XLEN};
        _TrapContexts[[ring]].bundle_argument_kind = Zeros{3};
        _TrapContexts[[ring]].bundle_operation = _BundleOperation;
        _TrapContexts[[ring]].bundle_dimensions = _BundleDimensions;
        _TrapContexts[[ring]].bundle_dimension_present =
            _BundleDimensionPresent;
        _TrapContexts[[ring]].bundle_scalar_bindings = _BundleScalarBindings;
        _TrapContexts[[ring]].bundle_tile_bindings = _BundleTileBindings;
        _TrapContexts[[ring]].bundle_shared_bindings = _BundleSharedBindings;
        _TrapContexts[[ring]].bundle_range_group = _BundleRangeGroup;
        _TrapContexts[[ring]].bundle_zero_participation_seen =
            _BundleZeroParticipationSeen;
        _TrapContexts[[ring]].bundle_control_attributes =
            _BundleControlAttributes;
        _TrapContexts[[ring]].bundle_data_attributes = _BundleDataAttributes;
        _TrapContexts[[ring]].bundle_data_attributes_present =
            _BundleDataAttributesPresent;
        _TrapContexts[[ring]].bundle_hint = _BundleHint;
        _TrapContexts[[ring]].bundle_fixed_point_attributes =
            _BundleFixedPointAttributes;
        _TrapContexts[[ring]].local_generations = _LocalGenerations;
        _TrapContexts[[ring]].shared_generations = _SharedGenerations;
        _TrapContexts[[ring]].bundle_execution_domain_token =
            _BundleExecutionDomainToken;
        _TrapContexts[[ring]].memory_copy_template = _MemoryCopyTemplate;
        _TrapContexts[[ring]].frame_template = _FrameTemplate;
        _TrapContexts[[ring]].t_queue = _TQueue;
        _TrapContexts[[ring]].t_queue_valid = _TQueueValid;
        _TrapContexts[[ring]].u_queue = _UQueue;
        _TrapContexts[[ring]].u_queue_valid = _UQueueValid;
        _TrapContexts[[ring]].predicates = _PredicateRegisters;
    end;
    _FrameDepth = 0;
    _LastFrameBegin = 0;
    _LastFrameEnd = 0;
    _LastFrameSize = Zeros{PTO_XLEN};
    _LastQueueLeft = Zeros{PTO_XLEN};
    _LastQueueRight = Zeros{PTO_XLEN};
    _LastQueueFlags = Zeros{4};
    _LastMemoryCommandAddress = Zeros{PTO_XLEN};
    _LastMemoryCommandSize = Zeros{PTO_XLEN};
    _LastCrossBlockACR = Zeros{10};
    _LastCrossBlockID = Zeros{7};
    _LastBundleHintPayload = Zeros{PTO_XLEN};
end;
```
<!-- GENERATED-ASL-END: unit -->
