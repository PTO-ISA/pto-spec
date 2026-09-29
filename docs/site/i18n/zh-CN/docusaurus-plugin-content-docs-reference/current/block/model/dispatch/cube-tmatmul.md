<!-- GENERATED FROM: asl/block/model/dispatch/cube-tmatmul.asl -->
# CUBE Tmatmul

**Normative ASL source:** `asl/block/model/dispatch/cube-tmatmul.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-CUBE-TMATMUL}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-dispatch-cube-tmatmul-purpose role=purpose-scope -->
## 用途与范围

本单元是 CUBE 矩阵族的指令束处理程序：`TMATMUL`、`TGEMV` 及其 `_ACC`、`_BIAS` 和 `MX` 形式。`ExecuteBundleTMATMULOperation` 验证完整的指令束，分配目标组，读取操作数，并运行矩阵操作。

当 `BundleCubeMatrixSelected` 成立时，Tile 执行分派在指令束提交时调用它：已安装的描述符属于 Tile 矩阵类，且其有效选择子的低 5 位指定一个已指派的矩阵功能。

<!-- PTO-READER-BLOCK: block-model-dispatch-cube-tmatmul-concepts role=concepts-state -->
## 概念与可见状态

- `LB0`、`LB1` 和 `LB2` 携带 M、N 和 K。
- 左类型来自 `BSTART` 的数据类型。存在 `B.DATR` 时右类型取自 `B.DATR`，否则等于左类型。
- `CCTRL` 是 2 位的 `B.DATR` 填充字段，没有 `B.DATR` 时读作零。位 0 选择累加器类型的原始输出。位 1 是累加器预取提示。
- 协作指令束是至少有一个 Shared 源的非 GEMV 矩阵指令束。此时 `LB0` 保存 Core 总的组 M，取值 1 到 128。组 M 不超过 64 时每个 PE 取 16 行，否则取 32 行；PE `i` 从第 `i` 乘以该行数的行开始，最多拥有该行数的行，并在组 M 处截止。

<!-- PTO-READER-BLOCK: block-model-dispatch-cube-tmatmul-rules role=rules-interactions -->
## 规则与交互

处理程序按以下顺序执行各阶段。

1. 若 PE 掩码没有选择任何 PE，它返回成功且没有任何效果。
2. 它要求存在 `B.FPATR`，否则引发 `Fault_BundleControl`；并要求可解码的 CUBE 操作，否则引发 `Fault_IllegalInstruction`。
3. 它检查指令束结构。类型对、源与目标数量、`B.DATR` 字段、`CCTRL` 用法、维度和 PE 掩码都必须合法。所有掩码必须一致，协作指令束需要掩码 `1111`。GEMV 功能要求 M 等于 1。失败时引发 `Fault_TileLegality`。
4. 它在不故障的情况下等待每个 Shared 源都已发布，然后检查 Shared schema。
5. 行数为零的协作 PE 消费其 Shared 绑定并返回成功。
6. 否则它解析相对源和 subview，并检查 Local 源、CScale、累加器与 CScale 的别名、结果布局以及后处理源。
7. 它分配目标组，对操作数做快照，并运行操作。若此后故障，则回滚目标。

MX 功能的结果类型为 `FP32`。否则，左类型为有符号、无符号或其他类型时，结果类型分别为 `S32`、`U32` 或 `FP32`。`CCTRL` 位 1 只对累加器功能合法。位 0 要求 `pre_quant_mode`、`relu_mode` 和 `group_n_code` 为零，且 `row_max_en`、`group_max_en` 和 `max_abs_en` 为 false。

设计要点：行数为零的 PE 保留阶段 1 到 4 的组级检查，但跳过全部 Local 工作。NDF 条款要求这样做，ASL 注释也说明只有在组级和 Shared 预检推导出非零片段之后才开始 Local 准备。因此没有行的 PE 仍会因组级和 Shared 错误而故障，但不改变任何 Local Tile。

设计要点：如 ASL 注释所述，分配发生在所有规则都已关闭之后、第一次操作数快照之前。因此合法性故障不会留下已分配的目标。

设计要点：位 1 的预取提示以及伴随位 0 的替换提示调用在可移植模型中不做任何事的实现定义钩子；这些钩子不改变发布的结果，位 0 只通过选择累加器类型的原始输出来改变结果。

<!-- PTO-READER-BLOCK: block-model-dispatch-cube-tmatmul-boundaries role=boundaries -->
## 架构边界

本单元不计算矩阵乘积；这由 `TMATMULShared` 和 `TMATMULMXSharedWithOptionalScales` 完成。目标布局与分配属于 CUBE 目标单元，Shared 操作数 schema属于共享 CUBE 矩阵单元。成功之后，分派提交 Local generation 并退役消费者依赖，但行数为零的协作 PE 除外。

<!-- PTO-READER-BLOCK: block-model-dispatch-cube-tmatmul-example role=example-usage -->
## 非规范阅读示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

```text
TMATMUL_ACC <M=16, N=16, K=16, FP16>, T#1, T#2, T#3, ->T<1KB>
```

所有源都是 Local，因此该指令束不是协作的。源序号 0 是累加器 `T#1`，序号 1 是左矩阵 `T#2`，序号 2 是右矩阵 `T#3`。左类型为 `FP16`，没有 `B.DATR` 时右类型也是 `FP16`，因此结果类型为 `FP32`。

