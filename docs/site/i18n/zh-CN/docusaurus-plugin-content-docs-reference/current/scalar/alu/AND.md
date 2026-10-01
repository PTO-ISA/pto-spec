<!-- GENERATED FROM: asl/scalar/alu/AND.asl -->
# AND

**Normative ASL source:** `asl/scalar/alu/AND.asl`

AND applies the selected right-source transformation before its encoded logical left shift, performs bitwise conjunction, and publishes the PTO_XLEN result.

## Normative identity {#PTO-INST-SCALAR-AND}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-and-purpose role=purpose -->
## AND 的作用

`AND` 先准备右源，再在全部 `PTO_XLEN` 位上计算该值与不变的左源逐位相与，然后通过 Reg5 目标发布结果。

设计要点：`AND` 复用 `ADD` 的字段布局，因此这里同样有 `SrcRType=10`。共享的修饰符辅助函数以逻辑族标志被调用，而该标志改变了这一个编码的含义：在 `AND` 中它是按位取反，在 `ADD` 中它是取负。因此同一个编码在这里产生掩码，在那里产生减法。

<!-- PTO-READER-BLOCK: scalar-and-mechanism role=mechanism -->
## 结果形成方式

右源分两步准备，然后取合取。

- `SrcRType` 变换 `SrcR`：`00` 对 `SrcR[31:0]` 做符号扩展，`01` 对 `SrcR[31:0]` 做零扩展，`10` 对每一位取反，`11` 保持该值不变。汇编中省略后缀即编码 `SrcRType=11`。
- `shamt` 随后把变换后的值逻辑左移 `0` 至 `31` 位；移出位 `63` 的位被丢弃，空出的低位为零。

结果为 `SrcL AND prepared-right`，按 `64` 个位位置独立计算。

设计要点：在相与之前对右源移位会移动掩码。`and a0, a1<<4, ->a2` 完全忽略 `a0` 的低 `4` 位，因为对应的掩码位为零。

设计要点：取反与移位在一个编码中组合。`and a0, a1.not<<3, ->a2` 先清掉 `a0` 的低 `3` 位，再只保留 `a1` 原本为零的那些位置。

<!-- PTO-READER-BLOCK: scalar-and-inputs role=inputs-outputs -->
## 输入与目标

- `SrcL` 和 `SrcR` 是 Reg5 源：`0..23` 读取绝对 GPR，`24..27` 读取 `T#1..T#4`，`28..31` 读取 `U#1..U#4`。读取临时源不会消费它。
- `RegDst` 发布结果：`1..23` 写入该 GPR，`30` 压入 `U`，`31` 压入 `T`，`0` 与 `24..29` 一起丢弃结果。

设计要点：`SrcL` 或 `SrcR` 的编码零读取架构零 GPR，因此 `and a0, zero, ->a1` 是物化常数零而不是无操作，而 `and a0, a0, ->a1` 是一次拷贝。`AND` 的任何字段都不能省略。

<!-- PTO-READER-BLOCK: scalar-and-effects role=effects -->
## 效果与顺序

两个源都在写入目标之前读取，因此 `and a0, a0, ->a0` 以及任何目标重名都使用指令执行前的值。

结果发布或丢弃之后，`TPC` 前进 `4` 字节。`AND` 不访问内存；除 `RegDst` 选中的那一次 `T` 或 `U` 压入外，它不改变保留状态、描述符、数值状态、陷阱、指令束、特权、谓词和控制流状态。

<!-- PTO-READER-BLOCK: scalar-and-constraints role=constraints -->
## 合法性与故障边界

每个编码取值都已分配：四个 `SrcRType` 编码以及 `0` 至 `31` 的全部 `32` 个 `shamt` 取值。既没有保留修饰符，也没有保留移位量。

无法译码的形式在 `PC` 处引发 `Fault_IllegalInstruction`；不适用于当前指令束的指令在 `TPC` 处引发 `Fault_BundleControl`；固定编码位不匹配或所选 T/U 源不可用会引发 `Fault_IllegalInstruction`。这些都先于目标效果和 `TPC` 前进。

