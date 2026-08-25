<!-- GENERATED FROM: asl/scalar/alu/SLLI.asl -->
# SLLI

**Normative ASL source:** `asl/scalar/alu/SLLI.asl`

SLLI performs an XLEN logical left shift by a six-bit immediate.

## Normative identity {#PTO-INST-SCALAR-SLLI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-slli-purpose role=purpose -->
## SLLI 的作用

`SLLI` 是一条 32 位标量 ALU 指令。它按照完整 XLEN 值移位规则对源值执行逻辑左移；当前指令契约定义结果发布路径以及任何额外状态效果。

<!-- PTO-READER-BLOCK: scalar-slli-mechanism role=mechanism -->
## 结果形成方式

执行时先对编码输入做快照，然后按照完整 XLEN 值移位规则对源值执行逻辑左移，最后才产生目标效果。

- 操作专属的宽度、有符号性和立即数规则由助记符以及下方编码字段共同确定。
- 结果发布使用当前指令契约为该助记符确定的位宽与扩展规则。

<!-- PTO-READER-BLOCK: scalar-slli-inputs role=inputs-outputs -->
## 输入与目标

- `RegDst` 是 5 位字段，选择 Reg5 结果目标，或丢弃结果。
- `SrcL` 是 5 位字段，通过 Reg5 选择标量输入。
- `shamt` 是 6 位字段，编码六位移位量。

这些角色来自当前指令契约；T/U 源只被读取和快照，不会因源选择而出队。编码零的精确含义列在下方生成的默认值章节中。

<!-- PTO-READER-BLOCK: scalar-slli-effects role=effects -->
## 效果与顺序

所有标量源都在目标效果前完成快照。完成后的值随后通过 `RegDst` 按当前标量目标映射发布。

该 ALU 操作不产生内存效果。成功完成架构效果后，`TPC` 前进 4 字节。

该操作不会产生隐藏的标量发布目标或隐式内存访问。架构变化仅限于当前契约列出的状态效果。

<!-- PTO-READER-BLOCK: scalar-slli-constraints role=constraints -->
## 合法性与故障边界

编码移位量的 6 位全部已分配，范围为 `0..63`；该移位按固定位宽获得总定义，不产生算术异常。

下方生成的合法性表是已分配字段值、保留编码和目标丢弃编码的权威说明。解码与源可用性检查先于架构效果完成。

<!-- PTO-READER-BLOCK: scalar-slli-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

以一个小型 `SLLI` 示例说明：源值 `1` 左移 `3` 位后得到 `8`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
slli SrcL, shamt, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| slli_32_b43ca2454e3a | L32 | 32 | 0x00007015 / 0xfc00707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| slli_32_b43ca2454e3a | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| slli_32_b43ca2454e3a | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| slli_32_b43ca2454e3a | shamt | 6 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":6}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| slli_32_b43ca2454e3a | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| slli_32_b43ca2454e3a | SrcL | 5 | 0–31 | none | none | Reg5 source | Encoded zero reads the architectural zero GPR. |
| slli_32_b43ca2454e3a | shamt | 6 | 0–63 | none | none | six-bit shift amount | Encoded zero performs no shift. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | Reg5 source |
| shamt | six-bit shift amount |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/SLLI.asl -->
```asl
readonly func InstructionContractOperation_SLLI()
    => ScalarOperation
begin
    return ScalarOperation_SLLI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/SLLI.asl -->
```asl
readonly func InstructionContractHandler_SLLI()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinary;
end;

pure func InstructionContractShiftWidth_SLLI()
    => integer {1..64}
begin
    return 6;
end;

pure func InstructionContractIsWordOperation_SLLI()
    => boolean
begin
    return FALSE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL, shamt, and RegDst are required fields; no field can be omitted.
- shamt is a 6-bit shift amount from 0 through 63. Encoded zero performs an identity shift.

## Legality

- SrcL codes 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consumption.
- RegDst codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write GPRs.
- Every 6-bit shift amount from 0 through 63 is legal.

## State effects

- Compute the XLEN logical left shift LSL(SrcL, shamt); discard bits shifted beyond bit PTO_XLEN-1 and insert zero bits at the right.
- Destination codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write GPRs; source queues are non-consuming.
- No memory, reservation, descriptor, flag, block, privilege, or control-flow state changes except the successful TPC advance.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot SrcL before the destination effect so aliases read the pre-instruction value.
- Publish the result, then advance TPC by four bytes.

## Exceptions

- SLLI raises no arithmetic exception; shifted-out bits are discarded and zero bits enter from the right.
- Bits 31:26 are fixed zero. A mismatch or unavailable T/U source raises Fault_IllegalInstruction before the destination effect and TPC advance.

## Examples

- slli a0, 1, ->a0
- slli t#1, 63, ->u
- slli zero, 0, ->zero
