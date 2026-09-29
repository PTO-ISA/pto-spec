<!-- GENERATED FROM: asl/block/model/state/descriptor-state.asl -->
# Descriptor State

**Normative ASL source:** `asl/block/model/state/descriptor-state.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-STATE-DESCRIPTOR-STATE}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-state-descriptor-state-purpose role=purpose-scope -->
## 用途与范围

本单元定义两个转换：安装新指令束的操作描述符，以及清除每指令束的头部状态。

操作描述符记录确切的 `BSTART` 形式及其操作字段。头部状态是头部命令为一个指令束累积的全部内容。

<!-- PTO-READER-BLOCK: block-model-state-descriptor-state-concepts role=concepts-state -->
## 概念与可见状态

一个 `BundleOperationDescriptor` 保存一个有效标志、7 位的形式标识、一个操作类别，以及四个各自带有有效标志的可选字段：10 位的选择子、5 位的数据类型、2 位的模式和 3 位的分支类型。

`ClearBundleHeaderState` 复位描述符、维度、绑定数组、范围组、零参与标记、控制属性、数据属性、提示属性和定点属性、执行掩码绑定、指令束参数，以及三个每指令束标记。

<!-- PTO-READER-BLOCK: block-model-state-descriptor-state-rules role=rules-interactions -->
## 规则与交互

`InstallBundleOperationDescriptor` 保存描述符。如果描述符带有数据类型并且尚未见到 `B.DATR`，它还会把该数据类型复制到数据属性中。

`ClearBundleHeaderState` 把每个维度设为 1 并标记为缺失。它把填充字段设为 `11`，把数据类型设为 `DTYPE_NONE`，并把每个绑定标记为无效。

设计要点：填充字段被清为 `11`（读作 `Null`），而不是 `00`。ASL 注释指出，缺失与显式编码的零填充值不同。没有 `B.DATR` 的指令束让填充保持未定义，而填充码为 `00` 的 `B.DATR` 则请求零。

设计要点：省略的维度被清为 1 而不是 0。从未写入 `LB1` 的指令束在那里读到 1，而显式的 `B.DIM` 取值 0 则以 0 进入操作的合法性检查。

设计要点：只有在 `B.DATR` 缺失时，起始数据类型才会填入数据属性。因此没有 `B.DATR` 的指令束仍然有一个取自其起始形式的数据类型。之后的 `B.DATR` 会用自己的数据类型字段覆盖复制来的值；如果该字段为 `DTYPE_NONE`，有效类型回退为起始数据类型。

<!-- PTO-READER-BLOCK: block-model-state-descriptor-state-boundaries role=boundaries -->
## 架构边界

`ClearBundleHeaderState` 不触碰 `_LocalGenerations`、`_SharedGenerations`、`BARG`、模板和活动标志。开始和停止负责写入活动标志和 `BARG`。代次只通过其自身的路径或复位关闭。

清除并不会把每个字段都置零。例如，标量绑定保留其旧的寄存器选择子，但被标记为无效。

<!-- PTO-READER-BLOCK: block-model-state-descriptor-state-example role=example-usage -->
## 非规范阅读示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

`BSTART.VEC TADD, FP32` 安装一个带有有效选择子和数据类型 `FP32` 的描述符。由于没有 `B.DATR`，`FP32` 被复制到数据属性中，填充值保持为 `Null`。提交时，`ClearBundleHeaderState` 擦除描述符和所有绑定，因此下一个指令束从空状态开始。

<!-- PTO-READER-BLOCK: block-model-state-descriptor-state-related role=related-owners-navigation -->
## 相关所有者

- [指令束开始分派](../dispatch/start.md)调用这两个转换。
- [描述符合法性](../dispatch/descriptor-legality.md)在安装之前验证描述符。
- [进入与停止](../lifecycle/enter-stop.md)在提交时清除头部。
- [控制状态](control-state.md)列出这些成员。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/state/descriptor-state.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-STATE-DESCRIPTOR-STATE","surface":"block","classification":["model","state","descriptor-state"],"depends_on":["PTO-BLOCK-MODEL-STATE-CONTROL-STATE"]}
func InstallBundleOperationDescriptor(descriptor: BundleOperationDescriptor)
begin
    _BundleOperation = descriptor;
    if descriptor.data_type_valid && !_BundleDataAttributesPresent then
        _BundleDataAttributes.data_type = descriptor.data_type;
    end;
end;

func ClearBundleHeaderState()
begin
    _BundleCommitTargetSet = FALSE;
    _BundleConditionSet = FALSE;
    _SystemBlockTerminalPending = FALSE;
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
        _BundleScalarBindings[[index]].source_count = 0;
        _BundleScalarBindings[[index]].execution_mask_present = FALSE;
    end;
    for index = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        _BundleTileBindings[[index]].valid = FALSE;
        _BundleTileBindings[[index]].destination_valid = FALSE;
        _BundleTileBindings[[index]].destination_allocated_by_bundle = FALSE;
        _BundleTileBindings[[index]].destination_reused_by_generation = FALSE;
        _BundleTileBindings[[index]].source0_valid = FALSE;
        _BundleTileBindings[[index]].source1_valid = FALSE;
        _BundleTileBindings[[index]].source0_relative = FALSE;
        _BundleTileBindings[[index]].source1_relative = FALSE;
        _BundleTileBindings[[index]].parent_ref_valid = FALSE;
        _BundleTileBindings[[index]].parent_ref_relative = FALSE;
        _BundleTileBindings[[index]].parent_ref = 0;
        _BundleTileBindings[[index]].last = FALSE;
        _BundleTileBindings[[index]].source0_subview.valid = FALSE;
        _BundleTileBindings[[index]].source0_subview.derived.valid = FALSE;
        _BundleTileBindings[[index]].source0_subview.materialized = FALSE;
        _BundleTileBindings[[index]].source0_subview.materialized_index = 0;
        _BundleTileBindings[[index]].source1_subview.valid = FALSE;
        _BundleTileBindings[[index]].source1_subview.derived.valid = FALSE;
        _BundleTileBindings[[index]].source1_subview.materialized = FALSE;
        _BundleTileBindings[[index]].source1_subview.materialized_index = 0;
        _BundleTileBindings[[index]].destination_assemble.valid = FALSE;
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
        _BundleSharedBindings[[index]].source0_subview.derived.valid = FALSE;
        _BundleSharedBindings[[index]].source0_subview.materialized = FALSE;
        _BundleSharedBindings[[index]].source0_subview.materialized_index = 0;
        _BundleSharedBindings[[index]].destination_assemble.valid = FALSE;
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
    // Absence is distinct from an explicitly encoded zero PadValue.  The
    // operation-visible omission default is Null; B.DATR 00 selects Zero.
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
end;
```
<!-- GENERATED-ASL-END: unit -->
