<!-- GENERATED FROM: asl/scalar/alu/SUBW.asl -->
# SUBW

**Normative ASL source:** `asl/scalar/alu/SUBW.asl`

SUBW applies the selected right-source transformation before its encoded logical left shift, performs fixed-width word subtraction, and publishes the low 32-bit result sign-extended to XLEN.

## Normative identity {#PTO-INST-SCALAR-SUBW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-subw-purpose role=purpose -->
## SUBW 的作用

`SUBW` 按与 `SUB` 完全相同的方式变换 `SrcR`，从 `SrcL` 的低 `32` 位中模 `2^32` 减去该移位后的值，并发布符号扩展到 `PTO_XLEN` 的字。它包含 `RegDst`、`SrcL`、`SrcR`、`SrcRType` 与 `shamt`。

该载体在掩码 `0x0000707f` 下匹配 `0x00001025`。处理函数是带算术族标志的 `ScalarBinaryW`，因此 `SrcRType=10` 取负完整的右操作数。

变换与移位按完整宽度作用于 `SrcR`；收窄只施加于减法与发布。

<!-- PTO-READER-BLOCK: scalar-subw-mechanism role=mechanism -->
## 字结果形成方式

`ExecuteDecodedBinary` 读取两个源与两个后缀字段，用 `PrepareScalarRight(right, modifier, shift_amount, FALSE)` 构造右操作数，并在 `word_operation` 为真时调用 `ScalarBinaryW(ScalarBinary_SUB, left, right)`（`asl/scalar/model/dispatch/alu.asl:86-87`）。该辅助函数按 `32` 位计算差值并返回 `SignExtend{PTO_XLEN}(result32)`（`asl/scalar/model/alu/semantics.asl:477`）。

```asm
subw SrcL, SrcR<{.sw,.uw,.neg}><<<shamt>, ->{t, u, Rd}
```

设计要点：`.neg` 在收窄之前对完整的 `PTO_XLEN` 寄存器取负，因此只要 `SrcR` 的低字不为零，取负后取值的低字就是 `SrcR` 低字的补码取负。当 `shamt` 为 `31` 时，只有变换后取值原来的第 `0` 位能到达字位 `31`。

设计要点：`SrcL` 的高半部从不进入减法。当源的低字为零、右操作数为 `1` 时，无论源的高半部是什么，`subw` 都发布 `-1`。

<!-- PTO-READER-BLOCK: scalar-subw-inputs role=inputs-outputs -->
## 输入与目标

两个操作数都是 Reg5 源，后缀字段来自载体，`RegDst` 选择目标。

- `SrcL` 位于 `[15 +: 5]`、`SrcR` 位于 `[20 +: 5]`：`0..23` 读取绝对 GPR，`24..27` 读取 `T#1..T#4`，`28..31` 读取 `U#1..U#4`，非消耗。只减去各自的低字。
- `SrcRType` 位于 `[25 +: 2]`：`00` 为 `.sw`，`01` 为 `.uw`，`10` 为 `.neg`，`11` 为无修饰；省略后缀时编码为 `11`。
- `shamt` 位于 `[27 +: 5]`：施加于变换后右操作数的逻辑左移量，取值 `0` 到 `31`。
- `RegDst` 位于 `[7 +: 5]`：`1..23` 写入对应 GPR，`30` 压入 `U`，`31` 压入 `T`，`0` 与 `24..29` 丢弃。

设计要点：两个宽度决定彼此独立，因此当某个操作数的高半部不是其低字的符号扩展时，`subw` 与 `sub` 就可能不一致。`subw` 减去变换后右操作数的低字再扩展字结果，而 `sub` 减去整个变换后的寄存器。

<!-- PTO-READER-BLOCK: scalar-subw-effects role=effects -->
## 效果与顺序

两个源都在写目标之前取快照，因此同名目标基于执行前的值计算。符号扩展后的字发布后 `TPC` 推进 `4` 字节。

`SUBW` 不访问内存，保留、描述符、数值标志、陷阱、指令束、特权、谓词与控制流状态都保持不变；仅当目标是 `30` 或 `31` 时临时队列才会移动。

设计要点：字级差值按模 `2^32` 回绕，最终的扩展把回绕后的字重新解释为有符号 `32` 位取值。因此字外的借位会改变发布值的符号，而不是被丢弃。

<!-- PTO-READER-BLOCK: scalar-subw-constraints role=constraints -->
## 合法性与故障边界

全部四个 `SrcRType` 编码与全部 `32` 个 `shamt` 值都有定义，Reg5 映射的每个源编码与目标编码也都有定义。该形式除固定位外没有约束。

不匹配的载体在 `PC` 触发 `Fault_IllegalInstruction`。对活动块不适用的指令在 `TPC` 触发 `Fault_BundleControl`，对 `SUBW` 而言仅在系统块终止请求挂起期间可达。所选 `T` 或 `U` 源不可用时在 `PC` 触发 `Fault_IllegalInstruction`，先于目标效果与 `TPC` 推进。

