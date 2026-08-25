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

`C.ADD` 是一条紧凑的 16 位标量指令。它把两个完整 XLEN Reg5 源按 `2^PTO_XLEN` 取模相加，并且始终向 T 队列压入一个结果。

<!-- PTO-READER-BLOCK: scalar-c-add-mechanism role=mechanism -->
## 执行机制

指令先对 `SrcL` 和 `SrcR` 取快照，再对两个保存值执行定宽加法，并把回绕后的结果发布为最新的 T 项。

目的位置是隐含的，并不占用编码字段：每次成功执行的 `C.ADD` 都恰好向 T 压入一个值。

<!-- PTO-READER-BLOCK: scalar-c-add-inputs role=inputs-outputs -->
## 输入与输出

- 每个源都使用完整 Reg5 域：`0..23` 选择 GPR，`24..27` 选择 `T#1..T#4`，`28..31` 选择 `U#1..U#4`。
- 两个编码源字段都不可省略。源编码 `0` 读取架构零 GPR。

重复源、绝对源与相对源的组合以及两个相对源的组合均合法；读取临时源不会消费该项。

<!-- PTO-READER-BLOCK: scalar-c-add-effects role=effects -->
## 效果与顺序

源快照先于隐含的 T 压入，因此先读 T 再压入 T 时，读取的是指令执行前的队列内容。

新结果成为 `T#1`，原有 T 项向 `T#4` 方向移动，原来的 `T#4` 被丢弃。U 队列保持不变，读取源本身不会消费队列项。

成功执行后 `TPC` 前进 `2` 字节；GPR、内存、保留状态、描述符、数值状态、指令束、特权、谓词和其他控制状态均不改变。

<!-- PTO-READER-BLOCK: scalar-c-add-constraints role=constraints -->
## 故障边界

加法本身是全定义且不触发陷阱的。选中的 T/U 源尚不可用时，会在 T 压入、`TPC` 前进和任何无关状态变化之前引发 `Fault_IllegalInstruction`。

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
