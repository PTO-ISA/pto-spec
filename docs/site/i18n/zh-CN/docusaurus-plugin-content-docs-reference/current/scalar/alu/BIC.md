<!-- GENERATED FROM: asl/scalar/alu/BIC.asl -->
# BIC

**Normative ASL source:** `asl/scalar/alu/BIC.asl`

BIC clears every bit in an independently selected wrapping scalar field and publishes the modified XLEN value.

## Normative identity {#PTO-INST-SCALAR-BIC}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-bic-purpose role=purpose -->
## BIC 的作用

`BIC` 清掉一个 Reg5 源中所选位字段的每一位，并通过 Reg5 目标发布修改后的 XLEN 值。

设计要点：字段由两个立即数而不是掩码描述，因此该指令一步完成字段范围内的清零。调用者不需要掩码寄存器，字段之外的位也不可能被该运算扰动。

<!-- PTO-READER-BLOCK: scalar-bic-mechanism role=mechanism -->
## 结果形成方式

- `imms` 是字段起始位 `M`，取值为 `0` 至 `63`。
- `imml` 编码字段宽度 `N` 减一，因此原始取值 `0` 至 `63` 选择宽度 `1` 至 `64`。

从位 `M` 开始的 `N` 位被写成 `0`。所选字段之外的每一位都保留源中的原值。

设计要点：`imml` 存放 `N - 1`，从而让完整的寄存器宽度 `64` 能用六位表示；编码零是 `1` 位字段，而不是被省略的字段。

设计要点：字段会回绕。当 `M + N` 超过 `64` 时，字段从位 `0` 继续。其机制是把源循环移位、清零低 `N` 位、再循环移回，这也正是 `N=64` 时无论 `M` 是多少都会清掉每一位的原因。

设计要点：字段之外的位是被保留的，而不是重新推导出来的。因此一次字段清零永远不需要第二条指令去恢复未受影响的位。

<!-- PTO-READER-BLOCK: scalar-bic-inputs role=inputs-outputs -->
## 输入与目标

- `SrcL` 是 Reg5 源：`0..23` 读取绝对 GPR，`24..27` 读取 `T#1..T#4`，`28..31` 读取 `U#1..U#4`。读取临时源不会消费它。
- `imml` 和 `imms` 是描述字段的立即数字段，不读取任何存储。
- `RegDst` 发布修改后的值：`1..23` 写入该 GPR，`30` 压入 `U`，`31` 压入 `T`，`0` 与 `24..29` 一起丢弃结果。

设计要点：`SrcL` 的编码零读取架构零 GPR，因此对它做任何清零都发布 `0`。`RegDst` 的编码零丢弃结果而不是写入零 GPR，因此 `bic a0, 0, 8, ->zero` 是合法编码，但不改变任何寄存器。

<!-- PTO-READER-BLOCK: scalar-bic-effects role=effects -->
## 效果与顺序

`SrcL` 在写入目标之前读取，因此与源重名的目标仍然给出按指令执行前值计算出的清零结果。

结果发布或丢弃之后，`TPC` 前进 `4` 字节。`BIC` 不访问内存；除 `RegDst` 选中的那一次 `T` 或 `U` 压入外，它不改变保留状态、描述符、数值状态、陷阱、指令束、特权、谓词和控制流状态。

<!-- PTO-READER-BLOCK: scalar-bic-constraints role=constraints -->
## 合法性与故障边界

每个编码取值都已分配：全部 `32` 个 `SrcL` 编码、全部 `32` 个 `RegDst` 编码，以及每个 `imml` 和 `imms` 取值。

无法译码的形式在 `PC` 处引发 `Fault_IllegalInstruction`；不适用于当前指令束的指令在 `TPC` 处引发 `Fault_BundleControl`；固定编码位不匹配或所选 T/U 源不可用会引发 `Fault_IllegalInstruction`。这些都先于目标效果和 `TPC` 前进。

设计要点：清零没有异常结果，因此 `BIC` 不引发算术、内存、对齐或权限故障。清掉程序仍然需要的位属于编程错误，而不是陷阱。

<!-- PTO-READER-BLOCK: scalar-bic-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

当 `SrcL=4294967295`、`M=4`、`N=4` 时，所选字段是位 `4..7`，其值为 `240`；`bic a0, 4, 4, ->a1` 发布 `4294967295 - 240 = 4294967055`。对同样的源取 `M=60`、`N=8` 时，字段经位 `63` 回绕到位 `0`，两端都被清零。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
bic SrcL, M, N, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| bic_32_3a10830a3a93 | L32 | 32 | 0x00002067 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| bic_32_3a10830a3a93 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| bic_32_3a10830a3a93 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| bic_32_3a10830a3a93 | imml | 6 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":6}] |
| bic_32_3a10830a3a93 | imms | 6 | encoding-defined | [{"instruction_lsb":26,"value_lsb":0,"width":6}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| bic_32_3a10830a3a93 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| bic_32_3a10830a3a93 | SrcL | 5 | 0–31 | none | none | Reg5 source | Encoded zero reads the architectural zero GPR. |
| bic_32_3a10830a3a93 | imml | 6 | 0–63 | none | none | selected field width N minus one | Encoded zero selects a one-bit field. |
| bic_32_3a10830a3a93 | imms | 6 | 0–63 | none | none | selected field starting bit M | Encoded zero starts the selected field at source bit zero. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | Reg5 source |
| imml | selected field width N minus one |
| imms | selected field starting bit M |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/BIC.asl -->
```asl
readonly func InstructionContractOperation_BIC()
    => ScalarOperation
begin
    return ScalarOperation_BIC;
end;

pure func InstructionContractWidth_BIC(encoded_imml: bits(6))
    => integer {1..64}
begin
    return UInt(encoded_imml) + 1;
end;

pure func InstructionContractOffset_BIC(encoded_imms: bits(6))
    => integer {0..63}
begin
    return UInt(encoded_imms);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/BIC.asl -->
```asl
readonly func InstructionContractHandler_BIC()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ModifyBitfield;
end;

pure func InstructionContractResult_BIC(
    value: Word,
    width: integer {1..64},
    offset: integer {0..63})
    => Word
begin
    return ModifyBitfield(
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

- Extract the N-bit field beginning at bit M, wrapping from bit 63 to bit 0. Clear the N selected source bits and preserve every unselected source bit.
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
- BIC raises no arithmetic, memory, alignment, permission, or control-flow exception.

## Examples

- bic a0, 60, 8, ->a1
- bic t#1, 0, 64, ->u
