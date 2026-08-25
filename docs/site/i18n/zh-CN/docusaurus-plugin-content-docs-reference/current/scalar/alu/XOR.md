<!-- GENERATED FROM: asl/scalar/alu/XOR.asl -->
# XOR

**Normative ASL source:** `asl/scalar/alu/XOR.asl`

XOR applies the selected right-source transformation before its encoded logical left shift, performs bitwise exclusive OR, and publishes the PTO_XLEN result.

## Normative identity {#PTO-INST-SCALAR-XOR}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-xor-purpose role=purpose -->
## XOR 的作用

`XOR` 是一条 32 位标量 ALU 指令。它按照完整 XLEN 值结果规则执行按位异或；当前指令契约定义结果发布路径以及任何额外状态效果。

<!-- PTO-READER-BLOCK: scalar-xor-mechanism role=mechanism -->
## 结果形成方式

执行时先对编码输入做快照，然后按照完整 XLEN 值结果规则执行按位异或，最后才产生目标效果。

- `SrcRType` 先转换右源；`shamt` 再对转换后的值执行逻辑左移，随后才进行算术或逻辑操作。
- 结果发布使用当前指令契约为该助记符确定的位宽与扩展规则。

<!-- PTO-READER-BLOCK: scalar-xor-inputs role=inputs-outputs -->
## 输入与目标

- `RegDst` 是 5 位字段，选择 Reg5 结果目标，或丢弃结果。
- `SrcL` 是 5 位字段，通过 Reg5 选择左操作数。
- `SrcR` 是 5 位字段，通过 Reg5 选择右操作数。
- `SrcRType` 是 2 位字段，选择应用到右源的转换。
- `shamt` 是 5 位字段，编码右源转换后执行的逻辑左移量。

这些角色来自当前指令契约；T/U 源只被读取和快照，不会因源选择而出队。编码零的精确含义列在下方生成的默认值章节中。

<!-- PTO-READER-BLOCK: scalar-xor-effects role=effects -->
## 效果与顺序

所有标量源都在目标效果前完成快照。完成后的值随后通过 `RegDst` 按当前标量目标映射发布。

该 ALU 操作不产生内存效果。成功完成架构效果后，`TPC` 前进 4 字节。

该操作不会产生隐藏的标量发布目标或隐式内存访问。架构变化仅限于当前契约列出的状态效果。

<!-- PTO-READER-BLOCK: scalar-xor-constraints role=constraints -->
## 合法性与故障边界

固定宽度算术按当前操作规则回绕，不产生算术异常；固定编码位不匹配或所选 T/U 源不可用时，会在结果发布和 `TPC` 前进之前触发 `Fault_IllegalInstruction`。

下方生成的合法性表是已分配字段值、保留编码和目标丢弃编码的权威说明。解码与源可用性检查先于架构效果完成。

<!-- PTO-READER-BLOCK: scalar-xor-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

以一个小型 `XOR` 示例说明：`SrcL=0xc`、`SrcR=0xa`、`SrcRType=11` 且 `shamt=0` 产生 `0x6`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
xor SrcL, SrcR<{.sw,.uw,.not}><<<shamt>, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| xor_32_33510860c585 | L32 | 32 | 0x00004005 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| xor_32_33510860c585 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| xor_32_33510860c585 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| xor_32_33510860c585 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| xor_32_33510860c585 | SrcRType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |
| xor_32_33510860c585 | shamt | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| xor_32_33510860c585 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| xor_32_33510860c585 | SrcL | 5 | 0–31 | none | none | left Reg5 source | Encoded zero reads the architectural zero GPR. |
| xor_32_33510860c585 | SrcR | 5 | 0–31 | none | none | right Reg5 source | Encoded zero reads the architectural zero GPR. |
| xor_32_33510860c585 | SrcRType | 2 | 0–3 | none | none | right-source transformation selector | Encoded zero selects .sw and sign-extends SrcR[31:0]. |
| xor_32_33510860c585 | shamt | 5 | 0–31 | none | none | post-transformation logical-left-shift amount | Encoded zero performs no shift. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | left Reg5 source |
| SrcR | right Reg5 source |
| SrcRType | right-source transformation selector |
| shamt | post-transformation logical-left-shift amount |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/XOR.asl -->
```asl
readonly func InstructionContractOperation_XOR()
    => ScalarOperation
begin
    return ScalarOperation_XOR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/XOR.asl -->
```asl
readonly func InstructionContractHandler_XOR()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinary;
end;

pure func InstructionContractRightModifier_XOR(encoded: bits(2))
    => ScalarRightModifier
begin
    case encoded of
        when '00' => return ScalarRight_SignedWord;
        when '01' => return ScalarRight_UnsignedWord;
        when '10' => return ScalarRight_NegateOrNot;
        when '11' => return ScalarRight_None;
    end;
end;

pure func InstructionContractPreparedRight_XOR(
    right: Word,
    encoded_modifier: bits(2),
    shift_amount: integer {0..31})
    => Word
begin
    let modifier = InstructionContractRightModifier_XOR(encoded_modifier);
    let transformed = ApplyScalarRightModifier(right, modifier, TRUE);
    let shifted = LSL(transformed, shift_amount);
    return shifted;
end;

pure func InstructionContractResult_XOR(
    left: Word,
    right: Word,
    encoded_modifier: bits(2),
    shift_amount: integer {0..31})
    => Word
begin
    let prepared_right = InstructionContractPreparedRight_XOR(
        right,
        encoded_modifier,
        shift_amount);
    return ScalarBinary(ScalarBinary_XOR, left, prepared_right);
end;

pure func InstructionContractIsLogicalFamily_XOR()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractIsWordOperation_XOR()
    => boolean
begin
    return FALSE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL, SrcR, SrcRType, shamt, and RegDst are required encoded fields; no field can be omitted.
- SrcRType=00 selects .sw, SrcRType=01 selects .uw, SrcRType=10 selects .not, and SrcRType=11 selects no modifier. An omitted assembly suffix encodes SrcRType=11.
- Encoded shamt zero performs no shift; every value from 0 through 31 is assigned.

## Legality

- SrcL and SrcR codes 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consumption.
- RegDst codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write GPRs.
- All four SrcRType encodings are assigned. The logical family uses .not while the arithmetic family uses .neg; XOR uses .not.
- Every five-bit shamt value from 0 through 31 is legal.

## State effects

- Transform SrcR, perform the logical left shift, and compute the bitwise exclusive OR with SrcL at PTO_XLEN width modulo 2^PTO_XLEN.
- Apply the selected SrcRType transformation before the logical left shift. The transformation and shift affect SrcR only; SrcL is unchanged before the final operation.
- Destination codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write GPRs; source queues are non-consuming.
- No memory, reservation, descriptor, numeric-flag, trap, block, privilege, or control-flow state changes except the successful TPC advance.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot both sources before the destination effect so duplicate sources, destination aliases, and queue publication use pre-instruction values.
- Publish the result, then advance TPC by four bytes.

## Exceptions

- XOR raises no arithmetic exception; transformation, shifting, and the final operation use PTO_XLEN bits modulo 2^PTO_XLEN.
- A fixed-bit mismatch or unavailable selected T/U source raises Fault_IllegalInstruction before the destination effect and before TPC advances.

## Examples

- xor a0, a1, ->a2
- xor t#1, u#1.not<<1, ->u
- xor zero, a0.sw, ->zero
