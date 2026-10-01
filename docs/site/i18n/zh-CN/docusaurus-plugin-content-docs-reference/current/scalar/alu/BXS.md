<!-- GENERATED FROM: asl/scalar/alu/BXS.asl -->
# BXS

**Normative ASL source:** `asl/scalar/alu/BXS.asl`

BXS extracts an independently selected wrapping scalar field, sign-extends it to XLEN, and publishes the result.

## Normative identity {#PTO-INST-SCALAR-BXS}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-bxs-purpose role=purpose -->
## BXS 的作用

`BXS` 从一个 Reg5 源中提取位字段，从该字段自身的最高位做符号扩展，并通过 Reg5 目标发布 XLEN 结果。

设计要点：字段由两个立即数描述，因此提取范围由指令文本固定。不需要掩码寄存器，源也不会被修改。

<!-- PTO-READER-BLOCK: scalar-bxs-mechanism role=mechanism -->
## 结果形成方式

- `imms` 是字段起始位 `M`，取值为 `0` 至 `63`。
- `imml` 编码字段宽度 `N` 减一，因此原始取值 `0` 至 `63` 选择宽度 `1` 至 `64`。

从位 `M` 开始的 `N` 位成为结果的 `0` 至 `N-1` 位，随后结果位 `N-1` 被复制到它上面的每一位。

设计要点：符号位是所选字段的最后一位，而不是寄存器位 `63`。当 `M=60`、`N=8` 时字段经位 `63` 回绕到位 `0`，因此决定扩展的符号是寄存器位 `3` 的取值。

设计要点：`imml` 存放 `N - 1`，从而让 `N=64` 可以表示。当 `N=64` 时，对任何 `M` 字段都是整个寄存器，而从位 `63` 做符号扩展是恒等操作，因此 `bxs a0, 0, 64, ->a1` 复制 `a0`。

设计要点：扩展用字段的符号填充 `N` 至 `63` 位。需要不带符号的原始字段值的调用者必须使用 `BXU`，两者的唯一区别就是这段填充。

<!-- PTO-READER-BLOCK: scalar-bxs-inputs role=inputs-outputs -->
## 输入与目标

- `SrcL` 是 Reg5 源：`0..23` 读取绝对 GPR，`24..27` 读取 `T#1..T#4`，`28..31` 读取 `U#1..U#4`。读取临时源不会消费它。
- `imml` 和 `imms` 描述字段，不读取任何存储。
- `RegDst` 发布提取结果：`1..23` 写入该 GPR，`30` 压入 `U`，`31` 压入 `T`，`0` 与 `24..29` 一起丢弃结果。

设计要点：`SrcL` 的编码零读取架构零 GPR，它的任何字段都提取为零结果且符号位为零。`imml` 的编码零选择 `1` 位字段，其符号位就是那一位，因此取值为 `1` 的 `1` 位字段会符号扩展为全一。

<!-- PTO-READER-BLOCK: scalar-bxs-effects role=effects -->
## 效果与顺序

`SrcL` 在写入目标之前读取，因此与源重名的目标不影响被提取的位。

结果发布或丢弃之后，`TPC` 前进 `4` 字节。`BXS` 不访问内存；除 `RegDst` 选中的那一次 `T` 或 `U` 压入外，它不改变保留状态、描述符、数值状态、陷阱、指令束、特权、谓词和控制流状态。

<!-- PTO-READER-BLOCK: scalar-bxs-constraints role=constraints -->
## 合法性与故障边界

每个编码取值都已分配：全部 `32` 个 `SrcL` 编码、全部 `32` 个 `RegDst` 编码，以及每个 `imml` 和 `imms` 取值。

无法译码的形式在 `PC` 处引发 `Fault_IllegalInstruction`；不适用于当前指令束的指令在 `TPC` 处引发 `Fault_BundleControl`；固定编码位不匹配或所选 T/U 源不可用会引发 `Fault_IllegalInstruction`。这些都先于目标效果和 `TPC` 前进。

设计要点：对任何源取值，提取都不会触发故障；不存在非法的字段位模式。`BXS` 也不通过数值状态报告任何内容，因为提取出的符号是结果位，而不是条件。

<!-- PTO-READER-BLOCK: scalar-bxs-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

当 `SrcL=8`、`M=60`、`N=8` 时，字段是位 `60..63` 再接位 `0..3`。其值为 `128`，符号位是已被置起的寄存器位 `3`，因此 `bxs a0, 60, 8, ->a1` 发布 `18446744073709551488`。当 `SrcL=4294967295`、`M=0`、`N=64` 时，发布值仍为 `4294967295`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
bxs SrcL, M, N, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| bxs_32_b1bb003c1703 | L32 | 32 | 0x00000067 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| bxs_32_b1bb003c1703 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| bxs_32_b1bb003c1703 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| bxs_32_b1bb003c1703 | imml | 6 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":6}] |
| bxs_32_b1bb003c1703 | imms | 6 | encoding-defined | [{"instruction_lsb":26,"value_lsb":0,"width":6}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| bxs_32_b1bb003c1703 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| bxs_32_b1bb003c1703 | SrcL | 5 | 0–31 | none | none | Reg5 source | Encoded zero reads the architectural zero GPR. |
| bxs_32_b1bb003c1703 | imml | 6 | 0–63 | none | none | selected field width N minus one | Encoded zero selects a one-bit field. |
| bxs_32_b1bb003c1703 | imms | 6 | 0–63 | none | none | selected field starting bit M | Encoded zero starts the selected field at source bit zero. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | Reg5 source |
| imml | selected field width N minus one |
| imms | selected field starting bit M |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/BXS.asl -->
```asl
readonly func InstructionContractOperation_BXS()
    => ScalarOperation
begin
    return ScalarOperation_BXS;
end;

pure func InstructionContractWidth_BXS(encoded_imml: bits(6))
    => integer {1..64}
begin
    return UInt(encoded_imml) + 1;
end;

pure func InstructionContractOffset_BXS(encoded_imms: bits(6))
    => integer {0..63}
begin
    return UInt(encoded_imms);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/BXS.asl -->
```asl
readonly func InstructionContractHandler_BXS()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExtractBitfield;
end;

pure func InstructionContractResult_BXS(
    value: Word,
    width: integer {1..64},
    offset: integer {0..63})
    => Word
begin
    return ExtractBitfield(
        value,
        width,
        offset,
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

- Extract the N-bit field beginning at bit M, wrapping from bit 63 to bit 0. Sign-extend selected field bit N-1 through result bit PTO_XLEN-1.
- Publish the complete XLEN result through the common Reg5 destination map. Relative sources are non-consuming; only a T or U destination push changes a temporary queue.
- No memory, reservation, descriptor, numeric-status, block, privilege, branch-target, or other control state changes. Successful execution advances TPC by four bytes.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot SrcL before any destination effect so a GPR alias or T/U destination push observes the pre-instruction value.
- Publish the result, then advance TPC by four bytes.

## Exceptions

- An unavailable selected T/U source raises Fault_IllegalInstruction before the destination effect and before TPC advances.
- BXS raises no arithmetic, memory, alignment, permission, or control-flow exception.

## Examples

- bxs a0, 60, 8, ->a1
- bxs t#1, 0, 64, ->u
