<!-- GENERATED FROM: asl/scalar/alu/HL.MULU.asl -->
# HL.MULU

**Normative ASL source:** `asl/scalar/alu/HL.MULU.asl`

HL.MULU computes an unsigned 128-bit scalar product and publishes its low half followed by its high half.

## Normative identity {#PTO-INST-SCALAR-HL-MULU}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-mulu-purpose role=purpose -->
## HL.MULU 的作用

`HL.MULU` 是一条 48 位标量 ALU 指令，它形成两个 XLEN 源的无符号 128 位乘积，并把 `product[63:0]` 发布到 `RegDst0`、把 `product[127:64]` 发布到 `RegDst1`。

两个源都按无符号数值读取，因此最高位被置位的源贡献的是它的大正值，而不是负值。

<!-- PTO-READER-BLOCK: scalar-hl-mulu-mechanism role=mechanism -->
## 结果形成方式

所属 ASL 提供 `InstructionContractProduct_HL_MULU`，它返回 `MultiplyWideUnsigned(left, right)`。该辅助函数把两个操作数零扩展到 128 位，并按 `right` 的每个置位位置累加左移后的 `left`。`InstructionContractLow_HL_MULU` 与 `InstructionContractHigh_HL_MULU` 分别取结果的 `63:0` 位与 `127:64` 位。

```asm
hl.mulu SrcL, SrcR, ->Dst0, Dst1
```

设计要点：只有高半部能区分无符号形式。由于乘积的低 `64` 位由操作数的低 `64` 位决定，对任意输入 `HL.MULU` 与 `HL.MUL` 的 `RegDst0` 都相同；`SrcL = 0xFFFFFFFFFFFFFFFF`、`SrcR = 2` 正是 `RegDst1` 把二者分开的情形：这里是 `0x1`，而在 `HL.MUL` 下是 `0xFFFFFFFFFFFFFFFF`。

<!-- PTO-READER-BLOCK: scalar-hl-mulu-inputs role=inputs-outputs -->
## 输入与目标

- `RegDst0`，指令切片 `[23 +: 5]`，接收 `product[63:0]`。
- `RegDst1`，指令切片 `[11 +: 5]`，接收 `product[127:64]`。
- `SrcL`，指令切片 `[31 +: 5]`，提供左乘数。
- `SrcR`，指令切片 `[36 +: 5]`，提供右乘数。

Reg5 源映射是通用的那一张：`0..23` 是绝对 GPR，`24..27` 是 `T#1..T#4`，`28..31` 是 `U#1..U#4`，全部非消耗读取。两份快照都在任一目标写入之前取得。

设计要点：目标映射与 `HL.MUL` 共用，因此 `->Dst0, Dst1` 取编码 `0` 与 `31` 时会丢弃低半部并把高半部推入 `T`。丢弃这一对中的一半并不会阻止另一半被发布。

<!-- PTO-READER-BLOCK: scalar-hl-mulu-effects role=effects -->
## 效果与顺序

源先取快照，完整的 128 位乘积在任何写入之前形成，因此目标同名与重复选择子观察到的都是执行前的值。

先用低半部写 `RegDst0`，再用高半部写 `RegDst1`。在重复的 GPR 上高半部是最终值；在重复的队列推送上高半部是最新表项，低半部是次新表项。

目标效果完成后 `TPC` 前进 `6` 字节。该指令不读写内存，对数值状态、保留、描述符、指令束、特权与控制流状态都没有影响。

<!-- PTO-READER-BLOCK: scalar-hl-mulu-constraints role=constraints -->
## 合法性与故障边界

5 位字段的每个源编码与每个目标编码都有定义。`ScalarDestinationSelectorLegal` 接受全部 `32` 个目标编码，因此操作数检查只可能因临时源不可用而失败。固定编码位必须与规范的 48 位形式匹配。

适用性只在系统块终止请求挂起时失败，并在 `TPC` 触发 `Fault_BundleControl`。否则第一个可能的故障是与形式不匹配的编码在进入指令束主体之前于 `PC` 触发的 `Fault_IllegalInstruction`，第二个是所选 `T` 或 `U` 源不可用时在任一目标写入之前于 `PC` 触发的 `Fault_IllegalInstruction`。

设计要点：由于源按无符号数值读取，根本不存在负值拐角。`0xFFFFFFFFFFFFFFFF` 只是最大的输入，两个 XLEN 数值的乘积总能放进 `128` 位结果，任何输入都不定义异常。

<!-- PTO-READER-BLOCK: scalar-hl-mulu-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

取 `SrcL = 0xFFFFFFFFFFFFFFFF`、`SrcR = 2` 时，无符号乘积为 `2^65 - 2`，因此 `RegDst0` 收到 `0xFFFFFFFFFFFFFFFE`，`RegDst1` 收到 `0x1`。取 `SrcL = 6`、`SrcR = 7` 时乘积为 `42`，`RegDst0`、`RegDst1` 分别收到 `42` 与 `0`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.mulu SrcL, SrcR, ->Dst0, Dst1
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_mulu_48_85efdc81e8fc | HL48 | 48 | 0x00001047000e / 0xfe00707f07ff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_mulu_48_85efdc81e8fc | RegDst0 | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_mulu_48_85efdc81e8fc | RegDst1 | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_mulu_48_85efdc81e8fc | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_mulu_48_85efdc81e8fc | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_mulu_48_85efdc81e8fc | RegDst0 | 5 | 0–31 | none | none | low product or accumulator Reg5 destination | Encoded zero discards the low result. |
| hl_mulu_48_85efdc81e8fc | RegDst1 | 5 | 0–31 | none | none | high product or accumulator Reg5 destination | Encoded zero discards the high result. |
| hl_mulu_48_85efdc81e8fc | SrcL | 5 | 0–31 | none | none | left multiplicand or additive Reg5 source | Encoded zero reads the architectural zero GPR. |
| hl_mulu_48_85efdc81e8fc | SrcR | 5 | 0–31 | none | none | right multiplicand Reg5 source | Encoded zero reads the architectural zero GPR. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst0 | low product or accumulator Reg5 destination |
| RegDst1 | high product or accumulator Reg5 destination |
| SrcL | left multiplicand or additive Reg5 source |
| SrcR | right multiplicand Reg5 source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/HL.MULU.asl -->
```asl
readonly func InstructionContractOperation_HL_MULU() => ScalarOperation
begin
    return ScalarOperation_HL_MULU;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/HL.MULU.asl -->
```asl
readonly func InstructionContractHandler_HL_MULU() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarMultiplyPair;
end;
pure func InstructionContractProduct_HL_MULU(left: Word, right: Word) => DoubleWord
begin
    return MultiplyWideUnsigned(left, right);
end;

pure func InstructionContractLow_HL_MULU(left: Word, right: Word) => Word
begin
    return InstructionContractProduct_HL_MULU(left, right)[63:0];
end;

pure func InstructionContractHigh_HL_MULU(left: Word, right: Word) => Word
begin
    return InstructionContractProduct_HL_MULU(left, right)[127:64];
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

- Zero-extend both XLEN sources into an unsigned 128-bit product.
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

- hl.mulu srcl, srcr, ->dst0, dst1
