<!-- GENERATED FROM: asl/scalar/alu/HL.DIVW.asl -->
# HL.DIVW

**Normative ASL source:** `asl/scalar/alu/HL.DIVW.asl`

HL.DIVW computes a signed low-32-bit quotient/remainder pair from source snapshots, then publishes quotient followed by remainder.

## Normative identity {#PTO-INST-SCALAR-HL-DIVW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-divw-purpose role=purpose -->
## HL.DIVW 的作用

`HL.DIVW` 是一条 48 位标量 ALU 指令。它根据源快照同时计算有符号商和余数；当前指令契约定义结果发布路径以及任何额外状态效果。

<!-- PTO-READER-BLOCK: scalar-hl-divw-mechanism role=mechanism -->
## 结果形成方式

执行时先对编码输入做快照，然后根据源快照同时计算有符号商和余数，最后才产生目标效果。

- 操作专属的宽度、有符号性和立即数规则由助记符以及下方编码字段共同确定。
- 结果发布使用当前指令契约为该助记符确定的位宽与扩展规则。

<!-- PTO-READER-BLOCK: scalar-hl-divw-inputs role=inputs-outputs -->
## 输入与目标

- `RegDst0` 是 5 位字段，选择商的 Reg5 目标，或丢弃商。
- `RegDst1` 是 5 位字段，选择余数的 Reg5 目标，或丢弃余数。
- `SrcL` 是 5 位字段，通过 Reg5 选择被除数。
- `SrcR` 是 5 位字段，通过 Reg5 选择除数。

这些角色来自当前指令契约；T/U 源只被读取和快照，不会因源选择而出队。编码零的精确含义列在下方生成的默认值章节中。

<!-- PTO-READER-BLOCK: scalar-hl-divw-effects role=effects -->
## 效果与顺序

所有结果都在发布前计算完成。随后按编码顺序（`RegDst0`, `RegDst1`）更新目标；目标重复指向同一寄存器或队列时也采用这一顺序。

该 ALU 操作不产生内存效果。成功完成架构效果后，`TPC` 前进 6 字节。

该操作不会产生隐藏的标量发布目标或隐式内存访问。架构变化仅限于当前契约列出的状态效果。

<!-- PTO-READER-BLOCK: scalar-hl-divw-constraints role=constraints -->
## 合法性与故障边界

除数为零和有符号最小值除以负一均使用总定义；两个结果都在任何目标写入前计算完成。

下方生成的合法性表是已分配字段值、保留编码和目标丢弃编码的权威说明。解码与源可用性检查先于架构效果完成。

<!-- PTO-READER-BLOCK: scalar-hl-divw-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

以一个小型 `HL.DIVW` 示例说明：被除数 `13` 与除数 `5` 产生商 `2`，并按目标顺序产生余数 `3`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.divw SrcL, SrcR, ->Dst0, Dst1
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_divw_48_9048cdb3b22f | HL48 | 48 | 0x00002057000e / 0xfe00707f07ff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_divw_48_9048cdb3b22f | RegDst0 | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_divw_48_9048cdb3b22f | RegDst1 | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_divw_48_9048cdb3b22f | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_divw_48_9048cdb3b22f | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_divw_48_9048cdb3b22f | RegDst0 | 5 | 0–31 | none | none | quotient Reg5 destination or discard | Encoded zero discards the quotient. |
| hl_divw_48_9048cdb3b22f | RegDst1 | 5 | 0–31 | none | none | remainder Reg5 destination or discard | Encoded zero discards the remainder. |
| hl_divw_48_9048cdb3b22f | SrcL | 5 | 0–31 | none | none | dividend Reg5 source | Encoded zero reads the architectural zero GPR dividend. |
| hl_divw_48_9048cdb3b22f | SrcR | 5 | 0–31 | none | none | divisor Reg5 source | Encoded zero reads the architectural zero GPR divisor and therefore selects defined zero-divisor pair results. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst0 | quotient Reg5 destination or discard |
| RegDst1 | remainder Reg5 destination or discard |
| SrcL | dividend Reg5 source |
| SrcR | divisor Reg5 source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/HL.DIVW.asl -->
```asl
readonly func InstructionContractOperation_HL_DIVW() => ScalarOperation
begin
    return ScalarOperation_HL_DIVW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/HL.DIVW.asl -->
```asl
readonly func InstructionContractHandler_HL_DIVW() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarDividePairW;
end;
pure func InstructionContractQuotient_HL_DIVW(
    dividend: Word,
    divisor: Word)
    => Word
begin
    return ScalarDivideSignedW(
        dividend,
        divisor);
end;

pure func InstructionContractRemainder_HL_DIVW(
    dividend: Word,
    divisor: Word)
    => Word
begin
    return ScalarRemainderSignedW(
        dividend,
        divisor);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL, SrcR, RegDst0, and RegDst1 are required encoded fields; no field can be omitted.
- There is no encoded arithmetic mode or implicit operand. The mnemonic fixes signedness and operand width; every HL division/remainder spelling returns both quotient and remainder.

## Legality

- SrcL and SrcR codes 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consumption.
- Each destination independently uses the common map: codes 0 and 24..29 discard, codes 1..23 write GPRs, code 30 pushes U, and code 31 pushes T. Duplicate destinations are legal.
- Every value of each Reg5 selector is assigned; fixed encoding bits must match the canonical 48-bit form.

## State effects

- Interpret the selected operands as signed values, compute both quotient and remainder using the fixed total division rules. For W forms, use the low 32 bits and sign-extend each 32-bit result to XLEN.
- A zero divisor returns quotient zero and the effective dividend as remainder. Signed minimum divided by negative one returns signed minimum quotient and zero remainder.
- Publish RegDst0 quotient first, then RegDst1 remainder. If both destinations name one GPR, remainder is final; if both push one queue, remainder is newest and quotient is next-newest.
- No memory, reservation, descriptor, numeric-status, block, privilege, branch-target, or other control state changes. Successful execution advances TPC by six bytes.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot both sources and compute both results before either destination effect.
- Publish quotient to RegDst0, publish remainder to RegDst1, then advance TPC by six bytes.

## Exceptions

- Division and remainder are total: zero divisors and signed minimum divided by negative one do not raise an arithmetic exception.
- An unavailable selected T/U source raises Fault_IllegalInstruction before either destination effect and before TPC advances.

## Examples

- hl.divw a0, a1, ->a2, a3
- hl.divw t#1, zero, ->u, u
