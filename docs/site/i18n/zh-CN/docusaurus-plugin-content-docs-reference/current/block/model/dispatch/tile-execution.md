<!-- GENERATED FROM: asl/block/model/dispatch/tile-execution.asl -->
# Tile Execution

**Normative ASL source:** `asl/block/model/dispatch/tile-execution.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-TILE-EXECUTION}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-dispatch-tile-execution-purpose role=purpose-scope -->
## 用途与范围

本单元在指令束提交时运行其 Tile 操作。对于操作类别为 Tile 元素、Tile 内存或 Tile 矩阵的指令束，提交校验调用 `ExecuteBundleTileOperationWithAcceptedApplicabilityRules`。操作完成时本单元返回真；故障或必须等待时返回假。

它分为两部分。专用分派器把部分操作路由到专用处理器。通用路径按封闭 schema 校验指令束并调用 Tile 指令处理器。

<!-- PTO-READER-BLOCK: block-model-dispatch-tile-execution-concepts role=concepts-state -->
## 概念与可见状态

- 代际是由多个写者部分组装的目标。Local 代际位于 Local Tile 中，Shared 代际位于 Shared Tile 中。
- 子视图物化是为本次尝试创建的 Tile 局部临时视图，在结束时被丢弃。
- 零参与表示每个 Tile 绑定的 PE 掩码都是 `0000`，或出现过零掩码绑定器且没有任何绑定。

本单元读取完整的指令束头部状态和 Tile 状态。它通过所调用的函数改变状态：目标解析、各处理器、`CommitBundleLocalGeneration`、`RetireBundleConsumerDependencies`、`FinalizeBundleTileAttempt`，以及回滚与中止辅助函数。

<!-- PTO-READER-BLOCK: block-model-dispatch-tile-execution-rules role=rules-interactions -->
## 规则与交互

本地路径按以下顺序运行：

1. 零参与且没有绑定的指令束直接返回真，没有任何效果。
2. 除非选择了 `TIMG2COL`，操作必须能够译码，且 `BundleProducerEffectEligible` 必须接受它。译码失败引发 `Fault_IllegalInstruction`。
3. 组装输出结构必须合法（`Fault_BundleControl`），Shared 目标组装策略必须合法（`Fault_TileLegality`）。
4. 对于矩阵、`TIMG2COL` 和权重 `TLOAD` 以外的操作，准备阶段 2 并复用 Local 续接目标。
5. 当 Tile 掩码不为零且未选择 `TIMG2COL` 时，标记、捕获并检查执行掩码。对于内存传输类操作和权重 `TLOAD`，在此准备其合并。
6. 专用分派器依次尝试：`TIMG2COL`、权重 `TLOAD`、矩阵、CUBE 传输、GMOV、MGATHER.CAS、GM 原子与归约、MGATHER.MASK、MGATHER、MSCATTER、MSCATTER.MASK、TPREFETCH 以及 Shared TLSU。如果仍有未消费的 Shared 绑定且没有处理器匹配，引发 `Fault_TileLegality`。

设计要点：ASL 注释指出，效果资格在描述符准备、专用分派、主体执行、分配或辅助效果之前检查。不具资格的操作不会改变 Tile 状态。

设计要点：专用分支的顺序很重要。MGATHER.CAS 使用选择子功能号 8，它也落在 GM 原子范围 8 到 12 内。由于 `BundleMGATHERCASSelected` 在 `BundleGMAtomRedSelected` 之前测试，未被更早选择器（例如仅依据 `B.DATR` 布局匹配的 CUBE 传输）认领的功能号 8 指令束会到达专用的 `MGATHER.CAS` 处理器，而不是原子与归约处理器。

走通用路径时，本单元译码操作；如果 Tile 掩码为零则返回真。随后依次检查：定点属性只用于矩阵操作、绑定完整性、B.IOR 值、数据属性、单元重排 schema 以及所有封闭 schema。产生 GPR 的比较在此处运行并提交。否则 PE 掩码必须一致，必须准备好执行掩码合并，然后解析并校验目标。只有这之后处理器才运行。

设计要点：ASL 注释指出，原始 B.IOR 值在零掩码退出之后、目标分配之前校验。非法值永远不会进入操作数记录或 Tile 状态。

成功时，本单元提交 Local 代际，退役消费者依赖，丢弃子视图，并完成本次尝试，从而发布由指令束分配的目标。目标解析成功后发生的后续失败会回滚由指令束分配的目标并中止代际。只要尝试未完成，外层函数还会中止 Local 与 Shared 代际。

当前存在一个可执行模型缺口：如果 `ResolveBundleTileDestinationsForOperation` 本身在较早绑定已经分配目标之后失败，此路径会中止代际并丢弃子视图，却不会调用 `RollBackBundleTileDestinations`。目标解析可能先为较早绑定完成分配，再因后续绑定失败，因此该解析失败场景的清理尚未得到保证。Issue #367 跟踪此冲突；上面的回滚保证只适用于目标解析成功之后发生的失败。

设计要点：设置 `far` 时，远程路径原样调用本地路径。ASL 注释说明路由与传输在架构上不可观察，因此结果只通过与本地指令束相同的提交路径发布。

<!-- PTO-READER-BLOCK: block-model-dispatch-tile-execution-boundaries role=boundaries -->
## 架构边界

本单元安排检查与效果的顺序，但不定义它们。每个封闭 schema、专用处理器、目标所有者和 Tile 处理器都位于各自的单元中。嵌入此处的 NDF 条款 `PTO-BLOCK-MODEL-DISPATCH-TGPR2T-BOUNDARY-001` 只是重申 `TGPR2T` 产生由其自身 schema 检查的普通 U8 CUBE Tile。停止指令束与选择下一个 PC 属于提交校验。

<!-- PTO-READER-BLOCK: block-model-dispatch-tile-execution-example role=example-usage -->
## 非规范阅读示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

某 `TADD` 指令束以一个合法绑定和掩码 `1111` 提交。没有专用处理器匹配，因此运行通用路径。所有 schema 通过，分配目标，处理器写入它。本单元提交代际并发布目标。如果处理器发生故障，目标会被释放，结果不可见。如果指令束唯一的 `B.IOT` 使用掩码 `0000`，则会在第 1 步、译码之前返回真，因为零掩码的 `B.IOT` 不创建绑定。

<!-- PTO-READER-BLOCK: block-model-dispatch-tile-execution-related role=related-owners-navigation -->
## 相关所有者

- [Commit validation](../commit/validation.md) 在提交时调用本单元。
- [Tile schema](tile-schema.md) 与 [Tile-scalar schema](tile-scalar-schema.md) 定义封闭 schema。
- [Destination operation](destination-operation.md) 在通用路径上解析目标。
- [Tile instruction operands](tile-instruction-operands.md) 构建操作数记录。
- [Rollback](../faults/rollback.md) 在失败后释放目标。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/tile-execution.asl -->
```asl
// NDF-BEGIN: PTO-BLOCK-MODEL-DISPATCH-TGPR2T-BOUNDARY-001
// ndf: kind=contract level=L1 layer=block status=accepted
// TGPR2T dispatch MUST preserve the downstream boundary: its result is an
// ordinary numeric U8 CUBE Tile, not a PredicateCell and not an implicit
// TSEL/TSELS mask. All destination descriptor, whole-tile definedness, and
// numeric padding checks belong to the TGPR2T complete schema before handler
// execution and atomic result publication.
// NDF-END: PTO-BLOCK-MODEL-DISPATCH-TGPR2T-BOUNDARY-001
// PTO-UNIT: {"classification":["model","dispatch","tile-execution"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-CELL-REARRANGEMENT-SCHEMA","PTO-BLOCK-MODEL-DISPATCH-COMPARISON-SCHEMA","PTO-BLOCK-MODEL-DISPATCH-CUBE-TMATMUL","PTO-BLOCK-MODEL-DISPATCH-DESTINATION-OPERATION","PTO-BLOCK-MODEL-DISPATCH-EXECUTION-MASK-SCHEMA","PTO-BLOCK-MODEL-DISPATCH-EXPANSION-SCHEMA","PTO-BLOCK-MODEL-DISPATCH-GENERATION-SCHEMA","PTO-BLOCK-MODEL-DISPATCH-REDUCTION-SCHEMA","PTO-BLOCK-MODEL-DISPATCH-SHARED-TLSU","PTO-BLOCK-MODEL-DISPATCH-TGPR2T-SCHEMA","PTO-BLOCK-MODEL-DISPATCH-TILE-INSTRUCTION-OPERANDS","PTO-BLOCK-MODEL-DISPATCH-TILE-SCALAR-SCHEMA","PTO-BLOCK-MODEL-DISPATCH-TLSU-GM-ATOM-RED","PTO-BLOCK-MODEL-DISPATCH-TLSU-GMOV","PTO-BLOCK-MODEL-DISPATCH-TLSU-LAYOUT-CONVERSION","PTO-BLOCK-MODEL-DISPATCH-TLSU-MGATHER","PTO-BLOCK-MODEL-DISPATCH-TLSU-MGATHER-CAS","PTO-BLOCK-MODEL-DISPATCH-TLSU-MGATHER-MASK","PTO-BLOCK-MODEL-DISPATCH-TLSU-MSCATTER","PTO-BLOCK-MODEL-DISPATCH-TLSU-MSCATTER-MASK","PTO-BLOCK-MODEL-DISPATCH-TLSU-PREFETCH","PTO-BLOCK-MODEL-DISPATCH-WEIGHT-SHARED-EXEC","PTO-BLOCK-MODEL-OPERANDS-LOCAL-GENERATION","PTO-BLOCK-MODEL-OPERANDS-PORTABLE-CARRIERS","PTO-BLOCK-MODEL-OPERANDS-SHARED-GENERATION","PTO-BLOCK-MODEL-OPERANDS-SUBVIEW-DESCRIPTOR","PTO-TILE-MODEL-DISPATCH-TOP-LEVEL","PTO-TILE-MODEL-EXECUTION-MASK-COMPARISON"],"id":"PTO-BLOCK-MODEL-DISPATCH-TILE-EXECUTION","surface":"block"}
readonly func BundleTileTypesMatch(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1},
    operands: TileInstructionOperands,
    expected: TileDataType) => boolean
