<!-- GENERATED FROM: asl/scalar/alu/ORW.asl -->
# ORW

**Normative ASL source:** `asl/scalar/alu/ORW.asl`

ORW applies the selected right-source transformation before its encoded logical left shift, performs word bitwise inclusive OR, and publishes the low 32-bit result sign-extended to XLEN.

## Normative identity {#PTO-INST-SCALAR-ORW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-orw-purpose role=purpose -->
## ORW 的作用

`ORW` 按与 `OR` 完全相同的方式构造 `SrcR`，在 `32` 位宽度下把它与 `SrcL` 的低 `32` 位做按位或，并发布符号扩展到 `PTO_XLEN` 的字。它包含 `RegDst`、`SrcL`、`SrcR`、`SrcRType` 与 `shamt`。

该载体在掩码 `0x0000707f` 下匹配 `0x00003025`，并以逻辑族标志置位的方式分派到 `ScalarBinaryW`，因此 `SrcRType=10` 取反完整的右操作数。

只有两侧的低字进入按位或，但修饰与移位先作用于完整的 `PTO_XLEN` 右操作数。

<!-- PTO-READER-BLOCK: scalar-orw-mechanism role=mechanism -->
## 字结果形成方式

`ExecuteDecodedBinary` 读取 `SrcL`、未修改的 `SrcR`、`SrcRType` 与 `shamt`，然后用 `PrepareScalarRight(right, modifier, shift_amount, TRUE)` 构造右操作数。在 `word_operation` 为真时它调用 `ScalarBinaryW(ScalarBinary_OR, left, right)`，后者的 `left32`/`right32` 绑定保留 `[31:0]`，返回 `32` 位或运算结果的 `SignExtend{PTO_XLEN}`（`asl/scalar/model/dispatch/alu.asl:82-83`、`asl/scalar/model/alu/semantics.asl:470-487`）。

```asm
orw SrcL, SrcR<{.sw,.uw,.not}><<<shamt>, ->{t, u, Rd}
```

设计要点：移位发生在收窄之前，因此 `shamt` 可以把 `SrcR` 中低于第 `32` 位的比特搬进低字，但永远无法从更高处搬入。把 `.sw` 或 `.uw` 右操作数左移 `31` 位会把它原来的第 `0` 位放到字位 `31`，该位随后成为发布字的符号位。

设计要点：由于收窄最后发生，`SrcL` 的高字无法置起任何结果位。即使 `SrcL` 的高半部全为 `1`，`orw` 也只会发布低字所产生的内容。

<!-- PTO-READER-BLOCK: scalar-orw-inputs role=inputs-outputs -->
## 输入与目标

两个源都使用 Reg5 源映射，后缀字段由载体译出，结果通过 Reg5 目标映射发布。

- `SrcL` 位于 `[15 +: 5]`、`SrcR` 位于 `[20 +: 5]`：`0..23` 读取绝对 GPR，`24..27` 读取 `T#1..T#4`，`28..31` 读取 `U#1..U#4`，非消耗。
- `SrcRType` 位于 `[25 +: 2]`：`00` 为 `.sw`，`01` 为 `.uw`，`10` 为 `.not`，`11` 为无修饰；省略后缀时编码为 `11`。
- `shamt` 位于 `[27 +: 5]`：修饰之后应用的逻辑左移量，取值 `0` 到 `31`。
- `RegDst` 位于 `[7 +: 5]`：`1..23` 写入对应 GPR，`30` 压入 `U`，`31` 压入 `T`，`0` 与 `24..29` 丢弃。

设计要点：`.not` 取反 `SrcR` 的 `PTO_XLEN` 位，因此 `orw a0, a1<.not>, ->a2` 发布的是 `a0` 低字与 `a1` 低字反码的或。修饰与收窄彼此独立：取反从不限制在 `32` 位之内。

<!-- PTO-READER-BLOCK: scalar-orw-effects role=effects -->
## 效果与顺序

两个源都在写入之前取快照，因此同名目标观察到的是执行前的值。字发布后 `TPC` 推进 `4` 字节。

`ORW` 不访问内存，也不改变保留、描述符、数值标志、陷阱、指令束、特权、谓词或控制流状态。仅当目标是 `30` 或 `31` 时它才会移动临时队列。

设计要点：发布的字始终有定义明确的高半部：`63..32` 位重复或运算结果的第 `31` 位。需要零扩展字的调用者必须自行清除这些位，因为 `ORW` 没有提供零扩展的变体。

<!-- PTO-READER-BLOCK: scalar-orw-constraints role=constraints -->
## 合法性与故障边界

全部四个 `SrcRType` 编码与全部 `32` 个 `shamt` 值都有定义，Reg5 映射的每个源编码与目标编码也都有定义。该形式除固定位外没有约束。