现在假设一个协作 `TMATMUL`，其右组来自 Shared，组 M 为 40。每个 PE 取 16 行。PE0 拥有 16 行，PE1 拥有 16 行，PE2 拥有 8 行，PE3 拥有 0 行。PE3 通过阶段 1 到 4，然后在阶段 5 停止。

<!-- PTO-READER-BLOCK: block-model-dispatch-cube-tmatmul-related role=related-owners-navigation -->
## 相关所有者

- [Tile 执行分派](tile-execution.md) 选择该处理程序并在其后提交。
- [CUBE 目标](cube-destination.md) 解析并分配目标组。
- [共享 CUBE 矩阵](shared-cube-matrix.md) 拥有协作行分配与 Shared schema。
- [CUBE 累加器路由](cube-accumulator-routing.md) 拥有 `CCTRL` 规则。
- [TMATMUL_ACC](../../../tile/matrix-and-matrix-vector/matrix-matrix/TMATMUL_ACC.md) 是累加指令页面。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/cube-tmatmul.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-CUBE-TMATMUL","surface":"block","classification":["model","dispatch","cube-tmatmul"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-CUBE-DESTINATION","PTO-BLOCK-MODEL-DISPATCH-MATRIX-SCALE","PTO-BLOCK-MODEL-DISPATCH-SHARED-CUBE-MATRIX","PTO-BLOCK-MODEL-FAULTS-ROLLBACK","PTO-TILE-MODEL-LEGALITY-MATRIX-OPERANDS","PTO-TILE-MODEL-EXECUTION-CUBE","PTO-TILE-MODEL-EXECUTION-INTERNAL-ACCUMULATOR"]}
// NDF-BEGIN: PTO-CUBE-ACCUMULATOR-OUTPUT-001
// ndf: kind=contract level=L1 layer=block status=accepted
// Every Matrix ACC form MUST bind explicit C and D. C's encoded relative
// selector MUST differ from zero-extended DstTile before any effects, and
// direct Tile calls MUST use different C/D TileIndex values. C MUST remain the
// architectural accumulator input and MUST persist while D, reductions, and
// numeric status publish atomically. CCTRL[1] MAY hint transparent cache use or
// prefetch of C. CCTRL[0] selects raw accumulator-type D output and MAY hint
// transparent cache replacement with the identical published D value.
// NDF-END: PTO-CUBE-ACCUMULATOR-OUTPUT-001
// NDF-BEGIN: PTO-CUBE-GROUP-M-DISTRIBUTION-001
// ndf: kind=contract level=L1 layer=block status=accepted
// Every cooperative Local-A/Shared-B or Shared-A/Shared-B TMATMUL form MUST
// interpret LB0 as Core-total group_M in 1..128 and MUST use PE_MASK=1111.
// group_M<=64 selects M_per_PE=16; group_M>=65 selects M_per_PE=32; PE i owns
// valid_M=clamp(group_M-i*M_per_PE,0,M_per_PE). A zero-row PE MUST retain
// structural, collective, and Shared preflight while suppressing all
// compute-only Local resolution, dependency, subview, alias, allocation,
// generation, payload, parameter, and output effects. TGEMV remains Local-only.
// NDF-END: PTO-CUBE-GROUP-M-DISTRIBUTION-001
readonly func BundleCubeMatrixSelected() => boolean
begin
    return _BundleOperation.valid &&
           _BundleOperation.operation_class == BundleOperation_TileMatrix &&
           _BundleOperation.selector_valid &&
           TileMatrixFunctionAssigned(
               UInt(_BundleOperation.selector[4:0]));
