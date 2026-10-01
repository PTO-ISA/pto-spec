<!-- GENERATED FROM: asl/scalar/alu/MUL.asl -->
# MUL

**Normative ASL source:** `asl/scalar/alu/MUL.asl`

MUL computes the low XLEN bits of the complete scalar product and publishes the result.

## Normative identity {#PTO-INST-SCALAR-MUL}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-mul-purpose role=purpose -->
## MUL 的作用

`MUL` 是一条 32 位编码的标量 ALU 指令，它把两个 XLEN 源相乘，并通过一个 Reg5 目标发布完整乘积的低 `PTO_XLEN` 位。

该形式的 `L32` 类指的是指令长度，因此源操作数仍以完整的 `64` 位值进入乘法。它不产生乘积高半部，也不编码立即数。

<!-- PTO-READER-BLOCK: scalar-mul-mechanism role=mechanism -->
## 结果形成方式

所属 ASL 提供 `InstructionContractResult_MUL`，它返回 `MultiplyWord(left, right)`。该辅助函数从零开始，对 `right` 的每个置位位置把 `LSL(left, bit_index)` 加到一个 `Word` 累加器上，因此每个部分和都已按模 `2^PTO_XLEN` 约简。

```asm
mul SrcL, SrcR, ->{t, u, Rd}
```

设计要点：无论采用哪种符号解释，保留下来的半部都相同，而且可执行分派把 `MUL` 与 `MULU` 绑定到同一个辅助函数。因此 `SrcL = 0xFFFFFFFFFFFFFFFF` 与 `SrcR = 0xFFFFFFFFFFFFFFFF` 在两个助记符下都发布 `1`。

<!-- PTO-READER-BLOCK: scalar-mul-inputs role=inputs-outputs -->
## 输入与目标

- `RegDst`，指令切片 `[7 +: 5]`，接收乘积的低 XLEN 位。
- `SrcL`，指令切片 `[15 +: 5]`，提供左乘数。
- `SrcR`，指令切片 `[20 +: 5]`，提供右乘数。

两个源都使用通用 Reg5 映射：`0..23` 读取绝对 GPR，`24..27` 读取 `T#1..T#4`，`28..31` 读取 `U#1..U#4`。读取不消耗队列表项，编码零读取体系结构零 GPR。

设计要点：该形式不编码 `SrcRType` 或移位字段，因此 `SrcR` 原样进入乘法。携带这些字段的形式（例如 `ADD`）把它们写成右源上的后缀（`.sw`、`.uw`、`.neg` 以及移位）；`MUL` 只有三个操作数字段。

<!-- PTO-READER-BLOCK: scalar-mul-effects role=effects -->
## 效果与顺序

两个源都在目标效果之前取快照，因此 `mul a0, a0, ->a0` 用执行前的 `a0` 自乘。

结果发布之后，`TPC` 前进 `4` 字节。`MUL` 不做内存访问，也不改变数值状态、保留、描述符、指令束、特权与控制流状态；唯一可能的队列变化是由 `RegDst` 选择的那一次 `T` 或 `U` 推送。

<!-- PTO-READER-BLOCK: scalar-mul-constraints role=constraints -->
## 合法性与故障边界

每个 `32` 编码的源编码都有定义，每个 `32` 编码的目标编码都被接受，因此临时源不可用是唯一可能失败的操作数条件。固定编码位必须与规范的 32 位形式匹配。

适用性只在系统块终止请求挂起时失败，并在 `TPC` 触发 `Fault_BundleControl`。否则，不匹配的编码在进入指令束主体之前于 `PC` 触发 `Fault_IllegalInstruction`，所选 `T` 或 `U` 源不可用时则在目标写入之前于 `PC` 触发 `Fault_IllegalInstruction`。

设计要点：被丢弃的乘积高位不留痕迹，也不设置标志，因此 `MUL` 无法上报溢出。需要检测溢出的代码必须与更宽的形式比较或重建乘积，因为对任何操作数对都没有定义异常。

<!-- PTO-READER-BLOCK: scalar-mul-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

取 `SrcL = 6`、`SrcR = 7` 时累加器为 `42`，`RegDst` 收到 `42`。取 `SrcL = SrcR = 0xFFFFFFFFFFFFFFFF` 时精确乘积为 `2^128 - 2^65 + 1`，其低 `PTO_XLEN` 位是 `1`，因此 `RegDst` 在 `MUL` 与 `MULU` 下同样收到 `1`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
mul SrcL, SrcR, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| mul_32_9f2affd8efb8 | L32 | 32 | 0x00000047 / 0xfe00707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| mul_32_9f2affd8efb8 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| mul_32_9f2affd8efb8 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| mul_32_9f2affd8efb8 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| mul_32_9f2affd8efb8 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| mul_32_9f2affd8efb8 | SrcL | 5 | 0–31 | none | none | left multiplicand or additive Reg5 source | Encoded zero reads the architectural zero GPR. |
| mul_32_9f2affd8efb8 | SrcR | 5 | 0–31 | none | none | right multiplicand Reg5 source | Encoded zero reads the architectural zero GPR. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | left multiplicand or additive Reg5 source |
| SrcR | right multiplicand Reg5 source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/MUL.asl -->
```asl
readonly func InstructionContractOperation_MUL() => ScalarOperation
begin
    return ScalarOperation_MUL;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/MUL.asl -->
```asl
readonly func InstructionContractHandler_MUL() => ScalarSemanticHandler
begin
    return ScalarHandler_MultiplyWord;
end;
pure func InstructionContractResult_MUL(left: Word, right: Word) => Word
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

- Multiply both complete XLEN source bit patterns modulo 2^PTO_XLEN; signedness does not affect the retained low half.
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

- mul srcl, srcr, ->{t, u, rd}
