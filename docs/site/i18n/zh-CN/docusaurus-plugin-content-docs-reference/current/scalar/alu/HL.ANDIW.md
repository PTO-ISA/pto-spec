<!-- GENERATED FROM: asl/scalar/alu/HL.ANDIW.asl -->
# HL.ANDIW

**Normative ASL source:** `asl/scalar/alu/HL.ANDIW.asl`

HL.ANDIW applies word bitwise conjunction to SrcL[31:0] and the low word of a sign-extended 24-bit immediate, then sign-extends the 32-bit result.

## Normative identity {#PTO-INST-SCALAR-HL-ANDIW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-andiw-purpose role=purpose -->
## HL.ANDIW 的作用

`HL.ANDIW` 是合取的字形式。它把 `simm24` 符号扩展到 `PTO_XLEN`，保留该掩码的低 `32` 位，与 `SrcL[31:0]` 逐位组合，再把 `32` 位结果的第 `31` 位符号扩展到 `PTO_XLEN`，并通过 `RegDst` 发布。成功执行会使 `TPC` 前进 `6` 字节。

设计要点：`hl.andiw a0, -1, ->a0` 不像 `hl.andi a0, -1, ->a0` 那样让 `a0` 保持不变。字掩码全为 1，所以低字得以保留，但随后 `32` 位结果被符号扩展：保存 `4294967295` 的源会被重新发布为 `18446744073709551615`。

<!-- PTO-READER-BLOCK: scalar-hl-andiw-mechanism role=mechanism -->
## 字掩码的形成方式

译码从两个 12 位片段重建一个精确的 `24` 位值并符号扩展它。掩码的第 `23:0` 位是编码值，第 `31:24` 位是它的符号位，因此 `simm24` 为负时这八位全为 1，不为负时全为 0。随后在 `32` 个掩码位上做逐位合取。

设计要点：因此不为负的 `simm24` 除了清除第 `23` 位以上的每一位，还会清除源的第 `31:24` 位。`hl.andiw a0, 8388607, ->a0` 保留 `SrcL[22:0]`，并且由于此时结果第 `31` 位是 `0`，发布值的第 `63:32` 位全为 0。

<!-- PTO-READER-BLOCK: scalar-hl-andiw-inputs role=inputs-outputs -->
## 输入与目标

- `SrcL` 读取一个 Reg5 值，且只有第 `31:0` 位参与：编码 `0..23` 读取绝对 GPR，`24..27` 读取 `T#1..T#4`，`28..31` 读取 `U#1..U#4`，且相对读取不消费队列项。
- `simm24` 提供有符号掩码，即 `-8388608` 至 `8388607`。
- `RegDst` 接收符号扩展后的字：`1..23` 写入该 GPR，`30` 压入 `U`，`31` 压入 `T`，`0` 与 `24..29` 一起丢弃结果。

设计要点：`simm24=0` 为全部 `32` 个字位提供零掩码，因此 `hl.andiw a0, 0, ->a0` 发布 `0`。让低字原样保留的掩码是 `-1`，而即使是它也会重写第 `31` 位以上的位。

<!-- PTO-READER-BLOCK: scalar-hl-andiw-effects role=effects -->
## 效果与顺序

`SrcL` 在发布之前解析，因此目标可以指向源寄存器，读到的仍是指令执行前的值。源队列只被读取而不被弹出；`T` 或 `U` 目标压入会让新值成为该队列的下标 `1`，并丢弃原来位于下标 `4` 的项。

发布之后是 `TPC` 前进 `6` 字节。`HL.ANDIW` 不访问内存，也不改变保留状态、描述符、数值状态、`Tile`、指令束、特权或分支目标状态。

<!-- PTO-READER-BLOCK: scalar-hl-andiw-constraints role=constraints -->
## 合法性与故障边界

每个编码取值都已分配：全部 `32` 个 `SrcL` 编码、全部 `32` 个 `RegDst` 编码，以及 `-8388608` 至 `8388607` 的每个有符号 `24` 位掩码。

