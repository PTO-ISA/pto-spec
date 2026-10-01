<!-- GENERATED FROM: asl/scalar/alu/HL.MADDW.asl -->
# HL.MADDW

**Normative ASL source:** `asl/scalar/alu/HL.MADDW.asl`

HL.MADDW computes a signed 64-bit word multiply-add result and publishes its sign-extended low and high 32-bit halves.

## Normative identity {#PTO-INST-SCALAR-HL-MADDW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-maddw-purpose role=purpose -->
## HL.MADDW 的作用

`HL.MADDW` 是一条 48 位标量 ALU 指令。它把三个源的低字按有符号值读取，形成 64 位累加值 `signed32(SrcL) * signed32(SrcR) + signed32(SrcD)`，并发布它的两个 32 位半部，每个半部都符号扩展到 XLEN。

两个半部都会被发布，因此目标对承载完整的 64 位累加值：`RegDst0` 收到 `SignExtend(result[31:0])`，`RegDst1` 收到 `SignExtend(result[63:32])`。

<!-- PTO-READER-BLOCK: scalar-hl-maddw-mechanism role=mechanism -->
## 结果形成方式

所属 ASL 提供 `InstructionContractResult_HL_MADDW`：它把 `addend[31:0]`、`left[31:0]` 与 `right[31:0]` 符号扩展到 XLEN，取 `MultiplyWideSigned` 的低 `64` 位，再加上扩展后的加数。分派路径以 `word_operation` 为真调用 `ExecuteScalarMultiplyAddPair`，得到同一个 64 位累加值。

```asm
hl.maddw SrcL, SrcR, SrcD, ->Dst0, Dst1
```

设计要点：字截断发生在乘法之前，而不是乘法之后。取 `SrcL = 0x100000000`、`SrcR = 2`、`SrcD = 0` 时，因为 `SrcL` 的低字是 `0`，`HL.MADDW` 在两个半部都发布 `0`，而 `HL.MADD` 会发布 `0x200000000`；源中高于第 `31` 位的任何位都无法影响 `HL.MADDW` 的两个目标。

<!-- PTO-READER-BLOCK: scalar-hl-maddw-inputs role=inputs-outputs -->
## 输入与目标

- `RegDst0`，指令切片 `[23 +: 5]`，接收 `SignExtend(result[31:0])`。
- `RegDst1`，指令切片 `[11 +: 5]`，接收 `SignExtend(result[63:32])`。
- `SrcD`，指令切片 `[43 +: 5]`，提供加数字。
- `SrcL`，指令切片 `[31 +: 5]`，提供左乘数字。
- `SrcR`，指令切片 `[36 +: 5]`，提供右乘数字。

源使用通用 Reg5 映射：`0..23` 读取绝对 GPR，`24..27` 读取 `T#1..T#4`，`28..31` 读取 `U#1..U#4` 且不消耗表项。三次读取都发生在任一目标写入之前。

设计要点：由于两个半部各自独立地符号扩展，负的累加值会在 `RegDst1` 发布 `0xFFFFFFFFFFFFFFFF`，而不是原始高字。因此高目标与低目标使用同一种 XLEN 值格式，而不是一个无符号字段。

<!-- PTO-READER-BLOCK: scalar-hl-maddw-effects role=effects -->
## 效果与顺序

完整的 64 位累加值在第一次目标写入之前由源快照形成，因此重复的目标名称以及源与目标同名的情况都只能观察到本指令执行前的值。

发布顺序是 `RegDst0` 之后 `RegDst1`。如果两个选择子指向同一个 GPR，第二个高字结果是最终值；如果两者推入同一队列，`SignExtend(result[63:32])` 是最新表项，`SignExtend(result[31:0])` 是次新表项。

发布之后，`TPC` 前进 `6` 字节。不读写内存，`RegDst0`、`RegDst1` 与 `TPC` 之外的任何状态都不改变。

<!-- PTO-READER-BLOCK: scalar-hl-maddw-constraints role=constraints -->
## 合法性与故障边界

每个 `32` 编码的源编码都有定义，每个 `32` 编码的目标编码都被接受，因此只有源可用性会使操作数检查失败。固定编码位必须与规范的 48 位形式匹配；除此之外没有操作数值被保留。

适用性只在系统块终止请求挂起时失败，并在 `TPC` 触发 `Fault_BundleControl`。与形式不匹配的编码在进入指令束主体之前于 `PC` 触发 `Fault_IllegalInstruction`。所选 `T` 或 `U` 源不可用时，在任一目标写入之前于 `PC` 触发 `Fault_IllegalInstruction`，`TPC` 停留在出错指令上。

设计要点：累加值在 `64` 位内计算，而两个目标都是 XLEN 字。两个目标都使用成对形式共用的目标映射，因此即使算术更窄，丢弃与队列推送目标编码的行为与其他成对形式完全一致。

