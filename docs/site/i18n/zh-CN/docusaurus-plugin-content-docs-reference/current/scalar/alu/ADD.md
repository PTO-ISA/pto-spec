<!-- GENERATED FROM: asl/scalar/alu/ADD.asl -->
# ADD

**Normative ASL source:** `asl/scalar/alu/ADD.asl`

ADD applies the selected right-source transformation before its encoded logical left shift, performs fixed-width addition, and publishes the PTO_XLEN result.

## Normative identity {#PTO-INST-SCALAR-ADD}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-add-purpose role=purpose -->
## ADD 的作用

`ADD` 是一条独立编码的 32 位标量指令。它先准备右源，再将其与不变的左源按 `2^PTO_XLEN` 取模相加，并发布一个 XLEN 结果。

<!-- PTO-READER-BLOCK: scalar-add-mechanism role=mechanism -->
## 结果如何形成

指令先对 `SrcR` 应用 `SrcRType` 选定的变换，再对变换后的值执行编码指定的逻辑左移，最后才把准备好的右值加到 `SrcL` 上。

- `SrcRType=00` 选择有符号字扩展，`01` 选择无符号字扩展，`10` 在 `ADD` 中选择取负，`11` 保持完整右源不变。
- `shamt` 是 `0` 至 `31` 的逻辑左移量；`0` 表示不移动变换后的值。

取负、移位和加法都是定宽操作。它们按 `2^PTO_XLEN` 取模回绕，不会引发算术异常。

<!-- PTO-READER-BLOCK: scalar-add-inputs role=inputs-outputs -->
## 输入与目的位置

- `SrcL` 和 `SrcR` 使用完整 Reg5 源域：`0..23` 选择 GPR，`24..27` 选择 `T#1..T#4`，`28..31` 选择 `U#1..U#4`；读取临时源不会消费队列项。
- `RegDst` 的 `1..23` 写入 GPR，`30` 压入 U，`31` 压入 T，`0` 和 `24..29` 丢弃结果。

页面显示的每个字段都有编码。汇编中省略修饰符表示 `SrcRType=11`；编码 `shamt=0` 表示不移位，而不是省略该操作。

<!-- PTO-READER-BLOCK: scalar-add-effects role=effects -->
## 效果与顺序

两个源都会在目的效果发生前完成快照，因此目的别名或队列压入不会改变同一条指令所消费的任一值。

结果计算完成后，`ADD` 按 `RegDst` 发布或丢弃结果，然后让 `TPC` 前进 `4` 字节。

`ADD` 不读写内存，也不改变保留状态、描述符、数值状态、陷阱、指令束、特权、谓词或控制流状态；唯一例外是成功时 `TPC` 前进。

<!-- PTO-READER-BLOCK: scalar-add-constraints role=constraints -->
## 合法性与故障边界

四个 `SrcRType` 值和全部 `32` 个移位量均已分配。固定编码位不匹配，或者选中的 T/U 源尚不可用，会在目的发布和 `TPC` 前进之前引发 `Fault_IllegalInstruction`。

<!-- PTO-READER-BLOCK: scalar-add-example role=example -->
## 非规范演示

下面的演示只帮助理解当前所有者，并不替代上面的规范操作。

当 `SrcL=10`、`SrcR=3`、`SrcRType=10`、`shamt=1` 时，`ADD` 先对右源取负，再左移一次，最后按 `2^PTO_XLEN` 取模计算 `10 + (-6) = 4`。即使目的位置与左侧 GPR 重叠，计算仍使用原始值 `10`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
add SrcL, SrcR<{.sw,.uw,.neg}><<<shamt>, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| add_32_d04202886d0a | L32 | 32 | 0x00000005 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| add_32_d04202886d0a | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| add_32_d04202886d0a | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| add_32_d04202886d0a | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| add_32_d04202886d0a | SrcRType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |
| add_32_d04202886d0a | shamt | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| add_32_d04202886d0a | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| add_32_d04202886d0a | SrcL | 5 | 0–31 | none | none | left Reg5 source | Encoded zero reads the architectural zero GPR. |
| add_32_d04202886d0a | SrcR | 5 | 0–31 | none | none | right Reg5 source | Encoded zero reads the architectural zero GPR. |
| add_32_d04202886d0a | SrcRType | 2 | 0–3 | none | none | right-source transformation selector | Encoded zero selects .sw and sign-extends SrcR[31:0]. |
| add_32_d04202886d0a | shamt | 5 | 0–31 | none | none | post-transformation logical-left-shift amount | Encoded zero performs no shift. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | left Reg5 source |
| SrcR | right Reg5 source |
| SrcRType | right-source transformation selector |
| shamt | post-transformation logical-left-shift amount |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/ADD.asl -->
```asl
readonly func InstructionContractOperation_ADD()
    => ScalarOperation
begin
    return ScalarOperation_ADD;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/ADD.asl -->
```asl
readonly func InstructionContractHandler_ADD()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinary;
end;

pure func InstructionContractRightModifier_ADD(encoded: bits(2))
    => ScalarRightModifier
begin
    case encoded of
        when '00' => return ScalarRight_SignedWord;
        when '01' => return ScalarRight_UnsignedWord;
        when '10' => return ScalarRight_NegateOrNot;
        when '11' => return ScalarRight_None;
    end;
end;

pure func InstructionContractPreparedRight_ADD(
    right: Word,
    encoded_modifier: bits(2),
    shift_amount: integer {0..31})
    => Word
begin
    let modifier = InstructionContractRightModifier_ADD(encoded_modifier);
    let transformed = ApplyScalarRightModifier(right, modifier, FALSE);
    let shifted = LSL(transformed, shift_amount);
    return shifted;
end;

pure func InstructionContractResult_ADD(
    left: Word,
    right: Word,
    encoded_modifier: bits(2),
    shift_amount: integer {0..31})
    => Word
begin
    let prepared_right = InstructionContractPreparedRight_ADD(
        right,
        encoded_modifier,
        shift_amount);
    return ScalarBinary(ScalarBinary_ADD, left, prepared_right);
end;

pure func InstructionContractIsLogicalFamily_ADD()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractIsWordOperation_ADD()
    => boolean
begin
    return FALSE;
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
- All four SrcRType encodings are assigned. The logical family uses .not while the arithmetic family uses .neg; ADD uses .neg.
- Every five-bit shamt value from 0 through 31 is legal.

## State effects

- Transform SrcR, perform the logical left shift, and add the shifted value to SrcL modulo 2^PTO_XLEN.
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

- ADD raises no arithmetic exception; negation, shifting, and addition wrap modulo 2^PTO_XLEN.
- A fixed-bit mismatch or unavailable selected T/U source raises Fault_IllegalInstruction before the destination effect and before TPC advances.

## Examples

- add a0, a1, ->a2
- add t#1, u#1.neg<<1, ->u
- add zero, a0.sw, ->zero
