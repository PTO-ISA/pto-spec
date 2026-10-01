<!-- GENERATED FROM: asl/scalar/alu/HL.SUBIW.asl -->
# HL.SUBIW

**Normative ASL source:** `asl/scalar/alu/HL.SUBIW.asl`

HL.SUBIW applies word subtraction to SrcL[31:0] and the low word of a zero-extended 24-bit immediate, then sign-extends the 32-bit result.

## Normative identity {#PTO-INST-SCALAR-HL-SUBIW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-subiw-purpose role=purpose -->
## HL.SUBIW 的作用

`HL.SUBIW` 是一条 48 位标量 ALU 指令，它从 `SrcL[31:0]` 中减去零扩展 `uimm24` 的低字并按模 `2^32` 回绕，对该字差的第 `31` 位做符号扩展，并通过一个 Reg5 目标发布 XLEN 结果。

`SrcL` 只有低 `32` 位参与，立即数只有低 `24` 位参与，因为零扩展字段的其余部分都是零。

<!-- PTO-READER-BLOCK: scalar-hl-subiw-mechanism role=mechanism -->
## 结果形成方式

所属 ASL 提供 `InstructionContractResult_HL_SUBIW`，它构造 `right = ZeroExtend{PTO_XLEN}(immediate)` 并返回 `ScalarBinaryW(ScalarBinary_SUB, left, right)`。`ScalarBinaryW` 把两个低字相减得到 32 位值，并返回它的 `SignExtend{PTO_XLEN}`。分派路径用 `ExecuteDecodedImmediateBinary(instruction, form, ScalarBinary_SUB, ScalarField_uimm24, TRUE)` 选择它。

```asm
hl.subiw SrcL, uimm, ->{t, u, Rd}
```

设计要点：下溢被限制在字内，随后由符号扩展广播出去。`hl.subiw zero, 1, ->a0` 发布 `0xFFFFFFFFFFFFFFFF`，`64` 位全为 1，尽管低字中只产生了一位借位。

<!-- PTO-READER-BLOCK: scalar-hl-subiw-inputs role=inputs-outputs -->
## 输入与目标

- `RegDst`，指令切片 `[23 +: 5]`，接收符号扩展后的字结果，或丢弃它。
- `SrcL`，指令切片 `[31 +: 5]`，提供只有 `31:0` 位参与的值。
- `uimm24`，指令切片 `[36 +: 12]` 与 `[4 +: 12]`，提供数值位 `11:0` 与 `23:12`。

`SrcL` 通过通用 Reg5 映射读取：`0..23` 为绝对 GPR，`24..27` 为 `T#1..T#4`，`28..31` 为 `U#1..U#4`，不消耗表项。编码零读取体系结构 GPR 零。

设计要点：`SrcL[63:32]` 在操作之外。低字相同的两个寄存器在 `HL.SUBIW` 下产生相同的发布值，无论它们的高半部差别多大。

<!-- PTO-READER-BLOCK: scalar-hl-subiw-effects role=effects -->
## 效果与顺序

`SrcL` 在目标效果之前取快照，因此与 `SrcL` 同名的目标观察到的是执行前的值。

符号扩展后的差值通过 `RegDst` 发布，随后 `TPC` 前进 `6` 字节。`HL.SUBIW` 不做内存访问，也不改变数值状态、保留、描述符、Tile、指令束、特权与控制流状态；它能造成的唯一队列变化是由 `RegDst` 选择的 `T` 或 `U` 推送。

<!-- PTO-READER-BLOCK: scalar-hl-subiw-constraints role=constraints -->
## 合法性与故障边界

全部 `32` 个 `SrcL` 编码与全部 `32` 个 `RegDst` 编码都有定义，每个无符号 24 位立即数也都合法，因此只有临时源不可用会使操作数检查失败。固定编码位必须与规范的 48 位形式匹配。

适用性只在系统块终止请求挂起时失败，并在 `TPC` 触发 `Fault_BundleControl`。否则，不匹配的编码在进入指令束主体之前于 `PC` 触发 `Fault_IllegalInstruction`，所选 `T` 或 `U` 源不可用时则在目标写入之前于 `PC` 触发 `Fault_IllegalInstruction`。字下溢不是异常。

