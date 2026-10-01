<!-- GENERATED FROM: asl/scalar/alu/C.SUB.asl -->
# C.SUB

**Normative ASL source:** `asl/scalar/alu/C.SUB.asl`

C.SUB snapshots two complete Reg5 sources, subtracts SrcR from SrcL modulo 2^XLEN, and pushes the result to T.

## Normative identity {#PTO-INST-SCALAR-C-SUB}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-c-sub-purpose role=purpose -->
## C.SUB 的作用

`C.SUB` 读取两个 Reg5 源，计算 `SrcL` 减 `SrcR`（按 `2^PTO_XLEN` 取模），并把 XLEN 差值压入 `T`。

设计要点：十六个编码位中有十位是两个 5 位源选择器，没有任何位是目标选择器，因此两个操作数都可以变化，而结果总是落在最新的 `T` 项中。压缩减法无法直接写 GPR。

<!-- PTO-READER-BLOCK: scalar-c-sub-mechanism role=mechanism -->
## 结果形成方式

两个源先被快照，然后用按 `2^PTO_XLEN` 取模的定宽算术相减。负差值以补码位型发布。

设计要点：由于发布的是完整的 XLEN 补码数值，`c.sub zero, a0, ->t` 发布的是 `0 - a0`。该助记符不需要第二种操作数形式来表达取负。

设计要点：减法是带顺序的，因此两个选择器字段不可互换：`c.sub a0, a1, ->t` 与 `c.sub a1, a0, ->t` 压入不同的值。两种编码都合法，且两个源都在压入之前读取。

<!-- PTO-READER-BLOCK: scalar-c-sub-inputs role=inputs-outputs -->
## 输入与目标

- `SrcL` 是左 Reg5 源，`SrcR` 是右 Reg5 源：编码 `0..23` 选择绝对 GPR，`24..27` 选择 `T#1..T#4`，`28..31` 选择 `U#1..U#4`，且不消费队列项。
- 目标固定为 `T`：每次成功执行恰好一个 XLEN 结果。

设计要点：任一源的零编码都读取架构零 GPR，因此 `c.sub a0, zero, ->t` 重新发布 `a0`，`c.sub zero, zero, ->t` 压入 `0`，都不依赖真实寄存器内容。重复和混合选择器都合法，所以 `c.sub t#1, u#1, ->t` 是有效编码。

<!-- PTO-READER-BLOCK: scalar-c-sub-effects role=effects -->
## 效果与顺序

`SrcL` 和 `SrcR` 在目标压入之前快照，因此该指令不可能减去自己的结果，目标别名也不会干扰操作数。压入把队列向更旧的索引方向移动，新值成为 `T#1`。

压入之后，`TPC` 前进 `2` 字节。不会写任何 GPR，`U` 项、内存、保留状态、描述符、数值状态、指令束、特权、谓词和其他控制状态都不改变。

<!-- PTO-READER-BLOCK: scalar-c-sub-constraints role=constraints -->
## 合法性与故障边界

`0` 至 `31` 的每个 `SrcL` 和 `SrcR` 编码都已分配，因此没有保留的源选择器，六个固定编码位必须匹配规范形式。定宽减法是全域定义的，包括下溢在内都不会引发算术异常。

所选 `T` 或 `U` 源不可用会在 `T` 压入之前、`TPC` 前进之前以及任何其他效果之前引发 `Fault_IllegalInstruction`。无法译码的 16 位形式在 `PC` 处引发 `Fault_IllegalInstruction`，不适用于当前指令束的指令在 `TPC` 处引发 `Fault_BundleControl`。

设计要点：源可用性由两个编码选择器在减法发生之前判定。因此指定了空队列槽的 `c.sub` 会引发故障，而不是发布一个由队列并不持有的值算出的差值。

<!-- PTO-READER-BLOCK: scalar-c-sub-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

当 `a0` 保存 `10`、`T#1` 保存 `7` 时，`c.sub a0, t#1, ->t` 压入 `3`，并把旧的 `7` 移到 `T#2`；源队列不变。当 `a0` 保存 `0`、`a1` 保存 `1` 时，`c.sub a0, a1, ->t` 压入 `2^PTO_XLEN - 1`，按补码读作 `-1`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
c.sub srcL, srcR, ->t
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| c_sub_16_ff0056ac7053 | C16 | 16 | 0x0018 / 0x003f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| c_sub_16_ff0056ac7053 | SrcL | 5 | encoding-defined | [{"instruction_lsb":6,"value_lsb":0,"width":5}] |
| c_sub_16_ff0056ac7053 | SrcR | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| c_sub_16_ff0056ac7053 | SrcL | 5 | 0–31 | none | none | left Reg5 source | Encoded zero reads the architectural zero GPR. |
| c_sub_16_ff0056ac7053 | SrcR | 5 | 0–31 | none | none | right Reg5 source | Encoded zero reads the architectural zero GPR. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | left Reg5 source |
| SrcR | right Reg5 source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/C.SUB.asl -->
```asl
readonly func InstructionContractOperation_C_SUB() => ScalarOperation
begin
    return ScalarOperation_C_SUB;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/C.SUB.asl -->
```asl
readonly func InstructionContractHandler_C_SUB() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinary;
end;

pure func InstructionContractResult_C_SUB(
    left: Word,
    right: Word)
    => Word
begin
    return ScalarBinary(
        ScalarBinary_SUB,
        left,
        right);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL and SrcR are required encoded fields; neither source can be omitted.
- The destination is not encoded: every successful form pushes exactly one result to T.

## Legality

- Each source code 0..23 selects an absolute GPR, 24..27 selects T#1..T#4, and 28..31 selects U#1..U#4 without consumption.
- Duplicate, absolute-relative, and relative-relative source pairs are legal. Every encoded source value is assigned.

## State effects

- Compute SrcL minus SrcR modulo 2^PTO_XLEN; underflow wraps.
- Push exactly one XLEN result to T. Existing T entries shift toward older indices, the former T#4 is discarded, and no source is consumed.
- No GPR, U queue, memory, reservation, descriptor, numeric-status, block, privilege, predicate, or other control state changes. Successful execution advances TPC by two bytes.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot both sources before pushing the destination so aliases observe the pre-instruction queue state.
- Push the result as the newest T entry, then advance TPC by two bytes.

## Exceptions

- Ordered subtraction is a total fixed-width operation and raises no arithmetic exception.
- An unavailable selected T/U source raises Fault_IllegalInstruction before the T push, before TPC advances, and before any other effect.

## Examples

- c.sub t#1, u#1, ->t
