<!-- GENERATED FROM: asl/scalar/alu/HL.MISUB.asl -->
# HL.MISUB

**Normative ASL source:** `asl/scalar/alu/HL.MISUB.asl`

HL.MISUB multiplies SrcR by the unsigned 19-bit immediate, subtracts the product from SrcL modulo 2^PTO_XLEN, and publishes the result.

## Normative identity {#PTO-INST-SCALAR-HL-MISUB}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-misub-purpose role=purpose -->
## HL.MISUB 的作用

`HL.MISUB` 是一条 48 位标量 ALU 指令，它通过一个 Reg5 目标发布按模 `2^PTO_XLEN` 回绕的 `SrcL - SrcR * uimm19`。

`SrcL` 是被减数，缩放后的乘积是减数，因此立即数决定从 `SrcL` 中减去多少份 `SrcR`。

<!-- PTO-READER-BLOCK: scalar-hl-misub-mechanism role=mechanism -->
## 结果形成方式

所属 ASL 提供 `InstructionContractResult_HL_MISUB`，它返回 `ScalarMultiplyImmediateAdd(left, right, immediate, TRUE)`。减法标志置位时，该辅助函数先计算 `MultiplyWord(right, ZeroExtend{PTO_XLEN}(immediate))`，再返回 `left - product`。分派路径共用 `ScalarOperation_HL_MIADD, ScalarOperation_HL_MISUB` 分支，并把 `operation == ScalarOperation_HL_MISUB` 作为该标志传入。

```asm
hl.misub SrcL, SrcR, uimm, ->{t, u, Rd}
```

设计要点：减法是一个完整宽度的步骤，因此大于 `SrcL` 的乘积会跨越整个字借位。`SrcL = 0`、`SrcR = 1`、`uimm19 = 1` 发布 `0xFFFFFFFFFFFFFFFF`，而不是被截断的零。

<!-- PTO-READER-BLOCK: scalar-hl-misub-inputs role=inputs-outputs -->
## 输入与目标

- `RegDst`，指令切片 `[23 +: 5]`，接收 XLEN 结果，或丢弃它。
- `SrcL`，指令切片 `[31 +: 5]`，提供被减数。
- `SrcR`，指令切片 `[36 +: 5]`，提供被乘数。
- `uimm19`，指令切片 `[41 +: 7]` 与 `[4 +: 12]`，提供数值位 `6:0` 与 `18:7`。

每个 Reg5 编码都是通用映射中的源编码或目标编码：`0..23` 命名绝对 GPR，`24..27` 命名 `T#1..T#4`，`28..31` 作为源命名 `U#1..U#4`。读取临时项会把它留在原处，两次读取都先于目标写入。

设计要点：目标与源共用这个 5 位字段，但两种角色并不对称：作为源时编码 `24..29` 是可读的临时表项，而作为目标时同样的编码会丢弃结果。`->u` 与 `->t` 分别是编码 `30` 与 `31`。

<!-- PTO-READER-BLOCK: scalar-hl-misub-effects role=effects -->
## 效果与顺序

两个源都在目标效果之前取快照，因此与 `SrcL` 或 `SrcR` 同名的目标收到的是由执行前寄存器算出的值。

结果通过 `RegDst` 发布，随后 `TPC` 前进 `6` 字节。不读写内存，数值状态、保留、描述符、指令束、特权与控制流状态都不改变；只有目标选择的队列推送能改动临时队列。

<!-- PTO-READER-BLOCK: scalar-hl-misub-constraints role=constraints -->
## 合法性与故障边界

每个 `32` 编码的源编码、每个 `32` 编码的目标编码以及 `0` 到 `524287` 之间的每个 `uimm19` 取值都有定义，因此只有临时源不可用会使操作数检查失败。固定编码位必须与规范的 48 位形式匹配。

适用性只在系统块终止请求挂起时失败，并在 `TPC` 触发 `Fault_BundleControl`。否则，不匹配的编码在进入指令束主体之前于 `PC` 触发 `Fault_IllegalInstruction`，所选 `T` 或 `U` 源不可用时则在目标写入之前于 `PC` 触发 `Fault_IllegalInstruction`。

