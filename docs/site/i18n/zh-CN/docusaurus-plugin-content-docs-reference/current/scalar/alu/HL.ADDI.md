<!-- GENERATED FROM: asl/scalar/alu/HL.ADDI.asl -->
# HL.ADDI

**Normative ASL source:** `asl/scalar/alu/HL.ADDI.asl`

HL.ADDI applies XLEN addition to SrcL and a zero-extended 24-bit immediate.

## Normative identity {#PTO-INST-SCALAR-HL-ADDI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-addi-purpose role=purpose -->
## HL.ADDI 的作用

`HL.ADDI` 是带常数的 XLEN 加法的 48 位形式。它读取一个 Reg5 源，把编码的 `uimm24` 立即数零扩展到 `PTO_XLEN`，按 `2^PTO_XLEN` 取模相加，并通过 `RegDst` 发布和。编码宽度为 `48` 位，因此成功执行会使 `TPC` 前进 `6` 字节。

设计要点：`uimm24` 是无符号的，因此本助记符能表达 `0` 至 `16777215` 的每个加数，不能表达任何负加数。向下的常数由另一个助记符承担：`HL.SUBI` 读取同样的 `SrcL` 和 `uimm24` 字段并施加减法，因此这两个形式共用同一套字段布局，区别在于所施行的运算。

<!-- PTO-READER-BLOCK: scalar-hl-addi-mechanism role=mechanism -->
## 和的形成方式

编码器把 `uimm24` 放在两个 12 位片段里。译码把第一片放进值位 `11:0`，把第二片放进值位 `23:12`，因此重组出的常数是精确的，全部 `16777216` 个编码都表示互不相同的加数。

设计要点：立即数片段占据指令的第 `4..15` 位和第 `36..47` 位，而 `RegDst` 占据指令的第 `23..27` 位。两个字段不可能重叠，因此任何立即数位都不能改选目标，也没有任何立即数取值需要保留给其他角色。

重组之后，常数被零扩展到 `PTO_XLEN` 并与快照的源相加。加法是定宽的：它会回绕，不会引发算术异常。

<!-- PTO-READER-BLOCK: scalar-hl-addi-inputs role=inputs-outputs -->
## 输入与目标

- `SrcL` 读取一个 Reg5 值：编码 `0..23` 读取绝对 GPR，`24..27` 读取 `T#1..T#4`，`28..31` 读取 `U#1..U#4`。相对读取永远不会移除它所指向的队列项。
- `uimm24` 提供无符号加数，即 `0` 至 `16777215`。
- `RegDst` 接收 `PTO_XLEN` 和：`1..23` 写入该 GPR，`30` 压入 `U`，`31` 压入 `T`，`0` 与 `24..29` 一起丢弃结果。

设计要点：三个编码零是三件不同的事。`SrcL=0` 读取 GPR 零，它恒读为零且没有存储；`uimm24=0` 是数值加数 `0`；`RegDst=0` 指向同一个 GPR 零，对它的写入会被丢弃。因此 `hl.addi a0, 0, ->zero` 计算出的和不会写入任何寄存器或队列，只有 `TPC` 前进。

<!-- PTO-READER-BLOCK: scalar-hl-addi-effects role=effects -->
## 效果与顺序

`SrcL` 和 `uimm24` 都在写入目标之前解析，因此像 `hl.addi a0, 1, ->a0` 这样两次指向同一寄存器的形式，加的是指令执行前的 `a0`。相对源读取不会触动它的队列，丢弃型目标也不会触动任何寄存器和队列。

发布之后是 `TPC` 前进 `6` 字节，即使 `RegDst` 丢弃了和也是如此。`HL.ADDI` 不访问内存，也不改变保留状态、描述符、数值状态、`Tile`、指令束、特权或分支目标状态。

<!-- PTO-READER-BLOCK: scalar-hl-addi-constraints role=constraints -->
## 合法性与故障边界

每个编码取值都已分配：全部 `32` 个 `SrcL` 编码、全部 `32` 个 `RegDst` 编码，以及完整的无符号 `24` 位加数范围。