设计要点：没有任何操作数取值会选择陷阱：修饰、移位、字级减法与符号扩展都是全定义的。`SUBW` 的故障边界是编码有效性加上源可用性。

<!-- PTO-READER-BLOCK: scalar-subw-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

当 `a0` 为 `7`、`a1` 为 `3` 时，`subw a0, a1, ->a2` 发布 `4`，`subw a0, a1<.neg>, ->a2` 发布 `10`。

当 `a0` 为 `3`、`a1` 为 `7` 时，字差值是 `0xFFFFFFFC`，因此 `a2` 收到 `0xFFFFFFFFFFFFFFFC`。当 `a1` 为 `1`、`shamt` 为 `4` 时，`subw a0, a1<<<4>, ->a2` 发布 `-13`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
subw SrcL, SrcR<{.sw,.uw,.neg}><<<shamt>, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| subw_32_3a8d45653c98 | L32 | 32 | 0x00001025 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| subw_32_3a8d45653c98 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| subw_32_3a8d45653c98 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| subw_32_3a8d45653c98 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| subw_32_3a8d45653c98 | SrcRType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |
| subw_32_3a8d45653c98 | shamt | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| subw_32_3a8d45653c98 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| subw_32_3a8d45653c98 | SrcL | 5 | 0–31 | none | none | left Reg5 source | Encoded zero reads the architectural zero GPR. |
| subw_32_3a8d45653c98 | SrcR | 5 | 0–31 | none | none | right Reg5 source | Encoded zero reads the architectural zero GPR. |
| subw_32_3a8d45653c98 | SrcRType | 2 | 0–3 | none | none | right-source transformation selector | Encoded zero selects .sw and sign-extends SrcR[31:0]. |
| subw_32_3a8d45653c98 | shamt | 5 | 0–31 | none | none | post-transformation logical-left-shift amount | Encoded zero performs no shift. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | left Reg5 source |
| SrcR | right Reg5 source |
| SrcRType | right-source transformation selector |
| shamt | post-transformation logical-left-shift amount |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/SUBW.asl -->
```asl
readonly func InstructionContractOperation_SUBW()
    => ScalarOperation
begin
    return ScalarOperation_SUBW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/SUBW.asl -->
```asl
readonly func InstructionContractHandler_SUBW()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinaryW;
end;

pure func InstructionContractRightModifier_SUBW(encoded: bits(2))
    => ScalarRightModifier
begin
    case encoded of
        when '00' => return ScalarRight_SignedWord;
        when '01' => return ScalarRight_UnsignedWord;
        when '10' => return ScalarRight_NegateOrNot;
        when '11' => return ScalarRight_None;
    end;
end;

pure func InstructionContractPreparedRight_SUBW(
    right: Word,
    encoded_modifier: bits(2),
    shift_amount: integer {0..31})
    => Word
begin
    let modifier = InstructionContractRightModifier_SUBW(encoded_modifier);
    let transformed = ApplyScalarRightModifier(right, modifier, FALSE);
    let shifted = LSL(transformed, shift_amount);
    return shifted;
end;

pure func InstructionContractResult_SUBW(
    left: Word,
    right: Word,
    encoded_modifier: bits(2),
    shift_amount: integer {0..31})
    => Word
begin
    let prepared_right = InstructionContractPreparedRight_SUBW(
        right,
        encoded_modifier,
        shift_amount);
    return ScalarBinaryW(ScalarBinary_SUB, left, prepared_right);
end;

pure func InstructionContractIsLogicalFamily_SUBW()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractIsWordOperation_SUBW()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL, SrcR, SrcRType, shamt, and RegDst are required encoded fields; no field can be omitted.
- SrcRType=00 selects .sw, SrcRType=01 selects .uw, SrcRType=10 selects .neg, and SrcRType=11 selects no modifier. An omitted assembly suffix encodes SrcRType=11.
- Encoded shamt zero performs no shift; every value from 0 through 31 is assigned.

## Legality

- SrcL and SrcR codes 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consumption.
- RegDst codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write GPRs.
- All four SrcRType encodings are assigned. The logical family uses .not while the arithmetic family uses .neg; SUBW uses .neg.
- Every five-bit shamt value from 0 through 31 is legal.

## State effects

- Transform SrcR, perform the logical left shift, subtract SrcL at 32-bit width modulo 2^32, and sign-extend the low 32-bit result to XLEN.
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

- SUBW raises no arithmetic exception; the word operation keeps its low 32-bit result and sign-extends it to XLEN.
- A fixed-bit mismatch or unavailable selected T/U source raises Fault_IllegalInstruction before the destination effect and before TPC advances.

## Examples

- subw a0, a1, ->a2
- subw t#1, u#1.neg<<1, ->u
- subw zero, a0.sw, ->zero
