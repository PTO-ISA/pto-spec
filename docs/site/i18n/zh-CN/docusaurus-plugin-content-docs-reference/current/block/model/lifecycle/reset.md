<!-- GENERATED FROM: asl/block/model/lifecycle/reset.asl -->
# Reset

**Normative ASL source:** `asl/block/model/lifecycle/reset.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-LIFECYCLE-RESET}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-lifecycle-reset-purpose role=purpose-scope -->
## 用途与范围

本单元定义 `ResetBundleControlState`，该转换把指令束控制状态的每个成员置为已知的初始值。它在清除程序计数器和指令束活动标志之后，由配置档复位调用。

<!-- PTO-READER-BLOCK: block-model-lifecycle-reset-concepts role=concepts-state -->
## 概念与可见状态

复位之后：

- 没有活动的指令束，没有活动的主体，所有逐指令束标记均为 false。
- `BARG` 为 `Standard`、`Fallthrough`，`taken` 为 false，`BPCN` 为零。
- 操作描述符无效。每个维度 `LB0..LB2` 都保存默认值 1，并被标记为缺失。
- 所有标量、Tile 和 Shared 绑定、范围组以及属性记录都被清除。数据属性的填充字段保存 `11`（`Null`），数据类型为 `DTYPE_NONE`。
- 全部 64 条 Local 代次记录和每条 Shared 代次记录都被清除。
- 执行域令牌为 0，下一个令牌为 1。
- 内存复制模板和帧模板处于非活动状态，`_FrameDepth` 和最近命令记录为零。
- `_TileDataLayoutCapabilities` 只置位 bit 0，因此只宣告 `NORM` 布局。
- 每个逐 ring 的陷阱上下文都被标记为无效，其指令束字段从刚复位的实时值载入。

<!-- PTO-READER-BLOCK: block-model-lifecycle-reset-rules role=rules-interactions -->
## 规则与交互

复位写入 `PTO-STATE-BLOCK-CONTROL` 的完整成员列表，包括在普通提交后仍保留的代次记录。

设计要点：复位清除的内容多于提交。提交时使用的 `ClearBundleHeaderState` 有意让 Local 和 Shared 代次保持打开，使多指令束组装可以继续。复位是这里唯一关闭全部代次的转换。复位之后，来自先前执行的任何代次都不能再接受写入者。

设计要点：当前令牌为 0 时，下一个执行域令牌从 1 开始。因此复位后的第一个指令束获得令牌 1，与复位值不同。

设计要点：缺省维度复位为 1 而不是 0，填充字段复位为 `Null` 而不是 `Zero`。这些正是每个新指令束看到的缺省默认值。显式的 `B.DIM` 取值 0 或 `B.DATR` 填充码 `00` 仍可与缺省区分。

<!-- PTO-READER-BLOCK: block-model-lifecycle-reset-boundaries role=boundaries -->
## 架构边界

本单元不复位程序计数器。寻址中的配置档复位清除 `_PC`、`_BPC`、`_BundleActive` 和 `_BundleBodyActive`，然后调用本转换，由本转换再次清除这两个活动标志。

Tile 和 Shared 寄存器内容由配置档复位的其他步骤复位，而不是由本转换复位。陷阱上下文被标记为无效，因此复位之后不能恢复到复位前的状态。

<!-- PTO-READER-BLOCK: block-model-lifecycle-reset-example role=example-usage -->
## 非规范阅读示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

复位刚结束时，一个使用 `LB0` 但没有任何 `B.DIM` 的指令束看到的值为 1。如果第一个操作需要 `LB0 = 16`，程序必须用 `B.DIM` 写入它。复位后的第一个 `BSTART` 获得执行域令牌 1，并把下一个令牌推进到 2。

<!-- PTO-READER-BLOCK: block-model-lifecycle-reset-related role=related-owners-navigation -->
## 相关所有者

- [寻址与配置档复位](../../../arch/system-registers/addressing.md)调用本转换。
- [控制状态](../state/control-state.md)列出复位成员。
- [描述符状态](../state/descriptor-state.md)定义范围更小的逐提交清除。
- [Shared 代次状态](../state/shared-generation-state.md)定义 Shared 代次复位。
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
        _BundleDimensions[[index]] = ZeroExtend{PTO_XLEN}('1');
        _BundleDimensionPresent[[index]] = FALSE;
    end;
    for index = 0 to PTO_BUNDLE_SCALAR_BINDING_COUNT - 1 do
        _BundleScalarBindings[[index]].valid = FALSE;
        _BundleScalarBindings[[index]].destination = 0;
        _BundleScalarBindings[[index]].source0 = 0;
        _BundleScalarBindings[[index]].source1 = 0;
        _BundleScalarBindings[[index]].source2 = 0;
        _BundleScalarBindings[[index]].source_count = 0;
        _BundleScalarBindings[[index]].execution_mask_present = FALSE;
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
        _BundleTileBindings[[index]].source0_relative = FALSE;
        _BundleTileBindings[[index]].source1_relative = FALSE;
        _BundleTileBindings[[index]].source0 = 0;
        _BundleTileBindings[[index]].source1 = 0;
        _BundleTileBindings[[index]].parent_ref_valid = FALSE;
        _BundleTileBindings[[index]].parent_ref_relative = FALSE;
        _BundleTileBindings[[index]].parent_ref = 0;
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
    _BundleDataAttributes.execution_mask_invert = FALSE;
    _BundleDataAttributes.execution_mask_zero = FALSE;
    _BundleDataAttributesPresent = FALSE;
    _BundleExecutionMask.valid = FALSE;
    _BundleExecutionMask.carrier = BundleExecutionMask_None;
    _BundleExecutionMask.predicate_tile = 0;
    _BundleExecutionMask.predicate_source_ordinal = 0;
    _BundleExecutionMask.low_word = Zeros{PTO_XLEN};
    _BundleExecutionMask.high_word = Zeros{PTO_XLEN};
    _BundleExecutionMask.word_count = 0;
    _BundleExecutionMask.layout = TileLayout_CUBE_M32;
    _BundleExecutionMask.valid_rows = 0;
    _BundleExecutionMask.valid_columns = 0;
    _BundleExecutionMask.invert = FALSE;
    _BundleExecutionMask.zero_inactive = FALSE;
    _BundleExecutionMask.merge_base_valid = FALSE;
    _BundleExecutionMask.merge_base = 0;
    _BundleExecutionMask.predicate_tile_snapshot = Zeros{524288};
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
