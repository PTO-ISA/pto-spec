<!-- GENERATED FROM: asl/scalar/alu/SUB.asl -->
# SUB

**Normative ASL source:** `asl/scalar/alu/SUB.asl`

SUB applies the selected right-source transformation before its encoded logical left shift, performs fixed-width subtraction, and publishes the PTO_XLEN result.

## Normative identity {#PTO-INST-SCALAR-SUB}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-sub-purpose role=purpose -->
## SUB 的作用

`SUB` 按 `SrcRType` 变换右源，按 `shamt` 对其逻辑左移，并从 `SrcL` 中模 `2^PTO_XLEN` 减去该结果。它包含 `RegDst`、`SrcL`、`SrcR`、`SrcRType` 与 `shamt`。

该载体在掩码 `0x0000707f` 下匹配 `0x00001005`。该助记符属于算术族，因此其修饰是取负而不是取反。

这里没有编码的加/减模式：方向由助记符确定，同族的 `ADD` 使用相同的字段布局。

<!-- PTO-READER-BLOCK: scalar-sub-mechanism role=mechanism -->
## 操作数形成方式

分派路径以 `ScalarBinary_SUB`、为假的 `logical_family` 与为假的 `word_operation` 调用 `ExecuteDecodedBinary`（`asl/scalar/model/dispatch/alu.asl:84-85`）。该路径读取 `SrcL`、未修改的 `SrcR`、`SrcRType` 与 `shamt`，用 `PrepareScalarRight(right, modifier, shift_amount, FALSE)` 构造右操作数，并从 `ScalarBinary` 返回 `left - right`（`asl/scalar/model/alu/semantics.asl:452`）。

```asm
sub SrcL, SrcR<{.sw,.uw,.neg}><<<shamt>, ->{t, u, Rd}
```

- `SrcRType=00` 选择 `.sw`：`SignExtend{PTO_XLEN}(SrcR[31:0])`。
- `SrcRType=01` 选择 `.uw`：`ZeroExtend{PTO_XLEN}(SrcR[31:0])`。
- `SrcRType=10` 选择 `.neg`：`Zeros{PTO_XLEN} - SrcR`，即完整寄存器的补码取负。
- `SrcRType=11` 不选择修饰，保持 `SrcR` 不变；省略汇编后缀时编码的就是该值。
- `shamt` 把变换后的值逻辑左移 `0` 到 `31` 位。

设计要点：由于 `SUB` 属于算术族，`SrcRType=10` 执行取负而不是取反。同样的两位选择子取值在 `OR` 中是取反，因此在两个助记符之间照搬编码时，位的含义会改变而位本身不变。

设计要点：`.neg` 对完整的 `PTO_XLEN` 寄存器取负，而 `.sw` 与 `.uw` 先用第 `31` 位替换高半部。因此只要 `SrcR` 的高半部不是其低字的符号扩展，用 `.neg` 相减就与用 `.sw` 相减不同。

<!-- PTO-READER-BLOCK: scalar-sub-inputs role=inputs-outputs -->
## 输入与目标

两个操作数都是 Reg5 源，两个后缀字段由载体译出，`RegDst` 选择目标。

- `SrcL` 位于 `[15 +: 5]`，是被减数；`SrcR` 位于 `[20 +: 5]`，是减数；两者都使用映射 `0..23` 绝对 GPR、`24..27` `T#1..T#4`、`28..31` `U#1..U#4`，且不消耗条目。
- `SrcRType` 位于 `[25 +: 2]`，选择施加于 `SrcR` 的变换；`shamt` 位于 `[27 +: 5]`，选择随后施加的逻辑左移。
- `RegDst` 位于 `[7 +: 5]`：`1..23` 写入对应 GPR，`30` 压入 `U`，`31` 压入 `T`，`0` 与 `24..29` 丢弃。
- `SrcL` 或 `SrcR` 的编码零读取体系结构零 GPR，`shamt` 的编码零不执行移位。

设计要点：变换与移位只施加于 `SrcR`。`SrcL` 原样使用，因此没有任何合法编码能让 `SUB` 移位或取负左操作数；需要反向求差的程序交换两个选择子即可。

<!-- PTO-READER-BLOCK: scalar-sub-effects role=effects -->
## 效果与顺序

两个源都在写目标之前取快照，因此与任一源同名的目标基于执行前的值计算。差值按模 `2^PTO_XLEN` 发布，`TPC` 推进 `4` 字节。

`SUB` 不读内存，也不改变保留、描述符、数值标志、陷阱、指令束、特权、谓词或控制流状态；仅当目标是 `30` 或 `31` 时它才会移动临时队列。

设计要点：减法回绕而不是饱和，也不记录进位或借位标志。`SrcL = 0`、`SrcR = 1` 时 `SUB` 发布全一值，后续指令无法判断曾经发生借位。

<!-- PTO-READER-BLOCK: scalar-sub-constraints role=constraints -->
## 合法性与故障边界