有三处可达的拒绝，按模型顺序如下。固定位不匹配任何形式的 `48` 位字在 `PC` 处引发 `Fault_IllegalInstruction`。不适用于当前指令束的指令在 `TPC` 处引发 `Fault_BundleControl`。所选 `T` 或 `U` 源不可用在 `PC` 处引发 `Fault_IllegalInstruction`。三者都先于目标效果和 `TPC` 前进。

设计要点：适用性检查先于源检查，因此一个既不适用又带有不可用源的编码报告的是 `TPC` 处的 `Fault_BundleControl`，而不是源故障。对 ALU 运算而言，适用性检查只在一个系统块已记录终止关闭请求时才会失败。

`HL.ADDI` 自身不增加算术异常：超出 `PTO_XLEN` 的和会通过回绕被丢弃。

<!-- PTO-READER-BLOCK: scalar-hl-addi-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

当 `a0` 保存 `1` 时，`hl.addi a0, 16777215, ->a0` 写入 `16777216`。当 `a0` 保存最大的 `PTO_XLEN` 值 `18446744073709551615` 时，`hl.addi a0, 1, ->a0` 写入 `0`，且 `TPC` 仍然前进 `6` 字节。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.addi SrcL, uimm, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_addi_48_9d3818bfbe64 | HL48 | 48 | 0x00000015000e / 0x0000707f000f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_addi_48_9d3818bfbe64 | RegDst | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_addi_48_9d3818bfbe64 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_addi_48_9d3818bfbe64 | uimm24 | 24 | unsigned | [{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":4,"value_lsb":12,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_addi_48_9d3818bfbe64 | RegDst | 5 | 0–31 | none | none | Reg5 scalar destination or discard selector | Encoded zero discards the result and does not modify any GPR or queue. |
| hl_addi_48_9d3818bfbe64 | SrcL | 5 | 0–31 | none | none | Reg5 scalar source | Encoded zero reads architectural GPR zero. |
| hl_addi_48_9d3818bfbe64 | uimm24 | 24 | 0–16777215 | none | none | unsigned split 24-bit immediate | Encoded zero supplies numeric zero. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 scalar destination or discard selector |
| SrcL | Reg5 scalar source |
| uimm24 | unsigned split 24-bit immediate |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/HL.ADDI.asl -->
```asl
readonly func InstructionContractOperation_HL_ADDI() => ScalarOperation
begin
    return ScalarOperation_HL_ADDI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/HL.ADDI.asl -->
```asl
readonly func InstructionContractHandler_HL_ADDI() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinary;
end;

pure func InstructionContractImmediateWidth_HL_ADDI()
    => integer {1..64}
begin
    return 24;
end;

pure func InstructionContractImmediateIsUnsigned_HL_ADDI()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractIsWordOperation_HL_ADDI()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractResult_HL_ADDI(
    left: Word,
    immediate: bits(24))
    => Word
begin
    let right = ZeroExtend{PTO_XLEN}(immediate);
    return ScalarBinary(
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

- Zero-extend uimm24 to PTO_XLEN, compute addition with the snapshotted SrcL value modulo 2^PTO_XLEN where applicable, and publish the result through RegDst.
- Codes 1..23 write a GPR; codes 0 and 24..29 discard; code 30 pushes U; code 31 pushes T. Relative source reads are non-consuming.
- No memory, reservation, descriptor, Tile, block, privilege, numeric-status, branch-target, or other control state changes. Successful execution advances TPC by six bytes.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot SrcL before the destination effect, including GPR aliases and same-queue read-then-push cases.
- Publish the result through RegDst, then advance TPC by six bytes.

## Exceptions

- HL.ADDI raises no arithmetic exception; fixed-width overflow or underflow is discarded.
- A fixed-bit mismatch or unavailable selected T/U source raises Fault_IllegalInstruction before any destination effect and before TPC advances.

## Examples

- hl.addi a0, 1, ->a0
- hl.addi t#1, 16777215, ->u
- hl.addi zero, 0, ->zero
