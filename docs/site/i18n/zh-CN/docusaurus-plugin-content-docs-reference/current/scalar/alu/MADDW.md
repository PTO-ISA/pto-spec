<!-- GENERATED FROM: asl/scalar/alu/MADDW.asl -->
# MADDW

**Normative ASL source:** `asl/scalar/alu/MADDW.asl`

MADDW adds low 32-bit source values modulo 2^32, sign-extends the accumulated result to XLEN, and publishes it.

## Normative identity {#PTO-INST-SCALAR-MADDW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-maddw-purpose role=purpose -->
## MADDW 的作用

`MADDW` 是一条 32 位编码的标量 ALU 指令，它把 `SrcL[31:0] * SrcR[31:0]` 与 `SrcD[31:0]` 按模 `2^32` 相加，对该 32 位和的第 `31` 位做符号扩展，并通过一个 Reg5 目标发布结果。

每个源只有低字参与。`SrcL`、`SrcR` 与 `SrcD` 的 `63:32` 位无法影响发布值。

<!-- PTO-READER-BLOCK: scalar-maddw-mechanism role=mechanism -->
## 结果形成方式

所属 ASL 提供 `InstructionContractResult_MADDW`，它返回 `ScalarMultiplyAddW(addend, left, right)`。该辅助函数用 `MultiplyWord(left, right)` 做乘法，取 `product[31:0]`，把 `addend[31:0]` 加进一个 32 位值，再对 32 位和应用 `SignExtend{PTO_XLEN}`。

```asm
maddw SrcL, SrcR, SrcD, ->{t, u, Rd}
```

设计要点：加法在 `32` 位内完成，只有最终值才被加宽。因此第 `31` 位的进位被丢弃，而不会传播到高位字：`SrcL = 70000`、`SrcR = 70000`、`SrcD = 0` 发布 `605032704`，而不是 `4900000000`。

<!-- PTO-READER-BLOCK: scalar-maddw-inputs role=inputs-outputs -->
## 输入与目标

- `RegDst`，指令切片 `[7 +: 5]`，接收符号扩展后的 32 位结果。
- `SrcD`，指令切片 `[27 +: 5]`，提供加数字。
- `SrcL`，指令切片 `[15 +: 5]`，提供左乘数字。
- `SrcR`，指令切片 `[20 +: 5]`，提供右乘数字。

源使用通用 Reg5 映射：`0..23` 为绝对 GPR，`24..27` 为 `T#1..T#4`，`28..31` 为 `U#1..U#4`，全部非消耗读取。编码零读取体系结构零 GPR。

设计要点：符号扩展发生在累加之后，因此发布字不是零扩展的和。第 `31` 位被置位的和会以高位全为 1 的 XLEN 值到达目标，这就是 `maddw` 能由两个正输入发布负结果的原因。

<!-- PTO-READER-BLOCK: scalar-maddw-effects role=effects -->
## 效果与顺序

三个源都在目标效果之前取快照，因此与 `SrcD`、`SrcL` 或 `SrcR` 同名的目标观察到的仍是该寄存器执行前的值。

结果通过 `RegDst` 发布，随后 `TPC` 前进 `4` 字节。`MADDW` 没有内存效果，也没有数值状态效果；除 `RegDst` 与 `TPC` 之外，它能改变的唯一状态是由目标编码选择的一次 `T` 或 `U` 队列推送。

<!-- PTO-READER-BLOCK: scalar-maddw-constraints role=constraints -->
## 合法性与故障边界

5 位字段的每个源编码与每个目标编码都有定义，且 `ScalarDestinationSelectorLegal` 接受全部 `32` 个目标编码，因此只有临时源不可用会使操作数检查失败。固定编码位必须与规范的 32 位形式匹配。

