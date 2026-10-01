<!-- GENERATED FROM: asl/scalar/alu/C.ADD.asl -->
# C.ADD

**Normative ASL source:** `asl/scalar/alu/C.ADD.asl`

C.ADD snapshots two complete Reg5 sources, adds SrcL and SrcR, and pushes the wrapping XLEN result to T.

## Normative identity {#PTO-INST-SCALAR-C-ADD}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-c-add-purpose role=purpose -->
## C.ADD 的作用

`C.ADD` 读取两个 Reg5 源，按 `2^PTO_XLEN` 取模相加，并把 XLEN 结果作为最新的临时值压入 `T`。它是 `ADD` 带编码目标那次加法的 16 位形式。

设计要点：目标完全没有编码。16 位形式把有效载荷花在两个 5 位源选择符上，因此每次成功的 `C.ADD` 恰好压入一个 `T` 值。结果只有通过之后读取临时源的指令才能到达 GPR，例如 `c.movr t#1, ->a0`。

<!-- PTO-READER-BLOCK: scalar-c-add-mechanism role=mechanism -->
## 执行机制

两个源编码都被解析，两个完整的 XLEN 值按 `2^PTO_XLEN` 取模相加，并把回绕后的和作为最新的 `T` 项压入。

设计要点：压入会移动整个队列，而不是覆盖某个槽位。新值成为 `T#1`，原 `T#1` 成为 `T#2`，原 `T#4` 被丢弃，因此一个临时值恰好能存活四次压入。

设计要点：两个源都在压入之前读取，因此 `c.add t#1, t#1, ->t` 的结果是原 `T#1` 的两倍。该指令永远读不到它即将产生的值。

定宽加法是全域定义的：它会回绕，不会引发算术异常。

<!-- PTO-READER-BLOCK: scalar-c-add-inputs role=inputs-outputs -->
## 输入与输出

- `SrcL` 和 `SrcR` 是 Reg5 源：编码 `0..23` 选择绝对 GPR，`24..27` 选择 `T#1..T#4`，`28..31` 选择 `U#1..U#4`，且不消费队列项。
- 目标固定为 `T`：每次成功执行恰好压入一个 XLEN 结果。

设计要点：每个源编码都已分配，重复、绝对-相对以及相对-相对的源组合都合法。因此 `c.add t#1, u#1, ->t` 和 `c.add t#1, t#1, ->t` 都能正常编码；只有所选临时值不可用才会触发故障。

设计要点：`SrcL` 或 `SrcR` 的编码零读取架构零 GPR，因此 `c.add zero, zero, ->t` 压入 `0`，是压入显式零的压缩写法。

<!-- PTO-READER-BLOCK: scalar-c-add-effects role=effects -->
## 效果与顺序

两个源在 `T` 压入之前完成快照，因此源与队列之间的重名观察到的是指令执行前的队列状态。压入本身是唯一的状态变化：原 `T#4` 被丢弃，其余各项向更旧的方向移动一个下标。

压入之后，`TPC` 前进 `2` 字节。GPR、`U` 项、内存、保留状态、描述符、数值状态、指令束、特权、谓词和控制流状态都不改变。

<!-- PTO-READER-BLOCK: scalar-c-add-constraints role=constraints -->
## 故障边界

每个编码源取值都已分配，因此 `C.ADD` 没有保留的源编码。所选 `T` 或 `U` 源不可用会在压入之前、`TPC` 前进之前以及任何其他效果之前引发 `Fault_IllegalInstruction`。

无法译码的 16 位形式在 `PC` 处引发 `Fault_IllegalInstruction`，不适用于当前指令束的指令在 `TPC` 处引发 `Fault_BundleControl`。两者同样先于压入。

设计要点：加法本身从不触发故障，因此 `C.ADD` 的每个依赖取值的陷阱都来自源可用性，而不是来自操作数。回绕的值或者程序员看起来为负的值都是普通结果。

<!-- PTO-READER-BLOCK: scalar-c-add-example role=example -->
## 非规范演示

下面的演示只帮助理解当前所有者，并不是另一份指令定义。

若 `T#1` 保存 `5`、`U#1` 保存 `3`，则 `c.add t#1, u#1, ->t` 把 `8` 压入 `T#1`，把旧值 `5` 移到 `T#2`，保持 `U#1` 等于 `3`，并让 `TPC` 前进 `2` 字节。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
c.add srcL, srcR, ->t
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| c_add_16_85136d1e4904 | C16 | 16 | 0x0008 / 0x003f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| c_add_16_85136d1e4904 | SrcL | 5 | encoding-defined | [{"instruction_lsb":6,"value_lsb":0,"width":5}] |
| c_add_16_85136d1e4904 | SrcR | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| c_add_16_85136d1e4904 | SrcL | 5 | 0–31 | none | none | left Reg5 source | Encoded zero reads the architectural zero GPR. |
| c_add_16_85136d1e4904 | SrcR | 5 | 0–31 | none | none | right Reg5 source | Encoded zero reads the architectural zero GPR. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | left Reg5 source |
| SrcR | right Reg5 source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/C.ADD.asl -->
```asl
readonly func InstructionContractOperation_C_ADD() => ScalarOperation
begin
    return ScalarOperation_C_ADD;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/C.ADD.asl -->
```asl
readonly func InstructionContractHandler_C_ADD() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinary;
end;

pure func InstructionContractResult_C_ADD(
    left: Word,
    right: Word)
    => Word
begin
    return ScalarBinary(
        ScalarBinary_ADD,
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

- Compute addition on the two complete XLEN source values.
- Push exactly one XLEN result to T. Existing T entries shift toward older indices, the former T#4 is discarded, and no source is consumed.
- No GPR, U queue, memory, reservation, descriptor, numeric-status, block, privilege, predicate, or other control state changes. Successful execution advances TPC by two bytes.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot both sources before pushing the destination so aliases observe the pre-instruction queue state.
- Push the result as the newest T entry, then advance TPC by two bytes.

## Exceptions

- Addition is a total fixed-width operation and raises no arithmetic exception.
- An unavailable selected T/U source raises Fault_IllegalInstruction before the T push, before TPC advances, and before any other effect.

## Examples

- c.add t#1, u#1, ->t
