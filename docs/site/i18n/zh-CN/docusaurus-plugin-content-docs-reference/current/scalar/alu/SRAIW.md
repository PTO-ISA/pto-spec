<!-- GENERATED FROM: asl/scalar/alu/SRAIW.asl -->
# SRAIW

**Normative ASL source:** `asl/scalar/alu/SRAIW.asl`

SRAIW performs a word arithmetic right shift and sign-extends the result.

## Normative identity {#PTO-INST-SCALAR-SRAIW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-sraiw-purpose role=purpose -->
## SRAIW 的作用

`SRAIW` 是一条 32 位标量 ALU 指令。它按照低 32 位字，再符号扩展到 XLEN移位规则对源值执行算术右移；当前指令契约定义结果发布路径以及任何额外状态效果。

<!-- PTO-READER-BLOCK: scalar-sraiw-mechanism role=mechanism -->
## 结果形成方式

执行时先对编码输入做快照，然后按照低 32 位字，再符号扩展到 XLEN移位规则对源值执行算术右移，最后才产生目标效果。

- 操作专属的宽度、有符号性和立即数规则由助记符以及下方编码字段共同确定。
- 结果发布使用当前指令契约为该助记符确定的位宽与扩展规则。

<!-- PTO-READER-BLOCK: scalar-sraiw-inputs role=inputs-outputs -->
## 输入与目标

- `RegDst` 是 5 位字段，选择 Reg5 结果目标，或丢弃结果。
- `SrcL` 是 5 位字段，通过 Reg5 选择标量输入，其中使用低 32 位。
- `shamt` 是 5 位字段，编码五位移位量。

这些角色来自当前指令契约；T/U 源只被读取和快照，不会因源选择而出队。编码零的精确含义列在下方生成的默认值章节中。

<!-- PTO-READER-BLOCK: scalar-sraiw-effects role=effects -->
## 效果与顺序

所有标量源都在目标效果前完成快照。完成后的值随后通过 `RegDst` 按当前标量目标映射发布。

该 ALU 操作不产生内存效果。成功完成架构效果后，`TPC` 前进 4 字节。

该操作不会产生隐藏的标量发布目标或隐式内存访问。架构变化仅限于当前契约列出的状态效果。

<!-- PTO-READER-BLOCK: scalar-sraiw-constraints role=constraints -->
## 合法性与故障边界

编码移位量的 5 位全部已分配，范围为 `0..31`；该移位按固定位宽获得总定义，不产生算术异常。

下方生成的合法性表是已分配字段值、保留编码和目标丢弃编码的权威说明。解码与源可用性检查先于架构效果完成。

<!-- PTO-READER-BLOCK: scalar-sraiw-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

以一个小型 `SRAIW` 示例说明：源值 `-8` 算术右移 `2` 位后得到 `-2`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
sraiw SrcL, shamt, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| sraiw_32_db04a6299504 | L32 | 32 | 0x00006035 / 0xfe00707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| sraiw_32_db04a6299504 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| sraiw_32_db04a6299504 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| sraiw_32_db04a6299504 | shamt | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| sraiw_32_db04a6299504 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| sraiw_32_db04a6299504 | SrcL | 5 | 0–31 | none | none | Reg5 source; low 32 bits used | Encoded zero reads the architectural zero GPR. |
| sraiw_32_db04a6299504 | shamt | 5 | 0–31 | none | none | five-bit shift amount | Encoded zero performs no shift. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | Reg5 source; low 32 bits used |
| shamt | five-bit shift amount |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/SRAIW.asl -->
```asl
readonly func InstructionContractOperation_SRAIW()
    => ScalarOperation
begin
    return ScalarOperation_SRAIW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/SRAIW.asl -->
```asl
readonly func InstructionContractHandler_SRAIW()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinaryW;
end;

pure func InstructionContractShiftWidth_SRAIW()
    => integer {1..64}
begin
    return 5;
end;

pure func InstructionContractIsWordOperation_SRAIW()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL, shamt, and RegDst are required fields; no field can be omitted.
- shamt is a 5-bit shift amount from 0 through 31. Encoded zero performs an identity word shift.

## Legality

- SrcL codes 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consumption.
- RegDst codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write GPRs.
- Every 5-bit shift amount from 0 through 31 is legal; source bits above bit 31 do not participate.

## State effects

- Compute the 32-bit arithmetic right shift ASR(SrcL[31:0], shamt), then publish the 32-bit result sign-extended to XLEN.
- Destination codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write GPRs; source queues are non-consuming.
- No memory, reservation, descriptor, flag, block, privilege, or control-flow state changes except the successful TPC advance.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot SrcL before the destination effect so aliases read the pre-instruction value.
- Publish the sign-extended word result, then advance TPC by four bytes.

## Exceptions

- SRAIW raises no arithmetic exception; copies of SrcL[31] enter from the left and the final word is sign-extended to XLEN.
- Bits 31:25 are fixed zero. A mismatch or unavailable T/U source raises Fault_IllegalInstruction before the destination effect and TPC advance.

## Examples

- sraiw a0, 1, ->a0
- sraiw u#1, 31, ->t
- sraiw zero, 0, ->zero
