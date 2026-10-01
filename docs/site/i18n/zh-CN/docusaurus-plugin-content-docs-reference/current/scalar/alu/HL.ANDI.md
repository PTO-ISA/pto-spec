<!-- GENERATED FROM: asl/scalar/alu/HL.ANDI.asl -->
# HL.ANDI

**Normative ASL source:** `asl/scalar/alu/HL.ANDI.asl`

HL.ANDI applies XLEN bitwise conjunction to SrcL and a sign-extended 24-bit immediate.

## Normative identity {#PTO-INST-SCALAR-HL-ANDI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-andi-purpose role=purpose -->
## HL.ANDI 的作用

`HL.ANDI` 是带常数的按位合取的 48 位形式。它读取一个 Reg5 源，把编码的 `simm24` 立即数符号扩展到 `PTO_XLEN`，并通过 `RegDst` 发布两个值的合取。成功执行会使 `TPC` 前进 `6` 字节。

设计要点：立即数是有符号的，因此当 `simm24` 为负时，扩展会把第 `23` 位以上的每个结果位填成 1，不为负时则填成 0。因此 `hl.andi a0, -1, ->a0` 是恒等掩码，而 `hl.andi a0, 8388607, ->a0` 会清除第 `23` 位起的每个源位。

<!-- PTO-READER-BLOCK: scalar-hl-andi-mechanism role=mechanism -->
## 掩码的形成方式

译码从值位 `11:0` 和 `23:12` 处的两个 12 位片段重建一个精确的 `24` 位值，再把第 `23` 位符号扩展到第 `63` 位。合取是逐位的，因此每个结果位只取决于同一位置上的源位和掩码位。

设计要点：合取不会溢出，因此本页唯一的宽度效应就是掩码本身。当 `simm24` 不为负时，掩码的第 `63:24` 位是 0，结果中第 `23` 位以上没有任何位被置位。当 `simm24` 为负时，这些掩码位是 1，对应的结果位就照抄源。

<!-- PTO-READER-BLOCK: scalar-hl-andi-inputs role=inputs-outputs -->
## 输入与目标

- `SrcL` 读取一个 Reg5 值：编码 `0..23` 读取绝对 GPR，`24..27` 读取 `T#1..T#4`，`28..31` 读取 `U#1..U#4`。相对读取会让所指的队列项留在原处。
- `simm24` 提供有符号掩码，即 `-8388608` 至 `8388607`。
- `RegDst` 接收合取结果：`1..23` 写入该 GPR，`30` 压入 `U`，`31` 压入 `T`，`0` 与 `24..29` 一起丢弃结果。

设计要点：`simm24=0` 是数值零掩码，而不是被省略的操作数，因此 `hl.andi a0, 0, ->a0` 会向 `a0` 写入 `0`。想让源原样通过的调用者必须编码 `-1`，因为掩码 `0` 什么都不保留。

<!-- PTO-READER-BLOCK: scalar-hl-andi-effects role=effects -->
## 效果与顺序

`SrcL` 在写入目标之前读取，因此像 `hl.andi a0, -1, ->a0` 这样重复选择符的形式仍然读取指令执行前的 `a0`。`T` 或 `U` 源不会被消费；只有 `RegDst=30` 或 `RegDst=31` 会改变队列，它让新值成为下标 `1`，并丢弃原来位于下标 `4` 的项。

发布之后是 `TPC` 前进 `6` 字节。`HL.ANDI` 不访问内存，也不改变保留状态、描述符、数值状态、`Tile`、指令束、特权或分支目标状态。

<!-- PTO-READER-BLOCK: scalar-hl-andi-constraints role=constraints -->
## 合法性与故障边界

每个编码取值都已分配：全部 `32` 个 `SrcL` 编码、全部 `32` 个 `RegDst` 编码，以及 `-8388608` 至 `8388607` 的每个有符号 `24` 位补码掩码。