end;
readonly func BundleTMATMULDataAttributesLegal() => boolean
begin
    if !_BundleDataAttributesPresent then return TRUE; end;
    return _BundleDataAttributes.data_layout == Zeros{5} &&
           _BundleDataAttributes.comparison_mode == Zeros{3} &&
           !_BundleDataAttributes.canonicalize;
end;
readonly func BundleTMATMULMasksAgree() => boolean
begin
    var seen = FALSE;
    var selected = Zeros{4};
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if _BundleTileBindings[[binding]].valid then
            let mask = _BundleTileBindings[[binding]].pe_mask;
            if seen && mask != selected then return FALSE; end;
            selected = mask;
            seen = TRUE;
        end;
    end;
    for binding = 0 to 3 do
        if _BundleSharedBindings[[binding]].valid then
            let mask = _BundleSharedBindings[[binding]].pe_mask;
            if seen && mask != selected then return FALSE; end;
            selected = mask;
            seen = TRUE;
        end;
    end;
    return seen;
end;
readonly func BundleTMATMULSharedMasksAreZero() => boolean
begin
    for binding = 0 to 3 do
        if _BundleSharedBindings[[binding]].valid &&
           _BundleSharedBindings[[binding]].pe_mask != Zeros{4} then
            return FALSE;
        end;
    end;
    return TRUE;
end;
readonly func BundleMatrixPostProcessSourceCount() => integer {0..3}
begin
    return
        (if _BundleFixedPointAttributes.row_max_en &&
            _BundleFixedPointAttributes.row_max_init
         then 1 else 0) +
        (if BundleFPATRModeUsesVectorParameter(
               _BundleFixedPointAttributes.pre_quant_mode)
         then 1 else 0) +
        (if BundleFPATRReluModeUsesVectorParameter(
               _BundleFixedPointAttributes.relu_mode)
         then 1 else 0);
end;
readonly func BundleMatrixDestinationCount() => integer {1..3}
begin
    return 1 +
        (if _BundleFixedPointAttributes.row_max_en then 1 else 0) +
        (if _BundleFixedPointAttributes.group_max_en then 1 else 0);
end;
readonly func BundleMatrixDynamicBindingsComplete(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1},
    function: integer {0..31},
    left_type: TileDataType,
    right_type: TileDataType,
    shared_count: integer {0..4}) => boolean
begin
    if !_BundleFixedPointAttributes.valid ||
       !TileMatrixSharedSourceCountLegal(
           function, left_type, right_type, shared_count) then
        return FALSE;
    end;
    let mathematical_sources = TileMatrixLocalMathematicalSourceCount(
        function, left_type, right_type, shared_count) +
        (if _BundleFixedPointAttributes.c_scale_en then 1 else 0);
    let expected_sources = mathematical_sources +
        BundleMatrixPostProcessSourceCount();
    return BundleLocalTileSourceCount() == expected_sources &&
           BundleLocalTileDestinationCount() + BundleLocalTileParentRefCount() ==
               BundleMatrixDestinationCount() &&
           BundleTileBindingStreamTerminated() &&
           BundleOperationScalarBindingSchemaLegal(operation);
end;
pure func BundleTMATMULCooperativeSelected(
    function: integer {0..31},
    shared_count: integer {0..4}) => boolean
