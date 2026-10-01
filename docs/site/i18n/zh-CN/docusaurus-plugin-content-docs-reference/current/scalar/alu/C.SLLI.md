<!-- GENERATED FROM: asl/scalar/alu/C.SLLI.asl -->
# C.SLLI

**Normative ASL source:** `asl/scalar/alu/C.SLLI.asl`

C.SLLI snapshots the pre-instruction T#1 value, logically shifts it left by uimm5, and pushes the XLEN result to T.

## Normative identity {#PTO-INST-SCALAR-C-SLLI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-c-slli-purpose role=purpose -->
## C.SLLI 的作用

`C.SLLI` 把当前的 `T#1` 值逻辑左移一个编码给出的量，并把结果作为最新的临时值压入 `T`。

设计要点：两个操作数都没有编码。源固定为 `T#1`，目标固定为 `T`，因此这个 16 位形式的五位有效载荷可以全部用于移位量。这正是两字节移位指令得以存在的原因。

<!-- PTO-READER-BLOCK: scalar-c-slli-mechanism role=mechanism -->
## 结果形成方式

- `uimm5` 被零扩展，并作为 `0` 至 `31` 的逻辑左移量使用。
- 被移位的操作数是指令执行前的 `T#1` 值。移出位 `63` 的位被丢弃，空出的低位为零。

移位后的值作为最新的 `T` 项压入。

设计要点：读取发生在压入之前，因此该指令不可能移位自己的结果。`c.slli t#1, 1, ->t` 把原 `T#1` 翻倍，并把原件移到 `T#2`。

设计要点：编码量为 `0` 时会把不变的值作为新项重新发布。它是真实的零位移而不是无操作，因此仍然产生一个新的 `T` 项，也仍然让 `TPC` 前进。

<!-- PTO-READER-BLOCK: scalar-c-slli-inputs role=inputs-outputs -->
## 输入与目标

- `uimm5` 是唯一编码操作数：`0` 至 `31` 的无符号移位量。
- 源隐含为 `T#1`，目标隐含为 `T`，因此每次成功执行恰好压入一个 XLEN 结果。

设计要点：固定的 `T#1` 源必须已经持有值。该要求先于移位被检查，因此在 `T` 队列为空时执行 `C.SLLI` 会触发故障，而不是移位陈旧的位。

设计要点：读取不会消费源；只有压入会改变队列，把原 `T#1` 移到 `T#2`，并丢弃原 `T#4`。

<!-- PTO-READER-BLOCK: scalar-c-slli-effects role=effects -->
## 效果与顺序

`T#1` 在压入之前读取，因此被移位的是指令执行前的 `T#1`。

压入之后，`TPC` 前进 `2` 字节。GPR、`U` 项、内存、保留状态、描述符、数值状态、指令束、特权、谓词和控制流状态都不改变。

<!-- PTO-READER-BLOCK: scalar-c-slli-constraints role=constraints -->
## 合法性与故障边界

`0` 至 `31` 的每个 `uimm5` 取值都已分配，因此 `C.SLLI` 没有保留的移位量。

若 `T#1` 不可用，会在压入之前、`TPC` 前进之前以及任何其他效果之前引发 `Fault_IllegalInstruction`。无法译码的 16 位形式在 `PC` 处引发 `Fault_IllegalInstruction`，不适用于当前指令束的指令在 `TPC` 处引发 `Fault_BundleControl`。

设计要点：对编码范围内的任何移位量，逻辑移位都是全域定义的，因此 `C.SLLI` 没有依赖取值的故障。移出寄存器顶端的位只是被丢弃；没有任何机制记录它们。

<!-- PTO-READER-BLOCK: scalar-c-slli-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

当 `T#1` 保存 `3`、`uimm5=2` 时，`c.slli t#1, 2, ->t` 把 `12` 压入 `T#1`，并把旧值 `3` 移到 `T#2`。当 `T#1` 保存 `1`、`uimm5=31` 时，压入值为 `2147483648`。当 `uimm5=0` 时，压入值就是不变的原 `T#1`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
c.slli t#1, uimm, ->t
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| c_slli_16_958a14dc4058 | C16 | 16 | 0x102c / 0xf83f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| c_slli_16_958a14dc4058 | uimm5 | 5 | unsigned | [{"instruction_lsb":6,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| c_slli_16_958a14dc4058 | uimm5 | 5 | 0–31 | none | none | unsigned five-bit logical left-shift amount | Encoded zero republishes the unchanged pre-instruction T#1 value. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| uimm5 | unsigned five-bit logical left-shift amount |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/C.SLLI.asl -->
```asl
readonly func InstructionContractOperation_C_SLLI() => ScalarOperation
begin
    return ScalarOperation_C_SLLI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/C.SLLI.asl -->
```asl
readonly func InstructionContractHandler_C_SLLI() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinary;
end;

pure func InstructionContractResult_C_SLLI(
    old_t1: Word,
    encoded_amount: bits(5))
    => Word
begin
    return ScalarBinary(
        ScalarBinary_SLL,
        old_t1,
        ZeroExtend{PTO_XLEN}(encoded_amount));
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- T#1 is the fixed source and T is the fixed destination; neither is encoded or omittable in canonical assembly.
- uimm5 is required and directly encodes a shift amount from 0 through 31.

## Legality

- Every uimm5 value 0..31 is assigned. Fixed encoding bits must match the canonical form.
- The fixed T#1 source must be initialized before execution.

## State effects

- Logically shift the complete XLEN old T#1 value left by UInt(uimm5); shifted-out bits are discarded and vacated bits are zero-filled.
- Push exactly one XLEN result to T. Existing T entries shift toward older indices and the former T#4 is discarded.
- No GPR, U queue, memory, reservation, descriptor, numeric-status, block, privilege, predicate, or other control state changes. Successful execution advances TPC by two bytes.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot old T#1 before the destination push, so the instruction cannot read its own result.
- Push the shifted result as the newest T entry, then advance TPC by two bytes.

## Exceptions

- The logical shift is total and raises no arithmetic exception.
- If T#1 is unavailable, Fault_IllegalInstruction is raised before the T push, before TPC advances, and before any other effect.

## Examples

- c.slli t#1, 31, ->t
