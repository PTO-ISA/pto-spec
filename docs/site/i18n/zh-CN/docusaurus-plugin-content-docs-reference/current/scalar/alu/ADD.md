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

`ADD` 先准备右源，再在 `PTO_XLEN` 位宽上把它加到不变的左源上，并通过 Reg5 目标发布和。`PTO_XLEN` 为 `64`，因此发布的值是一个 64 位字。

设计要点：`ADD` 与 `AND`、`OR`、`XOR` 以及这些助记符的 `W` 字形式共用五个编码字段。一种字段布局意味着整个族共用一个译码器和一份操作数合法性检查；元素运算由助记符单独选择，而在 `SrcRType=10` 时，该修饰符表示取负还是按位取反也由助记符决定。

<!-- PTO-READER-BLOCK: scalar-add-mechanism role=mechanism -->
## 结果如何形成

执行按两个有序步骤准备右源，然后相加。

- `SrcRType` 变换 `SrcR`：`00` 对 `SrcR[31:0]` 做符号扩展，`01` 对 `SrcR[31:0]` 做零扩展，`10` 对完整值取负，`11` 保持不变。汇编中省略后缀即编码 `SrcRType=11`。
- `shamt` 随后把变换后的值逻辑左移 `0` 至 `31` 位。

准备好的右值按 `2^PTO_XLEN` 取模加到快照的 `SrcL` 上，因此和会回绕，且不会引发算术异常。

设计要点：移位作用于右操作数，而不是作用于和。因此单条编码 `add a0, a1.neg<<3, ->a0` 计算 `a0 - 8*a1`，而 `add a0, a1<<4` 加上右源的十六倍。

设计要点：取负是 XLEN 位宽上的 `Zeros - value`，因此对最小负字取负会得到它自身。该指令没有可供选择的溢出或饱和形式。

<!-- PTO-READER-BLOCK: scalar-add-inputs role=inputs-outputs -->
## 输入与目标

- `SrcL` 和 `SrcR` 是 Reg5 源：`0..23` 读取绝对 GPR，`24..27` 读取 `T#1..T#4`，`28..31` 读取 `U#1..U#4`。读取临时源不会消费它。
- `RegDst` 发布结果：`1..23` 写入该 GPR，`30` 压入 `U`，`31` 压入 `T`，`0` 与 `24..29` 一起丢弃结果。

设计要点：目标编码 `0` 是丢弃，而不是写入零 GPR；`24..29` 同样丢弃，尽管 `24..27` 在读取时命名 T 源。因此同一个 5 位字段在读取侧和写入侧并不对称。

设计要点：`SrcL` 或 `SrcR` 的编码零读取架构零 GPR，因此 `add zero, a0, ->a1` 就是一次普通拷贝。编码中没有任何字段可以省略；汇编后缀是唯一可以省略的写法。

<!-- PTO-READER-BLOCK: scalar-add-effects role=effects -->
## 效果与顺序

两个源都在写入目标之前读取，因此 `add a0, a0, ->a0` 以及与源重名的目标都使用指令执行前的值。

和发布或丢弃之后，`TPC` 前进 `4` 字节。除此之外没有其他变化。`ADD` 不读写内存；除 `RegDst` 选中的那一次 `T` 或 `U` 压入外，它不改变保留状态、描述符、数值状态、陷阱、指令束、特权、谓词和控制流状态。

<!-- PTO-READER-BLOCK: scalar-add-constraints role=constraints -->
## 合法性与故障边界

每个编码取值都已分配：四个 `SrcRType` 编码以及 `0` 至 `31` 的全部 `32` 个 `shamt` 取值都合法，因此 `ADD` 自身没有保留编码。

各项检查在结果产生之前按固定顺序执行。无法译码的形式在 `PC` 处引发 `Fault_IllegalInstruction`；不适用于当前指令束的指令在 `TPC` 处引发 `Fault_BundleControl`；固定编码位不匹配或所选 T/U 源不可用会引发 `Fault_IllegalInstruction`。任何故障之后都不会写入目标，`TPC` 停在出错指令上，因此重新发射时会重新计算地址、源和结果，不保留任何进度。

设计要点：源可用性检查先于源读取。这正是空 T 队列上的 `add t#1, a0, ->a0` 会触发故障、而不是读取未定义值的原因：该检查把未初始化的临时值变成了有定义的陷阱。

<!-- PTO-READER-BLOCK: scalar-add-example role=example -->
## 非规范演示

下面的演示只帮助理解当前所有者，并不替代上面的规范操作。

当 `SrcL=10`、`SrcR=3`、`SrcRType=10`、`shamt=1` 时，`ADD` 先把右源取负为 `-3`，再把它左移一次得到 `-6`，最后按 `2^PTO_XLEN` 取模计算 `10 + (-6) = 4`。发布出的字为 `4`。
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
