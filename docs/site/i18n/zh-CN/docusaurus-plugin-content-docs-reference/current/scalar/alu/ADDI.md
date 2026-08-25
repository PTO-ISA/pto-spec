<!-- GENERATED FROM: asl/scalar/alu/ADDI.asl -->
# ADDI

**Normative ASL source:** `asl/scalar/alu/ADDI.asl`

ADDI performs unsigned-immediate XLEN addition with Reg5 source and destination selection.

## Normative identity {#PTO-INST-SCALAR-ADDI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-addi-purpose role=purpose -->
## ADDI 的作用

`ADDI` 是一条 32 位标量 ALU 指令。它按照完整 XLEN 值结果规则执行加法；当前指令契约定义结果发布路径以及任何额外状态效果。

<!-- PTO-READER-BLOCK: scalar-addi-mechanism role=mechanism -->
## 结果形成方式

执行时先对编码输入做快照，然后按照完整 XLEN 值结果规则执行加法，最后才产生目标效果。

- 立即数宽度与扩展规则由下方编码字段确定；除非生成契约给出其他零值含义，编码零提供数值零。
- 结果发布使用当前指令契约为该助记符确定的位宽与扩展规则。

<!-- PTO-READER-BLOCK: scalar-addi-inputs role=inputs-outputs -->
## 输入与目标

- `RegDst` 是 5 位字段，选择 Reg5 标量结果目标，或丢弃结果。
- `SrcL` 是 5 位字段，通过 Reg5 选择标量值。
- `uimm12` 是 12 位无符号字段，携带无符号 12 位立即数。

这些角色来自当前指令契约；T/U 源只被读取和快照，不会因源选择而出队。编码零的精确含义列在下方生成的默认值章节中。

<!-- PTO-READER-BLOCK: scalar-addi-effects role=effects -->
## 效果与顺序

所有标量源都在目标效果前完成快照。完成后的值随后通过 `RegDst` 按当前标量目标映射发布。

该 ALU 操作不产生内存效果。成功完成架构效果后，`TPC` 前进 4 字节。

该操作不会产生隐藏的标量发布目标或隐式内存访问。架构变化仅限于当前契约列出的状态效果。

<!-- PTO-READER-BLOCK: scalar-addi-constraints role=constraints -->
## 合法性与故障边界

固定宽度算术按当前操作规则回绕，不产生算术异常；固定编码位不匹配或所选 T/U 源不可用时，会在结果发布和 `TPC` 前进之前触发 `Fault_IllegalInstruction`。

下方生成的合法性表是已分配字段值、保留编码和目标丢弃编码的权威说明。解码与源可用性检查先于架构效果完成。

<!-- PTO-READER-BLOCK: scalar-addi-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

以一个小型 `ADDI` 示例说明：`SrcL=7` 与 `uimm12=3` 产生 `10`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
addi SrcL, uimm, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| addi_32_2decd0a93a0a | L32 | 32 | 0x00000015 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| addi_32_2decd0a93a0a | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| addi_32_2decd0a93a0a | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| addi_32_2decd0a93a0a | uimm12 | 12 | unsigned | [{"instruction_lsb":20,"value_lsb":0,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| addi_32_2decd0a93a0a | RegDst | 5 | 0–31 | none | none | Reg5 scalar destination or discard selector | Encoded zero discards the result and does not modify any GPR or queue. |
| addi_32_2decd0a93a0a | SrcL | 5 | 0–31 | none | none | Reg5 scalar source | Encoded zero reads the architectural zero GPR. |
| addi_32_2decd0a93a0a | uimm12 | 12 | 0–4095 | none | none | unsigned 12-bit immediate | Encoded zero supplies numeric zero. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 scalar destination or discard selector |
| SrcL | Reg5 scalar source |
| uimm12 | unsigned 12-bit immediate |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/ADDI.asl -->
```asl
readonly func InstructionContractOperation_ADDI()
    => ScalarOperation
begin
    return ScalarOperation_ADDI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/ADDI.asl -->
```asl
readonly func InstructionContractHandler_ADDI()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinary;
end;

pure func InstructionContractImmediateWidth_ADDI()
    => integer {1..64}
begin
    return 12;
end;

pure func InstructionContractImmediateIsUnsigned_ADDI()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractIsWordOperation_ADDI()
    => boolean
begin
    return FALSE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL, uimm12, and RegDst are required encoded fields; no field can be omitted.
- uimm12 is an unsigned 12-bit immediate from 0 through 4095. Encoded zero supplies numeric zero.

## Legality

- All 32 SrcL encodings are assigned: 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4.
- All 32 RegDst encodings are assigned: codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write absolute GPRs.
- Every unsigned 12-bit immediate from 0 through 4095 is legal.

## State effects

- Zero-extend uimm12, add it to the snapshotted SrcL value modulo 2^PTO_XLEN, and publish the XLEN result through RegDst.
- Codes 1..23 write a GPR; codes 0 and 24..29 discard; code 30 pushes U; code 31 pushes T. Source queue selections are non-consuming.
- No memory, reservation, descriptor, block, privilege, or control-flow state changes other than TPC advancing by four bytes after success.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot SrcL before the destination effect. Repeated source and destination selectors therefore read the pre-instruction value.
- Successful execution publishes the result and then advances TPC by four bytes.

## Exceptions

- ADDI raises no arithmetic exception: addition wraps modulo 2^PTO_XLEN.
- A fixed-bit mismatch or unavailable selected T/U source raises Fault_IllegalInstruction before the destination effect and before TPC advances.

## Examples

- addi a0, 1, ->a0
- addi t#1, 4095, ->u
- addi zero, 0, ->zero