有三处可达的拒绝，按模型顺序如下。固定位不匹配任何形式的 `48` 位字在 `PC` 处引发 `Fault_IllegalInstruction`。不适用于当前指令束的指令在 `TPC` 处引发 `Fault_BundleControl`。所选 `T` 或 `U` 源不可用在 `PC` 处引发 `Fault_IllegalInstruction`。三者都先于目标效果和 `TPC` 前进。

设计要点：由于该字段取值全部已分配，两个极端掩码都是普通编码。`-8388608` 保留第 `63:23` 位并清除第 `22:0` 位，`8388607` 则是它在低 `24` 位内的补集。两个极端都没有被保留，也都不是故障。

`HL.ANDI` 不增加算术异常：合取没有可丢弃的溢出。

<!-- PTO-READER-BLOCK: scalar-hl-andi-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

当 `a0` 保存 `18446744073709551615`、`simm24=8388607` 时，`hl.andi a0, 8388607, ->a0` 发布 `8388607`。当 `simm24=-8388608` 时，同一个源发布 `18446744073701163008`；当 `simm24=-1` 时，它被原样重新发布。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.andi SrcL, simm, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_andi_48_fe11c7ebca41 | HL48 | 48 | 0x00002015000e / 0x0000707f000f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_andi_48_fe11c7ebca41 | RegDst | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_andi_48_fe11c7ebca41 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_andi_48_fe11c7ebca41 | simm24 | 24 | signed | [{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":4,"value_lsb":12,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_andi_48_fe11c7ebca41 | RegDst | 5 | 0–31 | none | none | Reg5 scalar destination or discard selector | Encoded zero discards the result and does not modify any GPR or queue. |
| hl_andi_48_fe11c7ebca41 | SrcL | 5 | 0–31 | none | none | Reg5 scalar source | Encoded zero reads architectural GPR zero. |
| hl_andi_48_fe11c7ebca41 | simm24 | 24 | 0–16777215 | none | none | signed split 24-bit immediate | Encoded zero supplies numeric zero. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 scalar destination or discard selector |
| SrcL | Reg5 scalar source |
| simm24 | signed split 24-bit immediate |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/HL.ANDI.asl -->
```asl
readonly func InstructionContractOperation_HL_ANDI() => ScalarOperation
begin
    return ScalarOperation_HL_ANDI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/HL.ANDI.asl -->
```asl
readonly func InstructionContractHandler_HL_ANDI() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinary;
end;

pure func InstructionContractImmediateWidth_HL_ANDI()
    => integer {1..64}
begin
    return 24;
end;

pure func InstructionContractImmediateIsSigned_HL_ANDI()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractIsWordOperation_HL_ANDI()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractResult_HL_ANDI(
    left: Word,
    immediate: bits(24))
    => Word
begin
    let right = SignExtend{PTO_XLEN}(immediate);
    return ScalarBinary(
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

- Sign-extend simm24 to PTO_XLEN, compute bitwise conjunction with the snapshotted SrcL value modulo 2^PTO_XLEN where applicable, and publish the result through RegDst.
- Codes 1..23 write a GPR; codes 0 and 24..29 discard; code 30 pushes U; code 31 pushes T. Relative source reads are non-consuming.
- No memory, reservation, descriptor, Tile, block, privilege, numeric-status, branch-target, or other control state changes. Successful execution advances TPC by six bytes.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot SrcL before the destination effect, including GPR aliases and same-queue read-then-push cases.
- Publish the result through RegDst, then advance TPC by six bytes.

## Exceptions

- HL.ANDI raises no arithmetic exception; fixed-width overflow or underflow is discarded.
- A fixed-bit mismatch or unavailable selected T/U source raises Fault_IllegalInstruction before any destination effect and before TPC advances.

## Examples

- hl.andi a0, -1, ->a0
- hl.andi t#1, -8388608, ->u
- hl.andi zero, 8388607, ->zero
