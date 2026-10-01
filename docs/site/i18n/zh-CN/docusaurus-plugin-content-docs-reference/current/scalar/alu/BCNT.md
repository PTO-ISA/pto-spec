<!-- GENERATED FROM: asl/scalar/alu/BCNT.asl -->
# BCNT

**Normative ASL source:** `asl/scalar/alu/BCNT.asl`

BCNT counts set bits in an independently selected wrapping scalar field and publishes the XLEN population count.

## Normative identity {#PTO-INST-SCALAR-BCNT}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-bcnt-purpose role=purpose -->
## BCNT 的作用

`BCNT` 在一个 Reg5 源中选取一个位字段，统计其中被置位的位数，并把该计数作为 XLEN 字通过 Reg5 目标发布。

设计要点：`BCNT` 用两个立即数字段而不是掩码寄存器来给出字段。这样该运算只需要三个编码操作数，并且所选字段是指令文本的属性，而不是运行期状态的属性。

<!-- PTO-READER-BLOCK: scalar-bcnt-mechanism role=mechanism -->
## 结果形成方式

- `imms` 是字段起始位 `M`，取值为 `0` 至 `63`。
- `imml` 编码字段宽度 `N` 减一，因此原始取值 `0` 至 `63` 选择宽度 `1` 至 `64`。

指令提取从位 `M` 开始的 `N` 位字段，并统计其中被置位的位数。发布值就是这个计数，因此全零字段发布 `0`，全一字段发布 `N`。

设计要点：`imml` 存放的是 `N - 1` 而不是 `N`，这样 `N=64`（整个寄存器）仍能放进六位。因此编码零选择的是一位字段，而不是空字段或被省略的字段。

设计要点：字段会回绕。当 `M + N` 超过 `64` 时，字段从位 `0` 继续；实现方式是把源循环右移 `M` 位，然后读取低 `N` 位。程序员可以依赖的一个结果是：对任何 `M`，`N=64` 都选取整个寄存器，因此 `bcnt a0, 0, 64, ->a1` 与 `bcnt a0, 63, 64, ->a1` 发布相同的计数。

设计要点：宽度是 6 位立即数，因此所选字段永远不会超过 `64` 位，计数也永远不会超过 `64`。既不需要饱和规则，也不会发生溢出。

<!-- PTO-READER-BLOCK: scalar-bcnt-inputs role=inputs-outputs -->
## 输入与目标

- `SrcL` 是 Reg5 源：`0..23` 读取绝对 GPR，`24..27` 读取 `T#1..T#4`，`28..31` 读取 `U#1..U#4`。读取临时源不会消费它。
- `imml` 和 `imms` 是编码字段而不是寄存器，因此不指向任何存储。
- `RegDst` 发布计数：`1..23` 写入该 GPR，`30` 压入 `U`，`31` 压入 `T`，`0` 与 `24..29` 一起丢弃结果。

设计要点：`SrcL` 的编码零读取架构零 GPR，它的任何位字段都计为 `0`。`imml` 的编码零选择 `1` 位字段，`imms` 的编码零把它起始于位 `0`，因此 `bcnt zero, 0, 1, ->a1` 发布 `0`，且没有任何可能改变答案的源读取。

<!-- PTO-READER-BLOCK: scalar-bcnt-effects role=effects -->
## 效果与顺序

`SrcL` 在写入目标之前读取，因此与源重名的目标不会改变被计数的值。

计数发布或丢弃之后，`TPC` 前进 `4` 字节。`BCNT` 不访问内存；除 `RegDst` 选中的那一次 `T` 或 `U` 压入外，它不改变保留状态、描述符、数值状态、陷阱、指令束、特权、谓词和控制流状态。

<!-- PTO-READER-BLOCK: scalar-bcnt-constraints role=constraints -->
## 合法性与故障边界

每个编码取值都已分配：全部 `32` 个 `SrcL` 编码、全部 `32` 个 `RegDst` 编码，以及每个 `imml` 和 `imms` 取值。既没有保留的字段宽度，也没有保留的起始位。

无法译码的形式在 `PC` 处引发 `Fault_IllegalInstruction`；不适用于当前指令束的指令在 `TPC` 处引发 `Fault_BundleControl`；固定编码位不匹配或所选 T/U 源不可用会引发 `Fault_IllegalInstruction`。这些都先于目标效果和 `TPC` 前进。