不匹配的载体在 `PC` 触发 `Fault_IllegalInstruction`。对活动块不适用的指令在 `TPC` 触发 `Fault_BundleControl`，对 `ORW` 而言仅在系统块终止请求挂起期间可达。所选 `T` 或 `U` 源不可用时在 `PC` 触发 `Fault_IllegalInstruction`。每项检查都先于目标效果与 `TPC` 推进。

设计要点：没有任何操作数取值会选择陷阱：变换、移位、字级或运算与符号扩展都是全定义的。`ORW` 的故障边界是编码有效性加上源可用性。

<!-- PTO-READER-BLOCK: scalar-orw-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

当 `a0` 的低 `32` 位为 `0x00F0`、`a1` 为 `0x000000000000000F` 时，`orw a0, a1, ->a2` 发布 `0x00FF`。

当 `a0` 为 `1`、`a1` 为 `1` 时，`orw a0, a1<.sw><<<31>, ->a2` 把变换后的 `1` 左移 `31` 位，因此移位后的右操作数是 `0x80000000`；字级或运算还会保留 `a0` 的第 `0` 位，因此发布的字是 `0xFFFFFFFF80000001`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
orw SrcL, SrcR<{.sw,.uw,.not}><<<shamt>, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| orw_32_84f7ac2ed68f | L32 | 32 | 0x00003025 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| orw_32_84f7ac2ed68f | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| orw_32_84f7ac2ed68f | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| orw_32_84f7ac2ed68f | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| orw_32_84f7ac2ed68f | SrcRType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |
| orw_32_84f7ac2ed68f | shamt | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| orw_32_84f7ac2ed68f | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| orw_32_84f7ac2ed68f | SrcL | 5 | 0–31 | none | none | left Reg5 source | Encoded zero reads the architectural zero GPR. |
| orw_32_84f7ac2ed68f | SrcR | 5 | 0–31 | none | none | right Reg5 source | Encoded zero reads the architectural zero GPR. |
| orw_32_84f7ac2ed68f | SrcRType | 2 | 0–3 | none | none | right-source transformation selector | Encoded zero selects .sw and sign-extends SrcR[31:0]. |
| orw_32_84f7ac2ed68f | shamt | 5 | 0–31 | none | none | post-transformation logical-left-shift amount | Encoded zero performs no shift. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | left Reg5 source |
| SrcR | right Reg5 source |
| SrcRType | right-source transformation selector |
| shamt | post-transformation logical-left-shift amount |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/ORW.asl -->
```asl
readonly func InstructionContractOperation_ORW()
    => ScalarOperation
begin
    return ScalarOperation_ORW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/ORW.asl -->
```asl
readonly func InstructionContractHandler_ORW()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinaryW;
end;

pure func InstructionContractRightModifier_ORW(encoded: bits(2))
    => ScalarRightModifier
begin
    case encoded of
        when '00' => return ScalarRight_SignedWord;
        when '01' => return ScalarRight_UnsignedWord;
        when '10' => return ScalarRight_NegateOrNot;
        when '11' => return ScalarRight_None;
    end;
end;

pure func InstructionContractPreparedRight_ORW(
    right: Word,
    encoded_modifier: bits(2),
    shift_amount: integer {0..31})
    => Word
begin
    let modifier = InstructionContractRightModifier_ORW(encoded_modifier);
    let transformed = ApplyScalarRightModifier(right, modifier, TRUE);
    let shifted = LSL(transformed, shift_amount);
    return shifted;
end;

pure func InstructionContractResult_ORW(
    left: Word,
    right: Word,
    encoded_modifier: bits(2),
    shift_amount: integer {0..31})
    => Word
begin
    let prepared_right = InstructionContractPreparedRight_ORW(
        right,
        encoded_modifier,
        shift_amount);
    return ScalarBinaryW(ScalarBinary_OR, left, prepared_right);
end;

pure func InstructionContractIsLogicalFamily_ORW()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractIsWordOperation_ORW()
    => boolean
begin
    return TRUE;
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
- All four SrcRType encodings are assigned. The logical family uses .not while the arithmetic family uses .neg; ORW uses .not.
- Every five-bit shamt value from 0 through 31 is legal.

## State effects

- Transform SrcR, perform the logical left shift, compute the bitwise inclusive OR with SrcL[31:0], and sign-extend the low 32-bit result to XLEN.
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

- ORW raises no arithmetic exception; the word operation keeps its low 32-bit result and sign-extends it to XLEN.
- A fixed-bit mismatch or unavailable selected T/U source raises Fault_IllegalInstruction before the destination effect and before TPC advances.

## Examples

- orw a0, a1, ->a2
- orw t#1, u#1.not<<1, ->u
- orw zero, a0.sw, ->zero