<!-- PTO-READER-BLOCK: scalar-hl-maddw-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

取 `SrcL = -3`、`SrcR = 5`、`SrcD = 1` 时，有符号字乘积为 `-15`，结果为 `-14`，`RegDst0` 收到 `SignExtend(0xFFFFFFF2)` = `0xFFFFFFFFFFFFFFF2`，而 `RegDst1` 收到 `SignExtend(0xFFFFFFFF)` = `0xFFFFFFFFFFFFFFFF`。取 `SrcL = 70000`、`SrcR = 70000`、`SrcD = 0` 时，64 位结果是 `4900000000`，即 `0x124101100`，因此 `RegDst0` 收到 `605032704`，`RegDst1` 收到 `1`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.maddw SrcL, SrcR, SrcD, ->Dst0, Dst1
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_maddw_48_6fac897f0264 | HL48 | 48 | 0x00007047000e / 0x0600707f07ff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_maddw_48_6fac897f0264 | RegDst0 | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_maddw_48_6fac897f0264 | RegDst1 | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_maddw_48_6fac897f0264 | SrcD | 5 | encoding-defined | [{"instruction_lsb":43,"value_lsb":0,"width":5}] |
| hl_maddw_48_6fac897f0264 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_maddw_48_6fac897f0264 | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_maddw_48_6fac897f0264 | RegDst0 | 5 | 0–31 | none | none | sign-extended result[31:0] Reg5 destination | Encoded zero discards the low result. |
| hl_maddw_48_6fac897f0264 | RegDst1 | 5 | 0–31 | none | none | sign-extended result[63:32] Reg5 destination | Encoded zero discards the high result. |
| hl_maddw_48_6fac897f0264 | SrcD | 5 | 0–31 | none | none | addend Reg5 source | Encoded zero reads the architectural zero GPR. |
| hl_maddw_48_6fac897f0264 | SrcL | 5 | 0–31 | none | none | left multiplicand or additive Reg5 source | Encoded zero reads the architectural zero GPR. |
| hl_maddw_48_6fac897f0264 | SrcR | 5 | 0–31 | none | none | right multiplicand Reg5 source | Encoded zero reads the architectural zero GPR. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst0 | sign-extended result[31:0] Reg5 destination |
| RegDst1 | sign-extended result[63:32] Reg5 destination |
| SrcD | addend Reg5 source |
| SrcL | left multiplicand or additive Reg5 source |
| SrcR | right multiplicand Reg5 source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/HL.MADDW.asl -->
```asl
readonly func InstructionContractOperation_HL_MADDW() => ScalarOperation
begin
    return ScalarOperation_HL_MADDW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/HL.MADDW.asl -->
```asl
readonly func InstructionContractHandler_HL_MADDW() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarMultiplyAddPair;
end;
pure func InstructionContractResult_HL_MADDW(
    addend: Word,
    left: Word,
    right: Word)
    => Word
begin
    let effective_addend = SignExtend{PTO_XLEN}(addend[31:0]);
    let effective_left = SignExtend{PTO_XLEN}(left[31:0]);
    let effective_right = SignExtend{PTO_XLEN}(right[31:0]);
    let product = MultiplyWideSigned(effective_left, effective_right);
    return product[63:0] + effective_addend;
end;

pure func InstructionContractLow_HL_MADDW(
    addend: Word,
    left: Word,
    right: Word)
    => Word
begin
    return SignExtend{PTO_XLEN}(
        InstructionContractResult_HL_MADDW(addend, left, right)[31:0]);
end;

pure func InstructionContractHigh_HL_MADDW(
    addend: Word,
    left: Word,
    right: Word)
    => Word
begin
    return SignExtend{PTO_XLEN}(
        InstructionContractResult_HL_MADDW(addend, left, right)[63:32]);
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

- Interpret SrcD[31:0], SrcL[31:0], and SrcR[31:0] as signed two-complement values; compute signed32(SrcL) * signed32(SrcR) + signed32(SrcD) modulo 2^64.
- Snapshot every source and compute the complete 64-bit result before destinations. Publish SignExtend(result[31:0]) to RegDst0, then SignExtend(result[63:32]) to RegDst1.
- Duplicate destinations are legal and retain the second high-word result. No memory, reservation, descriptor, numeric-status, block, privilege, branch-target, or other control state changes. Successful execution advances TPC by six bytes.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot every source before any destination effect so duplicate selectors and destination aliases observe pre-instruction values.
- Publish SignExtend(result[31:0]) to RegDst0, publish SignExtend(result[63:32]) to RegDst1, then advance TPC by six bytes.

## Exceptions

- Multiplication and accumulation are fixed-width and raise no arithmetic exception; discarded overflow wraps modulo the defined result width.
- An unavailable selected T/U source raises Fault_IllegalInstruction before any destination effect and before TPC advances.

## Examples

- hl.maddw srcl, srcr, srcd, ->dst0, dst1
