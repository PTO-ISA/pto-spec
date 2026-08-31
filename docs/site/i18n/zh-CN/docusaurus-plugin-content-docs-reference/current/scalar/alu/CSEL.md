<!-- GENERATED FROM: asl/scalar/alu/CSEL.asl -->
# CSEL

**Normative ASL source:** `asl/scalar/alu/CSEL.asl`

CSEL snapshots three Reg5 sources, selects SrcL for a nonzero predicate or its optionally negated SrcR for zero, and publishes through the common scalar destination map.

## Normative identity {#PTO-INST-SCALAR-CSEL}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-csel-purpose role=purpose -->
## CSEL 的作用

`CSEL` 是一条 32 位标量 ALU 指令。它谓词非零时选择左值，否则选择可选取反的右值；当前指令契约定义结果发布路径以及任何额外状态效果。

<!-- PTO-READER-BLOCK: scalar-csel-mechanism role=mechanism -->
## 结果形成方式

执行时先对编码输入做快照，然后谓词非零时选择左值，否则选择可选取反的右值，最后才产生目标效果。

- `SrcRType` 在操作专属的算术或逻辑步骤之前选择右源转换方式。
- 结果发布使用当前指令契约为该助记符确定的位宽与扩展规则。

<!-- PTO-READER-BLOCK: scalar-csel-inputs role=inputs-outputs -->
## 输入与目标

- `SrcP` 是 5 位字段，通过 Reg5 选择谓词值。
- `SrcL` 是 5 位字段，选择谓词为真时使用的值。
- `SrcR` 是 5 位字段，选择谓词为假时使用的值。
- `SrcRType` 是 2 位字段，选择应用到假侧源的 CSEL 转换。
- `RegDst` 是 5 位字段，选择 Reg5 结果目标，或丢弃结果。

这些角色来自当前指令契约；T/U 源只被读取和快照，不会因源选择而出队。编码零的精确含义列在下方生成的默认值章节中。

<!-- PTO-READER-BLOCK: scalar-csel-effects role=effects -->
## 效果与顺序

所有标量源都在目标效果前完成快照。完成后的值随后通过 `RegDst` 按当前标量目标映射发布。

该 ALU 操作不产生内存效果。成功完成架构效果后，`TPC` 前进 4 字节。

该操作不会产生隐藏的标量发布目标或隐式内存访问。架构变化仅限于当前契约列出的状态效果。

<!-- PTO-READER-BLOCK: scalar-csel-constraints role=constraints -->
## 合法性与故障边界

三个源都会在选择前读取；即使谓词最终不选择某一侧，该侧不可用的 T/U 源仍会在发布前触发 `Fault_IllegalInstruction`。

下方生成的合法性表是已分配字段值、保留编码和目标丢弃编码的权威说明。解码与源可用性检查先于架构效果完成。

<!-- PTO-READER-BLOCK: scalar-csel-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

以一个小型 `CSEL` 示例说明：谓词为 `0`、假侧值为 `3` 并选择取负转换时，发布按 `2^PTO_XLEN` 回绕的 `-3`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
csel SrcP, SrcL, SrcR<.neg>, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| csel_32_ba77cbad3c99 | L32 | 32 | 0x00000077 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| csel_32_ba77cbad3c99 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| csel_32_ba77cbad3c99 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| csel_32_ba77cbad3c99 | SrcP | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |
| csel_32_ba77cbad3c99 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| csel_32_ba77cbad3c99 | SrcRType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| csel_32_ba77cbad3c99 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| csel_32_ba77cbad3c99 | SrcL | 5 | 0–31 | none | none | Reg5 true-value source | Encoded zero reads the architectural zero GPR. |
| csel_32_ba77cbad3c99 | SrcP | 5 | 0–31 | none | none | Reg5 predicate source | Encoded zero reads the architectural zero GPR and therefore selects the false value. |
| csel_32_ba77cbad3c99 | SrcR | 5 | 0–31 | none | none | Reg5 false-value source | Encoded zero reads the architectural zero GPR. |
| csel_32_ba77cbad3c99 | SrcRType | 2 | 0–3 | none | none | CSEL-specific false-source modifier selector | Encoded zero is an assigned unmodified false-source alias. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcP | Reg5 predicate source |
| SrcL | Reg5 true-value source |
| SrcR | Reg5 false-value source |
| SrcRType | CSEL-specific false-source modifier selector |
| RegDst | Reg5 destination or discard |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/CSEL.asl -->
```asl
readonly func InstructionContractOperation_CSEL()
    => ScalarOperation
begin
    return ScalarOperation_CSEL;
end;

pure func InstructionContractRightModifier_CSEL(encoded: bits(2))
    => ScalarRightModifier
begin
    return DecodeScalarSelectRightModifier(encoded);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/CSEL.asl -->
```asl
readonly func InstructionContractHandler_CSEL()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarConditionalSelect;
end;

pure func InstructionContractFalseValue_CSEL(
    right: Word,
    encoded_modifier: bits(2))
    => Word
begin
    let modifier = InstructionContractRightModifier_CSEL(encoded_modifier);
    return ApplySelectModifier(right, modifier);
end;

pure func InstructionContractResult_CSEL(
    predicate: Word,
    selected_true: Word,
    selected_false: Word,
    encoded_modifier: bits(2))
    => Word
begin
    let prepared_false = InstructionContractFalseValue_CSEL(
        selected_false,
        encoded_modifier);
    return ScalarConditionalSelect(
        predicate,
        selected_true,
        prepared_false);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcP, SrcL, SrcR, SrcRType, and RegDst are required encoded fields; no field can be omitted.
- Assembly without .neg uses the canonical unmodified alias selected by the assembler. Raw SrcRType codes 00, 01, and 11 are assigned unmodified aliases; raw code 10 is .neg.

## Legality

- SrcP, SrcL, and SrcR codes 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consumption.
- All four SrcRType values are assigned. Codes 00, 01, and 11 leave SrcR unchanged; code 10 negates the complete XLEN value modulo 2^PTO_XLEN.
- RegDst codes 0 and 24..29 discard, codes 1..23 write GPRs, code 30 pushes U, and code 31 pushes T.

## State effects

- Snapshot SrcP, SrcL, and SrcR before any destination effect. Only an all-zero SrcP is false; every nonzero bit pattern is true.
- For a true predicate publish the complete snapshotted SrcL. For a false predicate publish the complete snapshotted SrcR after the CSEL-specific raw modifier; negation wraps modulo 2^PTO_XLEN and does not fault.
- No memory, reservation, descriptor, numeric-status, block, privilege, branch-target, or other control state changes. Successful execution advances TPC by four bytes.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Read all three Reg5 sources eagerly and non-consumingly before the destination write, even when the predicate outcome does not select one value.
- Publish the selected value, then advance TPC by four bytes.

## Exceptions

- An unavailable selected T/U queue source raises Fault_IllegalInstruction before the destination effect and before TPC advances, including a source not selected by the predicate outcome.
- CSEL raises no arithmetic, memory, alignment, permission, or control-flow exception.

## Examples

- csel a0, a1, a2, ->a3
- csel t#1, u#1, a0.neg, ->u
- csel zero, a0, a1, ->zero
