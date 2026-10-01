<!-- GENERATED FROM: asl/scalar/alu/MADD.asl -->
# MADD

**Normative ASL source:** `asl/scalar/alu/MADD.asl`

MADD adds a snapshotted XLEN addend to the low XLEN scalar product modulo 2^PTO_XLEN and publishes the result.

## Normative identity {#PTO-INST-SCALAR-MADD}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-madd-purpose role=purpose -->
## MADD 的作用

`MADD` 是一条 32 位编码的标量 ALU 指令，通过一个 Reg5 目标发布按模 `2^PTO_XLEN` 回绕的 `SrcD + SrcL * SrcR`。它是乘加组里单目标的形式：不产生乘积高半部。

`L32` 编码类固定的是指令长度，而不是操作数宽度。两个乘数都按完整 XLEN 宽度使用，这一点与只读取低字的 `MADDW` 不同。

<!-- PTO-READER-BLOCK: scalar-madd-mechanism role=mechanism -->
## 结果形成方式

所属 ASL 提供 `InstructionContractResult_MADD`，它返回 `ScalarMultiplyAdd(addend, left, right)`。该辅助函数就是 `addend + MultiplyWord(left, right)`，而 `MultiplyWord` 按 `right` 的每个置位位置累加左移后的 `left`，并在每一步保留 `PTO_XLEN` 位以内的部分和。

```asm
madd SrcL, SrcR, SrcD, ->{t, u, Rd}
```

设计要点：乘积从不超出 XLEN 宽度。`SrcL = 2^63` 与 `SrcR = 2` 会产生 `2^64` 的部分和，该位被丢弃，因此发布值是 `SrcD`；而 `HL.MADD` 这类宽形式会把这一位保留在高半部。

<!-- PTO-READER-BLOCK: scalar-madd-inputs role=inputs-outputs -->
## 输入与目标

- `RegDst`，指令切片 `[7 +: 5]`，接收 XLEN 结果。
- `SrcD`，指令切片 `[27 +: 5]`，提供加数。
- `SrcL`，指令切片 `[15 +: 5]`，提供左乘数。
- `SrcR`，指令切片 `[20 +: 5]`，提供右乘数。

三个源都使用通用 Reg5 映射：`0..23` 读取绝对 GPR，`24..27` 读取 `T#1..T#4`，`28..31` 读取 `U#1..U#4`。读取是非消耗的，编码零读取的是体系结构零 GPR，而不是未定义值。

设计要点：目标映射并不是源映射的镜像。编码 `1..23` 写 GPR，编码 `30` 与 `31` 分别推入 `U` 与 `T`，而编码 `0` 与 `24..29` 丢弃结果。因此目标编码 `24` 虽然指向可读的 `T#1` 源，却不写入任何东西。

<!-- PTO-READER-BLOCK: scalar-madd-effects role=effects -->
## 效果与顺序

三个源在目标效果之前取快照，因此 `madd a0, a1, a0, ->a0` 把执行前的 `a0` 同时用作加数和目标。

结果被发布或被丢弃之后，`TPC` 前进 `4` 字节。`MADD` 不访问内存，不改变保留、描述符、数值状态、指令束、特权与控制流状态；唯一可能的队列变化是由 `RegDst` 选择的 `T` 或 `U` 推送。

<!-- PTO-READER-BLOCK: scalar-madd-constraints role=constraints -->
## 合法性与故障边界

每个 `32` 编码的源编码都有定义，每个 `32` 编码的目标编码都被接受，因此操作数合法性只可能因临时源不可用而失败。固定编码位必须与规范的 32 位形式匹配；没有操作数值被保留。

适用性只在系统块终止请求挂起时失败，并在 `TPC` 触发 `Fault_BundleControl`。否则，不匹配的编码在进入指令束主体之前于 `PC` 触发 `Fault_IllegalInstruction`，所选 `T` 或 `U` 源不可用时则在目标写入之前于 `PC` 触发 `Fault_IllegalInstruction`。乘法与加法在任何数值上都不触发算术异常。

设计要点：乘法、加法与回绕都是没有标志输出的固定宽度步骤，因此该指令不存在会上报溢出的操作数对。需要被丢弃的高位的调用方必须改用更宽的形式。

<!-- PTO-READER-BLOCK: scalar-madd-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

取 `SrcL = 6`、`SrcR = 7`、`SrcD = 1` 时 `MultiplyWord` 返回 `42`，加数再加 `1`，`RegDst` 收到 `43`。取 `SrcL = 2^63`、`SrcR = 2`、`SrcD = 0` 时乘积为 `2^64`，按模 `2^PTO_XLEN` 回绕为 `0`，因此 `RegDst` 收到 `0`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
madd SrcL, SrcR, SrcD, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| madd_32_6208e8e59303 | L32 | 32 | 0x00006047 / 0x0600707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| madd_32_6208e8e59303 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| madd_32_6208e8e59303 | SrcD | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |
| madd_32_6208e8e59303 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| madd_32_6208e8e59303 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| madd_32_6208e8e59303 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| madd_32_6208e8e59303 | SrcD | 5 | 0–31 | none | none | addend Reg5 source | Encoded zero reads the architectural zero GPR. |
| madd_32_6208e8e59303 | SrcL | 5 | 0–31 | none | none | left multiplicand or additive Reg5 source | Encoded zero reads the architectural zero GPR. |
| madd_32_6208e8e59303 | SrcR | 5 | 0–31 | none | none | right multiplicand Reg5 source | Encoded zero reads the architectural zero GPR. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcD | addend Reg5 source |
| SrcL | left multiplicand or additive Reg5 source |
| SrcR | right multiplicand Reg5 source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/MADD.asl -->
```asl
readonly func InstructionContractOperation_MADD() => ScalarOperation
begin
    return ScalarOperation_MADD;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/MADD.asl -->
```asl
readonly func InstructionContractHandler_MADD() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarMultiplyAdd;
end;
pure func InstructionContractResult_MADD(addend: Word, left: Word, right: Word) => Word
begin
    return ScalarMultiplyAdd(addend, left, right);
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

- Multiply SrcL and SrcR modulo 2^PTO_XLEN, add SrcD modulo 2^PTO_XLEN, and retain the low XLEN bits.
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

- madd srcl, srcr, srcd, ->{t, u, rd}