begin
    return shared_count > 0 && !TileMatrixFunctionIsGEMV(function);
end;
pure func BundleTMATMULCooperativeMaskValueLegal(mask: bits(4)) => boolean
begin
    return mask == '1111';
end;
readonly func BundleTMATMULCooperativeMasksLegal(
    function: integer {0..31},
    shared_count: integer {0..4}) => boolean
begin
    if !BundleTMATMULCooperativeSelected(function, shared_count) then
        return TRUE;
    end;
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if _BundleTileBindings[[binding]].valid &&
           !BundleTMATMULCooperativeMaskValueLegal(
               _BundleTileBindings[[binding]].pe_mask) then
            return FALSE;
        end;
    end;
    for binding = 0 to 3 do
        if _BundleSharedBindings[[binding]].valid &&
           !BundleTMATMULCooperativeMaskValueLegal(
               _BundleSharedBindings[[binding]].pe_mask) then
            return FALSE;
        end;
    end;
    return TRUE;
end;
readonly func BundleTMATMULSelectedMask() => bits(4)
begin
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if _BundleTileBindings[[binding]].valid then
            return _BundleTileBindings[[binding]].pe_mask;
        end;
    end;
    return Zeros{4};
end;
readonly func BundleTMATMULCurrentPEInactive() => boolean
begin
    if !BundleCubeMatrixSelected() then return FALSE; end;
    let function = UInt(_BundleOperation.selector[4:0]);
    let shared_count = BundleSharedBindingCount();
    if !BundleTMATMULCooperativeSelected(function, shared_count) then
        return FALSE;
    end;
    let group_m = BundleCubeDimensionValue(BundleDimension_LB0);
    if group_m == 0 || group_m > 128 then return FALSE; end;
    return BundleMatrixCooperativeValidM(
        group_m as integer {1..65535}, _CurrentMemoryAgent) == 0;
end;
readonly func BundleMatrixPrimaryDestinationCapacityBytes()
    => integer {0,128,256,512,1024,2048,4096,8192,16384,32768,65536,
                131072,262144}
begin
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if _BundleTileBindings[[binding]].valid &&
           _BundleTileBindings[[binding]].destination_valid then
            return BundleTileDestinationSizeBytes(
                binding as BundleTileBindingIndex);
        end;
    end;
    return 0;
end;
readonly func BundleMatrixAccumulatorDestinationIndicesDistinct(
    function: integer {0..31}) => boolean
begin
    if !TileMatrixFunctionUsesAccumulator(function) then return TRUE; end;
    let (destination_seen, destination_hand) =
        BundleMatrixPrimaryDestinationHand();
    if !destination_seen then return FALSE; end;
    var accumulator: TileIndex = 0;
    var found = FALSE;
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if !found && _BundleTileBindings[[binding]].valid then
            if _BundleTileBindings[[binding]].source0_valid then
                accumulator = BundleTileArchitecturalSourceIndex(
                    binding as BundleTileBindingIndex, FALSE);
                found = TRUE;
            elsif _BundleTileBindings[[binding]].source1_valid then
                accumulator = BundleTileArchitecturalSourceIndex(
                    binding as BundleTileBindingIndex, TRUE);
                found = TRUE;
            end;
        end;
    end;
    if !found then return FALSE; end;
    return accumulator != destination_hand;
