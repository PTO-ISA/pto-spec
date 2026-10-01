<!-- GENERATED FROM: asl/scalar/alu/OR.asl -->
# OR

**Normative ASL source:** `asl/scalar/alu/OR.asl`

OR applies the selected right-source transformation before its encoded logical left shift, performs bitwise inclusive OR, and publishes the PTO_XLEN result.

## Normative identity {#PTO-INST-SCALAR-OR}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-or-purpose role=purpose -->
## OR 的作用

`OR` 由 `SrcR` 构造右操作数，并以完整的 `PTO_XLEN` 宽度发布该操作数与 `SrcL` 的按位或。它包含五个字段：`RegDst`、`SrcL`、`SrcR`、两位的 `SrcRType` 选择子以及五位的 `shamt`。

载体在掩码 `0x0000707f` 下匹配 `0x00003005`；助记符与这五个字段确定了该指令的全部行为。

`OR` 属于逻辑族，正是该族标志使 `SrcRType=10` 成为按位取反而非取负。

<!-- PTO-READER-BLOCK: scalar-or-mechanism role=mechanism -->
## 操作数形成方式

分派路径读取 `SrcL`、未修改的 `SrcR`、`SrcRType` 与 `shamt`，然后在 `asl/scalar/model/dispatch/alu.asl:80-83` 处调用 `PrepareScalarRight(unmodified_right, modifier, shift_amount, TRUE)`。该辅助函数先应用修饰再对结果逻辑左移 `shamt`；这个被修饰并移位后的值就是最终 `ScalarBinary_OR` 的右操作数。

```asm
or SrcL, SrcR<{.sw,.uw,.not}><<<shamt>, ->{t, u, Rd}
```

- `SrcRType=00` 选择 `.sw`：`SignExtend{PTO_XLEN}(SrcR[31:0])`。
- `SrcRType=01` 选择 `.uw`：`ZeroExtend{PTO_XLEN}(SrcR[31:0])`。
- `SrcRType=10` 选择 `.not`：完整的 `SrcR` 的每一位都被取反。
- `SrcRType=11` 不选择修饰，保持 `SrcR` 不变；省略汇编后缀时编码的就是该值。
- `shamt` 把变换后的值逻辑左移 `0` 到 `31` 位；编码零不执行移位。

设计要点：`.not` 取反 `SrcR` 的全部 `PTO_XLEN` 位，而不仅是低字，因此 `or a0, a1<.not>, ->a2` 是“或上一个完整寄存器的反码”的表达方式。`.sw` 与 `.uw` 会先替换高半部，因此无法用一条指令在它们之后再叠加 `.not`。

设计要点：变换只作用于 `SrcR`，`SrcL` 原封不动地进入按位或。

<!-- PTO-READER-BLOCK: scalar-or-inputs role=inputs-outputs -->
## 输入与目标

`SrcL` 与 `SrcR` 是五位 Reg5 字段；`SrcRType` 与 `shamt` 是载体内的编码选择子；`RegDst` 是五位目标。

- `SrcL` 位于 `[15 +: 5]`、`SrcR` 位于 `[20 +: 5]`，按 Reg5 映射读取：`0..23` 为绝对 GPR，`24..27` 为 `T#1..T#4`，`28..31` 为 `U#1..U#4`，都不消耗条目。
- `SrcRType` 位于 `[25 +: 2]`，选择右源变换；`shamt` 位于 `[27 +: 5]`，选择变换后的逻辑左移量。
- `RegDst` 位于 `[7 +: 5]`，发布或运算结果：`1..23` 写入对应 GPR，`30` 压入 `U`，`31` 压入 `T`，`0` 与 `24..29` 丢弃。
- `SrcL` 或 `SrcR` 的编码零读取体系结构零 GPR，`shamt` 的编码零不执行任何移位。

设计要点：`SrcRType` 的编码零选择 `.sw`，而不是“无修饰”。无修饰的右操作数是值 `11`，因此省略后缀与写出 `.sw` 会产生不同的指令。

<!-- PTO-READER-BLOCK: scalar-or-effects role=effects -->
## 效果与顺序

两个源都在写目标之前读取，因此与 `SrcL` 或 `SrcR` 同名的目标仍然对执行前的值做或运算。结果发布后 `TPC` 推进 `4` 字节。

`OR` 不访问内存，也不改变保留、描述符、数值标志、陷阱、指令束、特权、谓词或控制流状态。它唯一可能引起的队列移动是 `30` 或 `31` 目标所选的一次压入。

设计要点：在修饰生效之前读取 `SrcR`，意味着 `30` 或 `31` 目标无法把被修饰的值送回同一条指令，尽管该压入会重命名该队列槽位。后续指令会把压入的结果读作 `T#1` 或 `U#1`。

<!-- PTO-READER-BLOCK: scalar-or-constraints role=constraints -->
## 合法性与故障边界

