<!-- GENERATED FROM: asl/scalar/alu/HL.XORIW.asl -->
# HL.XORIW

**Normative ASL source:** `asl/scalar/alu/HL.XORIW.asl`

HL.XORIW applies word bitwise exclusive-or to SrcL[31:0] and the low word of a sign-extended 24-bit immediate, then sign-extends the 32-bit result.

## Normative identity {#PTO-INST-SCALAR-HL-XORIW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-xoriw-purpose role=purpose -->
## HL.XORIW 的作用

`HL.XORIW` 是一条 48 位标量 ALU 指令，它对 `SrcL[31:0]` 与符号扩展后 `simm24` 的低字做字异或，再把 32 位结果符号扩展到 XLEN，并通过一个 Reg5 目标发布。

结果是一个先算出、后被加宽的 `32` 位值，因此发布的高半部是结果第 `31` 位的副本，而不是 `SrcL[63:32]` 的副本。

<!-- PTO-READER-BLOCK: scalar-hl-xoriw-mechanism role=mechanism -->
## 结果形成方式

所属 ASL 提供 `InstructionContractResult_HL_XORIW`，它构造 `right = SignExtend{PTO_XLEN}(immediate)` 并返回 `ScalarBinaryW(ScalarBinary_XOR, left, right)`。`ScalarBinaryW` 把 `left[31:0]` 与 `right[31:0]` 异或成 32 位值，并返回它的 `SignExtend{PTO_XLEN}`。分派路径用 `ExecuteDecodedImmediateBinary(instruction, form, ScalarBinary_XOR, ScalarField_simm24, TRUE)` 选择它。

```asm
hl.xoriw SrcL, simm, ->{t, u, Rd}
```

设计要点：字结果会清掉源的高半部，除非字结果把第 `31` 位置位。取 `a0 = 0x00000000F0F0F0F0`、`simm24 = -1` 时操作数字为 `0xFFFFFFFF`，字结果为 `0x0F0F0F0F`，发布值是 `0x000000000F0F0F0F`；而对同一源使用 `hl.xori` 会发布 `0xFFFFFFFF0F0F0F0F`。

<!-- PTO-READER-BLOCK: scalar-hl-xoriw-inputs role=inputs-outputs -->
## 输入与目标

- `RegDst`，指令切片 `[23 +: 5]`，接收符号扩展后的字结果，或丢弃它。
- `SrcL`，指令切片 `[31 +: 5]`，提供只有 `31:0` 位参与的值。
- `simm24`，指令切片 `[36 +: 12]` 与 `[4 +: 12]`，提供数值位 `11:0` 与 `23:12`。

`SrcL` 通过通用 Reg5 映射读取：`0..23` 为绝对 GPR，`24..27` 为 `T#1..T#4`，`28..31` 为 `U#1..U#4`，表项保持原位。编码零读取体系结构零 GPR。

设计要点：立即数操作数只有低字进入异或，因此立即数的符号扩展在这里不可见，而结果的符号扩展可见。该操作数字的 `31:24` 位是 `simm24` 第 `23` 位的副本。

<!-- PTO-READER-BLOCK: scalar-hl-xoriw-effects role=effects -->
## 效果与顺序

`SrcL` 在目标效果之前取快照，因此与 `SrcL` 同名的目标收到的是由执行前寄存器内容导出的值。

加宽后的字通过 `RegDst` 发布，随后 `TPC` 前进 `6` 字节。不访问内存，数值状态、保留、描述符、Tile、指令束、特权与控制流状态都不改变；只有目标选择的 `T` 或 `U` 推送能改动队列。

<!-- PTO-READER-BLOCK: scalar-hl-xoriw-constraints role=constraints -->
## 合法性与故障边界

全部 `32` 个 `SrcL` 编码与全部 `32` 个 `RegDst` 编码都有定义，每个有符号 24 位立即数也都合法，因此只有临时源不可用会使操作数检查失败。固定编码位必须与规范的 48 位形式匹配。

适用性只在系统块终止请求挂起时失败，并在 `TPC` 触发 `Fault_BundleControl`。否则，不匹配的编码在进入指令束主体之前于 `PC` 触发 `Fault_IllegalInstruction`，所选 `T` 或 `U` 源不可用时则在目标写入之前于 `PC` 触发 `Fault_IllegalInstruction`。