设计要点：下溢的减法不是异常，因此该指令无法上报负的中间结果。`HL.MISUB` 发布回绕后的字，差值的符号只能从它的最高位读出。

<!-- PTO-READER-BLOCK: scalar-hl-misub-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

取 `SrcL = 20`、`SrcR = 3`、`uimm19 = 4` 时乘积为 `12`，`RegDst` 收到 `8`。取 `SrcL = 0`、`SrcR = 1`、`uimm19 = 1` 时减法回绕，`RegDst` 收到 `0xFFFFFFFFFFFFFFFF`。取 `uimm19 = 0` 时乘积为 `0`，`RegDst` 收到 `SrcL`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.misub SrcL, SrcR, uimm, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_misub_48_e9e4c7b23479 | HL48 | 48 | 0x0000104d000e / 0x0000707f000f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_misub_48_e9e4c7b23479 | RegDst | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_misub_48_e9e4c7b23479 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_misub_48_e9e4c7b23479 | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |
| hl_misub_48_e9e4c7b23479 | uimm19 | 19 | unsigned | [{"instruction_lsb":41,"value_lsb":0,"width":7},{"instruction_lsb":4,"value_lsb":7,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_misub_48_e9e4c7b23479 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| hl_misub_48_e9e4c7b23479 | SrcL | 5 | 0–31 | none | none | left multiplicand or additive Reg5 source | Encoded zero reads the architectural zero GPR. |
| hl_misub_48_e9e4c7b23479 | SrcR | 5 | 0–31 | none | none | right multiplicand Reg5 source | Encoded zero reads the architectural zero GPR. |
| hl_misub_48_e9e4c7b23479 | uimm19 | 19 | 0–524287 | none | none | unsigned 19-bit multiplier | Encoded zero selects multiplier zero. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | left multiplicand or additive Reg5 source |
| SrcR | right multiplicand Reg5 source |
| uimm19 | unsigned 19-bit multiplier |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/HL.MISUB.asl -->
```asl
readonly func InstructionContractOperation_HL_MISUB() => ScalarOperation
begin
    return ScalarOperation_HL_MISUB;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/HL.MISUB.asl -->
```asl
readonly func InstructionContractHandler_HL_MISUB() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarMultiplyImmediateAdd;
end;
pure func InstructionContractResult_HL_MISUB(
    left: Word,
    right: Word,
    immediate: bits(19))
    => Word
begin
    return ScalarMultiplyImmediateAdd(left, right, immediate, TRUE);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every encoded operand and destination field is required; no field can be omitted.
- The mnemonic fixes signedness, effective operand width, single-versus-pair result shape, and add-versus-subtract behavior; there is no encoded arithmetic mode.
- uimm19 is an unsigned value from 0 through 524287; encoded zero contributes a zero product.

## Legality

- Every source Reg5 code is assigned: 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consumption.
- Each destination independently uses the common map: codes 0 and 24..29 discard, codes 1..23 write GPRs, code 30 pushes U, and code 31 pushes T.
- Fixed encoding bits must match the canonical form; every encoded source, destination, and immediate value otherwise has assigned behavior.

## State effects

- Zero-extend uimm19 to XLEN, multiply it by SrcR, then subtract the product from SrcL modulo 2^PTO_XLEN.
- Snapshot every source before the destination effect, publish the XLEN result through the common Reg5 destination map, and do not consume relative sources.
- No memory, reservation, descriptor, numeric-status, block, privilege, branch-target, or other control state changes. Successful execution advances TPC by six bytes.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot every source before any destination effect so duplicate selectors and destination aliases observe pre-instruction values.
- Publish the result, then advance TPC by six bytes.

## Exceptions

- Multiplication and accumulation are fixed-width and raise no arithmetic exception; discarded overflow wraps modulo the defined result width.
- An unavailable selected T/U source raises Fault_IllegalInstruction before any destination effect and before TPC advances.

## Examples

- hl.misub srcl, srcr, uimm, ->{t, u, rd}
