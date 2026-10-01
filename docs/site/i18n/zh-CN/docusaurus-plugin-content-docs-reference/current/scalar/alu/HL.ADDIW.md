<!-- GENERATED FROM: asl/scalar/alu/HL.ADDIW.asl -->
# HL.ADDIW

**Normative ASL source:** `asl/scalar/alu/HL.ADDIW.asl`

HL.ADDIW applies word addition to SrcL[31:0] and the low word of a zero-extended 24-bit immediate, then sign-extends the 32-bit result.

## Normative identity {#PTO-INST-SCALAR-HL-ADDIW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-addiw-purpose role=purpose -->
## HL.ADDIW 的作用

`HL.ADDIW` 是同一 48 位加法的字形式。它取 `SrcL[31:0]` 和零扩展后 `uimm24` 的低 `32` 位，按 `2^32` 取模相加，把 `32` 位和符号扩展到 `PTO_XLEN`，并通过 `RegDst` 发布结果。成功执行会使 `TPC` 前进 `6` 字节。

设计要点：字宽边界属于运算本身，而不属于源寄存器。`SrcL` 的第 `63:32` 位从不被读取，因此进位无法离开第 `31` 位。当 `a0` 保存 `18446744069414584320` 时，`hl.addiw a0, 1, ->a0` 写入 `1`，源的整个高半部分都从结果中消失。

<!-- PTO-READER-BLOCK: scalar-hl-addiw-mechanism role=mechanism -->
## 字结果的形成方式

译码把两个 12 位立即数片段重组为一个精确的 `uimm24` 值，并把它零扩展到 `PTO_XLEN`。随后字宽助手保留两个操作数的第 `31:0` 位，用 `32` 位算术相加，并把和的第 `31` 位符号扩展到第 `63` 位。

设计要点：扩展发生在回绕之后，因此结果的第 `63:32` 位是结果第 `31` 位的副本。于是无论源保存什么，发布值都落在有符号范围 `-2147483648` 至 `2147483647` 内。

`HL.ADDIW` 与 `HL.ADDI` 共用立即数字段和目标映射。两个形式的区别在于源和结果各有多少位参与。

<!-- PTO-READER-BLOCK: scalar-hl-addiw-inputs role=inputs-outputs -->
## 输入与目标

- `SrcL` 读取一个 Reg5 值，且只有它的第 `31:0` 位参与：编码 `0..23` 读取绝对 GPR，`24..27` 读取 `T#1..T#4`，`28..31` 读取 `U#1..U#4`，且不消费队列项。
- `uimm24` 提供无符号加数，即 `0` 至 `16777215`。
- `RegDst` 接收符号扩展后的字：`1..23` 写入该 GPR，`30` 压入 `U`，`31` 压入 `T`，`0` 与 `24..29` 一起丢弃结果。

设计要点：对本形式而言 `uimm24=0` 不是空操作。`hl.addiw a0, 0, ->a0` 会把 `a0` 换成 `SrcL[31:0]` 符号扩展后的值，因此保存 `4294967295` 的 `a0` 会变成 `18446744073709551615`。编码零是一个数值加数，字运算仍然会对它做扩展。

<!-- PTO-READER-BLOCK: scalar-hl-addiw-effects role=effects -->
## 效果与顺序

`SrcL` 在写入目标之前解析，因此 `hl.addiw a0, 1, ->a0` 加的是指令执行前的 `a0`。当 `RegDst` 为 `30` 或 `31` 时，压入使新值成为 `U#1` 或 `T#1`，并丢弃原来是 `U#4` 或 `T#4` 的项。

发布之后是 `TPC` 前进 `6` 字节。`HL.ADDIW` 不访问内存，也不改变保留状态、描述符、数值状态、`Tile`、指令束、特权或分支目标状态。

<!-- PTO-READER-BLOCK: scalar-hl-addiw-constraints role=constraints -->
## 合法性与故障边界

每个编码取值都已分配：全部 `32` 个 `SrcL` 编码、全部 `32` 个 `RegDst` 编码，以及全部 `16777216` 个无符号 `24` 位加数。