全部四个 `SrcRType` 编码、从 `0` 到 `31` 的全部 `32` 个 `shamt` 值、全部 `32` 个源编码与全部 `32` 个目标编码都有定义。该形式除固定编码位外没有约束条目。

不匹配的载体在 `PC` 触发 `Fault_IllegalInstruction`。对活动块不适用的指令在 `TPC` 触发 `Fault_BundleControl`；对 `OR` 而言，这仅在系统块终止请求挂起期间可达。所选 `T` 或 `U` 源不可用时在 `PC` 触发 `Fault_IllegalInstruction`，先于目标效果与 `TPC` 推进。

设计要点：`OR` 对全部操作数取值都是全定义的：没有任何选择子组合或源位模式会产生陷阱，因此故障边界是编码有效性加上源可用性。

<!-- PTO-READER-BLOCK: scalar-or-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

当 `a0` 为 `0x0F0F`、`a1` 为 `0x00F0` 时，`or a0, a1, ->a2` 发布 `0x0FFF`。

当 `a0` 为 `0`、`a1` 为 `1` 时，`or a0, a1<.sw><<<4>, ->a2` 先把低字 `1` 符号扩展，再左移 `4` 位，因此 `a2` 收到 `16`。若同一编码使用 `SrcRType=10`，则改为对 `a1` 取反，把该反码左移 `4` 位后发布 `0xFFFFFFFFFFFFFFE0`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
or SrcL, SrcR<{.sw,.uw,.not}><<<shamt>, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| or_32_a7fb80e78831 | L32 | 32 | 0x00003005 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| or_32_a7fb80e78831 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| or_32_a7fb80e78831 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| or_32_a7fb80e78831 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| or_32_a7fb80e78831 | SrcRType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |
| or_32_a7fb80e78831 | shamt | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| or_32_a7fb80e78831 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| or_32_a7fb80e78831 | SrcL | 5 | 0–31 | none | none | left Reg5 source | Encoded zero reads the architectural zero GPR. |
| or_32_a7fb80e78831 | SrcR | 5 | 0–31 | none | none | right Reg5 source | Encoded zero reads the architectural zero GPR. |
| or_32_a7fb80e78831 | SrcRType | 2 | 0–3 | none | none | right-source transformation selector | Encoded zero selects .sw and sign-extends SrcR[31:0]. |
| or_32_a7fb80e78831 | shamt | 5 | 0–31 | none | none | post-transformation logical-left-shift amount | Encoded zero performs no shift. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | left Reg5 source |
| SrcR | right Reg5 source |
| SrcRType | right-source transformation selector |
| shamt | post-transformation logical-left-shift amount |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/OR.asl -->
```asl
readonly func InstructionContractOperation_OR()
    => ScalarOperation
begin
    return ScalarOperation_OR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/OR.asl -->
```asl
readonly func InstructionContractHandler_OR()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinary;
end;

pure func InstructionContractRightModifier_OR(encoded: bits(2))
    => ScalarRightModifier
begin
    case encoded of
        when '00' => return ScalarRight_SignedWord;
        when '01' => return ScalarRight_UnsignedWord;
        when '10' => return ScalarRight_NegateOrNot;
        when '11' => return ScalarRight_None;
    end;
end;

pure func InstructionContractPreparedRight_OR(
    right: Word,
    encoded_modifier: bits(2),
    shift_amount: integer {0..31})
    => Word
begin
    let modifier = InstructionContractRightModifier_OR(encoded_modifier);
    let transformed = ApplyScalarRightModifier(right, modifier, TRUE);
    let shifted = LSL(transformed, shift_amount);
    return shifted;
end;

pure func InstructionContractResult_OR(
    left: Word,
    right: Word,
    encoded_modifier: bits(2),
    shift_amount: integer {0..31})
    => Word
begin
    let prepared_right = InstructionContractPreparedRight_OR(
        right,
        encoded_modifier,
        shift_amount);
    return ScalarBinary(ScalarBinary_OR, left, prepared_right);
end;

pure func InstructionContractIsLogicalFamily_OR()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractIsWordOperation_OR()
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
- All four SrcRType encodings are assigned. The logical family uses .not while the arithmetic family uses .neg; OR uses .not.
- Every five-bit shamt value from 0 through 31 is legal.

## State effects

- Transform SrcR, perform the logical left shift, and compute the bitwise inclusive OR with SrcL at PTO_XLEN width modulo 2^PTO_XLEN.
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

- OR raises no arithmetic exception; transformation, shifting, and the final operation use PTO_XLEN bits modulo 2^PTO_XLEN.
- A fixed-bit mismatch or unavailable selected T/U source raises Fault_IllegalInstruction before the destination effect and before TPC advances.

## Examples

- or a0, a1, ->a2
- or t#1, u#1.not<<1, ->u
- or zero, a0.sw, ->zero
