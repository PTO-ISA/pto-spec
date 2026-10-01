<!-- GENERATED FROM: asl/scalar/alu/HL.ORIW.asl -->
# HL.ORIW

**Normative ASL source:** `asl/scalar/alu/HL.ORIW.asl`

HL.ORIW applies word bitwise inclusive-or to SrcL[31:0] and the low word of a sign-extended 24-bit immediate, then sign-extends the 32-bit result.

## Normative identity {#PTO-INST-SCALAR-HL-ORIW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-oriw-purpose role=purpose -->
## HL.ORIW 的作用

`HL.ORIW` 是一条 48 位标量 ALU 指令，它对 `SrcL[31:0]` 与符号扩展后 `simm24` 的低字做字或运算，再把 32 位结果符号扩展到 XLEN，并通过一个 Reg5 目标发布。

只计算 `32` 个结果位，但发布字是完整的 XLEN 值，其高半部重复该结果的第 `31` 位。

<!-- PTO-READER-BLOCK: scalar-hl-oriw-mechanism role=mechanism -->
## 结果形成方式

所属 ASL 提供 `InstructionContractResult_HL_ORIW`，它构造 `right = SignExtend{PTO_XLEN}(immediate)` 并返回 `ScalarBinaryW(ScalarBinary_OR, left, right)`。`ScalarBinaryW` 取 `left[31:0]` 与 `right[31:0]`，把它们或合成 32 位值，并返回该值的 `SignExtend{PTO_XLEN}`。分派路径用 `ExecuteDecodedImmediateBinary(instruction, form, ScalarBinary_OR, ScalarField_simm24, TRUE)` 选择它。

```asm
hl.oriw SrcL, simm, ->{t, u, Rd}
```

设计要点：符号扩展后立即数的高半部在或运算之前就被丢弃，因此在这里扩展立即数不改变任何东西。真正被结果符号扩展改变的是发布的高半部：`a0 = 0x00000000FFFFFFFF` 时 `hl.oriw a0, 0, ->a0` 发布 `0xFFFFFFFFFFFFFFFF`，因为字结果的第 `31` 位是 `1`。

<!-- PTO-READER-BLOCK: scalar-hl-oriw-inputs role=inputs-outputs -->
## 输入与目标

- `RegDst`，指令切片 `[23 +: 5]`，接收符号扩展后的字结果，或丢弃它。
- `SrcL`，指令切片 `[31 +: 5]`，提供只有 `31:0` 位参与的值。
- `simm24`，指令切片 `[36 +: 12]` 与 `[4 +: 12]`，提供数值位 `11:0` 与 `23:12`。

`SrcL` 通过通用 Reg5 映射读取：`0..23` 为绝对 GPR，`24..27` 为 `T#1..T#4`，`28..31` 为 `U#1..U#4`，不消耗队列表项。编码零读取体系结构零 GPR。

设计要点：操作数字是符号扩展后立即数的低 `32` 位，因此该操作数的 `31:24` 位重复 `simm24` 的第 `23` 位。所以非负立即数在第 `23` 位以上贡献零，负立即数贡献一。

<!-- PTO-READER-BLOCK: scalar-hl-oriw-effects role=effects -->
## 效果与顺序

`SrcL` 在目标效果之前取快照，因此与 `SrcL` 同名的目标收到的是执行前值算出的结果。

符号扩展后的结果通过 `RegDst` 发布，随后 `TPC` 前进 `6` 字节。该指令没有内存效果，也没有数值状态效果；只有目标选择的 `T` 或 `U` 推送能改变队列。

<!-- PTO-READER-BLOCK: scalar-hl-oriw-constraints role=constraints -->
## 合法性与故障边界

全部 `32` 个 `SrcL` 编码与全部 `32` 个 `RegDst` 编码都有定义，每个有符号 24 位立即数也都合法，因此只有临时源不可用会使操作数检查失败。固定编码位必须与规范的 48 位形式匹配。

