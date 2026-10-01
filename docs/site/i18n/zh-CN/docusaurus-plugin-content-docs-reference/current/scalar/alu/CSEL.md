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

`CSEL` 读取三个 Reg5 源，并发布两个候选值之一：当谓词源不全为零时发布真值源，否则发布按编码可选取负后的假值源。

设计要点：谓词判断是“不全为零”，因此任何非零位型都为真，包括唯一置位位远离位零的值。调用者可以直接把掩码或比较结果作为条件传入，而不必先把它归一化成 `0` 或 `1`。

<!-- PTO-READER-BLOCK: scalar-csel-mechanism role=mechanism -->
## 结果形成方式

三个源都被快照。假候选先被准备：`SrcRType` 原始编码 `00`、`01` 和 `10` 让 `SrcR` 保持不变，原始编码 `11` 用按 `2^PTO_XLEN` 取模的 `0 - SrcR` 替换它。随后选择逻辑在谓词快照非零时发布真候选，在谓词为零时发布准备好的假候选。

设计要点：修饰在选出结果之前施加于假候选，因此取负永远不可能作用到真值上。在 `csel a0, a1, a2.neg, ->a3` 中两个可能结果是 `a1` 和 `-a2`，而这个形式无法对 `a1` 取负。

设计要点：`SrcRType` 的四个编码中有三个表示“不变”，因此省略 `.neg` 的汇编器必须从中选一个，其余两个仍是同一操作的合法编码。两条指令流可以在这些位上不同而结果完全相同。

设计要点：取负按 `2^PTO_XLEN` 回绕且不引发故障，因此对最负的值取负会重新发布该值本身，而不是溢出。

<!-- PTO-READER-BLOCK: scalar-csel-inputs role=inputs-outputs -->
## 输入与目标

- `SrcP` 是谓词：全零值选择假候选，任何非零值选择真候选。
- `SrcL` 是真值源，`SrcR` 是假值源；两者都使用 Reg5 映射，其中编码 `0..23` 是绝对 GPR，`24..27` 是 `T#1..T#4`，`28..31` 是 `U#1..U#4`，读取时不消费队列项。
- `SrcRType` 是两位假值源修饰选择器：`00`、`01` 和 `10` 是不变别名，`11` 是 `.neg`。
- `RegDst` 通过公共目标映射发布所选值：编码 `0` 和 `24..29` 丢弃，`1..23` 写 GPR，`30` 压入 `U`，`31` 压入 `T`。

设计要点：`SrcP` 的编码零读取架构零 GPR，因此 `csel zero, a0, a1, ->a2` 总是发布 `a1`。谓词在每个编码中都是真实操作数，绝不是被省略的字段。

<!-- PTO-READER-BLOCK: scalar-csel-effects role=effects -->
## 效果与顺序

三个源都在目标写之前被急切地、非消费地读取，即使谓词结果并不选择其中之一。因此与源同名的目标看到的是指令执行前的值：`csel a0, a1, a2, ->a0` 判断的是旧的 `a0`。所选值随后只发布一次。

`TPC` 前进 `4` 字节。只有 `T` 或 `U` 目标压入才会改变临时队列；内存、保留状态、描述符、数值状态、指令束、特权、分支目标和其他控制状态都不改变。

<!-- PTO-READER-BLOCK: scalar-csel-constraints role=constraints -->
## 合法性与故障边界

`SrcRType` 的四个取值都已分配，每个 Reg5 选择器的每个取值都已分配，固定编码位必须匹配规范形式。`CSEL` 没有任何保留的操作数。

所选 `T` 或 `U` 队列源不可用会在目标效果之前、`TPC` 前进之前引发 `Fault_IllegalInstruction`，包括谓词结果并不选择的源。`CSEL` 不会引发算术、内存、对齐、权限或控制流异常。

设计要点：预检覆盖的是编码选择器而不是胜出的值，因此当 `U#1` 不可用时，`csel t#1, a0, u#1, ->a2` 会引发故障，即使非零的 `T#1` 会发布 `a0`。故障判定在谓词被查看之前就已经由编码确定。

<!-- PTO-READER-BLOCK: scalar-csel-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

当 `a0` 保存 `5`、`a1` 保存 `7`、`a2` 保存 `9` 时，`csel a0, a1, a2, ->a3` 发布 `7`，因为非零谓词选择真候选。当 `a0` 保存 `0` 时，同一条指令发布 `9`，而 `csel a0, a1, a2.neg, ->a3` 发布 `-9`。规范形式 `csel t#1, u#1, a0.neg, ->u` 从 `T#1` 读取谓词、从 `U#1` 读取真候选，两者都不会被消费。
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
- Assembly without .neg uses the canonical unmodified alias selected by the assembler. Raw SrcRType codes 00, 01, and 10 are assigned unmodified aliases; raw code 11 is .neg.

## Legality

- SrcP, SrcL, and SrcR codes 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consumption.
- All four SrcRType values are assigned. Codes 00, 01, and 10 leave SrcR unchanged; code 11 negates the complete XLEN value modulo 2^PTO_XLEN.
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