全部四个 `SrcRType` 编码与全部 `32` 个 `shamt` 值都有定义，Reg5 映射的每个源编码与目标编码也都有定义。该形式除固定位外没有约束条目。

不匹配的载体在 `PC` 触发 `Fault_IllegalInstruction`。对活动块不适用的指令在 `TPC` 触发 `Fault_BundleControl`，对 `SUB` 而言仅在系统块终止请求挂起期间可达。所选 `T` 或 `U` 源不可用时在 `PC` 触发 `Fault_IllegalInstruction`。每项检查都先于目标效果与 `TPC` 推进。

设计要点：变换、移位与回绕减法都是全定义的，因此 `SUB` 没有由操作数选择的陷阱。它的故障边界是编码有效性加上源可用性。

<!-- PTO-READER-BLOCK: scalar-sub-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

当 `a0` 为 `7`、`a1` 为 `3` 时，`sub a0, a1, ->a2` 发布 `4`，而 `sub a0, a1<.neg>, ->a2` 发布 `10`，因为取负后的减数是 `-3`。

当 `a0` 为 `0`、`a1` 为 `1` 时，`sub a0, a1<.uw>, ->a2` 发布回绕后的差值 `0xFFFFFFFFFFFFFFFF`。当 `a1` 为 `1`、`shamt` 为 `4` 时，`sub a0, a1<<<4>, ->a2` 发布 `-16`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
sub SrcL, SrcR<{.sw,.uw,.neg}><<<shamt>, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| sub_32_af383d4a2b42 | L32 | 32 | 0x00001005 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| sub_32_af383d4a2b42 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| sub_32_af383d4a2b42 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| sub_32_af383d4a2b42 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| sub_32_af383d4a2b42 | SrcRType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |
| sub_32_af383d4a2b42 | shamt | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| sub_32_af383d4a2b42 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| sub_32_af383d4a2b42 | SrcL | 5 | 0–31 | none | none | left Reg5 source | Encoded zero reads the architectural zero GPR. |
| sub_32_af383d4a2b42 | SrcR | 5 | 0–31 | none | none | right Reg5 source | Encoded zero reads the architectural zero GPR. |
| sub_32_af383d4a2b42 | SrcRType | 2 | 0–3 | none | none | right-source transformation selector | Encoded zero selects .sw and sign-extends SrcR[31:0]. |
| sub_32_af383d4a2b42 | shamt | 5 | 0–31 | none | none | post-transformation logical-left-shift amount | Encoded zero performs no shift. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | left Reg5 source |
| SrcR | right Reg5 source |
| SrcRType | right-source transformation selector |
| shamt | post-transformation logical-left-shift amount |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/SUB.asl -->
```asl
readonly func InstructionContractOperation_SUB()
    => ScalarOperation
begin
    return ScalarOperation_SUB;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/SUB.asl -->
```asl
readonly func InstructionContractHandler_SUB()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinary;
end;

pure func InstructionContractRightModifier_SUB(encoded: bits(2))
    => ScalarRightModifier
begin
    case encoded of
        when '00' => return ScalarRight_SignedWord;
        when '01' => return ScalarRight_UnsignedWord;
        when '10' => return ScalarRight_NegateOrNot;
        when '11' => return ScalarRight_None;
    end;
end;

pure func InstructionContractPreparedRight_SUB(
    right: Word,
    encoded_modifier: bits(2),
    shift_amount: integer {0..31})
    => Word
begin
    let modifier = InstructionContractRightModifier_SUB(encoded_modifier);
    let transformed = ApplyScalarRightModifier(right, modifier, FALSE);
    let shifted = LSL(transformed, shift_amount);
    return shifted;
end;

pure func InstructionContractResult_SUB(
    left: Word,
    right: Word,
    encoded_modifier: bits(2),
    shift_amount: integer {0..31})
    => Word
begin
    let prepared_right = InstructionContractPreparedRight_SUB(
        right,
        encoded_modifier,
        shift_amount);
    return ScalarBinary(ScalarBinary_SUB, left, prepared_right);
end;

pure func InstructionContractIsLogicalFamily_SUB()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractIsWordOperation_SUB()
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
- All four SrcRType encodings are assigned. The logical family uses .not while the arithmetic family uses .neg; SUB uses .neg.
- Every five-bit shamt value from 0 through 31 is legal.

## State effects

- Transform SrcR, perform the logical left shift, and subtract the shifted value from SrcL modulo 2^PTO_XLEN.
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

- SUB raises no arithmetic exception; transformation, shifting, and the final operation use PTO_XLEN bits modulo 2^PTO_XLEN.
- A fixed-bit mismatch or unavailable selected T/U source raises Fault_IllegalInstruction before the destination effect and before TPC advances.

## Examples

- sub a0, a1, ->a2
- sub t#1, u#1.neg<<1, ->u
- sub zero, a0.sw, ->zero
