<!-- GENERATED FROM: asl/scalar/alu/C.AND.asl -->
# C.AND

**Normative ASL source:** `asl/scalar/alu/C.AND.asl`

C.AND snapshots two complete Reg5 sources, computes the bitwise conjunction of SrcL and SrcR, and pushes the wrapping XLEN result to T.

## Normative identity {#PTO-INST-SCALAR-C-AND}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-c-and-purpose role=purpose -->
## C.AND 的作用

`C.AND` 读取两个 Reg5 源，在全部 `PTO_XLEN` 位上计算逐位合取，并把结果作为最新的临时值压入 `T`。

设计要点：压缩逻辑形式从 opcode 取得运算，从 16 位编码仅有的两个字段取得两个操作数。没有修饰符字段，因此 `C.AND` 总是使用完整的源值；带变换的形式属于 32 位的 `AND` 族。

<!-- PTO-READER-BLOCK: scalar-c-and-mechanism role=mechanism -->
## 结果形成方式

两个源编码都被解析，并按 `64` 个位位置独立计算合取。结果作为最新的 `T` 项压入。

设计要点：压入会移动整个队列而不是覆盖某个槽位，因此新值成为 `T#1`，原 `T#1` 成为 `T#2`，原 `T#4` 被丢弃。一个临时值能存活四次压入。

设计要点：相对于源而言，合取只能清位，因此结果中被置起的每一位在两个源中都被置起。这样构造出的掩码不可能获得两个输入都不曾拥有的位。

<!-- PTO-READER-BLOCK: scalar-c-and-inputs role=inputs-outputs -->
## 输入与目标

- `SrcL` 和 `SrcR` 是 Reg5 源：编码 `0..23` 选择绝对 GPR，`24..27` 选择 `T#1..T#4`，`28..31` 选择 `U#1..U#4`，且不消费队列项。
- 目标固定为 `T`：每次成功执行恰好压入一个 XLEN 结果。

设计要点：重复和混合的源组合都合法，因此 `c.and t#1, u#1, ->t` 与 `c.and t#1, t#1, ->t` 都能编码。由于两个源都在压入之前读取，后一种形式压入的是原 `T#1` 值与自身的合取。

设计要点：任一源的编码零读取架构零 GPR，因此 `c.and a0, zero, ->t` 压入 `0`，而 `c.and zero, zero, ->t` 是压入常数零。

<!-- PTO-READER-BLOCK: scalar-c-and-effects role=effects -->
## 效果与顺序

两个源在 `T` 压入之前完成快照，因此源与队列之间的重名观察到的是指令执行前的状态。

压入之后，`TPC` 前进 `2` 字节。GPR、`U` 项、内存、保留状态、描述符、数值状态、指令束、特权、谓词和控制流状态都不改变，也不消费任何源队列项。

<!-- PTO-READER-BLOCK: scalar-c-and-constraints role=constraints -->
## 合法性与故障边界

每个编码源取值都已分配，因此 `C.AND` 没有保留的源编码，也没有非法的操作数组合。

所选 `T` 或 `U` 源不可用会在压入之前、`TPC` 前进之前以及任何其他效果之前引发 `Fault_IllegalInstruction`。无法译码的 16 位形式在 `PC` 处引发 `Fault_IllegalInstruction`，不适用于当前指令束的指令在 `TPC` 处引发 `Fault_BundleControl`。

设计要点：按位合取不产生任何信号，也不会溢出，因此 `C.AND` 没有依赖取值的故障，也没有状态标志。被掩码移除的位只是不出现在压入值中。

<!-- PTO-READER-BLOCK: scalar-c-and-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

当 `T#1` 保存 `12`、`U#1` 保存 `10` 时，`c.and t#1, u#1, ->t` 把 `12 AND 10 = 8` 压入 `T#1`，把旧值 `12` 移到 `T#2`，并保持 `U#1` 为 `10`。当 `SrcR` 指向架构零 GPR 时，无论 `SrcL` 是什么，压入值都是 `0`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
c.and srcL, srcR, ->t
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| c_and_16_379e5bed3352 | C16 | 16 | 0x0028 / 0x003f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| c_and_16_379e5bed3352 | SrcL | 5 | encoding-defined | [{"instruction_lsb":6,"value_lsb":0,"width":5}] |
| c_and_16_379e5bed3352 | SrcR | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| c_and_16_379e5bed3352 | SrcL | 5 | 0–31 | none | none | left Reg5 source | Encoded zero reads the architectural zero GPR. |
| c_and_16_379e5bed3352 | SrcR | 5 | 0–31 | none | none | right Reg5 source | Encoded zero reads the architectural zero GPR. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | left Reg5 source |
| SrcR | right Reg5 source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/C.AND.asl -->
```asl
readonly func InstructionContractOperation_C_AND() => ScalarOperation
begin
    return ScalarOperation_C_AND;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/C.AND.asl -->
```asl
readonly func InstructionContractHandler_C_AND() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinary;
end;

pure func InstructionContractResult_C_AND(
    left: Word,
    right: Word)
    => Word
begin
    return ScalarBinary(
        ScalarBinary_AND,
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

- Compute bitwise AND on the two complete XLEN source values.
- Push exactly one XLEN result to T. Existing T entries shift toward older indices, the former T#4 is discarded, and no source is consumed.
- No GPR, U queue, memory, reservation, descriptor, numeric-status, block, privilege, predicate, or other control state changes. Successful execution advances TPC by two bytes.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot both sources before pushing the destination so aliases observe the pre-instruction queue state.
- Push the result as the newest T entry, then advance TPC by two bytes.

## Exceptions

- Bitwise and is a total fixed-width operation and raises no arithmetic exception.
- An unavailable selected T/U source raises Fault_IllegalInstruction before the T push, before TPC advances, and before any other effect.

## Examples

- c.and t#1, u#1, ->t