适用性只在系统块终止请求挂起时失败，并在 `TPC` 触发 `Fault_BundleControl`。否则，不匹配的编码在进入指令束主体之前于 `PC` 触发 `Fault_IllegalInstruction`，所选 `T` 或 `U` 源不可用时则在目标写入之前于 `PC` 触发 `Fault_IllegalInstruction`。任何操作数对都不定义算术异常。

设计要点：字形式承担与 XLEN 形式相同的故障面。把算术收窄到 `32` 位去掉的是结果位，而不是合法性检查，因此 `-8388608` 到 `8388607` 的立即数范围不变。

<!-- PTO-READER-BLOCK: scalar-hl-oriw-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

取 `SrcL = 0x00000000FFFFFFFF`、`simm24 = 0` 时或运算让字保持 `0xFFFFFFFF` 不变，而该字的 `SignExtend` 是 `0xFFFFFFFFFFFFFFFF`，因此 `RegDst` 收到 `0xFFFFFFFFFFFFFFFF`。取 `SrcL = 0`、`simm24 = 8388607` 时操作数字为 `0x007FFFFF`，字结果为 `0x007FFFFF`，`RegDst` 收到 `0x00000000007FFFFF`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.oriw SrcL, simm, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_oriw_48_17673d186249 | HL48 | 48 | 0x00003035000e / 0x0000707f000f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_oriw_48_17673d186249 | RegDst | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_oriw_48_17673d186249 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_oriw_48_17673d186249 | simm24 | 24 | signed | [{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":4,"value_lsb":12,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_oriw_48_17673d186249 | RegDst | 5 | 0–31 | none | none | Reg5 scalar destination or discard selector | Encoded zero discards the result and does not modify any GPR or queue. |
| hl_oriw_48_17673d186249 | SrcL | 5 | 0–31 | none | none | Reg5 scalar source; only bits 31:0 participate | Encoded zero reads architectural GPR zero. |
| hl_oriw_48_17673d186249 | simm24 | 24 | 0–16777215 | none | none | signed split 24-bit immediate | Encoded zero supplies numeric zero. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 scalar destination or discard selector |
| SrcL | Reg5 scalar source; only bits 31:0 participate |
| simm24 | signed split 24-bit immediate |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/HL.ORIW.asl -->
```asl
readonly func InstructionContractOperation_HL_ORIW() => ScalarOperation
begin
    return ScalarOperation_HL_ORIW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/HL.ORIW.asl -->
```asl
readonly func InstructionContractHandler_HL_ORIW() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinaryW;
end;

pure func InstructionContractImmediateWidth_HL_ORIW()
    => integer {1..64}
begin
    return 24;
end;

pure func InstructionContractImmediateIsSigned_HL_ORIW()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractIsWordOperation_HL_ORIW()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractResult_HL_ORIW(
    left: Word,
    immediate: bits(24))
    => Word
begin
    let right = SignExtend{PTO_XLEN}(immediate);
    return ScalarBinaryW(
        ScalarBinary_OR,
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

- Take SrcL[31:0] and the low 32 bits of the sign-extended simm24, compute word bitwise inclusive-or modulo 2^32, sign-extend the 32-bit result to PTO_XLEN, and publish it through RegDst.
- Codes 1..23 write a GPR; codes 0 and 24..29 discard; code 30 pushes U; code 31 pushes T. Relative source reads are non-consuming.
- No memory, reservation, descriptor, Tile, block, privilege, numeric-status, branch-target, or other control state changes. Successful execution advances TPC by six bytes.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot SrcL before the destination effect, including GPR aliases and same-queue read-then-push cases.
- Publish the result through RegDst, then advance TPC by six bytes.

## Exceptions

- HL.ORIW raises no arithmetic exception; fixed-width overflow or underflow is discarded.
- A fixed-bit mismatch or unavailable selected T/U source raises Fault_IllegalInstruction before any destination effect and before TPC advances.

## Examples

- hl.oriw a0, -1, ->a0
- hl.oriw t#1, -8388608, ->u
- hl.oriw zero, 8388607, ->zero
