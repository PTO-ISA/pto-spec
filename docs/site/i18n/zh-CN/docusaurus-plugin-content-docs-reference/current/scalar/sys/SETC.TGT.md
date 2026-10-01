<!-- GENERATED FROM: asl/scalar/sys/SETC.TGT.asl -->
# SETC.TGT

**Normative ASL source:** `asl/scalar/sys/SETC.TGT.asl`

SETC.TGT snapshots SrcL into BARG.BPCN for the active Standard or Floating block.

## Normative identity {#PTO-INST-SCALAR-SETC-TGT}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-setc-tgt-purpose role=purpose -->
## SETC.TGT 的作用

`SETC.TGT` 设置活动块的候选下一 PC。它把 Reg5 源 `SrcL` 快照进 `BARG.BPCN`，也就是块边界在延续规则要求候选时稍后选作下一 PC 的字段。

<!-- PTO-READER-BLOCK: scalar-setc-tgt-mechanism role=mechanism -->
## 系统机制

`InstructionContractHandler_SETC_TGT` 选择 `ScalarHandler_SetCommitTarget`（`asl/scalar/sys/SETC.TGT.asl:18`），且 `InstructionContractRequiresCommitTargetBlock_SETC_TGT` 返回 `TRUE`（`asl/scalar/sys/SETC.TGT.asl:30`）。该操作的适用性规则是 `BundleCommitTargetWritable`，它要求活动 bundle 且块种类为 Standard 或 Floating（`asl/scalar/model/sys/semantics.asl:316`）。

`InstructionContractRequiresSystemBlock_SETC_TGT` 返回 `FALSE`（`asl/scalar/sys/SETC.TGT.asl:24`），因此该指令不是 SYS 块操作：它就在自己所修改目标的那个块中运行。

<!-- PTO-READER-BLOCK: scalar-setc-tgt-inputs-outputs role=inputs-outputs -->
## 输入与输出

`SrcL` 是唯一操作数，即来自 R0..R23、T#1..T#4 或 U#1..U#4 的 Reg5 源（`asl/scalar/sys/SETC.TGT.asl:1`）。它提供成为新候选 PC 的完整 XLEN 值。

没有目的地操作数。输出是块状态字段 `BARG.BPCN` 本身。`SrcL` 中的编码零命名架构零 GPR，因此零是作为真实值写入的，而不是省略。

<!-- PTO-READER-BLOCK: scalar-setc-tgt-effects role=effects -->
## 架构效果

成功时该指令用已快照的源值替换 `BARG.BPCN`，并把 `TPC` 推进 4 字节（`asl/scalar/model/sys/semantics.asl:336`、`asl/scalar/model/dispatch/top-level.asl:56`）。`BARG` 中的其他部分都保留：`BPC`、块种类、传送种类与 `TAKEN` 都不被触碰。

设计要点：`BARG.BPCN` 只是候选。块边界通过延续规则选择它，该规则对直接、调用、间接、间接调用和返回传送取候选，而对条件传送只在 `TAKEN` 被置位时取候选（`asl/block/model/state/barg.asl:14`）。因此写入候选本身并不改变块继续的位置。

该指令不执行普通标量内存访问，不写寄存器，也不消耗源；源保持其值。

<!-- PTO-READER-BLOCK: scalar-setc-tgt-constraints role=constraints -->
## 位置与拒绝边界

位置是唯一的门，而且它限制的是种类而不是位置：该次尝试需要活动的 Standard 或 Floating 块，任何其他块种类都会在活动块的 `TPC` 值处引发 `Fault_BundleControl`。源只在该判定之后被读取，被拒绝的尝试让 `BARG.BPCN` 与待决延续状态保持不变，这正是归属方 NDF 条款的要求。

没有保留的源编码需要拒绝，因为每个 Reg5 源选择器都已分配；也不受访问环限制。

<!-- PTO-READER-BLOCK: scalar-setc-tgt-example role=example -->
## 非规范示例

该写法示例只用于说明；确切合法性与效果仍由下方生成契约定义。

在活动的 Standard 块体内，GPR 持有 0x1000 时 `setc.tgt SrcL` 把 0x1000 快照进 `BARG.BPCN`。如果该块以直接传送离开，边界会选择 `BARG.BPCN`，因此执行在 0x1000 继续；如果它以 `TAKEN` 为清除的条件传送离开，则顺序延续胜出，新的 `BARG.BPCN` 不被使用。在 SYS 块体内运行同一指令则会引发 `Fault_BundleControl`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
setc.tgt SrcL
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| setc_tgt_32_c02656d3a2b8 | L32 | 32 | 0x0000403b / 0xfff07fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| setc_tgt_32_c02656d3a2b8 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| setc_tgt_32_c02656d3a2b8 | SrcL | 5 | 0–31 | none | none | Reg5 source: R0..R23, T#1..T#4, or U#1..U#4 | Encoded zero names the architectural zero GPR. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 source: R0..R23, T#1..T#4, or U#1..U#4 |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/SETC.TGT.asl -->
```asl
readonly func InstructionContractOperation_SETC_TGT()
    => ScalarOperation
begin
    return ScalarOperation_SETC_TGT;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
SETC.TGT is legal in the body of an active Standard or Floating block and is not a SYS-block instruction.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/SETC.TGT.asl -->
```asl
readonly func InstructionContractHandler_SETC_TGT()
    => ScalarSemanticHandler
begin
    return ScalarHandler_SetCommitTarget;
end;

pure func InstructionContractRequiresSystemBlock_SETC_TGT()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractRequiresCommitTargetBlock_SETC_TGT()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractWritesBARGBPCN_SETC_TGT()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every displayed operand is encoded explicitly. Encoded zero is an assigned value and never denotes omission.

## Legality

- Every available Reg5 source selector is assigned; block applicability is checked before the source read.

## State effects

- Replace only BARG.BPCN with the complete XLEN source; preserve BPC, BlockType, TYPE, TAKEN, and all other block state.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Check block applicability, snapshot SrcL, write BARG.BPCN, and then advance TPC.

## Exceptions

- Invalid block placement raises Illegal Block Exception before encoded-field legality or effects.
- A reserved encoding or rejected access raises Illegal Instruction before destination, queue, system-state, or TPC effects.

## Examples

- setc.tgt SrcL
