<!-- GENERATED FROM: asl/block/execution/BSTART.SYS.asl -->
# BSTART.SYS

**Normative ASL source:** `asl/block/execution/BSTART.SYS.asl`

Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.

## Normative identity {#PTO-INST-BLOCK-BSTART-SYS}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-bstart-sys-purpose role=purpose -->
## BSTART.SYS 的作用

`BSTART.SYS` 打开一个 System 块。块（也称指令束）是一段 header 命令和标量主体指令，结束于提交边界：`BSTOP` 或下一条 `BSTART`。System 块是系统标量操作可用的块类型，例如 `SSRSET`、`FENCE.I`、`TLB.IALL` 和 `ACRC`。

该助记符只有一种 32 位形式 `BSTART.SYS FALL`，匹配值为 `0x00001081`。它没有转移目标，也不运行 Tile 操作。

<!-- PTO-READER-BLOCK: block-bstart-sys-mechanism role=mechanism -->
## 位置与机制

[指令束启动分派](../model/dispatch/start.md)处理该形式。其转移类型为 `Fallthrough`，因此候选目标是 `BSTART` 地址加 4。分派先提交有效前驱，并且只有当该提交选择本 `BSTART` 地址作为下一个 `TPC` 时才打开 System 块。

随后[开始](../model/lifecycle/begin.md)把 `BPC` 设为 `BSTART` 地址，把 `BARG` 块类型设为 System。对于 System 块，它忽略传入的转移：写入 `BARG` 转移 `Fallthrough`、`taken` 为假、`BPCN` 为零。

设计要点：System 块没有候选后续地址，因此 `BARG` 保存固定的非选择值。提交时 `BARGCommitPC` 总是返回顺序后续地址，任何残留目标都无法改变程序流向。

<!-- PTO-READER-BLOCK: block-bstart-sys-inputs role=inputs-outputs -->
## 操作数与 header 角色

- `simm17` 占据位 `31:15`，必须为零。非零值保留给扩展。
- 该形式没有 `DataType`、选择器或目标操作数。

在主体中，`SETC.TGT` 无法写入目标：`BundleCommitTargetWritable` 仅对 Standard 和 Floating 块为真，因此在 System 块中它引发 `Fault_BundleControl`。

<!-- PTO-READER-BLOCK: block-bstart-sys-effects role=effects -->
## 待处理状态与完成

成功的 `BSTART.SYS` 清除每指令束标志（包括 `_SystemBlockTerminalPending`），记录 `BPC`，设置 System 块类型，并把 `TPC` 移到下一条指令。该形式没有内存效果。

在块主体有效期间，标量分派器接受系统标量操作；在 System 块主体之外它们引发 `Fault_BundleControl`。`ACRC` 设置 `_SystemBlockTerminalPending` 之后，[顶层分派](../model/dispatch/top-level.md)只接受 `BSTOP` 或 `BSTART` 作为下一条块命令。

提交时，块在顺序后续地址继续。

<!-- PTO-READER-BLOCK: block-bstart-sys-constraints role=constraints -->
## 合法性与故障边界

- 非零 `simm17` 不满足操作数合法性，在前驱提交之前引发 `Fault_IllegalInstruction`。
- 如果前驱提交失败，或选择了本 `BSTART` 之外的下一 PC，则不会安装 System 块，前驱的结果保持有效。
- 块仍有效时执行开始会引发 `Fault_BundleControl`；分派通过先提交前驱来避免这种情况。

设计要点：固定为零的载荷使唯一编码保持无歧义。所有非零值都保留并被拒绝，因此以后的扩展可以分配它们而不改变现有代码的含义。

<!-- PTO-READER-BLOCK: block-bstart-sys-example role=example -->
## 非规范示例

以下为非规范示例，仅用于说明当前所有者，不替代其定义。

```asm
BSTART.SYS FALL
```

假设 `BSTART.SYS FALL` 位于 `0x2000`，主体包含 `FENCE.I`，随后是位于 `0x2008` 的 4 字节 `BSTOP`。开始之后，`BPC` 为 `0x2000`，`BARG.BPCN` 为零，`TPC` 为 `0x2004`。由于主体位于 System 块中，`FENCE.I` 可用。`BSTOP` 以后续地址 `0x200C` 提交，而 System `BARG` 从不选择 `BPCN`，因此 `TPC` 变为 `0x200C`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
BSTART.SYS FALL
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| bstart_sys_32_762d9d84a6d8 | L32 | 32 | 0x00001081 / 0x00007fff | [{"field":"simm17","operator":"one-of","values":[0]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| bstart_sys_32_762d9d84a6d8 | simm17 | 17 | signed | [{"instruction_lsb":15,"value_lsb":0,"width":17}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| bstart_sys_32_762d9d84a6d8 | simm17 | 17 | 0 | none | 1–131071 | fixed-zero fallthrough payload; nonzero values are extension-reserved | Encoded zero supplies a zero displacement or zero immediate value. |

- `bstart_sys_32_762d9d84a6d8.simm17` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| simm17 | fixed-zero fallthrough payload; nonzero values are extension-reserved |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/execution/BSTART.SYS.asl -->
```asl
readonly func InstructionContractMatches_BSTART_SYS(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_bstart_sys_32_762d9d84a6d8);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.SYS retires any active predecessor block, then opens one system block whose header commands execute sequentially until BSTOP or the next BSTART.
SYS has no candidate transfer: BPCN, TYPE, and TAKEN are inapplicable and cannot select the next PC.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/execution/BSTART.SYS.asl -->
```asl
readonly func InstructionContractHandler_BSTART_SYS() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;

readonly func InstructionContractBundleKind_BSTART_SYS()
    => BundleKind
begin
    return BundleKind_System;
end;

pure func InstructionContractStartsBundle_BSTART_SYS()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- The encoded simm17 field is fixed to zero; nonzero values are extension-reserved.

## Legality

- Only simm17=0 is accepted; every nonzero payload is extension-reserved.

## State effects

- On success BPC records the BSTART address and BARG.BlockType becomes SYS. BPCN, TYPE, and TAKEN are inapplicable and are canonicalized to non-selecting values.
- Header execution and the eventual block continuation are sequential.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- The fixed-zero payload and form legality are checked before predecessor retirement. New SYS BARG state is installed only after successful retirement.

## Exceptions

- Any nonzero simm17 in the SYS FALL family is extension-reserved and raises before predecessor retirement or new BARG effects.
- If predecessor commit fails, the old block and continuation remain authoritative and no system block is installed.

## Examples

- BSTART.SYS FALL