设计要点：按位运算不产生任何信号，因此除上述检查外 `AND` 没有故障。取反或移出的位只是不出现在结果中；没有任何状态标志记录它们。

<!-- PTO-READER-BLOCK: scalar-and-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

当 `SrcL=12`、`SrcR=10`、`SrcRType=11`、`shamt=0` 时，合取为 `12 AND 10 = 8`。对同样的操作数取 `SrcRType=10` 时，准备好的右值是 `10` 的按位取反，发布结果为 `12 AND NOT 10 = 4`。取 `SrcRType=11`、`shamt=2` 时，准备好的右值为 `40`，且 `12 AND 40 = 8`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
and SrcL, SrcR<{.sw,.uw,.not}><<<shamt>, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| and_32_b6a903a3ec94 | L32 | 32 | 0x00002005 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| and_32_b6a903a3ec94 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| and_32_b6a903a3ec94 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| and_32_b6a903a3ec94 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| and_32_b6a903a3ec94 | SrcRType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |
| and_32_b6a903a3ec94 | shamt | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| and_32_b6a903a3ec94 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| and_32_b6a903a3ec94 | SrcL | 5 | 0–31 | none | none | left Reg5 source | Encoded zero reads the architectural zero GPR. |
| and_32_b6a903a3ec94 | SrcR | 5 | 0–31 | none | none | right Reg5 source | Encoded zero reads the architectural zero GPR. |
| and_32_b6a903a3ec94 | SrcRType | 2 | 0–3 | none | none | right-source transformation selector | Encoded zero selects .sw and sign-extends SrcR[31:0]. |
| and_32_b6a903a3ec94 | shamt | 5 | 0–31 | none | none | post-transformation logical-left-shift amount | Encoded zero performs no shift. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | left Reg5 source |
| SrcR | right Reg5 source |
| SrcRType | right-source transformation selector |
| shamt | post-transformation logical-left-shift amount |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/AND.asl -->
```asl
readonly func InstructionContractOperation_AND()
    => ScalarOperation
begin
    return ScalarOperation_AND;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/AND.asl -->
```asl
readonly func InstructionContractHandler_AND()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinary;
end;

pure func InstructionContractRightModifier_AND(encoded: bits(2))
    => ScalarRightModifier
begin
    case encoded of
        when '00' => return ScalarRight_SignedWord;
        when '01' => return ScalarRight_UnsignedWord;
        when '10' => return ScalarRight_NegateOrNot;
        when '11' => return ScalarRight_None;
    end;
end;

pure func InstructionContractPreparedRight_AND(
    right: Word,
    encoded_modifier: bits(2),
    shift_amount: integer {0..31})
    => Word
begin
    let modifier = InstructionContractRightModifier_AND(encoded_modifier);
    let transformed = ApplyScalarRightModifier(right, modifier, TRUE);
    let shifted = LSL(transformed, shift_amount);
    return shifted;
end;

pure func InstructionContractResult_AND(
    left: Word,
    right: Word,
    encoded_modifier: bits(2),
    shift_amount: integer {0..31})
    => Word
begin
    let prepared_right = InstructionContractPreparedRight_AND(
        right,
        encoded_modifier,
        shift_amount);
    return ScalarBinary(ScalarBinary_AND, left, prepared_right);
end;

pure func InstructionContractIsLogicalFamily_AND()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractIsWordOperation_AND()
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
- All four SrcRType encodings are assigned. The logical family uses .not while the arithmetic family uses .neg; AND uses .not.
- Every five-bit shamt value from 0 through 31 is legal.

## State effects

- Transform SrcR, perform the logical left shift, and compute the PTO_XLEN bitwise conjunction with SrcL.
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

- AND raises no arithmetic exception; transformed or shifted-out bits are discarded at PTO_XLEN width.
- A fixed-bit mismatch or unavailable selected T/U source raises Fault_IllegalInstruction before the destination effect and before TPC advances.

## Examples

- and a0, a1, ->a2
- and t#1, u#1.not<<1, ->u
- and zero, a0.sw, ->zero
