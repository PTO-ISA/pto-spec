<!-- GENERATED FROM: asl/scalar/alu/C.OR.asl -->
# C.OR

**Normative ASL source:** `asl/scalar/alu/C.OR.asl`

C.OR snapshots two complete Reg5 sources, computes the bitwise inclusive OR of SrcL and SrcR, and pushes the wrapping XLEN result to T.

## Normative identity {#PTO-INST-SCALAR-C-OR}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-c-or-purpose role=purpose -->
## C.OR 的作用

`C.OR` 读取两个 Reg5 源，在全部 `PTO_XLEN` 位上计算按位或，并把结果作为最新的临时值压入 `T`。

设计要点：`C.OR` 是同样压缩形状中与 `C.AND` 对应的置位操作。两者都从 opcode 取得运算、从仅有的两个字段取得两个操作数，因此都不能变换源；带变换的形式属于 32 位的 `OR` 族。

<!-- PTO-READER-BLOCK: scalar-c-or-mechanism role=mechanism -->
## 结果形成方式

两个源编码都被解析，按 `64` 个位位置计算按位或，结果作为最新的 `T` 项压入。

设计要点：压入会移动整个队列而不是覆盖某个槽位，因此新值成为 `T#1`，原 `T#1` 成为 `T#2`，原 `T#4` 被丢弃。

设计要点：相对于源而言，按位或只能置位，因此结果中为零的位在两个源中也都为零。用 `C.OR` 合并字段永远不会清掉任一输入已经置起的位。

设计要点：由于两个源都在压入之前读取，`c.or t#1, t#1, ->t` 会把原 `T#1` 的副本作为新项压入，并把原件移到 `T#2`。队列增加了一个副本，而不是该指令读到自己的结果。

<!-- PTO-READER-BLOCK: scalar-c-or-inputs role=inputs-outputs -->
## 输入与目标

- `SrcL` 和 `SrcR` 是 Reg5 源：编码 `0..23` 选择绝对 GPR，`24..27` 选择 `T#1..T#4`，`28..31` 选择 `U#1..U#4`，且不消费队列项。
- 目标固定为 `T`：每次成功执行恰好压入一个 XLEN 结果。

设计要点：重复和混合的源组合都合法，且每个源编码都已分配。只有所选临时值不可用才会阻止压入。

设计要点：其中一个源的编码零读取架构零 GPR，因此 `c.or a0, zero, ->t` 压入 `a0` 的副本，`c.or zero, zero, ->t` 压入 `0`。与零做按位或就是压缩的拷贝操作。

<!-- PTO-READER-BLOCK: scalar-c-or-effects role=effects -->
## 效果与顺序

两个源在 `T` 压入之前完成快照，因此命名队列项的源看到的是指令执行前的队列。

压入之后，`TPC` 前进 `2` 字节。GPR、`U` 项、内存、保留状态、描述符、数值状态、指令束、特权、谓词和控制流状态都不改变，也不消费任何源队列项。

<!-- PTO-READER-BLOCK: scalar-c-or-constraints role=constraints -->
## 合法性与故障边界

每个编码源取值都已分配，因此 `C.OR` 没有保留的源编码。

所选 `T` 或 `U` 源不可用会在压入之前、`TPC` 前进之前以及任何其他效果之前引发 `Fault_IllegalInstruction`。无法译码的 16 位形式在 `PC` 处引发 `Fault_IllegalInstruction`，不适用于当前指令束的指令在 `TPC` 处引发 `Fault_BundleControl`。

设计要点：按位或是全域定义的，因此 `C.OR` 没有依赖取值的故障，也没有状态标志。置起程序中另一部分拥有的位属于编程错误，而不是异常。

<!-- PTO-READER-BLOCK: scalar-c-or-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

当 `T#1` 保存 `12`、`U#1` 保存 `10` 时，`c.or t#1, u#1, ->t` 把 `12 OR 10 = 14` 压入 `T#1`，把旧值 `12` 移到 `T#2`，并保持 `U#1` 为 `10`。当 `SrcR` 指向架构零 GPR、`SrcL=15` 时，压入值为 `15`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
c.or srcL, srcR, ->t
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| c_or_16_90864d13a661 | C16 | 16 | 0x0038 / 0x003f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| c_or_16_90864d13a661 | SrcL | 5 | encoding-defined | [{"instruction_lsb":6,"value_lsb":0,"width":5}] |
| c_or_16_90864d13a661 | SrcR | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| c_or_16_90864d13a661 | SrcL | 5 | 0–31 | none | none | left Reg5 source | Encoded zero reads the architectural zero GPR. |
| c_or_16_90864d13a661 | SrcR | 5 | 0–31 | none | none | right Reg5 source | Encoded zero reads the architectural zero GPR. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | left Reg5 source |
| SrcR | right Reg5 source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/C.OR.asl -->
```asl
readonly func InstructionContractOperation_C_OR() => ScalarOperation
begin
    return ScalarOperation_C_OR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/C.OR.asl -->
```asl
readonly func InstructionContractHandler_C_OR() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinary;
end;

pure func InstructionContractResult_C_OR(
    left: Word,
    right: Word)
    => Word
begin
    return ScalarBinary(
        ScalarBinary_OR,
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

- Compute bitwise OR on the two complete XLEN source values.
- Push exactly one XLEN result to T. Existing T entries shift toward older indices, the former T#4 is discarded, and no source is consumed.
- No GPR, U queue, memory, reservation, descriptor, numeric-status, block, privilege, predicate, or other control state changes. Successful execution advances TPC by two bytes.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot both sources before pushing the destination so aliases observe the pre-instruction queue state.
- Push the result as the newest T entry, then advance TPC by two bytes.

## Exceptions

- Bitwise or is a total fixed-width operation and raises no arithmetic exception.
- An unavailable selected T/U source raises Fault_IllegalInstruction before the T push, before TPC advances, and before any other effect.

## Examples

- c.or t#1, u#1, ->t
