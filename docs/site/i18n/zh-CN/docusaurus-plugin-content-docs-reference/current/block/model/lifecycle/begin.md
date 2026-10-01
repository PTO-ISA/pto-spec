<!-- GENERATED FROM: asl/block/model/lifecycle/begin.asl -->
# Begin

**Normative ASL source:** `asl/block/model/lifecycle/begin.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-LIFECYCLE-BEGIN}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-lifecycle-begin-purpose role=purpose-scope -->
## 用途与范围

本单元定义指令束打开时发生的事情。指令束（也称为 block）是一组指令：它以某种 `BSTART` 形式开始，从 `B.DIM`、`B.DATR` 和 `B.IOT` 等头部命令收集配置，并在提交边界处结束：`BSTOP` 或下一个 `BSTART`。

`BeginBundleAt` 是唯一的状态转换：它把指令束标记为活动，并记录指令束提交后程序在何处继续。`BeginBundle` 是同一转换，只是以当前 `TPC` 作为起始地址。

<!-- PTO-READER-BLOCK: block-model-lifecycle-begin-concepts role=concepts-state -->
## 概念与可见状态

成功的 begin 写入以下状态。

- `_BundleActive` 变为 true，`_BundleBodyActive` 变为 false。指令束此时处于头部阶段。
- 清除每个指令束的标记 `_BundleCommitTargetSet`、`_BundleConditionSet` 和 `_SystemBlockTerminalPending`。
- `BARG` 接收 block 种类、转移类型、`taken` 标志和候选下一地址 `BPCN`。`BARG` 是指令束参数寄存器：它是决定指令束提交时执行去向的唯一记录。
- `_BundleSequentialPC` 接收 `BSTART` 之后那条指令的地址，`_FrameStackReturnTarget` 接收所提供的返回目标。
- `BPC` 被设为 `BSTART` 的地址，`TPC` 被设为顺序地址，因此下一条取出的指令是第一条头部命令。
- 从 `_NextBundleExecutionDomainToken` 取得一个新的执行域令牌，并递增该计数器。

对于调用或间接调用，`_ReturnAddress` 和 GPR 10 也会被写入返回目标。

<!-- PTO-READER-BLOCK: block-model-lifecycle-begin-rules role=rules-interactions -->
## 规则与交互

begin 在两种情况下发生故障，并且两种情况下都不改变任何指令束状态。如果已有活动指令束，它在当前 `TPC` 处引发 `Fault_BundleControl`。如果目标地址的位 0 被置位，它以该目标引发 `Fault_InstructionPC`。

系统 block（`BundleKind_System`）忽略所提供的转移。其 `BARG` 被写为 `Fallthrough`、`taken` 为 false、`BPCN` 为零。

设计要点：SYS block 没有候选延续，因此它存储一个固定的规范值，而不是编码所提供的任意值。因此其 `BARG` 在提交时永远不会选择 `BPCN`，编码中残留的目标也不会进入提交决策。

设计要点：`BSTART` 执行时不改变控制流。它只把候选目标记录到 `BARG.BPCN`，并把 `TPC` 移到下一条顺序指令。转移稍后在提交边界、整个指令束通过验证之后才被应用。因此，在退役之前发生故障的指令束尚未重定向程序。

设计要点：指令束的每次动态执行都会获得一个新的执行域令牌，即使同一个 `BSTART` 地址再次运行也是如此。ASL 注释说明了原因：静态 `BSTART` 地址是程序位置，永远不能代表动态重放或 squash 身份。因此，同一循环体的两次运行是不同的写者。

<!-- PTO-READER-BLOCK: block-model-lifecycle-begin-boundaries role=boundaries -->
## 架构边界

本单元不译码 `BSTART` 编码，不验证操作描述符，也不提交前驱指令束。这些步骤由分派所有者先行完成。它检查目标，提交任何活动的前驱，并且只有当该提交选择此 `BSTART` 地址作为下一 `TPC` 时才继续；如果前驱转移到了别处，此 `BSTART` 位于未被选中的路径上，不会被安装。否则，分派清除头部状态，然后调用 `BeginBundleAt`。在无故障的 begin 之后，它安装操作描述符。

此处的奇数目标检查适用于传入的目标。之后的 `SETC.TGT` 可能替换 `BPCN`，该最终值会在提交时再次检查。

<!-- PTO-READER-BLOCK: block-model-lifecycle-begin-example role=example-usage -->
## 非规范阅读示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

假设一条 4 字节的 `BSTART DIRECT, <label>` 位于地址 `0x1000`，标签位于 `0x2000`。begin 之后，`BPC` 为 `0x1000`，`BARG.BPCN` 为 `0x2000`，`_BundleSequentialPC` 和 `TPC` 为 `0x1004`，指令束处于头部阶段。执行在 `0x1004` 处继续。跳转到 `0x2000` 只在指令束提交时发生。

<!-- PTO-READER-BLOCK: block-model-lifecycle-begin-related role=related-owners-navigation -->
## 相关所有者

- [指令束启动分派](../dispatch/start.md)验证描述符、提交前驱并调用此转换。
- [BARG 辅助函数](../state/barg.md)定义所记录的字段如何在提交时选择下一 PC。
- [进入与停止](enter-stop.md)定义主体进入以及提交时对此状态的清除。
- [BSTART](../../lifecycle/BSTART.md) 是普通启动形式的指令页面。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/lifecycle/begin.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-LIFECYCLE-BEGIN","surface":"block","classification":["model","lifecycle","begin"],"depends_on":["PTO-BLOCK-MODEL-SCHEMA-ATTRIBUTES"]}
func BeginBundleAt(start_pc: Word, kind: BundleKind, transfer: BundleTransfer,
                   target: Word, sequential: Word, return_target: Word,
                   taken: boolean)
begin
    if _BundleActive then
        SetFault(Fault_BundleControl, ReadTPC());
    elsif target[0] == '1' then
        SetFault(Fault_InstructionPC, target);
    else
        _BundleActive = TRUE;
        _BundleBodyActive = FALSE;
        _BundleCommitTargetSet = FALSE;
        _BundleConditionSet = FALSE;
        _SystemBlockTerminalPending = FALSE;
        _BARG.block_type = kind;
        if kind == BundleKind_System then
            // SYS has no architectural candidate continuation. Keep the
            // shared representation in a canonical non-selecting state.
            _BARG.transfer_type = BundleTransfer_Fallthrough;
            _BARG.taken = FALSE;
            _BARG.bpcn = Zeros{PTO_XLEN};
        else
            _BARG.transfer_type = transfer;
            _BARG.taken = taken;
            _BARG.bpcn = target;
        end;
        _BundleSequentialPC = sequential;
        _FrameStackReturnTarget = return_target;
        // Each dynamic block execution receives a distinct mathematical
        // domain identity. Static BSTART addresses remain program locations
        // and never stand in for dynamic replay/squash identity.
        _BundleExecutionDomainToken = _NextBundleExecutionDomainToken;
        _NextBundleExecutionDomainToken =
            _NextBundleExecutionDomainToken + 1;
        // BPC is the address of this BSTART. BPCN is retained in
        // BARG.BPCN until BSTOP or the next BSTART commits the block.
        WriteBPC(start_pc);
        // BSTART installs the transfer selected for the bundle commit. Header
        // commands remain sequential until BSTOP or the next BSTART commits it.
        WriteTPC(sequential);
        if transfer == BundleTransfer_Call ||
           transfer == BundleTransfer_IndirectCall then
            _ReturnAddress = return_target;
            WriteGPR(10, return_target);
        end;
    end;
end;

func BeginBundle(kind: BundleKind, transfer: BundleTransfer, target: Word,
                 sequential: Word, return_target: Word, taken: boolean)
begin
    BeginBundleAt(ReadTPC(), kind, transfer, target, sequential,
        return_target, taken);
end;
```
<!-- GENERATED-ASL-END: unit -->
