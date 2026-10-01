<!-- GENERATED FROM: asl/scalar/alu/BXU.asl -->
# BXU

**Normative ASL source:** `asl/scalar/alu/BXU.asl`

BXU extracts an independently selected wrapping scalar field, zero-extends it to XLEN, and publishes the result.

## Normative identity {#PTO-INST-SCALAR-BXU}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-bxu-purpose role=purpose -->
## BXU 的作用

`BXU` 从一个 Reg5 源中提取位字段，把它上面的每一位填零，并通过 Reg5 目标发布 XLEN 结果。

设计要点：`BXU` 与 `BXS` 的字段语法和字段选择完全相同，只有字段之上各位的填充方式不同。程序依据要对提取值做什么来选择两者，而不是依据想怎样切片。

<!-- PTO-READER-BLOCK: scalar-bxu-mechanism role=mechanism -->
## 结果形成方式

- `imms` 是字段起始位 `M`，取值为 `0` 至 `63`。
- `imml` 编码字段宽度 `N` 减一，因此原始取值 `0` 至 `63` 选择宽度 `1` 至 `64`。

从位 `M` 开始的 `N` 位成为结果的 `0` 至 `N-1` 位，从 `N` 往上的每一位都是 `0`。

设计要点：字段会回绕，因此 `M + N` 可能超过 `64`，字段从位 `0` 继续；实现方式是把源循环右移 `M` 位并读取低 `N` 位。因此对任何 `M`，`N=64` 都选取整个寄存器，而 `bxu a0, 60, 8, ->a1` 先读位 `60..63`，再读位 `0..3`。

设计要点：填零使发布值成为纯无符号字段。它不可能超过 `2^N - 1`，因此需要从打包字中取出无符号小整数的调用者不需要第二条掩码指令。

<!-- PTO-READER-BLOCK: scalar-bxu-inputs role=inputs-outputs -->
## 输入与目标

- `SrcL` 是 Reg5 源：`0..23` 读取绝对 GPR，`24..27` 读取 `T#1..T#4`，`28..31` 读取 `U#1..U#4`。读取临时源不会消费它。
- `imml` 和 `imms` 描述字段，不读取任何存储。
- `RegDst` 发布提取结果：`1..23` 写入该 GPR，`30` 压入 `U`，`31` 压入 `T`，`0` 与 `24..29` 一起丢弃结果。

设计要点：`SrcL` 的编码零读取架构零 GPR，它的任何字段都提取为 `0`。`RegDst` 的编码零丢弃提取值而不是把它写入零 GPR，因此丢弃是真实的选择，而不是静默存储。

<!-- PTO-READER-BLOCK: scalar-bxu-effects role=effects -->
## 效果与顺序

`SrcL` 在写入目标之前读取，因此与源重名的目标不会扰动被提取的位。

结果发布或丢弃之后，`TPC` 前进 `4` 字节。`BXU` 不访问内存；除 `RegDst` 选中的那一次 `T` 或 `U` 压入外，它不改变保留状态、描述符、数值状态、陷阱、指令束、特权、谓词和控制流状态。

<!-- PTO-READER-BLOCK: scalar-bxu-constraints role=constraints -->
## 合法性与故障边界

每个编码取值都已分配：全部 `32` 个 `SrcL` 编码、全部 `32` 个 `RegDst` 编码，以及每个 `imml` 和 `imms` 取值。

无法译码的形式在 `PC` 处引发 `Fault_IllegalInstruction`；不适用于当前指令束的指令在 `TPC` 处引发 `Fault_BundleControl`；固定编码位不匹配或所选 T/U 源不可用会引发 `Fault_IllegalInstruction`。这些都先于目标效果和 `TPC` 前进。

设计要点：对任何源取值，提取和填零都是全域定义的，因此 `BXU` 没有依赖取值的故障。跨越打包边界的字段仍然只是一个位范围；架构不对它做任何解释。

<!-- PTO-READER-BLOCK: scalar-bxu-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

当 `SrcL=18446744073709551615`、`M=0`、`N=8` 时，`bxu a0, 0, 8, ->a1` 发布 `255`。当 `SrcL=8`、`M=60`、`N=8` 时，字段是位 `60..63` 再接位 `0..3`，其值为 `128`，因此发布值为 `128`；而同样的操作数在 `BXS` 下发布 `18446744073709551488`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
bxu SrcL, M, N, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| bxu_32_e9ea9715ba62 | L32 | 32 | 0x00001067 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| bxu_32_e9ea9715ba62 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| bxu_32_e9ea9715ba62 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| bxu_32_e9ea9715ba62 | imml | 6 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":6}] |
| bxu_32_e9ea9715ba62 | imms | 6 | encoding-defined | [{"instruction_lsb":26,"value_lsb":0,"width":6}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| bxu_32_e9ea9715ba62 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| bxu_32_e9ea9715ba62 | SrcL | 5 | 0–31 | none | none | Reg5 source | Encoded zero reads the architectural zero GPR. |
| bxu_32_e9ea9715ba62 | imml | 6 | 0–63 | none | none | selected field width N minus one | Encoded zero selects a one-bit field. |
| bxu_32_e9ea9715ba62 | imms | 6 | 0–63 | none | none | selected field starting bit M | Encoded zero starts the selected field at source bit zero. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | Reg5 source |
| imml | selected field width N minus one |
| imms | selected field starting bit M |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/BXU.asl -->
```asl
readonly func InstructionContractOperation_BXU()
    => ScalarOperation
begin
    return ScalarOperation_BXU;
end;

pure func InstructionContractWidth_BXU(encoded_imml: bits(6))
    => integer {1..64}
begin
    return UInt(encoded_imml) + 1;
end;

pure func InstructionContractOffset_BXU(encoded_imms: bits(6))
    => integer {0..63}
begin
    return UInt(encoded_imms);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/BXU.asl -->
```asl
readonly func InstructionContractHandler_BXU()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExtractBitfield;
end;

pure func InstructionContractResult_BXU(
    value: Word,
    width: integer {1..64},
    offset: integer {0..63})
    => Word
begin
    return ExtractBitfield(
        value,
        width,
        offset,
        FALSE);
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

- Extract the N-bit field beginning at bit M, wrapping from bit 63 to bit 0. Zero-fill every result bit above selected field bit N-1.
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
- BXU raises no arithmetic, memory, alignment, permission, or control-flow exception.

## Examples

- bxu a0, 60, 8, ->a1
- bxu t#1, 0, 64, ->u