有三处可达的拒绝，按模型顺序如下。固定位不匹配任何形式的 `48` 位字在 `PC` 处引发 `Fault_IllegalInstruction`。不适用于当前指令束的指令在 `TPC` 处引发 `Fault_BundleControl`。所选 `T` 或 `U` 源不可用在 `PC` 处引发 `Fault_IllegalInstruction`。它们都不会发布半个字。

设计要点：`32` 位加法是全域定义的，因此离开第 `31` 位的进位被丢弃而不是被报告。当低字为 `4294967295` 时，`hl.addiw a0, 1, ->a0` 得到的低字是 `0`，于是发布 `0`，没有任何溢出指示可读。

<!-- PTO-READER-BLOCK: scalar-hl-addiw-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

当 `a0` 保存 `18446744069414584320` 时，`hl.addiw a0, 1, ->a0` 发布 `1`，因为只有低字参与。当 `a0` 保存 `4294967295` 且 `uimm24=0` 时，`hl.addiw a0, 0, ->a0` 发布 `18446744073709551615`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.addiw SrcL, uimm, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_addiw_48_f6d7f5032964 | HL48 | 48 | 0x00000035000e / 0x0000707f000f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_addiw_48_f6d7f5032964 | RegDst | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_addiw_48_f6d7f5032964 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_addiw_48_f6d7f5032964 | uimm24 | 24 | unsigned | [{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":4,"value_lsb":12,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_addiw_48_f6d7f5032964 | RegDst | 5 | 0–31 | none | none | Reg5 scalar destination or discard selector | Encoded zero discards the result and does not modify any GPR or queue. |
| hl_addiw_48_f6d7f5032964 | SrcL | 5 | 0–31 | none | none | Reg5 scalar source; only bits 31:0 participate | Encoded zero reads architectural GPR zero. |
| hl_addiw_48_f6d7f5032964 | uimm24 | 24 | 0–16777215 | none | none | unsigned split 24-bit immediate | Encoded zero supplies numeric zero. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 scalar destination or discard selector |
| SrcL | Reg5 scalar source; only bits 31:0 participate |
| uimm24 | unsigned split 24-bit immediate |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/HL.ADDIW.asl -->
```asl
readonly func InstructionContractOperation_HL_ADDIW() => ScalarOperation
begin
    return ScalarOperation_HL_ADDIW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/HL.ADDIW.asl -->
```asl
readonly func InstructionContractHandler_HL_ADDIW() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinaryW;
end;

pure func InstructionContractImmediateWidth_HL_ADDIW()
    => integer {1..64}
begin
    return 24;
end;

pure func InstructionContractImmediateIsUnsigned_HL_ADDIW()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractIsWordOperation_HL_ADDIW()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractResult_HL_ADDIW(
    left: Word,
    immediate: bits(24))
    => Word
begin
    let right = ZeroExtend{PTO_XLEN}(immediate);
    return ScalarBinaryW(
        ScalarBinary_ADD,
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

- Take SrcL[31:0] and the low 32 bits of the zero-extended uimm24, compute word addition modulo 2^32, sign-extend the 32-bit result to PTO_XLEN, and publish it through RegDst.
- Codes 1..23 write a GPR; codes 0 and 24..29 discard; code 30 pushes U; code 31 pushes T. Relative source reads are non-consuming.
- No memory, reservation, descriptor, Tile, block, privilege, numeric-status, branch-target, or other control state changes. Successful execution advances TPC by six bytes.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot SrcL before the destination effect, including GPR aliases and same-queue read-then-push cases.
- Publish the result through RegDst, then advance TPC by six bytes.

## Exceptions

- HL.ADDIW raises no arithmetic exception; fixed-width overflow or underflow is discarded.
- A fixed-bit mismatch or unavailable selected T/U source raises Fault_IllegalInstruction before any destination effect and before TPC advances.

## Examples

- hl.addiw a0, 1, ->a0
- hl.addiw t#1, 16777215, ->u
- hl.addiw zero, 0, ->zero