end;
func ExecuteBundleTMATMULOperation() => boolean
begin
    // Zero-mask B.IOT/B.IOS commands do not install bindings.  Their sole
    // architectural trace is the participation marker, which exits before
    // descriptor, readiness, dimension, allocation, or payload inspection.
    if SelectedBundleTileMaskIsZero() &&
       BundleTMATMULSharedMasksAreZero() then
        return TRUE;
    end;
    if !_BundleFixedPointAttributes.valid then
        SetFault(Fault_BundleControl, ReadTPC());
        return FALSE;
    end;
    let decoded = DecodeTileOperation(TileDecode_CUBE,
        BundleOperationDecodeCode(_BundleOperation));
    if decoded == PTO_TILE_OPERATION_COUNT then
        SetFault(Fault_IllegalInstruction, ReadTPC());
        return FALSE;
    end;
    let operation = decoded as integer {0..PTO_TILE_OPERATION_COUNT-1};
    let function = UInt(_BundleOperation.selector[4:0]);
    let cctrl = BundleTMATMULCCTRL();
    let left_type = TileDataTypeFromEncoding(
        CurrentBundleTileOperationDataTypeCode() as TileDataTypeEncoding);
    let right_type = if _BundleDataAttributesPresent then
        TileDataTypeFromEncoding(
            _BundleDataAttributes.data_type as TileDataTypeEncoding)
        else left_type;
    let shared_count = BundleSharedBindingCount();
    let matrix_types_legal = if TileMatrixFunctionUsesMX(function) then
        TileMXOperandPairLegal(left_type, right_type)
    else
        TileOrdinaryMatrixInputTypesSameClass(left_type, right_type);
    if !matrix_types_legal ||
       !BundleMatrixDynamicBindingsComplete(
           operation, function, left_type, right_type, shared_count) ||
       !BundleTMATMULDataAttributesLegal() ||
       !BundleTMATMULAccumulatorControlLegal(function, cctrl) ||
       !BundleTMATMULPartialPostProcessLegal(cctrl) ||
       !BundleTMATMULDimensionsLegal(shared_count) ||
       !SelectedBundleTileMasksLegal() ||
       !BundleTMATMULMasksAgree() ||
       !BundleTMATMULCooperativeMasksLegal(function, shared_count) then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    let m_raw = BundleCubeDimensionValue(BundleDimension_LB0);
    let n_raw = BundleCubeDimensionValue(BundleDimension_LB1);
    let k_raw = BundleCubeDimensionValue(BundleDimension_LB2);
    let m = m_raw as integer {1..65535};
    let n = n_raw as integer {1..65535};
    let k = k_raw as integer {1..65535};
    if TileMatrixFunctionIsGEMV(function) && m != 1 then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    // Structurally legal Shared groups wait until whole-ready and published.
    if !BundleMatrixSharedSourcesReady(shared_count) then return FALSE; end;
    if !BundleMatrixSharedSchemasLegal(
           function, left_type, right_type,
           m, n, k, shared_count) then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    let cooperative = BundleTMATMULCooperativeSelected(
        function, shared_count);
    let valid_m = if cooperative then
        BundleMatrixCooperativeValidM(m, _CurrentMemoryAgent)
    else m;
    if cooperative && valid_m == 0 then
        ConsumeBundleSharedBindings(shared_count as integer {1..4});
        FinalizeBundleTileAttempt(TileExecution_Executed);
        return TRUE;
    end;
    let pe_m = valid_m as integer {1..65535};
    // Generic Stage2 Local dependency/subview/generation work occurs only
    // after group-level and Shared preflight has derived a nonzero current-PE
    // fragment. Zero-row PEs returned above without touching Local state.
    if !PrepareSelectedBundleStage2() then return FALSE; end;
    if !ReuseBundleLocalGenerationDestination() then return FALSE; end;
    if !BundleOperationGPRBindingValuesLegal(operation) then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    let mathematical_sources = TileMatrixLocalMathematicalSourceCount(
        function, left_type, right_type, shared_count) +
        (if _BundleFixedPointAttributes.c_scale_en then 1 else 0);
    let result_type = if TileMatrixFunctionUsesMX(function) then
        TileDataType_FP32
    else
        TileOrdinaryMatrixAccumulatorType(left_type, right_type);
    if _BundleFixedPointAttributes.c_scale_en &&
       (!TileMatrixFunctionAllowsCScale(function) ||
        result_type != TileDataType_FP32) then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    if !BundleMatrixLocalMathematicalSourcesLegal(
           function, left_type, right_type, pe_m, n, k, shared_count,
           result_type, BundleMatrixPrimaryDestinationCapacityBytes()) then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    if !BundleMatrixAccumulatorDestinationIndicesDistinct(function) then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    if _BundleFixedPointAttributes.c_scale_en &&
       !BundleMatrixCScaleDestinationIndicesDistinct(
           (mathematical_sources - 1) as integer {0..8}) then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    let (layout_found, primary_layout) =
        BundleMatrixCooperativeMLayout(
            function, right_type, pe_m, shared_count);
    if !layout_found then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    if !BundleMatrixPostProcessSourcesLegal(
           mathematical_sources, pe_m, n, result_type, primary_layout) then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    // Every field, stream, Local/Shared descriptor, parameter payload, shape,
    // and capacity rule is now closed. Allocate the atomic destination group
    // before taking the first mathematical or scalar payload snapshot.
    let allocation_mask = if cooperative then
        BundleMatrixCooperativeCurrentPEMask(m, _CurrentMemoryAgent)
    else BundleTMATMULSelectedMask();
    let partial_output = BundleTMATMULRawPartialOutput(cctrl);
    if !ResolveBundleTMATMULDestination(
           pe_m, n, result_type, TRUE, primary_layout,
           allocation_mask) then
        return FALSE;
    end;
    if !ValidateBundleLocalGenerationWriters() then
        RollBackBundleTileDestinations();
        return FALSE;
    end;
    let operands = BundleTileInstructionOperands(operation);
    var left = _Tiles[[0]];
    var right = _Tiles[[0]];
    var left_scale = _Tiles[[0]];
    var right_scale = _Tiles[[0]];
    let left_scale_present = TileMatrixFunctionUsesMX(function) &&
        TileMXInputTypeNeedsScale(left_type);
    let right_scale_present = TileMatrixFunctionUsesMX(function) &&
        TileMXInputTypeNeedsScale(right_type);
    var accumulator: TileIndex = operands.destination0;
    var bias: TileIndex = operands.destination0;
    var c_scale: TileIndex = operands.destination0;
    var local_ordinal: integer {0..6} = 0;
    var shared_ordinal: integer {0..4} = 0;
    if TileMatrixFunctionUsesAccumulator(function) then
        accumulator = BundleMatrixSourceAt(
            local_ordinal as integer {0..8});
        local_ordinal = (local_ordinal + 1) as integer {0..6};
    end;
    if shared_count == 0 then
        left = _Tiles[[BundleMatrixSourceAt(
            local_ordinal as integer {0..8})]];
        local_ordinal = (local_ordinal + 1) as integer {0..6};
        if left_scale_present then
            left_scale = _Tiles[[BundleMatrixSourceAt(
                local_ordinal as integer {0..8})]];
            local_ordinal = (local_ordinal + 1) as integer {0..6};
        end;
        right = _Tiles[[BundleMatrixSourceAt(
            local_ordinal as integer {0..8})]];
        local_ordinal = (local_ordinal + 1) as integer {0..6};
        if right_scale_present then
            right_scale = _Tiles[[BundleMatrixSourceAt(
                local_ordinal as integer {0..8})]];
            local_ordinal = (local_ordinal + 1) as integer {0..6};
        end;
    else
        let right_group = TileMatrixRightGroupSourceCount(
            function, right_type);
        if shared_count == right_group then
            left = _Tiles[[BundleMatrixSourceAt(
                local_ordinal as integer {0..8})]];
            local_ordinal = (local_ordinal + 1) as integer {0..6};
            if left_scale_present then
                left_scale = _Tiles[[BundleMatrixSourceAt(
                    local_ordinal as integer {0..8})]];
                local_ordinal = (local_ordinal + 1) as integer {0..6};
            end;
        else
            left = MaterializeBundleSharedMatrixLeftPrimary(
                shared_ordinal as integer {0..3},
                m, k, left_type,
                _BundleFixedPointAttributes.trans_a,
                _CurrentMemoryAgent);
            shared_ordinal = (shared_ordinal + 1) as integer {0..4};
            if left_scale_present then
                left_scale = MaterializeBundleSharedMatrixLeftScale(
                    shared_ordinal as integer {0..3},
                    m, k, left_type,
                    _CurrentMemoryAgent);
                shared_ordinal = (shared_ordinal + 1) as integer {0..4};
            end;
        end;
        right = MaterializeBundleSharedMatrixPrimary(
            shared_ordinal as integer {0..3},
            k, n, right_type,
            _BundleFixedPointAttributes.trans_b,
            _CurrentMemoryAgent);
        shared_ordinal = (shared_ordinal + 1) as integer {0..4};
        if right_scale_present then
            let scale_groups = TileMXScaleGroupCount(k, right_type);
            right_scale = MaterializeBundleSharedMatrixPrimary(
                shared_ordinal as integer {0..3},
                scale_groups, n,
                TileMXScaleCarrierType(right_type),
                FALSE, _CurrentMemoryAgent);
            shared_ordinal = (shared_ordinal + 1) as integer {0..4};
        end;
    end;

    if TileMatrixFunctionUsesBias(function) then
        bias = BundleMatrixSourceAt(
            local_ordinal as integer {0..8});
        local_ordinal = (local_ordinal + 1) as integer {0..6};
    end;

    if _BundleFixedPointAttributes.c_scale_en then
        c_scale = BundleMatrixSourceAt(
            local_ordinal as integer {0..8});
    end;

    let right_group = TileMatrixRightGroupSourceCount(
        function, right_type);
    let shape_legal = if shared_count == 0 then
        TileMatrixCubeInfosMatchDimensions(left, right, pe_m, n, k)
    else if shared_count == right_group then
        TileMatrixMixedInfosMatchDimensions(left, right, pe_m, n, k)
    else
        TileMatrixInfosMatchDimensions(left, right, pe_m, n, k);
    let operand_types_legal = left.data_type == left_type &&
        right.data_type == right_type;
    let scales_legal = !TileMatrixFunctionUsesMX(function) ||
        TileMatrixInfoOptionalScalesLegal(
            left, left_scale, left_scale_present,
            right, right_scale, right_scale_present);
    assert shape_legal && operand_types_legal && scales_legal;

    let accumulator_legal = !TileMatrixFunctionUsesAccumulator(function) ||
        TileMatrixLocalCubeAccumulatorSchemaLegal(
            accumulator, pe_m, n, result_type, primary_layout,
            BundleMatrixPrimaryDestinationCapacityBytes());
    assert accumulator_legal;
    assert !TileMatrixFunctionUsesBias(function) ||
           TileMatrixInfoBiasLegal(
               left, right, bias, TileMatrixFunctionUsesMX(function));
    if TileMatrixFunctionUsesAccumulator(function) &&
       BundleTMATMULAccumulatorPrefetchHint(cctrl) then
        TileProfileInternalAccumulatorPrefetchHint(
            accumulator, _Tiles[[accumulator]].cube_storage_bytes);
    end;
    let destination = BundleMatrixDestinationAt(0);
    let destination_template = _Tiles[[destination]];
    if TileMatrixFunctionUsesMX(function) then
        TMATMULMXSharedWithOptionalScales(
            destination, destination_template, accumulator,
            left, left_scale, left_scale_present,
            right, right_scale, right_scale_present,
            bias, TileMatrixFunctionUsesBias(function),
            TileMatrixFunctionUsesAccumulator(function),
            c_scale, _BundleFixedPointAttributes.c_scale_en,
            cctrl[0:0] != Zeros{1});
    else
        TMATMULShared(
            destination, destination_template, accumulator, left, right, bias,
            TileMatrixFunctionUsesBias(function),
            TileMatrixFunctionUsesAccumulator(function),
            c_scale, _BundleFixedPointAttributes.c_scale_en,
            cctrl[0:0] != Zeros{1});
    end;
    if _LastFault != Fault_None then
        RollBackBundleTileDestinations();
        return FALSE;
    end;
    if partial_output then
        TileProfileInternalAccumulatorReplacementHint(
            destination, _Tiles[[destination]].cube_storage_bytes);
    end;
    if shared_count > 0 then
        ConsumeBundleSharedBindings(shared_count as integer {1..4});
    end;
    FinalizeBundleTileAttempt(TileExecution_Executed);
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: unit -->