begin
    if TileOperandPresent(operation, TileOperand_destination0) &&
       _Tiles[[operands.destination0]].allocated &&
       _Tiles[[operands.destination0]].data_type != expected then return FALSE; end;
    if TileOperandPresent(operation, TileOperand_source0) &&
       _Tiles[[operands.source0]].allocated &&
       _Tiles[[operands.source0]].data_type != expected then return FALSE; end;
    if TileOperandPresent(operation, TileOperand_source1) &&
       _Tiles[[operands.source1]].allocated &&
       _Tiles[[operands.source1]].data_type != expected then return FALSE; end;
    return TRUE;
end;

readonly func SelectedBundleClosedSchemasLegal(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    // These four selector/comparison operations have complete mutually
    // exclusive schemas; generic tile arity predicates are not applicable.
    case TileOperationOfIndex(operation) of
        when TileOperation_TCMP =>
            return SelectedBundleClosedTCMPSchemaLegal(operation);
        when TileOperation_TCMPS =>
            return SelectedBundleClosedTCMPSSchemaLegal(operation);
        when TileOperation_TSEL =>
            return SelectedBundleClosedTSELSchemaLegal(operation);
        when TileOperation_TSELS =>
            return SelectedBundleClosedTSELSSchemaLegal(operation);
        otherwise =>
            return SelectedBundleClosedBinarySchemaLegal(operation) &&
                   SelectedBundleClosedUnarySchemaLegal(operation) &&
                   SelectedBundleClosedTFMASchemaLegal(operation) &&
                   SelectedBundleCellRearrangementSchemaLegal(operation) &&
                   SelectedBundleClosedGenerationSchemaLegal(operation) &&
                   SelectedBundleClosedReductionSchemaLegal(operation) &&
                   SelectedBundleClosedExpansionSchemaLegal(operation) &&
                   SelectedBundleClosedTCVTSchemaLegal(operation) &&
                   SelectedBundleClosedTGPR2TSchemaLegal(operation) &&
                   SelectedBundleClosedTileScalarBinarySchemaLegal(operation) &&
                   SelectedBundleClosedTEXPANDSSchemaLegal(operation);
    end;
end;

func ExecuteBundleComparisonGPRCarrier(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    if !SelectedBundleComparisonUsesGPRCarrier(operation) then return FALSE; end;
    let (operation_type_valid, operation_type) =
        ResolveBundleEffectiveDataType();
    if !operation_type_valid then return FALSE; end;
    let selected_high = _BundleDataAttributes.saturating;
    case TileOperationOfIndex(operation) of
        when TileOperation_TCMP =>
            let left = BundleTileSourceIndex(0, FALSE);
            let right = BundleTileSourceIndex(0, TRUE);
            let gpr_destination = _BundleScalarBindings[[0]].destination
                as GPRIndex;
            var value = TileCompareCUBEToGPRAs(
                left, right, BundleComparisonCodeAsTileComparison(),
                selected_high, operation_type);
            if _BundleExecutionMask.valid then
                let old_value = ReadGPR(gpr_destination);
                let tile = _Tiles[[left]];
                value = TileExecutionMaskPredicateGPRResult(
                    value, old_value, operation_type, tile.layout,
                    tile.valid_rows as integer {1..65535},
                    tile.valid_columns as integer {1..65535}, selected_high);
            end;
            WriteGPR(gpr_destination, value);
        when TileOperation_TCMPS =>
            let source = BundleTileSourceIndex(0, FALSE);
            let scalar = ReadScalarRegisterOperand(
                _BundleScalarBindings[[0]].source0);
            let gpr_destination = _BundleScalarBindings[[0]].destination
                as GPRIndex;
            var value = TileCompareCUBEScalarToGPRAs(
                source, scalar,
                BundleComparisonCodeAsTileComparison(), selected_high,
                operation_type);
            if _BundleExecutionMask.valid then
                let old_value = ReadGPR(gpr_destination);
                let tile = _Tiles[[source]];
                value = TileExecutionMaskPredicateGPRResult(
                    value, old_value, operation_type, tile.layout,
                    tile.valid_rows as integer {1..65535},
                    tile.valid_columns as integer {1..65535}, selected_high);
            end;
            WriteGPR(gpr_destination, value);
        when TileOperation_TSEL =>
            let source_true = BundleComparisonSelectTrueSource(operation);
            let (-, destination_binding) = BundleFirstDestinationBinding();
            let mask_words = SelectedBundleComparisonGPRMaskWordCount(
                operation_type);
            let low = ReadScalarRegisterOperand(
                _BundleScalarBindings[[0]].source0);
            let high = if mask_words == 2 then
                ReadScalarRegisterOperand(_BundleScalarBindings[[0]].source1)
                else Zeros{PTO_XLEN};
            ExecuteTileSelectCUBEGPRAs(
                _BundleTileBindings[[destination_binding]].destination,
                low, high,
                source_true,
                BundleTileSourceIndex(0, TRUE), operation_type);
        when TileOperation_TSELS =>
            let source_true = BundleComparisonSelectTrueSource(operation);
            let (-, destination_binding) = BundleFirstDestinationBinding();
            let mask_words = SelectedBundleComparisonGPRMaskWordCount(
                operation_type);
            let low = ReadScalarRegisterOperand(
                _BundleScalarBindings[[0]].source0);
            let mask_high = if mask_words == 2 then
                ReadScalarRegisterOperand(_BundleScalarBindings[[0]].source1)
                else Zeros{PTO_XLEN};
            let scalar_selector = if mask_words == 2 then
                _BundleScalarBindings[[0]].source2
                else _BundleScalarBindings[[0]].source1;
            let scalar_false = ReadScalarRegisterOperand(scalar_selector);
            ExecuteTileSelectScalarCUBEGPRAs(
                _BundleTileBindings[[destination_binding]].destination,
                low, mask_high,
                source_true, scalar_false, operation_type);
        otherwise => return FALSE;
    end;
    return TRUE;
end;


func ExecuteBundleTileOperationLocallyWithAcceptedApplicabilityRules(
    rules: NumericApplicabilityRuleSet) => boolean
begin
    if _BundleZeroParticipationSeen && BundleTileBindingCount() == 0 &&
       BundleSharedBindingCount() == 0 then return TRUE; end;
    let timg2col_selected =
        BundleDescriptorSelectsTIMG2COL(_BundleOperation);
    // Effect eligibility is a generated handler-group contract and is
    // checked before descriptor preparation, specialized dispatch, body
    // execution, allocation, or auxiliary effects.
    if _BundleOperation.valid && !timg2col_selected then
        let effect_family = BundleTileDecodeFamily(
            _BundleOperation.operation_class);
        let effect_code = BundleOperationDecodeCode(_BundleOperation);
        let effect_decoded = DecodeTileOperation(effect_family, effect_code);
        if effect_decoded == PTO_TILE_OPERATION_COUNT then
            SetFault(Fault_IllegalInstruction, ReadTPC());
            return FALSE;
        end;
        if !BundleProducerEffectEligible(
                effect_decoded as integer {0..PTO_TILE_OPERATION_COUNT-1}) then
            return FALSE;
        end;
    end;
    // ParentRef/output structure is a bundle contract and must fault before
    // relative-parent resolution, consumer readiness, descriptor preparation,
    // or any destination allocation.  Zero-participation groups retain their
    // strict no-effect path below the existing binder contract.
    if !SelectedBundleTileMaskIsZero() &&
       !BundleAssembleOutputStructureLegal() then
        SetFault(Fault_BundleControl, ReadTPC());
        return FALSE;
    end;
    if !BundleSharedDestinationAssemblyPolicyLegal() then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    let matrix_selected = BundleCubeMatrixSelected();
    let weight_tload_selected = BundleWeightTLOADSelected();
    var stage2_prepared = TRUE;
    if !matrix_selected && !timg2col_selected && !weight_tload_selected then
        stage2_prepared = PrepareSelectedBundleStage2();
    end;
    if !matrix_selected && !timg2col_selected && !weight_tload_selected && !stage2_prepared then
        DiscardBundleSubviewMaterializations();
        return FALSE;
    end;
    // Normalize a Local continuation ParentRef into its existing semantic
    // destination after wire-form validation and before every closed schema or
    // specialized handler.  This never allocates or publishes a new Tile.
    if !matrix_selected && !timg2col_selected && !weight_tload_selected &&
       !ReuseBundleLocalGenerationDestination() then
        DiscardBundleSubviewMaterializations();
        return FALSE;
    end;
    if !SelectedBundleTileMaskIsZero() && _BundleOperation.valid &&
       !timg2col_selected then
        let mask_family = BundleTileDecodeFamily(
            _BundleOperation.operation_class);
        let mask_code = BundleOperationDecodeCode(_BundleOperation);
        let mask_operation = DecodeTileOperation(mask_family, mask_code);
        if mask_operation != PTO_TILE_OPERATION_COUNT &&
           TileOperationExecutionMaskEligible(
               mask_operation as integer {0..PTO_TILE_OPERATION_COUNT-1}) &&
           !MarkSelectedBundleExecutionMaskCarrier(
               mask_operation as integer {0..PTO_TILE_OPERATION_COUNT-1}) then
            SetFault(Fault_TileLegality, ReadTPC());
            DiscardBundleSubviewMaterializations();
            return FALSE;
        end;
        if mask_operation != PTO_TILE_OPERATION_COUNT &&
           TileOperationExecutionMaskEligible(
               mask_operation as integer {0..PTO_TILE_OPERATION_COUNT-1}) &&
           !CaptureSelectedBundleExecutionMask(
               mask_operation as integer {0..PTO_TILE_OPERATION_COUNT-1}) then
            SetFault(Fault_TileLegality, ReadTPC());
            DiscardBundleSubviewMaterializations();
            return FALSE;
        end;
        if mask_operation != PTO_TILE_OPERATION_COUNT &&
           TileOperationExecutionMaskEligible(
               mask_operation as integer {0..PTO_TILE_OPERATION_COUNT-1}) &&
           _BundleExecutionMask.valid &&
           !BundleExecutionMaskDataAttributesLegal(
               mask_operation as integer {0..PTO_TILE_OPERATION_COUNT-1}) then
            SetFault(Fault_TileLegality, ReadTPC());
            DiscardBundleSubviewMaterializations();
            return FALSE;
        end;
        if _BundleExecutionMask.valid &&
           (weight_tload_selected || BundleCubeTransportSelected() ||
            BundleGMOVSelected() || BundleMGATHERCASSelected() ||
            BundleGMAtomRedSelected() || BundleMGATHERMASKSelected() ||
            BundleMGATHERSelected() || BundleMSCATTERSelected() ||
            BundleMSCATTERMASKSelected() || BundleTPREFETCHSelected() ||
            BundleSharedTLSUSelected()) &&
           !PrepareSelectedBundleExecutionMaskMerge(
               mask_operation as integer {0..PTO_TILE_OPERATION_COUNT-1}) then
            SetFault(Fault_TileLegality, ReadTPC());
            DiscardBundleSubviewMaterializations();
            return FALSE;
        end;
    end;
    var specialized = TRUE;
    var specialized_completed = FALSE;
    if timg2col_selected then
        specialized_completed = ExecuteBundleTIMG2COLOperation();
    elsif weight_tload_selected then
        specialized_completed = ExecuteBundleWeightTLOADOperation();
    elsif matrix_selected then
        specialized_completed = ExecuteBundleTMATMULOperation();
    elsif BundleCubeTransportSelected() then
        specialized_completed = ExecuteBundleCubeTransportOperation();
    elsif BundleGMOVSelected() then
        specialized_completed = ExecuteBundleGMOVOperation();
    elsif BundleMGATHERCASSelected() then
        specialized_completed = ExecuteBundleMGATHERCASOperation();
    elsif BundleGMAtomRedSelected() then
        specialized_completed = ExecuteBundleGMAtomRedOperation();
    elsif BundleMGATHERMASKSelected() then
        specialized_completed = ExecuteBundleMGATHERMASKOperation();
    elsif BundleMGATHERSelected() then
        specialized_completed = ExecuteBundleMGATHEROperation();
    elsif BundleMSCATTERSelected() then
        specialized_completed = ExecuteBundleMSCATTEROperation();
    elsif BundleMSCATTERMASKSelected() then
        specialized_completed = ExecuteBundleMSCATTERMASKOperation();
    elsif BundleTPREFETCHSelected() then
        specialized_completed = ExecuteBundleTPREFETCHOperation();
    elsif BundleSharedTLSUSelected() then
        specialized_completed = ExecuteBundleSharedTLSUOperation();
    elsif BundleSharedBindingsUnconsumed() then
        SetFault(Fault_TileLegality, ReadTPC());
        specialized_completed = FALSE;
    else
        specialized = FALSE;
    end;
    if specialized then
        if specialized_completed && _LastFault == Fault_None then
            if !matrix_selected || !BundleTMATMULCurrentPEInactive() then
                CommitBundleLocalGeneration();
                RetireBundleConsumerDependencies();
                if timg2col_selected then
                    FinalizeBundleTileAttempt(TileExecution_Executed);
                end;
            end;
        else
            AbortBundleLocalGenerationsForBundle();
        end;
        DiscardBundleSubviewMaterializations();
        return specialized_completed;
    end;
    let family = BundleTileDecodeFamily(_BundleOperation.operation_class);
    let code = BundleOperationDecodeCode(_BundleOperation);
    let decoded = DecodeTileOperation(family, code);
    if decoded == PTO_TILE_OPERATION_COUNT then
        SetFault(Fault_IllegalInstruction, ReadTPC());
        return FALSE;
    end;
    let operation = decoded as integer {0..PTO_TILE_OPERATION_COUNT-1};
    if SelectedBundleTileMaskIsZero() then return TRUE; end;
    if _BundleFixedPointAttributes.valid &&
       _BundleOperation.operation_class != BundleOperation_TileMatrix then
        SetFault(Fault_BundleControl, ReadTPC());
        return FALSE;
    end;
    if !BundleOperationBindingsComplete(operation) then
        SetFault(Fault_BundleControl, ReadTPC());
        return FALSE;
    end;
    // Validate raw B.IOR controls only after the PE mask zero no-effect exit
    // and before destination allocation/resolution.  Invalid values never
    // enter constrained TileInstructionOperands fields or architectural Tile
    // state.
    if !BundleOperationGPRBindingValuesLegal(operation) then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    if !SelectedBundleTileDataAttributesLegal(operation) then
        return FALSE;
    end;
    // Cell-rearrangement B.IOR/B.IOT shape is bundle structure.  Report
    // omitted or surplus controls as BundleControl before the generic closed
    // schema maps a failed operand contract to TileLegality.
    if TileOperationUsesCellRearrangementSchema(operation) &&
       !SelectedBundleCellRearrangementSchemaLegal(operation) then
        SetFault(Fault_BundleControl, ReadTPC());
        return FALSE;
    end;
    if !SelectedBundleClosedSchemasLegal(operation) then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    if SelectedBundleComparisonProducesGPR(operation) then
        if !ExecuteBundleComparisonGPRCarrier(operation) then
            SetFault(Fault_TileLegality, ReadTPC());
            return FALSE;
        end;
        CommitBundleLocalGeneration();
        RetireBundleConsumerDependencies();
        FinalizeBundleTileAttempt(TileExecution_Executed);
        return TRUE;
    end;
    if !SelectedBundleTileMasksLegal() then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    if !PrepareSelectedBundleExecutionMaskMerge(operation) then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    if !ResolveBundleTileDestinationsForOperation(operation) then
        AbortBundleLocalGenerationsForBundle();
        DiscardBundleSubviewMaterializations();
        return FALSE;
    end;
    if !ValidateBundleLocalGenerationWriters() then
        RollBackBundleTileDestinations();
        AbortBundleLocalGenerationsForBundle();
        DiscardBundleSubviewMaterializations();
        return FALSE;
    end;
    if SelectedBundleComparisonConsumesGPR(operation) then
        if !ExecuteBundleComparisonGPRCarrier(operation) then
            SetFault(Fault_TileLegality, ReadTPC());
            RollBackBundleTileDestinations();
            AbortBundleLocalGenerationsForBundle();
            DiscardBundleSubviewMaterializations();
            return FALSE;
        end;
        CommitBundleLocalGeneration();
        RetireBundleConsumerDependencies();
        DiscardBundleSubviewMaterializations();
        FinalizeBundleTileAttempt(TileExecution_Executed);
        return TRUE;
    end;
    let operands = BundleTileInstructionOperands(operation);
    var status = TileExecution_Rejected;
    if TileOperationOfIndex(operation) == TileOperation_TCI &&
       (CurrentBundleTileLayout() == TileLayout_CUBE_M16 ||
        CurrentBundleTileLayout() == TileLayout_CUBE_M32) then
        let step2d = ReadScalarRegisterOperand(
            BundleOperationGPRInputSelector(
                BundleOperationGPRInputSlot(
                    operation, TileOperand_flag0) as integer {0..2}));
        if !TileOperandsLegal_TCICube(
               operands.destination0, operands.scalar0, step2d) then
            SetFault(Fault_TileLegality, ReadTPC());
        else
            TCICube(operands.destination0, operands.scalar0, step2d);
            status = TileExecution_Executed;
        end;
    else
        let (generated_status, -) =
            ExecuteTileInstructionWithoutTimeWithAcceptedApplicabilityRules(
            rules, family, code, operands);
        status = generated_status;
    end;
    if _LastFault != Fault_None || status != TileExecution_Executed then
        RollBackBundleTileDestinations();
        AbortBundleLocalGenerationsForBundle();
        DiscardBundleSubviewMaterializations();
        return FALSE;
    end;
    CommitBundleLocalGeneration();
    RetireBundleConsumerDependencies();
    DiscardBundleSubviewMaterializations();
    FinalizeBundleTileAttempt(status);
    return TRUE;
end;

func ExecuteFarBundleTileOperationWithAcceptedApplicabilityRules(
    rules: NumericApplicabilityRuleSet) => boolean
begin
    // Routing and transport are not architecturally observable.  The formal
    // model therefore executes the selected operation against the initiating
    // core's captured inputs and publishes the returned results only through
    // the same commit path as a local block.  A concrete implementation may
    // dispatch this work to the target selected by its routing state, but it
    // may not expose an intermediate remote result or a partial local commit.
    return ExecuteBundleTileOperationLocallyWithAcceptedApplicabilityRules(
        rules);
end;

func ExecuteBundleTileOperationWithAcceptedApplicabilityRules(
    rules: NumericApplicabilityRuleSet) => boolean
begin
    var completed = FALSE;
    if _BundleControlAttributes.far then
        completed = ExecuteFarBundleTileOperationWithAcceptedApplicabilityRules(
            rules);
    else
        completed = ExecuteBundleTileOperationLocallyWithAcceptedApplicabilityRules(
            rules);
    end;
    if !completed then
        AbortBundleLocalGenerationsForBundle();
        AbortBundleSharedGenerationsForBundle();
    end;
    return completed;
end;

func ExecuteBundleTileOperation() => boolean
begin
    return ExecuteBundleTileOperationWithAcceptedApplicabilityRules(
        NumericApplicabilityRules_None);
end;
```
<!-- GENERATED-ASL-END: unit -->