有三处可达的拒绝，按模型顺序如下。固定位不匹配任何形式的 `48` 位字在 `PC` 处引发 `Fault_IllegalInstruction`。不适用于当前指令束的指令在 `TPC` 处引发 `Fault_BundleControl`。所选 `T` 或 `U` 源不可用在 `PC` 处引发 `Fault_IllegalInstruction`。三者都先于目标效果和 `TPC` 前进。

设计要点：`32` 位合取是全域定义的。它不会溢出，也不会引发算术异常，因此本页中唯一能置位或清除第 `31` 位以上各位的机制，就是结果的符号扩展。

<!-- PTO-READER-BLOCK: scalar-hl-andiw-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

当 `a0` 保存 `4294967295`、`simm24=-1` 时，`hl.andiw a0, -1, ->a0` 发布 `18446744073709551615`。同一个源配合 `simm24=8388607` 时，它发布 `8388607`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.andiw SrcL, simm, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_andiw_48_878c6594c6ff | HL48 | 48 | 0x00002035000e / 0x0000707f000f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_andiw_48_878c6594c6ff | RegDst | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_andiw_48_878c6594c6ff | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_andiw_48_878c6594c6ff | simm24 | 24 | signed | [{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":4,"value_lsb":12,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_andiw_48_878c6594c6ff | RegDst | 5 | 0–31 | none | none | Reg5 scalar destination or discard selector | Encoded zero discards the result and does not modify any GPR or queue. |
| hl_andiw_48_878c6594c6ff | SrcL | 5 | 0–31 | none | none | Reg5 scalar source; only bits 31:0 participate | Encoded zero reads architectural GPR zero. |
| hl_andiw_48_878c6594c6ff | simm24 | 24 | 0–16777215 | none | none | signed split 24-bit immediate | Encoded zero supplies numeric zero. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 scalar destination or discard selector |
| SrcL | Reg5 scalar source; only bits 31:0 participate |
| simm24 | signed split 24-bit immediate |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/HL.ANDIW.asl -->
```asl
readonly func InstructionContractOperation_HL_ANDIW() => ScalarOperation
begin
    return ScalarOperation_HL_ANDIW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/HL.ANDIW.asl -->
```asl
readonly func InstructionContractHandler_HL_ANDIW() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinaryW;
end;

pure func InstructionContractImmediateWidth_HL_ANDIW()
    => integer {1..64}
begin
    return 24;
end;

pure func InstructionContractImmediateIsSigned_HL_ANDIW()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractIsWordOperation_HL_ANDIW()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractResult_HL_ANDIW(
    left: Word,
    immediate: bits(24))
    => Word
begin
    let right = SignExtend{PTO_XLEN}(immediate);
    return ScalarBinaryW(
        ScalarBinary_AND,
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

- Take SrcL[31:0] and the low 32 bits of the sign-extended simm24, compute word bitwise conjunction modulo 2^32, sign-extend the 32-bit result to PTO_XLEN, and publish it through RegDst.
- Codes 1..23 write a GPR; codes 0 and 24..29 discard; code 30 pushes U; code 31 pushes T. Relative source reads are non-consuming.
- No memory, reservation, descriptor, Tile, block, privilege, numeric-status, branch-target, or other control state changes. Successful execution advances TPC by six bytes.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot SrcL before the destination effect, including GPR aliases and same-queue read-then-push cases.
- Publish the result through RegDst, then advance TPC by six bytes.

## Exceptions

- HL.ANDIW raises no arithmetic exception; fixed-width overflow or underflow is discarded.
- A fixed-bit mismatch or unavailable selected T/U source raises Fault_IllegalInstruction before any destination effect and before TPC advances.

## Examples

- hl.andiw a0, -1, ->a0
- hl.andiw t#1, -8388608, ->u
- hl.andiw zero, 8388607, ->zero
