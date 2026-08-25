<!-- GENERATED FROM: asl/scalar/alu/C.SETC.TGT.asl -->
# C.SETC.TGT

**Normative ASL source:** `asl/scalar/alu/C.SETC.TGT.asl`

Snapshot one scalar source value into the active block BARG.BPCN.

## Normative identity {#PTO-INST-SCALAR-C-SETC-TGT}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-c-setc-tgt-purpose role=purpose -->
## C.SETC.TGT 的作用

`C.SETC.TGT` 是一条 16 位标量 ALU 指令。它把所选标量值记录为活动块的提交目标；当前指令契约定义结果发布路径以及任何额外状态效果。

<!-- PTO-READER-BLOCK: scalar-c-setc-tgt-mechanism role=mechanism -->
## 结果形成方式

执行时先对编码输入做快照，然后把所选标量值记录为活动块的提交目标，最后才产生目标效果。

- 操作专属的宽度、有符号性和立即数规则由助记符以及下方编码字段共同确定。
- 结果发布使用当前指令契约为该助记符确定的位宽与扩展规则。

<!-- PTO-READER-BLOCK: scalar-c-setc-tgt-inputs role=inputs-outputs -->
## 输入与目标

- `SrcL` 是 5 位字段，选择绝对 GPR、T#1..T#4 或 U#1..U#4 标量值。

这些角色来自当前指令契约；T/U 源只被读取和快照，不会因源选择而出队。编码零的精确含义列在下方生成的默认值章节中。

<!-- PTO-READER-BLOCK: scalar-c-setc-tgt-effects role=effects -->
## 效果与顺序

所选源值在 `BARG.BPCN` 改变前完成快照，因此源别名不会观察到新的提交目标。

该 ALU 操作不产生内存效果。成功完成架构效果后，`TPC` 前进 2 字节。

该操作不会产生隐藏的标量发布目标或隐式内存访问。架构变化仅限于当前契约列出的状态效果。

<!-- PTO-READER-BLOCK: scalar-c-setc-tgt-constraints role=constraints -->
## 合法性与故障边界

该指令只在活动的 Standard 或 Floating 块中合法，并且每个活动块至多成功执行一次。目标对齐延后到块提交边界检查。

下方生成的合法性表是已分配字段值、保留编码和目标丢弃编码的权威说明。解码与源可用性检查先于架构效果完成。

<!-- PTO-READER-BLOCK: scalar-c-setc-tgt-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

以一个小型 `C.SETC.TGT` 示例说明：源值 `0x100` 完成快照后写入活动 `BARG.BPCN`；目标对齐仍延后到块提交时检查。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
c.setc.tgt srcL
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| c_setc_tgt_16_736be9cada01 | C16 | 16 | 0x001c / 0xf83f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| c_setc_tgt_16_736be9cada01 | SrcL | 5 | encoding-defined | [{"instruction_lsb":6,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| c_setc_tgt_16_736be9cada01 | SrcL | 5 | 0–31 | none | none | common scalar source: absolute GPR, T#1..T#4, or U#1..U#4 | Encoded zero names the architectural zero GPR. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | common scalar source: absolute GPR, T#1..T#4, or U#1..U#4 |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/C.SETC.TGT.asl -->
```asl
readonly func InstructionContractOperation_C_SETC_TGT() => ScalarOperation
begin
    return ScalarOperation_C_SETC_TGT;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
Applicable inside one active Standard or Floating block. The first successful occurrence owns the block target; a second occurrence is illegal.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/C.SETC.TGT.asl -->
```asl
readonly func InstructionContractHandler_C_SETC_TGT() => ScalarSemanticHandler
begin
    return ScalarHandler_SetCommitTarget;
end;

readonly func InstructionContractTarget_C_SETC_TGT(
    source_value: Word)
    => Word
begin
    return source_value;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- C.SETC.TGT has no omitted operand. SrcL code zero names the architectural zero GPR and snapshots numeric zero.

## Legality

- All SrcL codes 0..31 are assigned common scalar sources; relative sources are non-consuming and must be available when the instruction executes.
- C.SETC.TGT is legal only while a Standard or Floating block is active. At most one C.SETC.TGT may complete successfully in that block.
- Target alignment is not checked by C.SETC.TGT; the block commit boundary validates the final selected BARG.BPCN.

## State effects

- Read and snapshot the complete selected 64-bit source, then atomically replace active BARG.BPCN with that value.
- Set the block-private successful-C.SETC.TGT marker only after the target snapshot succeeds. Do not retain the selector and do not modify the generic commit-condition argument.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Applicability and duplicate checks precede source readiness and source read. Source readiness precedes the BARG.BPCN update.
- Later changes to the source register or queue cannot alter the pending target.

## Exceptions

- No active Standard or Floating block, or a second successful C.SETC.TGT in the active block, raises Fault_BundleControl before source readiness or any state effect.
- An unavailable relative source raises Fault_IllegalInstruction before changing BARG.BPCN, the uniqueness marker, TPC, or queue state.
- An odd snapshotted target is accepted by C.SETC.TGT and raises Fault_InstructionPC only if the later block commit selects it.

## Examples

- c.setc.tgt a0
- c.setc.tgt T#1