设计要点：统计位数不会产生异常取值，因此 `BCNT` 不引发算术、内存、对齐或权限故障。它的故障边界完全由编码与源可用性构成。

<!-- PTO-READER-BLOCK: scalar-bcnt-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

当 `SrcL=1`、`M=60`、`N=8` 时，所选字段是位 `60..63` 再接位 `0..3`；其中包含被置位的位 `0`，因此 `bcnt a0, 60, 8, ->a1` 发布 `1`。当 `SrcL=18446744073709551615`、`M=0`、`N=64` 时，每一位都被置位，发布的计数为 `64`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
bcnt srcL,  M, N, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| bcnt_32_e0b06e436a5b | L32 | 32 | 0x00006067 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| bcnt_32_e0b06e436a5b | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| bcnt_32_e0b06e436a5b | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| bcnt_32_e0b06e436a5b | imml | 6 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":6}] |
| bcnt_32_e0b06e436a5b | imms | 6 | encoding-defined | [{"instruction_lsb":26,"value_lsb":0,"width":6}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| bcnt_32_e0b06e436a5b | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| bcnt_32_e0b06e436a5b | SrcL | 5 | 0–31 | none | none | Reg5 source | Encoded zero reads the architectural zero GPR. |
| bcnt_32_e0b06e436a5b | imml | 6 | 0–63 | none | none | selected field width N minus one | Encoded zero selects a one-bit field. |
| bcnt_32_e0b06e436a5b | imms | 6 | 0–63 | none | none | selected field starting bit M | Encoded zero starts the selected field at source bit zero. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | Reg5 source |
| imml | selected field width N minus one |
| imms | selected field starting bit M |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/BCNT.asl -->
```asl
readonly func InstructionContractOperation_BCNT()
    => ScalarOperation
begin
    return ScalarOperation_BCNT;
end;

pure func InstructionContractWidth_BCNT(encoded_imml: bits(6))
    => integer {1..64}
begin
    return UInt(encoded_imml) + 1;
end;

pure func InstructionContractOffset_BCNT(encoded_imms: bits(6))
    => integer {0..63}
begin
    return UInt(encoded_imms);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/BCNT.asl -->
```asl
readonly func InstructionContractHandler_BCNT()
    => ScalarSemanticHandler
begin
    return ScalarHandler_CountBitfield;
end;

pure func InstructionContractResult_BCNT(
    value: Word,
    width: integer {1..64},
    offset: integer {0..63})
    => Word
begin
    return CountBitfield(
        value,
        width,
        offset,
        FALSE,
        TRUE);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL, imml, imms, and RegDst are required encoded fields; no field can be omitted.
- imml encodes N minus one, so raw values 0 through 63 select widths 1 through 64; encoded zero selects N=1.
- imms directly encodes M from 0 through 63; encoded zero selects source bit zero.

## Legality

- SrcL codes 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consumption.
- RegDst codes 0 and 24..29 discard, codes 1..23 write GPRs, code 30 pushes U, and code 31 pushes T.
- Every imml and imms value is assigned. The selected N-bit field begins at bit M and wraps through bit 63 to bit 0.

## State effects

- Extract the N-bit field beginning at bit M, wrapping from bit 63 to bit 0, then count every set bit in the selected field. An all-zero selected field returns zero and an all-one selected field returns N.
- Publish the complete XLEN result through the common Reg5 destination map. Relative sources are non-consuming; only a T or U destination push changes a temporary queue.
- No memory, reservation, descriptor, numeric-status, block, privilege, branch-target, or other control state changes. Successful execution advances TPC by four bytes.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot SrcL before any destination effect so a GPR alias or a T/U destination push observes the pre-instruction source value.
- Publish the result, then advance TPC by four bytes.

## Exceptions

- An unavailable selected T/U source raises Fault_IllegalInstruction before the destination effect and before TPC advances.
- BCNT raises no arithmetic, memory, alignment, permission, or control-flow exception.

## Examples

- bcnt a0, 0, 64, ->a1
- bcnt t#1, 60, 8, ->u
- bcnt zero, 0, 1, ->zero
