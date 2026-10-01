<!-- GENERATED FROM: asl/scalar/alu/MULU.asl -->
# MULU

**Normative ASL source:** `asl/scalar/alu/MULU.asl`

MULU computes the low XLEN bits of the complete unsigned scalar product and publishes the result.

## Normative identity {#PTO-INST-SCALAR-MULU}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-mulu-purpose role=purpose -->
## MULU 的作用

`MULU` 是一条 32 位编码的标量 ALU 指令，它把两个 XLEN 源相乘，并通过一个 Reg5 目标发布乘积的低 `PTO_XLEN` 位。它没有立即数，也没有高半部目标。

该助记符表示按无符号方式读取操作数，而可执行分派把它与 `MUL` 绑定到同一个 `MultiplyWord` 辅助函数。

<!-- PTO-READER-BLOCK: scalar-mulu-mechanism role=mechanism -->
## 结果形成方式

所属 ASL 提供 `InstructionContractResult_MULU`，它返回 `MultiplyWord(left, right)`。该辅助函数在累加过程中把每个部分和按模 `2^PTO_XLEN` 约简，因此它返回的是两个源位模式精确乘积的低 XLEN 位。

```asm
mulu SrcL, SrcR, ->{t, u, Rd}
```

设计要点：`MUL` 与 `MULU` 的区别在名称，而不在可执行行为。`asl/scalar/model/dispatch/alu.asl` 在同一个分支中处理 `ScalarOperation_MUL` 与 `ScalarOperation_MULU` 并调用 `MultiplyWord`，因此没有任何输入对能让这两个助记符发布不同的字。

<!-- PTO-READER-BLOCK: scalar-mulu-inputs role=inputs-outputs -->
## 输入与目标

- `RegDst`，指令切片 `[7 +: 5]`，接收乘积的低 XLEN 位。
- `SrcL`，指令切片 `[15 +: 5]`，提供左乘数。
- `SrcR`，指令切片 `[20 +: 5]`，提供右乘数。

两个源都使用通用 Reg5 映射：`0..23` 读取绝对 GPR，`24..27` 读取 `T#1..T#4`，`28..31` 读取 `U#1..U#4`。读取临时项会保留该表项，编码零读取体系结构零 GPR。

设计要点：两个操作数的每一位都能进入被保留的乘积，因此 `MULU` 不是字操作。它唯一的截断是丢弃高于第 `PTO_XLEN - 1` 位的乘积位，这与 `MUL` 施加的截断相同。

<!-- PTO-READER-BLOCK: scalar-mulu-effects role=effects -->
## 效果与顺序

两个源都在目标写入之前读取，因此与源同名的目标收到的仍是由执行前寄存器内容算出的值。

发布之后 `TPC` 前进 `4` 字节。`MULU` 不读写内存，也不触及数值状态、保留、描述符、指令束、特权与控制流状态；只有 `RegDst` 选择的 `T` 或 `U` 推送能改变队列。

<!-- PTO-READER-BLOCK: scalar-mulu-constraints role=constraints -->
## 合法性与故障边界

每个 `32` 编码的源编码都有定义，每个 `32` 编码的目标编码都被接受，因此所选临时项不可用是唯一可能失败的操作数条件。固定编码位必须与规范的 32 位形式匹配；没有保留的操作数值，也没有编码的模式。

适用性只在系统块终止请求挂起时失败，并在 `TPC` 触发 `Fault_BundleControl`。否则，不匹配的编码在进入指令束主体之前于 `PC` 触发 `Fault_IllegalInstruction`，所选 `T` 或 `U` 源不可用时则在目标写入之前于 `PC` 触发 `Fault_IllegalInstruction`。对任何操作数对都不存在算术异常。

设计要点：无符号读取完全消除了负值拐角。`0xFFFFFFFFFFFFFFFF` 是最大操作数而不是 `-1`，因此需要有符号低半部的调用方不必为它另设规则，而且两种情况下都不定义溢出故障。

<!-- PTO-READER-BLOCK: scalar-mulu-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

取 `SrcL = SrcR = 0xFFFFFFFFFFFFFFFF` 时，`MultiplyWord` 只累加能放进 `PTO_XLEN` 位的部分和并返回 `1`，因此 `RegDst` 收到 `1`。取 `SrcL = 6`、`SrcR = 7` 时目标收到 `42`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
mulu SrcL, SrcR, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| mulu_32_10b9d1936631 | L32 | 32 | 0x00001047 / 0xfe00707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| mulu_32_10b9d1936631 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| mulu_32_10b9d1936631 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| mulu_32_10b9d1936631 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| mulu_32_10b9d1936631 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| mulu_32_10b9d1936631 | SrcL | 5 | 0–31 | none | none | left multiplicand or additive Reg5 source | Encoded zero reads the architectural zero GPR. |
| mulu_32_10b9d1936631 | SrcR | 5 | 0–31 | none | none | right multiplicand Reg5 source | Encoded zero reads the architectural zero GPR. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | left multiplicand or additive Reg5 source |
| SrcR | right multiplicand Reg5 source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/MULU.asl -->
```asl
readonly func InstructionContractOperation_MULU() => ScalarOperation
begin
    return ScalarOperation_MULU;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/MULU.asl -->
```asl
readonly func InstructionContractHandler_MULU() => ScalarSemanticHandler
begin
    return ScalarHandler_MultiplyWord;
end;
pure func InstructionContractResult_MULU(left: Word, right: Word) => Word
begin
    return MultiplyWord(left, right);
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

- Multiply both complete XLEN source bit patterns modulo 2^PTO_XLEN; the result is identical to MUL for the same source bits.
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

- mulu srcl, srcr, ->{t, u, rd}