设计要点：字形式与 XLEN 形式共享同一立即数范围和同样两项故障检查。`W` 后缀收窄了参与合并的位，又通过符号扩展把结果加宽；它不增加也不删除任何合法性规则。

<!-- PTO-READER-BLOCK: scalar-hl-xoriw-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

取 `SrcL = 0x00000000F0F0F0F0`、`simm24 = -1` 时操作数字为 `0xFFFFFFFF`，字结果为 `0x0F0F0F0F`，`RegDst` 收到 `0x000000000F0F0F0F`。取 `SrcL = 0xFFFFFFFF00000000`、`simm24 = 0` 时只有低字参与：字结果为 `0`，因此 `RegDst` 收到 `0`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.xoriw SrcL, simm, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_xoriw_48_9a3edbd09746 | HL48 | 48 | 0x00004035000e / 0x0000707f000f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_xoriw_48_9a3edbd09746 | RegDst | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_xoriw_48_9a3edbd09746 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_xoriw_48_9a3edbd09746 | simm24 | 24 | signed | [{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":4,"value_lsb":12,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_xoriw_48_9a3edbd09746 | RegDst | 5 | 0–31 | none | none | Reg5 scalar destination or discard selector | Encoded zero discards the result and does not modify any GPR or queue. |
| hl_xoriw_48_9a3edbd09746 | SrcL | 5 | 0–31 | none | none | Reg5 scalar source; only bits 31:0 participate | Encoded zero reads architectural GPR zero. |
| hl_xoriw_48_9a3edbd09746 | simm24 | 24 | 0–16777215 | none | none | signed split 24-bit immediate | Encoded zero supplies numeric zero. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 scalar destination or discard selector |
| SrcL | Reg5 scalar source; only bits 31:0 participate |
| simm24 | signed split 24-bit immediate |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/HL.XORIW.asl -->
```asl
readonly func InstructionContractOperation_HL_XORIW() => ScalarOperation
begin
    return ScalarOperation_HL_XORIW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/HL.XORIW.asl -->
```asl
readonly func InstructionContractHandler_HL_XORIW() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinaryW;
end;

pure func InstructionContractImmediateWidth_HL_XORIW()
    => integer {1..64}
begin
    return 24;
end;

pure func InstructionContractImmediateIsSigned_HL_XORIW()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractIsWordOperation_HL_XORIW()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractResult_HL_XORIW(
    left: Word,
    immediate: bits(24))
    => Word
begin
    let right = SignExtend{PTO_XLEN}(immediate);
    return ScalarBinaryW(
        ScalarBinary_XOR,
        left,
        right);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL, simm24, and RegDst are required encoded fields; no field can be omitted.
- simm24 has the complete signed 24-bit range -8388608 through 8388607; encoded zero is numeric zero.

## Legality

- All 32 SrcL encodings are assigned: 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consuming a queue entry.
- All 32 RegDst encodings are assigned: codes 0 and 24..29 discard, codes 1..23 write absolute GPRs, code 30 pushes U, and code 31 pushes T.
- Every signed 24-bit two's-complement value is assigned. The two 12-bit pieces reconstruct one exact 24-bit value.

## State effects

- Take SrcL[31:0] and the low 32 bits of the sign-extended simm24, compute word bitwise exclusive-or modulo 2^32, sign-extend the 32-bit result to PTO_XLEN, and publish it through RegDst.
- Codes 1..23 write a GPR; codes 0 and 24..29 discard; code 30 pushes U; code 31 pushes T. Relative source reads are non-consuming.
- No memory, reservation, descriptor, Tile, block, privilege, numeric-status, branch-target, or other control state changes. Successful execution advances TPC by six bytes.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot SrcL before the destination effect, including GPR aliases and same-queue read-then-push cases.
- Publish the result through RegDst, then advance TPC by six bytes.

## Exceptions

- HL.XORIW raises no arithmetic exception; fixed-width overflow or underflow is discarded.
- A fixed-bit mismatch or unavailable selected T/U source raises Fault_IllegalInstruction before any destination effect and before TPC advances.

## Examples

- hl.xoriw a0, -1, ->a0
- hl.xoriw t#1, -8388608, ->u
- hl.xoriw zero, 8388607, ->zero