设计要点：立即数的扩展仍然是零扩展，因此字形式沿用 `HL.SUBI` 的无符号规则，而不是 `HL.ORIW` 的有符号规则。`W` 后缀带来的唯一差别是保留哪些源位与哪些结果位。

<!-- PTO-READER-BLOCK: scalar-hl-subiw-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

取 `SrcL = 3`、`uimm24 = 5` 时字差为 `-2`，`SignExtend(0xFFFFFFFE)` 是 `0xFFFFFFFFFFFFFFFE`，`RegDst` 收到该值。`SrcL` 取体系结构零 GPR、`uimm24 = 1` 时字下溢为 `0xFFFFFFFF`，因此 `RegDst` 收到 `0xFFFFFFFFFFFFFFFF`。取 `uimm24 = 0` 时发布值是 `SignExtend(SrcL[31:0])`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.subiw SrcL, uimm, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_subiw_48_adc7b127a2f8 | HL48 | 48 | 0x00001035000e / 0x0000707f000f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_subiw_48_adc7b127a2f8 | RegDst | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_subiw_48_adc7b127a2f8 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_subiw_48_adc7b127a2f8 | uimm24 | 24 | unsigned | [{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":4,"value_lsb":12,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_subiw_48_adc7b127a2f8 | RegDst | 5 | 0–31 | none | none | Reg5 scalar destination or discard selector | Encoded zero discards the result and does not modify any GPR or queue. |
| hl_subiw_48_adc7b127a2f8 | SrcL | 5 | 0–31 | none | none | Reg5 scalar source; only bits 31:0 participate | Encoded zero reads architectural GPR zero. |
| hl_subiw_48_adc7b127a2f8 | uimm24 | 24 | 0–16777215 | none | none | unsigned split 24-bit immediate | Encoded zero supplies numeric zero. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 scalar destination or discard selector |
| SrcL | Reg5 scalar source; only bits 31:0 participate |
| uimm24 | unsigned split 24-bit immediate |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/HL.SUBIW.asl -->
```asl
readonly func InstructionContractOperation_HL_SUBIW() => ScalarOperation
begin
    return ScalarOperation_HL_SUBIW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/HL.SUBIW.asl -->
```asl
readonly func InstructionContractHandler_HL_SUBIW() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinaryW;
end;

pure func InstructionContractImmediateWidth_HL_SUBIW()
    => integer {1..64}
begin
    return 24;
end;

pure func InstructionContractImmediateIsUnsigned_HL_SUBIW()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractIsWordOperation_HL_SUBIW()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractResult_HL_SUBIW(
    left: Word,
    immediate: bits(24))
    => Word
begin
    let right = ZeroExtend{PTO_XLEN}(immediate);
    return ScalarBinaryW(
        ScalarBinary_SUB,
        left,
        right);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL, uimm24, and RegDst are required encoded fields; no field can be omitted.
- uimm24 has the complete unsigned 24-bit range 0 through 16777215; encoded zero is numeric zero.

## Legality

- All 32 SrcL encodings are assigned: 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consuming a queue entry.
- All 32 RegDst encodings are assigned: codes 0 and 24..29 discard, codes 1..23 write absolute GPRs, code 30 pushes U, and code 31 pushes T.
- Every unsigned 24-bit value is assigned. The two 12-bit pieces reconstruct one exact 24-bit value.

## State effects

- Take SrcL[31:0] and the low 32 bits of the zero-extended uimm24, compute word subtraction modulo 2^32, sign-extend the 32-bit result to PTO_XLEN, and publish it through RegDst.
- Codes 1..23 write a GPR; codes 0 and 24..29 discard; code 30 pushes U; code 31 pushes T. Relative source reads are non-consuming.
- No memory, reservation, descriptor, Tile, block, privilege, numeric-status, branch-target, or other control state changes. Successful execution advances TPC by six bytes.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot SrcL before the destination effect, including GPR aliases and same-queue read-then-push cases.
- Publish the result through RegDst, then advance TPC by six bytes.

## Exceptions

- HL.SUBIW raises no arithmetic exception; fixed-width overflow or underflow is discarded.
- A fixed-bit mismatch or unavailable selected T/U source raises Fault_IllegalInstruction before any destination effect and before TPC advances.

## Examples

- hl.subiw a0, 1, ->a0
- hl.subiw t#1, 16777215, ->u
- hl.subiw zero, 0, ->zero
