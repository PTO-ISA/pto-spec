<!-- GENERATED FROM: asl/block/model/state/barg.asl -->
# Barg

**Normative ASL source:** `asl/block/model/state/barg.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-STATE-BARG}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-state-barg-purpose role=purpose-scope -->
## 用途与范围

本单元定义指令束参数寄存器 `BARG` 如何在指令束提交后选择执行继续的位置。它还定义了 `LSRGET` 可在指令束主体内读取的三个 `BARG` 字。

其契约 `PTO-BARG-CONTINUATION-001` 规定，`BSTART` 初始化 `BARG` 的每个字段，并且只有 `BSTOP` 或下一个 `BSTART` 这一边界会选择下一个 PC。

<!-- PTO-READER-BLOCK: block-model-state-barg-concepts role=concepts-state -->
## 概念与可见状态

`BARG` 有五个部分：

- `BPC`，当前 `BSTART` 的地址，保存在程序控制状态中。
- `BlockType`，块类别，例如 `Standard`、`Floating` 或 `System`。
- `BPCN`，候选的下一个 PC。
- `TYPE`，转移规则：`Fallthrough`、`Direct`、`Conditional`、`Call`、`Return`、`Indirect` 或 `IndirectCall`。
- `TAKEN`，只对 `Conditional` 有意义。

`BARG` 没有陷阱字段。`B.CATR` 的陷阱请求保存在指令束控制属性中。

<!-- PTO-READER-BLOCK: block-model-state-barg-rules role=rules-interactions -->
## 规则与交互

`BARGSelectsBPCN` 对 `Direct`、`Call`、`Indirect`、`IndirectCall` 和 `Return` 为 true，对 `Conditional` 则在 `TAKEN` 置位时为 true。`BARGCommitPC(continuation)` 在选中 `BPCN` 时返回 `BPCN`，否则返回顺序继续地址。

`LSRGET` 标识符如下：

| ID | 字 | 适用条件 |
| --- | --- | --- |
| 0 | `BPC` | 活动的指令束主体 |
| 1 | `BPCN` | `Standard` 或 `Floating` 块的活动主体 |
| 2 | 打包控制字 | 活动的指令束主体 |

打包控制字在 bits `3:0` 中保存块种类编码。对于 `Standard` 和 `Floating` 块，它在 bits `6:4` 中保存转移编码，在 bit 7 中保存 `TAKEN`。Bits 8 到 12 保存 `B.CATR` 的 atomic、acquire、release、far 和 dimension-reduction 标志。所有更高位均为零。

设计要点：由一条记录决定继续位置。`SETC.TGT` 重写 `BPCN`，`SETC` 条件设置 `TAKEN`，但两者都不直接改变控制流。提交时一次性读取最终的 `BARG`，因此程序在每个指令束中恰好看到一次转移，且只在指令束提交时发生。

设计要点：`BARGHasCandidateWord` 只对 `Standard` 和 `Floating` 块为 true。对于其他种类，ID 1 不适用，打包字的转移位和 `TAKEN` 位保持为零，因此程序永远不会从这些种类读到候选目标。

<!-- PTO-READER-BLOCK: block-model-state-barg-boundaries role=boundaries -->
## 架构边界

`ReadCurrentBARGWord` 断言适用性。`LSRGET` 调用方会先检查适用性，并在 ID 不适用或没有活动的指令束主体时引发 `Fault_BundleControl`。

本单元不写入 `BARG`。写入它的是 Begin、提交目标设置命令、条件设置命令、stop、reset 以及陷阱上下文恢复。

<!-- PTO-READER-BLOCK: block-model-state-barg-example role=example-usage -->
## 非规范阅读示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

在 `BPCN = 0x2000` 的 `Standard` 条件块主体中，一条 `SETC` 置位 `TAKEN`。`LSRGET` ID 1 返回 `0x2000`。ID 2 返回块种类编码 `0000`、bits `6:4` 中的转移编码 `010`，以及 bit 7 中的 1。在 `BSTOP` 时，`BARGCommitPC` 选择 `0x2000`。

<!-- PTO-READER-BLOCK: block-model-state-barg-related role=related-owners-navigation -->
## 相关所有者

- [Begin](../lifecycle/begin.md) 初始化 `BARG`。
- [进入与停止](../lifecycle/enter-stop.md)在提交时消费它。
- [指令束编码](../schema/bundle-encoding.md)定义种类编码和转移编码。
- [LSRGET](../../../scalar/sys/LSRGET.md) 和 [SETC.TGT](../../../scalar/sys/SETC.TGT.md) 在主体中读取和写入它。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/state/barg.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-STATE-BARG","surface":"block","classification":["model","state","barg"],"depends_on":["PTO-BLOCK-MODEL-STATE-CONTROL-STATE"]}
// BARG is the sole block-continuation authority. BPC names the current BSTART;
// BlockType identifies the block class; BPCN is the candidate next PC; TYPE
// selects the continuation rule; TAKEN is meaningful only for COND. BARG has
// no TRAP field.

// NDF-BEGIN: PTO-BARG-CONTINUATION-001
// ndf: kind=contract level=L1 layer=block status=accepted
// BSTART MUST initialize BARG.BPC, BARG.BlockType, BARG.BPCN, BARG.TYPE, and
// BARG.TAKEN; BSTOP or the next BSTART MUST be the only boundary that selects
// the next PC from BARG.BPCN or the sequential continuation.
// NDF-END: PTO-BARG-CONTINUATION-001

readonly func BARGSelectsBPCN() => boolean
begin
    return _BARG.transfer_type == BundleTransfer_Direct ||
           _BARG.transfer_type == BundleTransfer_Call ||
           _BARG.transfer_type == BundleTransfer_Indirect ||
           _BARG.transfer_type == BundleTransfer_IndirectCall ||
           _BARG.transfer_type == BundleTransfer_Return ||
           (_BARG.transfer_type == BundleTransfer_Conditional && _BARG.taken);
end;

readonly func BARGCommitPC(continuation: Word) => Word
begin
    if BARGSelectsBPCN() then return _BARG.bpcn;
    else return continuation;
    end;
end;

readonly func BARGHasCandidateWord() => boolean
begin
    return _BARG.block_type == BundleKind_Standard ||
           _BARG.block_type == BundleKind_Floating;
end;

readonly func PackCurrentBARGControlWord() => Word
begin
    var value: Word = Zeros{PTO_XLEN};
    value[3:0] = BundleKindCode(_BARG.block_type);
    if BARGHasCandidateWord() then
        value[6:4] = BundleTransferCode(_BARG.transfer_type);
        value[7] = if _BARG.taken then '1' else '0';
    end;
    value[8] = if _BundleControlAttributes.atomic then '1' else '0';
    value[9] = if _BundleControlAttributes.acquire then '1' else '0';
    value[10] = if _BundleControlAttributes.release then '1' else '0';
    value[11] = if _BundleControlAttributes.far then '1' else '0';
    value[12] =
        if _BundleControlAttributes.dimension_reduction then '1' else '0';
    return value;
end;

readonly func CurrentBARGWordApplicable(identifier: bits(12)) => boolean
begin
    if !_BundleActive || !_BundleBodyActive then
        return FALSE;
    end;
    case UInt(identifier) of
        when 0 => return TRUE;
        when 1 => return BARGHasCandidateWord();
        when 2 => return TRUE;
        otherwise => return FALSE;
    end;
end;

readonly func ReadCurrentBARGWord(identifier: bits(12)) => Word
begin
    assert CurrentBARGWordApplicable(identifier);
    case UInt(identifier) of
        when 0 => return ReadBPC();
        when 1 => return _BARG.bpcn;
        when 2 => return PackCurrentBARGControlWord();
        otherwise => unreachable;
    end;
end;
```
<!-- GENERATED-ASL-END: unit -->