适用性只在系统块终止请求挂起时失败，并在 `TPC` 触发 `Fault_BundleControl`。否则该有序检查序列中的第一个故障是与形式不匹配的编码在进入指令束主体之前于 `PC` 触发的 `Fault_IllegalInstruction`，第二个是所选 `T` 或 `U` 源不可用时在目标写入之前于 `PC` 触发的 `Fault_IllegalInstruction`。

设计要点：由于被丢弃的位在加法之前就已去掉，`MADDW` 不需要溢出规则，也不为任何操作数三元组定义异常。它的全部固定宽度契约就是模 `2^32` 的和加上最后的符号扩展。

<!-- PTO-READER-BLOCK: scalar-maddw-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

取 `SrcL = -3`、`SrcR = 5`、`SrcD = 1` 时，低字给出 `-15 + 1 = -14`；`SignExtend(0xFFFFFFF2)` 为 `0xFFFFFFFFFFFFFFF2`，因此目标收到一个负的 XLEN 字。取 `SrcL = 0x100000000`、`SrcR = 5`、`SrcD = 7` 时 `SrcL[31:0]` 为 `0`，目标收到 `7`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
maddw SrcL, SrcR, SrcD, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| maddw_32_9f922b15e674 | L32 | 32 | 0x00007047 / 0x0600707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| maddw_32_9f922b15e674 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| maddw_32_9f922b15e674 | SrcD | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |
| maddw_32_9f922b15e674 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| maddw_32_9f922b15e674 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| maddw_32_9f922b15e674 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| maddw_32_9f922b15e674 | SrcD | 5 | 0–31 | none | none | addend Reg5 source | Encoded zero reads the architectural zero GPR. |
| maddw_32_9f922b15e674 | SrcL | 5 | 0–31 | none | none | left multiplicand or additive Reg5 source | Encoded zero reads the architectural zero GPR. |
| maddw_32_9f922b15e674 | SrcR | 5 | 0–31 | none | none | right multiplicand Reg5 source | Encoded zero reads the architectural zero GPR. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcD | addend Reg5 source |
| SrcL | left multiplicand or additive Reg5 source |
| SrcR | right multiplicand Reg5 source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/MADDW.asl -->
```asl
readonly func InstructionContractOperation_MADDW() => ScalarOperation
begin
    return ScalarOperation_MADDW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/MADDW.asl -->
```asl
readonly func InstructionContractHandler_MADDW() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarMultiplyAddW;
end;
pure func InstructionContractResult_MADDW(addend: Word, left: Word, right: Word) => Word
begin
    return ScalarMultiplyAddW(addend, left, right);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every encoded operand and destination field is required; no field can be omitted.
- The mnemonic fixes signedness, effective operand width, single-versus-pair result shape, and add-versus-subtract behavior; there is no encoded arithmetic mode.

## Legality

- Every source Reg5 code is assigned: 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consumption.
- Each destination independently uses the common map: codes 0 and 24..29 discard, codes 1..23 write GPRs, code 30 pushes U, and code 31 pushes T.
- Fixed encoding bits must match the canonical form; every encoded source, destination, and immediate value otherwise has assigned behavior.

## State effects

- Multiply SrcL[31:0] and SrcR[31:0], add SrcD[31:0] modulo 2^32, then sign-extend the final low 32-bit result.
- Snapshot every source before the destination effect, publish the XLEN result through the common Reg5 destination map, and do not consume relative sources.
- No memory, reservation, descriptor, numeric-status, block, privilege, branch-target, or other control state changes. Successful execution advances TPC by four bytes.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot every source before any destination effect so duplicate selectors and destination aliases observe pre-instruction values.
- Publish the result, then advance TPC by four bytes.

## Exceptions

- Multiplication and accumulation are fixed-width and raise no arithmetic exception; discarded overflow wraps modulo the defined result width.
- An unavailable selected T/U source raises Fault_IllegalInstruction before any destination effect and before TPC advances.

## Examples

- maddw srcl, srcr, srcd, ->{t, u, rd}
