<!-- GENERATED FROM: asl/scalar/alu/HL.MADD.asl -->
# HL.MADD

**Normative ASL source:** `asl/scalar/alu/HL.MADD.asl`

HL.MADD computes a signed 128-bit product plus a sign-extended XLEN addend and publishes low then high halves.

## Normative identity {#PTO-INST-SCALAR-HL-MADD}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-madd-purpose role=purpose -->
## HL.MADD 的作用

`HL.MADD` 是一条 48 位标量 ALU 指令，以 128 位宽度计算 `SrcL * SrcR + SrcD`。两个乘数按有符号 XLEN 值读取，加数被符号扩展到 128 位，和值以两个 XLEN 半部发布。

它没有舍入、饱和或标志输出。低半部写入 `RegDst0`，高半部写入 `RegDst1`。这一对目标形态正是它与 `MADD` 的区别：`MADD` 把同一个加数加到乘积上并按模 `2^PTO_XLEN` 回绕，只发布一个目标。

<!-- PTO-READER-BLOCK: scalar-hl-madd-mechanism role=mechanism -->
## 结果形成方式

所属 ASL 提供 `InstructionContractAccumulator_HL_MADD`：`MultiplyWideSigned(left, right)` 产生 128 位乘积，`SignExtend{PTO_XLEN * 2}(addend)` 把 `SrcD` 扩展到相同宽度，再由一次 128 位加法合并。分派路径以 `word_operation` 为假调用 `ExecuteScalarMultiplyAddPair`，得到同一个累加值。

```asm
hl.madd SrcL, SrcR, SrcD, ->Dst0, Dst1
```

设计要点：加数被符号扩展到 `128` 位，既不做零扩展，也不截断到 `64` 位。因此 `SrcD = -1` 会从完整的 128 位乘积中减去 1，借位可以影响到 `RegDst1` 收到的高半部。

<!-- PTO-READER-BLOCK: scalar-hl-madd-inputs role=inputs-outputs -->
## 输入与目标

- `RegDst0`，指令切片 `[23 +: 5]`，接收 `accumulator[63:0]`。
- `RegDst1`，指令切片 `[11 +: 5]`，接收 `accumulator[127:64]`。
- `SrcD`，指令切片 `[43 +: 5]`，提供加数。
- `SrcL`，指令切片 `[31 +: 5]`，提供左乘数。
- `SrcR`，指令切片 `[36 +: 5]`，提供右乘数。

每个源都是 Reg5 编码：`0..23` 读取绝对 GPR，`24..27` 读取 `T#1..T#4`，`28..31` 读取 `U#1..U#4`。读取临时项不会把它从队列中移除，并且三个源都在任一目标被写入之前读取。

设计要点：两个目标字段各自独立写入，因此 `->Dst0, Dst1` 取编码 `30` 和 `31` 时，低半部先推入 `U`，高半部随后推入 `T`。重复目标合法，因为这两次写入只是按 `RegDst0`、`RegDst1` 的顺序发生。

<!-- PTO-READER-BLOCK: scalar-hl-madd-effects role=effects -->
## 效果与顺序

三个源都在任何写入之前读取，因此即使某个源与某个目标同名，它贡献的仍是本指令执行前的值。128 位累加值在第一次写入之前就已完整。

随后写入按编码顺序进行：先用 `accumulator[63:0]` 写 `RegDst0`，再用 `accumulator[127:64]` 写 `RegDst1`。当两个名称指向同一个 GPR 时，高半部是最终值；当两者都是队列推送时，高半部是最新表项。

目标效果之后，`TPC` 前进 `6` 字节。`HL.MADD` 不读写内存，也不改变其他体系结构状态；它能造成的唯一队列变化是由 `RegDst0` 与 `RegDst1` 选择的一次或两次推送。

<!-- PTO-READER-BLOCK: scalar-hl-madd-constraints role=constraints -->
## 合法性与故障边界

`32` 个源编码全部有定义：`0..23` 选择 GPR，`24..31` 选择必须有效的临时队列表项。`32` 个目标编码全部被接受，因此 `ScalarDestinationSelectorLegal` 不会失败。该形式的固定位是对整个 48 位编码的匹配与掩码测试，没有任何操作数值被保留。

