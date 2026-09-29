<!-- GENERATED FROM: asl/block/model/lifecycle/enter-stop.asl -->
# Enter Stop

**Normative ASL source:** `asl/block/model/lifecycle/enter-stop.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-LIFECYCLE-ENTER-STOP}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-lifecycle-enter-stop-purpose role=purpose-scope -->
## 用途与范围

本单元定义指令束其余的两个生命周期转换：进入主体，以及退役指令束并把程序移到其延续地址的最终停止。

指令束有两个阶段。在头部阶段，配置命令（`B.*`）累积状态。在主体阶段，普通标量指令运行。停止转换是提交的最后一步；验证和 tile 效果都发生在它之前。

<!-- PTO-READER-BLOCK: block-model-lifecycle-enter-stop-concepts role=concepts-state -->
## 概念与可见状态

- `EnterBundleBody` 设置 `_BundleBodyActive`。当指令束处于活动状态且仍在头部阶段时，标量分派器会为执行的第一条标量指令调用它。
- `StopBundle` 以 `_BundleSequentialPC` 作为延续地址调用 `StopBundleAt`。
- `StopBundleAt(continuation)` 从其调用者接收顺序延续地址，并用 `BARGCommitPC` 计算下一 PC。当 `BARG` 选择候选目标时，结果为 `BARG.BPCN`，否则为 `continuation`。

<!-- PTO-READER-BLOCK: block-model-lifecycle-enter-stop-rules role=rules-interactions -->
## 规则与交互

当没有活动指令束时，`EnterBundleBody`、`StopBundle` 和 `StopBundleAt` 都会引发 `Fault_BundleControl`。

`StopBundleAt` 同时检查延续地址和所选的下一 PC。如果其中任一个的位 0 被置位，它以所选地址引发 `Fault_InstructionPC`，并使指令束保持活动。

成功时，`StopBundleAt` 按顺序执行以下操作：

1. 捕获下一 PC 以及来自 `B.CATR` 的 `trap` 控制属性。
2. 清除 `_BundleActive` 和 `_BundleBodyActive`。
3. 调用 `ClearBundleHeaderState` 丢弃头部配置和绑定。
4. 把 `BARG` 重置为 `Standard`、`Fallthrough`、`taken` 为 false、`BPCN` 为零，并清除 `_BundleSequentialPC`、`_FrameStackReturnTarget` 和 `BPC`。
5. 用下一 PC 写入 `TPC`。
6. 如果设置了 `trap`，以下一 PC 引发 `Fault_BundlePostCommit`。

设计要点：下一 PC 和 `trap` 标志在清除任何状态之前读取。清除头部会抹去 `B.CATR`，重置 `BARG` 会抹去目标，因此之后再读取会丢失这两个值。

设计要点：提交后陷阱在 block 完全退役之后引发。ASL 注释说明，该陷阱对已提交、已清除的状态做快照，因此恢复该上下文时会在下一 PC 处继续，永远不会回到已退役的 block 或其 `BSTOP`。因此 `trap` 属性不会导致 block 运行两次。

设计要点：无效的延续地址在任何清除之前发生故障。指令束保持活动且其配置保持完整，因此已保存的上下文仍然描述失败的那个 block。

<!-- PTO-READER-BLOCK: block-model-lifecycle-enter-stop-boundaries role=boundaries -->
## 架构边界

`StopBundleAt` 不执行指令束的操作。[validation](../commit/validation.md) 中的提交所有者先运行所选的 tile 操作，只有在其成功之后才调用 `StopBundleAt`。

Local 和 Shared 代次记录不属于头部状态，因此步骤 3 会保留它们。它们只能通过各自的 `LAST` 或中止路径结束，或在复位时结束。

<!-- PTO-READER-BLOCK: block-model-lifecycle-enter-stop-example role=example-usage -->
## 非规范阅读示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

一个条件指令束具有 `BARG.BPCN = 0x2000`，主体中的一条 `SETC` 指令把 `taken` 设为 false。位于 `0x1040` 的 4 字节 `BSTOP` 以延续地址 `0x1044` 提交。`BARGCommitPC` 返回 `0x1044`，`TPC` 变为 `0x1044`，头部状态和 `BARG` 被清除。如果 `taken` 为 true，`TPC` 则会变为 `0x2000`。

<!-- PTO-READER-BLOCK: block-model-lifecycle-enter-stop-related role=related-owners-navigation -->
## 相关所有者

- [Begin](begin.md) 打开指令束，本单元清除的正是该指令束的状态。
- [提交验证](../commit/validation.md)在调用 `StopBundleAt` 之前运行合法性检查和操作。
- [BARG 辅助函数](../state/barg.md)定义 `BARGCommitPC`。
- [描述符状态](../state/descriptor-state.md)定义 `ClearBundleHeaderState`。
- [BSTOP](../../lifecycle/BSTOP.md) 是显式停止指令。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/lifecycle/enter-stop.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-LIFECYCLE-ENTER-STOP","surface":"block","classification":["model","lifecycle","enter-stop"],"depends_on":["PTO-BLOCK-MODEL-LIFECYCLE-BEGIN","PTO-BLOCK-MODEL-STATE-BARG"]}
func EnterBundleBody()
begin
    if !_BundleActive then
        SetFault(Fault_BundleControl, ReadTPC());
    else
        _BundleBodyActive = TRUE;
    end;
end;

func StopBundle()
begin
    if !_BundleActive then
        SetFault(Fault_BundleControl, ReadTPC());
    else
        StopBundleAt(_BundleSequentialPC);
    end;
end;

func StopBundleAt(continuation: Word)
begin
    if !_BundleActive then
        SetFault(Fault_BundleControl, ReadTPC());
    elsif continuation[0] == '1' || BARGCommitPC(continuation)[0] == '1' then
        SetFault(Fault_InstructionPC, BARGCommitPC(continuation));
    else
        let next_pc = BARGCommitPC(continuation);
        let post_commit_trap = _BundleControlAttributes.trap_enabled;
        _BundleActive = FALSE;
        _BundleBodyActive = FALSE;
        ClearBundleHeaderState();
        _BARG.block_type = BundleKind_Standard;
        _BARG.transfer_type = BundleTransfer_Fallthrough;
        _BARG.taken = FALSE;
        _BARG.bpcn = Zeros{PTO_XLEN};
        _BundleSequentialPC = Zeros{PTO_XLEN};
        _FrameStackReturnTarget = Zeros{PTO_XLEN};
        WriteBPC(Zeros{PTO_XLEN});
        WriteTPC(next_pc);
        if post_commit_trap then
            // SetFault snapshots the already committed, cleared block state.
            // Recovering that context resumes next_pc, never the retired
            // block or its BSTOP instruction.
            SetFault(Fault_BundlePostCommit, next_pc);
        end;
    end;
end;
```
<!-- GENERATED-ASL-END: unit -->
