<!-- GENERATED FROM: asl/block/model/commit/validation.asl -->
# Validation

**Normative ASL source:** `asl/block/model/commit/validation.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-COMMIT-VALIDATION}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-commit-validation-purpose role=purpose-scope -->
## 用途与范围

本单元定义指令束提交。`CompleteBundleAt(continuation)` 由 `BSTOP`、后继的 `BSTART`、关闭活动指令束的 trace `B.HINT` 以及架构进入请求调用。它检查指令束是否可以提交，运行所选的 tile 操作，然后通过 `StopBundleAt` 退役该指令束。

本单元还定义 Linx 运行时 trace 边界提示辅助函数。

<!-- PTO-READER-BLOCK: block-model-commit-validation-concepts role=concepts-state -->
## 概念与可见状态

提交读取累积的指令束状态：`BARG` 延续记录、`B.CATR` 控制属性，以及由 `BSTART` 安装的操作描述符。`continuation` 参数是顺序执行的下一地址。`BSTOP` 传入其自身之后的地址；后继的 `BSTART` 或 trace `B.HINT` 传入其自身的地址，因此顺序落入的前驱会继续执行到该指令；架构进入请求传入 `_BundleSequentialPC`。

只有当提交在没有故障的情况下完成时，结果才为 true。

<!-- PTO-READER-BLOCK: block-model-commit-validation-rules role=rules-interactions -->
## 规则与交互

提交按以下顺序执行各步骤，并在第一次失败时停止：

1. 没有活动指令束时引发 `Fault_BundleControl`。
2. 奇数的延续地址，或由 `BARG` 选出的奇数下一 PC，引发 `Fault_InstructionPC`。
3. 在既不是 `TileElement` 也不是 `TileMemory` 的 block 上设置 `DR`（维度归约）控制属性时，引发 `Fault_BundleControl`。
4. tile 操作描述符（`TileElement`、`TileMemory` 或 `TileMatrix`）运行 tile 操作。如果操作失败，提交返回 false。`FixedPoint` 描述符引发 `Fault_IllegalInstruction`。
5. `StopBundleAt(continuation)` 退役该指令束并写入 `TPC`。

设计要点：延续地址在任何 tile 效果之前被检查。ASL 注释指出，`SETC.TGT` 可以在 `BSTART` 之后替换 `BARG.BPCN`，因此最终目标只有在提交时才能确定。先检查它意味着错误的目标永远不会留下已发布的 Tile 结果。

设计要点：`DR` 在提交时检查，而不是在 `B.CATR` 执行时检查。ASL 注释解释说，原始位可能在完整头部选定其操作之前就已被收集。该检查从 `BARG` 读取 block 种类，并在提交时、任何 block 效果之前运行。

设计要点：失败的 tile 操作在 `StopBundleAt` 之前返回。因此指令束保持活动且其头部保持完整，`BARG` 延续也不会被应用。tile 执行所有者已经回滚了分配并中止了代次。陷阱处理程序看到的是发生故障的 block，恢复时可以将其作为整体重试。

<!-- PTO-READER-BLOCK: block-model-commit-validation-boundaries role=boundaries -->
## 架构边界

本单元不包含特定于操作的合法性检查。schema、绑定、类型和形状检查位于 tile 执行路径中，该路径在目标分配和操作主体之前检查它们。

没有有效描述符的指令束，或只有控制描述符的指令束，在没有操作的情况下提交，并直接进入 `StopBundleAt`。

`LinxTraceBoundaryHintApplies` 总是返回 false，因为其条件以常量 `FALSE` 结尾。因此可移植配置档永远不会走 Linx 标记路径，trace 提示遵循普通的 `B.HINT` 生命周期。

<!-- PTO-READER-BLOCK: block-model-commit-validation-example role=example-usage -->
## 非规范阅读示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

指令束 `BSTART.VEC TADD, FP32` 缺少一个源绑定。`BSTOP` 调用 `CompleteBundleAt`。步骤 1 到 3 通过。tile 路径以 `Fault_BundleControl` 拒绝不完整的操作数集合并返回 false。不会到达 `StopBundleAt`。该故障保存的陷阱上下文记录指令束为活动状态，并以 `BSTOP` 的地址作为其 `TPC`，且不存在目标 Tile。

<!-- PTO-READER-BLOCK: block-model-commit-validation-related role=related-owners-navigation -->
## 相关所有者

- [Tile 执行](../dispatch/tile-execution.md)以其自身的预检和回滚运行所选操作。
- [进入与停止](../lifecycle/enter-stop.md)定义 `StopBundleAt`。
- [指令束启动分派](../dispatch/start.md)在打开新指令束之前提交前驱。
- [BSTOP](../../lifecycle/BSTOP.md) 和 [B.HINT](../../lifecycle/B.HINT.md) 是提交边界。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/commit/validation.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-COMMIT-VALIDATION","surface":"block","classification":["model","commit","validation"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-DECODE","PTO-BLOCK-MODEL-DISPATCH-TILE-EXECUTION","PTO-BLOCK-MODEL-STATE-CONTROL-STATE"]}
func CompleteBundleAtWithAcceptedApplicabilityRules(
    rules: NumericApplicabilityRuleSet, continuation: Word) => boolean
begin
    if !_BundleActive then
        SetFault(Fault_BundleControl, ReadTPC());
        return FALSE;
    end;
    // SETC.TGT can replace BARG.BPCN after BSTART. Validate the final selected
    // continuation before any tile or block effect is made visible.
    if continuation[0] == '1' || BARGCommitPC(continuation)[0] == '1' then
        SetFault(Fault_InstructionPC, BARGCommitPC(continuation));
        return FALSE;
    end;
    // DR is group execution for VEC/SFU/TLSU only.  The raw bit may be
    // collected before the complete header selects its operation, so reject
    // the incompatible completed block here, before any block effect.
    if _BundleControlAttributes.dimension_reduction &&
       _BARG.block_type != BundleKind_TileElement &&
       _BARG.block_type != BundleKind_TileMemory then
        SetFault(Fault_BundleControl, ReadTPC());
        return FALSE;
    end;
    if _BundleOperation.valid then
        if _BundleOperation.operation_class == BundleOperation_TileElement ||
           _BundleOperation.operation_class == BundleOperation_TileMemory ||
           _BundleOperation.operation_class == BundleOperation_TileMatrix then
            if !ExecuteBundleTileOperationWithAcceptedApplicabilityRules(
                rules) then
                return FALSE;
            end;
        elsif _BundleOperation.operation_class == BundleOperation_FixedPoint then
            SetFault(Fault_IllegalInstruction, ReadTPC());
            return FALSE;
        end;
    end;
    StopBundleAt(continuation);
    return _LastFault == Fault_None;
end;

func CompleteBundleAt(continuation: Word) => boolean
begin
    return CompleteBundleAtWithAcceptedApplicabilityRules(
        NumericApplicabilityRules_None, continuation);
end;

// A TRACE hint selects the active direct block boundary. The Linx runtime
// compatibility profile records the boundary kind as a marker of the active
// block; the marker takes effect only when that block commits at its own
// boundary, so the hint never completes the block itself and cannot re-drive
// an active frame template. The portable profile keeps the ordinary TRACE
// boundary lifecycle owned by the dispatch command handler.
readonly func LinxTraceBoundaryHintApplies(
    hint_trace: boolean, instruction: bits(64),
    form: integer {0..PTO_COMMAND_FORM_COUNT-1}) => boolean
begin
    return hint_trace &&
           CommandDecodedBool(instruction, form, CommandField_B_E) &&
           _BundleActive &&
           FALSE;
end;

func ExecuteLinxTraceBoundaryHint(
    instruction: bits(64),
    form: integer {0..PTO_COMMAND_FORM_COUNT-1}) => CommandExecutionStatus
begin
    // Marker only: the trace boundary starts at the active block and takes
    // effect when that block commits at its own boundary. The hint does not
    // complete the block and has no memory effects, so an active frame
    // template keeps its saved state until its own commit.
    _LastBundleHintPayload = instruction;
    _BundleHint.present = TRUE;
    _BundleHint.trace = TRUE;
    _BundleHint.trace_end =
        CommandDecodedBool(instruction, form, CommandField_B_E);
    _BundleHint.branch_valid = FALSE;
    _BundleHint.branch_likely = FALSE;
    _BundleHint.temperature = Zeros{2};
    _BundleHint.prefetch_size = Zeros{12};
    BundleTransformHint();
    return CommandExecution_Executed;
end;
```
<!-- GENERATED-ASL-END: unit -->
