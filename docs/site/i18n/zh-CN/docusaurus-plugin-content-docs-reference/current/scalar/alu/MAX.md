<!-- GENERATED FROM: asl/scalar/alu/MAX.asl -->
# MAX

**Normative ASL source:** `asl/scalar/alu/MAX.asl`

MAX performs a signed full-XLEN comparison and publishes the complete bit pattern of the maximum operand.

## Normative identity {#PTO-INST-SCALAR-MAX}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-max-purpose role=purpose -->
## MAX 的作用

`MAX` 是一条 32 位编码的标量 ALU 指令，它把两个 XLEN 值按有符号整数比较，并通过一个 Reg5 目标原样发布其中较大的那个。

发布字是两个操作数位模式之一，而不是新算出的值。两个源都以完整 XLEN 宽度比较，因此 `L32` 类描述的是指令长度，而不是操作数宽度。

<!-- PTO-READER-BLOCK: scalar-max-mechanism role=mechanism -->
## 结果形成方式

所属 ASL 提供 `InstructionContractResult_MAX`：当 `SInt(left) > SInt(right)` 时返回 `left`，否则返回 `right`；并提供返回真的 `InstructionContractUsesSignedComparison_MAX`。分派路径通过 `ExecuteDecodedSimpleBinary(instruction, form, ScalarBinary_MAX, FALSE)` 到达同一个辅助函数，它读取 `SrcL` 与 `SrcR` 并写入被选中的操作数。

```asm
max SrcL, SrcR, ->{t, u, Rd}
```

设计要点：比较是严格的，因此相等操作数落入 `right` 分支。这一选择不可见，因为比较相等的补码值具有完全相同的位模式；不存在需要另行定义的并列情形。

<!-- PTO-READER-BLOCK: scalar-max-inputs role=inputs-outputs -->
## 输入与目标

- `RegDst`，指令切片 `[7 +: 5]`，接收被选中的操作数，或丢弃它。
- `SrcL`，指令切片 `[15 +: 5]`，提供左操作数。
- `SrcR`，指令切片 `[20 +: 5]`，提供右操作数。

两个源都使用通用 Reg5 映射：`0..23` 读取绝对 GPR，`24..27` 读取 `T#1..T#4`，`28..31` 读取 `U#1..U#4` 且不消耗表项。任一源的编码零都读取体系结构零 GPR。

设计要点：该形式没有右源修饰，因此 `SrcR` 按读取到的原样参与比较。部分其他标量 ALU 形式（例如 `ADD`、`SUB`、`AND`、`OR` 与 `XOR`）带有 `SrcRType` 字段，可以在使用前对右源做符号扩展、零扩展或取反；`MAX` 没有这个字段，它比较完整的寄存器内容。

<!-- PTO-READER-BLOCK: scalar-max-effects role=effects -->
## 效果与顺序

两个源都在目标效果之前取快照，因此 `max a0, a0, ->a0` 以及与某个源同名的目标都作用于执行前的值。

被选中的操作数通过 `RegDst` 发布，随后 `TPC` 前进 `4` 字节。`MAX` 不读写内存，不设置数值标志，也不改变保留、描述符、指令束、特权与控制流状态；唯一可能的队列变化是由 `RegDst` 选择的 `T` 或 `U` 推送。

<!-- PTO-READER-BLOCK: scalar-max-constraints role=constraints -->
## 合法性与故障边界

每个 `32` 编码的源编码与每个 `32` 编码的目标编码都有定义，每个 XLEN 位模式都是合法操作数，因此只有临时源不可用会使操作数检查失败。指令第 `31:25` 位与 `14:12` 位由所接受的形式固定。

适用性只在系统块终止请求挂起时失败，并在 `TPC` 触发 `Fault_BundleControl`。否则，不匹配的编码在进入指令束主体之前于 `PC` 触发 `Fault_IllegalInstruction`，所选 `T` 或 `U` 源不可用时则在目标写入之前于 `PC` 触发 `Fault_IllegalInstruction`。比较本身不触发算术异常。

设计要点：在两个操作数之间做选择不可能溢出，因此没有操作数对会触发故障。两个寄存器的最大值在每个取值上都是精确的，包括有符号最小值与最大值，因为没有对它们做任何算术。

<!-- PTO-READER-BLOCK: scalar-max-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

取 `SrcL = 0xFFFFFFFFFFFFFFFF`、`SrcR = 0` 时，有符号读法让 `SrcL` 等于 `-1`，它不大于 `0`，因此 `RegDst` 收到 `SrcR`，即字 `0`。取 `SrcL = 5`、`SrcR = 5` 时比较为假，`RegDst` 收到 `5`。取 `SrcL = 4`、`SrcR = 7` 时 `RegDst` 收到 `7`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
max SrcL, SrcR, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| max_32_9166468a1db7 | L32 | 32 | 0x0000405b / 0xfe00707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| max_32_9166468a1db7 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| max_32_9166468a1db7 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| max_32_9166468a1db7 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| max_32_9166468a1db7 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| max_32_9166468a1db7 | SrcL | 5 | 0–31 | none | none | left Reg5 source | Encoded zero reads the architectural zero GPR. |
| max_32_9166468a1db7 | SrcR | 5 | 0–31 | none | none | right Reg5 source | Encoded zero reads the architectural zero GPR. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | left Reg5 source |
| SrcR | right Reg5 source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/MAX.asl -->
```asl
readonly func InstructionContractOperation_MAX()
    => ScalarOperation
begin
    return ScalarOperation_MAX;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/MAX.asl -->
```asl
readonly func InstructionContractHandler_MAX()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinary;
end;

pure func InstructionContractResult_MAX(left: Word, right: Word)
    => Word
begin
    if SInt(left) > SInt(right) then
        return left;
    else
        return right;
    end;
end;

pure func InstructionContractUsesSignedComparison_MAX()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL, SrcR, and RegDst are required fields; no field can be omitted.
- Encoded source zero reads the architectural zero GPR; encoded destination zero discards the result.

## Legality

- SrcL and SrcR codes 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consumption.
- RegDst codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write GPRs.
- The operands use a signed full-XLEN comparison; every XLEN bit pattern is legal.

## State effects

- Perform a signed full-XLEN comparison and return the complete bit pattern of the maximum operand; equal operands are observationally identical.
- Destination codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write GPRs; source queues are non-consuming.
- No memory, reservation, descriptor, numeric-flag, trap, block, privilege, or control-flow state changes except the successful TPC advance.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot both sources before the destination effect so repeated sources, destination aliases, and queue publication use pre-instruction values.
- Publish the selected operand, then advance TPC by four bytes.

## Exceptions

- MAX raises no arithmetic exception; comparison selects one unchanged operand bit pattern.
- Bits 31:25 are fixed by the accepted form. A mismatch or unavailable T/U source raises Fault_IllegalInstruction before the destination effect and TPC advance.

## Examples

- max a0, a1, ->a2
- max t#1, u#1, ->u
- max zero, zero, ->zero
