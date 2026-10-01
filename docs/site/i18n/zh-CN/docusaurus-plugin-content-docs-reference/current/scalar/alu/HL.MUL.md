<!-- GENERATED FROM: asl/scalar/alu/HL.MUL.asl -->
# HL.MUL

**Normative ASL source:** `asl/scalar/alu/HL.MUL.asl`

HL.MUL computes a signed 128-bit scalar product and publishes its low half followed by its high half.

## Normative identity {#PTO-INST-SCALAR-HL-MUL}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-mul-purpose role=purpose -->
## HL.MUL 的作用

`HL.MUL` 是一条 48 位标量 ALU 指令，它形成两个 XLEN 源的有符号 128 位乘积，并以两个 XLEN 半部发布。它没有加数，也没有立即数。

`RegDst0` 接收低半部 `product[63:0]`，`RegDst1` 接收高半部 `product[127:64]`，因此目标对承载精确乘积，没有舍入或饱和。

<!-- PTO-READER-BLOCK: scalar-hl-mul-mechanism role=mechanism -->
## 结果形成方式

所属 ASL 提供 `InstructionContractProduct_HL_MUL`，它返回 `MultiplyWideSigned(left, right)`。`InstructionContractLow_HL_MUL` 取该乘积的 `63:0` 位，`InstructionContractHigh_HL_MUL` 取 `127:64` 位。分派路径以 `signed_operation` 为真调用 `ExecuteScalarMultiplyPair`，得到相同的切片。

```asm
hl.mul SrcL, SrcR, ->Dst0, Dst1
```

设计要点：源的有符号解释会改变高半部，但不改变低半部。补码乘积的 `63:0` 位只取决于操作数的低 `64` 位，因此对任意输入对，`HL.MUL` 与 `HL.MULU` 发布的 `RegDst0` 完全相同，差异只能出现在 `RegDst1`。

<!-- PTO-READER-BLOCK: scalar-hl-mul-inputs role=inputs-outputs -->
## 输入与目标

- `RegDst0`，指令切片 `[23 +: 5]`，接收乘积低半部 `product[63:0]`。
- `RegDst1`，指令切片 `[11 +: 5]`，接收乘积高半部 `product[127:64]`。
- `SrcL`，指令切片 `[31 +: 5]`，提供左乘数。
- `SrcR`，指令切片 `[36 +: 5]`，提供右乘数。

两个源都是 Reg5 编码：`0..23` 读取绝对 GPR，`24..27` 读取 `T#1..T#4`，`28..31` 读取 `U#1..U#4`。读取临时项不会消耗该表项。完整乘积在任一目标写入之前由这两份快照算出。

设计要点：该形式不编码右源修饰。部分其他标量 ALU 形式（例如 `ADD`、`SUB`、`AND`、`OR` 与 `XOR`）带有 `SrcRType` 字段，可以在使用前对 `SrcR` 做符号扩展、零扩展或取反，而 `HL.MUL` 没有这个字段，因此寄存器值原样进入乘法。

<!-- PTO-READER-BLOCK: scalar-hl-mul-effects role=effects -->
## 效果与顺序

两个源都在第一次写入之前读取，因此与某个源同名的目标收到的仍是由执行前的值算出的结果。

两次写入按编码顺序执行：先用 `product[63:0]` 写 `RegDst0`，再用 `product[127:64]` 写 `RegDst1`。当两个字段指向同一个 GPR 时，保留下来的是高半部；当两者推入同一队列时，高半部是最新表项。

目标效果之后 `TPC` 前进 `6` 字节。`HL.MUL` 不做内存访问，除目标选择的队列推送之外，保留、描述符、数值状态、指令束、特权与控制流状态都不改变。

<!-- PTO-READER-BLOCK: scalar-hl-mul-constraints role=constraints -->
## 合法性与故障边界

每个 `32` 编码的源编码都有定义，每个 `32` 编码的目标编码都被接受，因此唯一可能失败的操作数检查是临时源可用性。固定编码位必须与规范形式匹配；两个乘数字段没有任何保留值。

