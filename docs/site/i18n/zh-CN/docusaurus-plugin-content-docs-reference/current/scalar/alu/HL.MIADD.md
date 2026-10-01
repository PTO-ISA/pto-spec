<!-- GENERATED FROM: asl/scalar/alu/HL.MIADD.asl -->
# HL.MIADD

**Normative ASL source:** `asl/scalar/alu/HL.MIADD.asl`

HL.MIADD multiplies SrcR by the unsigned 19-bit immediate, adds SrcL modulo 2^PTO_XLEN, and publishes the result.

## Normative identity {#PTO-INST-SCALAR-HL-MIADD}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-miadd-purpose role=purpose -->
## HL.MIADD 的作用

`HL.MIADD` 是一条 48 位标量 ALU 指令，它通过一个 Reg5 目标发布按模 `2^PTO_XLEN` 回绕的 `SrcL + SrcR * uimm19`。

19 位字段是乘数。它被零扩展到 XLEN 并与 `SrcR` 相乘；乘积再以完整 XLEN 宽度加到 `SrcL` 上。

<!-- PTO-READER-BLOCK: scalar-hl-miadd-mechanism role=mechanism -->
## 结果形成方式

所属 ASL 提供 `InstructionContractResult_HL_MIADD`，它返回 `ScalarMultiplyImmediateAdd(left, right, immediate, FALSE)`。该辅助函数计算 `MultiplyWord(right, ZeroExtend{PTO_XLEN}(immediate))`，再把 `left` 加到乘积上。分派路径从 `ScalarOperation_HL_MIADD, ScalarOperation_HL_MISUB` 分支以 `ScalarDecodedBits19(instruction, form, ScalarField_uimm19)` 到达它。

```asm
hl.miadd SrcL, SrcR, uimm, ->{t, u, Rd}
```

设计要点：立即数缩放的是 `SrcR`，它本身不是独立操作数。因此令 `uimm19 = 0` 会使乘积为零，指令原样发布 `SrcL`，这是唯一不依赖 `SrcR` 的立即数取值。

<!-- PTO-READER-BLOCK: scalar-hl-miadd-inputs role=inputs-outputs -->
## 输入与目标

- `RegDst`，指令切片 `[23 +: 5]`，接收 XLEN 结果，或丢弃它。
- `SrcL`，指令切片 `[31 +: 5]`，提供加法操作数。
- `SrcR`，指令切片 `[36 +: 5]`，提供被乘数。
- `uimm19`，指令切片 `[41 +: 7]` 与 `[4 +: 12]`，提供数值位 `6:0` 与 `18:7`。

三个 Reg5 编码都使用通用映射：`0..23` 读取绝对 GPR，`24..27` 读取 `T#1..T#4`，`28..31` 读取 `U#1..U#4` 且不消耗表项。`SrcL` 或 `SrcR` 的编码零读取体系结构零 GPR。

设计要点：两段立即数并不相邻。数值位 `6:0` 位于 48 位字的高端，数值位 `18:7` 位于目标字段之下，因此译码器必须先安放两段才能做乘法。

<!-- PTO-READER-BLOCK: scalar-hl-miadd-effects role=effects -->
## 效果与顺序

`SrcL` 与 `SrcR` 在目标效果之前取快照，因此 `hl.miadd a0, a1, 3, ->a0` 仍以执行前的 `a0` 作为加法操作数。

唯一结果通过 `RegDst` 发布，随后 `TPC` 前进 `6` 字节。`HL.MIADD` 没有内存效果，也没有数值状态效果；除 `RegDst` 与 `TPC` 之外，只有目标编码选择的 `T` 或 `U` 推送能改变状态。

<!-- PTO-READER-BLOCK: scalar-hl-miadd-constraints role=constraints -->
## 合法性与故障边界

每个 `32` 编码的源编码与每个 `32` 编码的目标编码都有定义，`0` 到 `524287` 之间的每个 `uimm19` 取值也都合法，因此操作数检查只可能因临时源不可用而失败。固定编码位必须与规范的 48 位形式匹配。

适用性只在系统块终止请求挂起时失败，并在 `TPC` 触发 `Fault_BundleControl`。否则，不匹配的编码在进入指令束主体之前于 `PC` 触发 `Fault_IllegalInstruction`，所选 `T` 或 `U` 源不可用时则在目标写入之前于 `PC` 触发 `Fault_IllegalInstruction`。乘法与加法在任何数值上都不触发算术异常。

设计要点：乘数是无符号的，上限为 `524287`，因此乘法永远不会被要求取负比例。负贡献来自 `SrcR` 本身：`MultiplyWord` 作用于 XLEN 位模式，因此补码负被乘数会产生回绕后的乘积。

<!-- PTO-READER-BLOCK: scalar-hl-miadd-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

取 `SrcL = 20`、`SrcR = 3`、`uimm19 = 4` 时乘积为 `12`，`RegDst` 收到 `32`。取 `SrcR = 3`、`uimm19 = 0` 时乘积为 `0`，因此无论 `SrcR` 是什么，`RegDst` 都收到 `SrcL`。取 `SrcL = 0`、`SrcR = 0xFFFFFFFFFFFFFFFF`、`uimm19 = 2` 时乘积为 `0xFFFFFFFFFFFFFFFE`，它就是发布值。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.miadd SrcL, SrcR, uimm, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_miadd_48_ec5127b6dfd6 | HL48 | 48 | 0x0000004d000e / 0x0000707f000f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_miadd_48_ec5127b6dfd6 | RegDst | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_miadd_48_ec5127b6dfd6 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_miadd_48_ec5127b6dfd6 | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |
| hl_miadd_48_ec5127b6dfd6 | uimm19 | 19 | unsigned | [{"instruction_lsb":41,"value_lsb":0,"width":7},{"instruction_lsb":4,"value_lsb":7,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_miadd_48_ec5127b6dfd6 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| hl_miadd_48_ec5127b6dfd6 | SrcL | 5 | 0–31 | none | none | left multiplicand or additive Reg5 source | Encoded zero reads the architectural zero GPR. |
| hl_miadd_48_ec5127b6dfd6 | SrcR | 5 | 0–31 | none | none | right multiplicand Reg5 source | Encoded zero reads the architectural zero GPR. |
| hl_miadd_48_ec5127b6dfd6 | uimm19 | 19 | 0–524287 | none | none | unsigned 19-bit multiplier | Encoded zero selects multiplier zero. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | left multiplicand or additive Reg5 source |
| SrcR | right multiplicand Reg5 source |
| uimm19 | unsigned 19-bit multiplier |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/HL.MIADD.asl -->
```asl
readonly func InstructionContractOperation_HL_MIADD() => ScalarOperation
begin
    return ScalarOperation_HL_MIADD;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/HL.MIADD.asl -->
```asl
readonly func InstructionContractHandler_HL_MIADD() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarMultiplyImmediateAdd;
end;
pure func InstructionContractResult_HL_MIADD(
    left: Word,
    right: Word,
    immediate: bits(19))
    => Word
begin
    return ScalarMultiplyImmediateAdd(left, right, immediate, FALSE);
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

- Zero-extend uimm19 to XLEN, multiply it by SrcR, then add SrcL modulo 2^PTO_XLEN.
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

- hl.miadd srcl, srcr, uimm, ->{t, u, rd}