检查按固定顺序执行。适用性只在系统块终止请求挂起时失败，此时在 `TPC` 触发 `Fault_BundleControl`。否则，与形式不匹配的编码会在进入指令束主体之前于 `PC` 触发 `Fault_IllegalInstruction`，所选 `T` 或 `U` 源不可用时则在任何目标写入之前于 `PC` 触发 `Fault_IllegalInstruction`。算术本身不触发任何故障：128 位和值按模 `2^128` 回绕。

设计要点：不可用的临时项由合法性检查拒绝，而不是被读取，因此累加值绝不会由未定义的队列表项构成。这就是 `hl.madd t#1, t#1, zero, ->a0, a1` 在空 `T` 队列上触发故障、而不是发布一个数值的原因。

<!-- PTO-READER-BLOCK: scalar-hl-madd-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

取 `SrcL = 6`、`SrcR = 7`、`SrcD = 1` 时，`MultiplyWideSigned` 产生 `42`，符号扩展后的加数为 `1`，累加值为 `43`，因此 `RegDst0` 收到 `43`，`RegDst1` 收到 `0`。取负数输入 `SrcL = -3`、`SrcR = 5`、`SrcD = 1` 时累加值为 `-14`：低半部是 `0xFFFFFFFFFFFFFFF2`，高半部是 `0xFFFFFFFFFFFFFFFF`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.madd SrcL, SrcR, SrcD, ->Dst0, Dst1
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_madd_48_b062d741fd99 | HL48 | 48 | 0x00006047000e / 0x0600707f07ff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_madd_48_b062d741fd99 | RegDst0 | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_madd_48_b062d741fd99 | RegDst1 | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_madd_48_b062d741fd99 | SrcD | 5 | encoding-defined | [{"instruction_lsb":43,"value_lsb":0,"width":5}] |
| hl_madd_48_b062d741fd99 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_madd_48_b062d741fd99 | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_madd_48_b062d741fd99 | RegDst0 | 5 | 0–31 | none | none | low product or accumulator Reg5 destination | Encoded zero discards the low result. |
| hl_madd_48_b062d741fd99 | RegDst1 | 5 | 0–31 | none | none | high product or accumulator Reg5 destination | Encoded zero discards the high result. |
| hl_madd_48_b062d741fd99 | SrcD | 5 | 0–31 | none | none | addend Reg5 source | Encoded zero reads the architectural zero GPR. |
| hl_madd_48_b062d741fd99 | SrcL | 5 | 0–31 | none | none | left multiplicand or additive Reg5 source | Encoded zero reads the architectural zero GPR. |
| hl_madd_48_b062d741fd99 | SrcR | 5 | 0–31 | none | none | right multiplicand Reg5 source | Encoded zero reads the architectural zero GPR. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst0 | low product or accumulator Reg5 destination |
| RegDst1 | high product or accumulator Reg5 destination |
| SrcD | addend Reg5 source |
| SrcL | left multiplicand or additive Reg5 source |
| SrcR | right multiplicand Reg5 source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/HL.MADD.asl -->
```asl
readonly func InstructionContractOperation_HL_MADD() => ScalarOperation
begin
    return ScalarOperation_HL_MADD;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/HL.MADD.asl -->
```asl
readonly func InstructionContractHandler_HL_MADD() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarMultiplyAddPair;
end;
pure func InstructionContractAccumulator_HL_MADD(
    addend: Word,
    left: Word,
    right: Word)
    => DoubleWord
begin
    let product = MultiplyWideSigned(left, right);
    return product + SignExtend{PTO_XLEN * 2}(addend);
end;

pure func InstructionContractLow_HL_MADD(addend: Word, left: Word, right: Word) => Word
begin
    return InstructionContractAccumulator_HL_MADD(addend, left, right)[63:0];
end;

pure func InstructionContractHigh_HL_MADD(addend: Word, left: Word, right: Word) => Word
begin
    return InstructionContractAccumulator_HL_MADD(addend, left, right)[127:64];
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

- Compute the signed 128-bit product of SrcL and SrcR, sign-extend SrcD to 128 bits, and add modulo 2^128.
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

- hl.madd srcl, srcr, srcd, ->dst0, dst1
