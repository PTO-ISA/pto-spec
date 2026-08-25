<!-- GENERATED FROM: asl/scalar/alu/ANDI.asl -->
# ANDI

**Normative ASL source:** `asl/scalar/alu/ANDI.asl`

ANDI performs XLEN conjunction with a sign-extended signed 12-bit immediate.

## Normative identity {#PTO-INST-SCALAR-ANDI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-andi-purpose role=purpose -->
## ANDI 的作用

`ANDI` 是一条 32 位标量 ALU 指令。它按照完整 XLEN 值结果规则执行按位与；当前指令契约定义结果发布路径以及任何额外状态效果。

<!-- PTO-READER-BLOCK: scalar-andi-mechanism role=mechanism -->
## 结果形成方式

执行时先对编码输入做快照，然后按照完整 XLEN 值结果规则执行按位与，最后才产生目标效果。

- 立即数宽度与扩展规则由下方编码字段确定；除非生成契约给出其他零值含义，编码零提供数值零。
- 结果发布使用当前指令契约为该助记符确定的位宽与扩展规则。

<!-- PTO-READER-BLOCK: scalar-andi-inputs role=inputs-outputs -->
## 输入与目标

- `RegDst` 是 5 位字段，选择 Reg5 标量结果目标，或丢弃结果。
- `SrcL` 是 5 位字段，通过 Reg5 选择标量值。
- `simm12` 是 12 位有符号字段，携带有符号 12 位立即数。

这些角色来自当前指令契约；T/U 源只被读取和快照，不会因源选择而出队。编码零的精确含义列在下方生成的默认值章节中。

<!-- PTO-READER-BLOCK: scalar-andi-effects role=effects -->
## 效果与顺序

所有标量源都在目标效果前完成快照。完成后的值随后通过 `RegDst` 按当前标量目标映射发布。

该 ALU 操作不产生内存效果。成功完成架构效果后，`TPC` 前进 4 字节。

该操作不会产生隐藏的标量发布目标或隐式内存访问。架构变化仅限于当前契约列出的状态效果。

<!-- PTO-READER-BLOCK: scalar-andi-constraints role=constraints -->
## 合法性与故障边界

固定宽度算术按当前操作规则回绕，不产生算术异常；固定编码位不匹配或所选 T/U 源不可用时，会在结果发布和 `TPC` 前进之前触发 `Fault_IllegalInstruction`。

下方生成的合法性表是已分配字段值、保留编码和目标丢弃编码的权威说明。解码与源可用性检查先于架构效果完成。

<!-- PTO-READER-BLOCK: scalar-andi-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

以一个小型 `ANDI` 示例说明：`SrcL=0xc` 与 `simm12=0xa` 产生 `0x8`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
andi SrcL, simm, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| andi_32_1d9302e57d30 | L32 | 32 | 0x00002015 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| andi_32_1d9302e57d30 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| andi_32_1d9302e57d30 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| andi_32_1d9302e57d30 | simm12 | 12 | signed | [{"instruction_lsb":20,"value_lsb":0,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| andi_32_1d9302e57d30 | RegDst | 5 | 0–31 | none | none | Reg5 scalar destination or discard selector | Encoded zero discards the result and does not modify any GPR or queue. |
| andi_32_1d9302e57d30 | SrcL | 5 | 0–31 | none | none | Reg5 scalar source | Encoded zero reads the architectural zero GPR. |
| andi_32_1d9302e57d30 | simm12 | 12 | 0–4095 | none | none | signed 12-bit immediate | Encoded zero supplies numeric zero. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 scalar destination or discard selector |
| SrcL | Reg5 scalar source |
| simm12 | signed 12-bit immediate |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/ANDI.asl -->
```asl
readonly func InstructionContractOperation_ANDI()
    => ScalarOperation
begin
    return ScalarOperation_ANDI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/ANDI.asl -->
```asl
readonly func InstructionContractHandler_ANDI()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinary;
end;

pure func InstructionContractImmediateWidth_ANDI()
    => integer {1..64}
begin
    return 12;
end;

pure func InstructionContractImmediateIsSigned_ANDI()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractIsWordOperation_ANDI()
    => boolean
begin
    return FALSE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL, simm12, and RegDst are required encoded fields; no field can be omitted.
- simm12 is a signed 12-bit immediate from -2048 through 2047. Encoded zero supplies numeric zero.

## Legality

- All 32 SrcL encodings are assigned: 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consuming a queue entry.
- All 32 RegDst encodings are assigned: codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write absolute GPRs.
- Every signed 12-bit immediate from -2048 through 2047 is legal and is sign-extended to PTO_XLEN before the conjunction.

## State effects

- Sign-extend simm12 to PTO_XLEN, compute the bitwise conjunction with the snapshotted SrcL value, and publish the complete XLEN result through RegDst.
- Codes 1..23 write a GPR; codes 0 and 24..29 discard; code 30 pushes U; code 31 pushes T. Source queue selections are non-consuming.
- No memory, reservation, descriptor, block, privilege, numeric-flag, or control-flow state changes other than TPC advancing by four bytes after success.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot SrcL before the destination effect. Repeated source and destination selectors therefore read the pre-instruction value.
- Successful execution publishes the result and then advances TPC by four bytes.

## Exceptions

- ANDI raises no arithmetic exception; bitwise conjunction is defined for every source and simm12 bit pattern.
- A fixed-bit mismatch or unavailable selected T/U source raises Fault_IllegalInstruction before the destination effect and before TPC advances.

## Examples

- andi a0, -1, ->a0
- andi t#1, 2047, ->u
- andi zero, -2048, ->zero