适用性只在系统块终止请求挂起时失败，并在 `TPC` 触发 `Fault_BundleControl`。否则，不匹配的编码在进入指令束主体之前于 `PC` 触发 `Fault_IllegalInstruction`，所选 `T` 或 `U` 源不可用时则在任一目标写入之前于 `PC` 触发 `Fault_IllegalInstruction`。乘法在任何操作数值上都不触发算术异常。

设计要点：所选 `T` 或 `U` 源不可用是该指令在译码之后唯一能触发的故障，而且它在乘积的任一半部发布之前触发。

<!-- PTO-READER-BLOCK: scalar-hl-mul-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

取 `SrcL = 6`、`SrcR = 7` 时乘积为 `42`，因此 `RegDst0` 收到 `42`，`RegDst1` 收到 `0`。取 `SrcL = 0xFFFFFFFFFFFFFFFF`、`SrcR = 2` 时有符号乘积为 `-2`：`RegDst0` 收到 `0xFFFFFFFFFFFFFFFE`，`RegDst1` 收到 `0xFFFFFFFFFFFFFFFF`。把后一组输入改用 `HL.MULU` 执行只会改变 `RegDst1`，它会变成 `0x1`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.mul SrcL, SrcR, ->Dst0, Dst1
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_mul_48_0d059ff178fb | HL48 | 48 | 0x00000047000e / 0xfe00707f07ff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_mul_48_0d059ff178fb | RegDst0 | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_mul_48_0d059ff178fb | RegDst1 | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_mul_48_0d059ff178fb | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_mul_48_0d059ff178fb | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_mul_48_0d059ff178fb | RegDst0 | 5 | 0–31 | none | none | low product or accumulator Reg5 destination | Encoded zero discards the low result. |
| hl_mul_48_0d059ff178fb | RegDst1 | 5 | 0–31 | none | none | high product or accumulator Reg5 destination | Encoded zero discards the high result. |
| hl_mul_48_0d059ff178fb | SrcL | 5 | 0–31 | none | none | left multiplicand or additive Reg5 source | Encoded zero reads the architectural zero GPR. |
| hl_mul_48_0d059ff178fb | SrcR | 5 | 0–31 | none | none | right multiplicand Reg5 source | Encoded zero reads the architectural zero GPR. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst0 | low product or accumulator Reg5 destination |
| RegDst1 | high product or accumulator Reg5 destination |
| SrcL | left multiplicand or additive Reg5 source |
| SrcR | right multiplicand Reg5 source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/HL.MUL.asl -->
```asl
readonly func InstructionContractOperation_HL_MUL() => ScalarOperation
begin
    return ScalarOperation_HL_MUL;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/HL.MUL.asl -->
```asl
readonly func InstructionContractHandler_HL_MUL() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarMultiplyPair;
end;
pure func InstructionContractProduct_HL_MUL(left: Word, right: Word) => DoubleWord
begin
    return MultiplyWideSigned(left, right);
end;

pure func InstructionContractLow_HL_MUL(left: Word, right: Word) => Word
begin
    return InstructionContractProduct_HL_MUL(left, right)[63:0];
end;

pure func InstructionContractHigh_HL_MUL(left: Word, right: Word) => Word
begin
    return InstructionContractProduct_HL_MUL(left, right)[127:64];
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

- Sign-extend both XLEN sources into a signed 128-bit product.
- Snapshot every source and compute the complete 128-bit result before destinations. Publish bits 63:0 to RegDst0, then bits 127:64 to RegDst1. Duplicate destinations are legal; the second high result is final/newest.
- No memory, reservation, descriptor, numeric-status, block, privilege, branch-target, or other control state changes. Successful execution advances TPC by six bytes.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot every source before any destination effect so duplicate selectors and destination aliases observe pre-instruction values.
- Publish the low result to RegDst0, publish the high result to RegDst1, then advance TPC by six bytes.

## Exceptions

- Multiplication and accumulation are fixed-width and raise no arithmetic exception; discarded overflow wraps modulo the defined result width.
- An unavailable selected T/U source raises Fault_IllegalInstruction before any destination effect and before TPC advances.

## Examples

- hl.mul srcl, srcr, ->dst0, dst1
