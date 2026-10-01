<!-- GENERATED FROM: asl/scalar/alu/MULUW.asl -->
# MULUW

**Normative ASL source:** `asl/scalar/alu/MULUW.asl`

MULUW multiplies the source low 32-bit values, retains the low 32 product bits, sign-extends them to XLEN, and publishes the result.

## Normative identity {#PTO-INST-SCALAR-MULUW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-muluw-purpose role=purpose -->
## MULUW 的作用

`MULUW` 是一条 32 位编码的标量 ALU 指令，它把两个源的低字相乘，保留该乘积的低 `32` 位，并把第 `31` 位符号扩展到 XLEN，再通过一个 Reg5 目标发布。

任一源的 `63:32` 位都在操作之外，因此只在第 `31` 位以上不同的源会产生相同的发布字。

<!-- PTO-READER-BLOCK: scalar-muluw-mechanism role=mechanism -->
## 结果形成方式

所属 ASL 提供 `InstructionContractResult_MULUW`，它返回 `ScalarMultiplyW(left, right)`。该辅助函数把 `left[31:0]` 与 `right[31:0]` 零扩展，用 `MultiplyWord` 相乘，并对 `product[31:0]` 应用 `SignExtend{PTO_XLEN}`。

```asm
muluw SrcL, SrcR, ->{t, u, Rd}
```

设计要点：源做零扩展，而结果做符号扩展，两种扩展并不对称。第 `31` 位被置位的乘积会作为负的 XLEN 字发布：`SrcL = SrcR = 0xFFFFFFFF` 的 32 位乘积是 `1`，因此目标收到 `1`；而同样的源值在 `MULU` 下产生 `0xFFFFFFFE00000001`。

<!-- PTO-READER-BLOCK: scalar-muluw-inputs role=inputs-outputs -->
## 输入与目标

- `RegDst`，指令切片 `[7 +: 5]`，接收 `SignExtend(product[31:0])`。
- `SrcL`，指令切片 `[15 +: 5]`，提供左乘数字。
- `SrcR`，指令切片 `[20 +: 5]`，提供右乘数字。

源使用通用 Reg5 映射：`0..23` 为绝对 GPR，`24..27` 为 `T#1..T#4`，`28..31` 为 `U#1..U#4`，非消耗读取。编码零读取体系结构零 GPR，因此编码零乘数会让整个乘积为零。

设计要点：目标映射就是常用的那一张：编码 `1..23` 写 GPR，`30` 与 `31` 推入 `U` 与 `T`，`0` 与 `24..29` 丢弃。丢弃结果之前仍然会读取源，因此被丢弃的 `muluw` 执行后队列状态不变。

<!-- PTO-READER-BLOCK: scalar-muluw-effects role=effects -->
## 效果与顺序

两份源快照都在目标效果之前取得，因此源与目标同名不会改变进入乘法的值。

目标收到符号扩展后的低字，随后 `TPC` 前进 `4` 字节。该指令没有内存效果，也没有数值状态效果；除 `RegDst` 与 `TPC` 之外，只有目标编码选择的 `T` 或 `U` 推送能改变状态。

<!-- PTO-READER-BLOCK: scalar-muluw-constraints role=constraints -->
## 合法性与故障边界

每个源编码与每个目标编码都有定义，且目标选择子检查接受全部 `32` 个编码，因此临时源不可用是唯一可能失败的操作数条件。固定编码位必须与规范的 32 位形式匹配。

适用性只在系统块终止请求挂起时失败，并在 `TPC` 触发 `Fault_BundleControl`。否则，与形式不匹配的编码在进入指令束主体之前于 `PC` 触发 `Fault_IllegalInstruction`，所选 `T` 或 `U` 源不可用时则在目标写入之前于 `PC` 触发 `Fault_IllegalInstruction`。乘法本身是全定义的，不触发任何故障。

设计要点：源的零扩展与结果的符号扩展是两个独立步骤，因此没有任何操作数值会引发异常，也没有任何操作数值被保留。唯一反直觉的情形是结果第 `31` 位为 1，它把一个看似很小的 32 位乘积变成负的 XLEN 字。

<!-- PTO-READER-BLOCK: scalar-muluw-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

取 `SrcL = 0xFFFFFFFF`、`SrcR = 0xFFFFFFFF` 时，两个低字相乘得到 `0xFFFFFFFE00000001`，其低 `32` 位是 `1`，因此 `RegDst` 收到 `1`。取 `SrcL = 0x0000000180000000`、`SrcR = 2` 时只有低字参与：乘积 `0x80000000 * 2` 是 `0x100000000`，其低 `32` 位为 `0x00000000`，因此目标收到 `0`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
muluw SrcL, SrcR, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| muluw_32_8f52b3d45e53 | L32 | 32 | 0x00003047 / 0xfe00707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| muluw_32_8f52b3d45e53 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| muluw_32_8f52b3d45e53 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| muluw_32_8f52b3d45e53 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| muluw_32_8f52b3d45e53 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| muluw_32_8f52b3d45e53 | SrcL | 5 | 0–31 | none | none | left multiplicand or additive Reg5 source | Encoded zero reads the architectural zero GPR. |
| muluw_32_8f52b3d45e53 | SrcR | 5 | 0–31 | none | none | right multiplicand Reg5 source | Encoded zero reads the architectural zero GPR. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | left multiplicand or additive Reg5 source |
| SrcR | right multiplicand Reg5 source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/MULUW.asl -->
```asl
readonly func InstructionContractOperation_MULUW() => ScalarOperation
begin
    return ScalarOperation_MULUW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/MULUW.asl -->
```asl
readonly func InstructionContractHandler_MULUW() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarMultiplyW;
end;
pure func InstructionContractResult_MULUW(left: Word, right: Word) => Word
begin
    return ScalarMultiplyW(left, right);
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

- Multiply the source low 32-bit patterns modulo 2^32, then sign-extend result bit 31 through XLEN; current MULUW and MULW results are identical for the same source bits.
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

- muluw srcl, srcr, ->{t, u, rd}
