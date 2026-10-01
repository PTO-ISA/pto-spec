<!-- GENERATED FROM: asl/scalar/alu/C.ADDI.asl -->
# C.ADDI

**Normative ASL source:** `asl/scalar/alu/C.ADDI.asl`

C.ADDI snapshots one complete Reg5 source, sign-extends simm5, adds modulo 2^XLEN, and pushes the result to T.

## Normative identity {#PTO-INST-SCALAR-C-ADDI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-c-addi-purpose role=purpose -->
## C.ADDI 的作用

`C.ADDI` 把一个符号扩展的 5 位立即数加到一个 Reg5 源上，并把 XLEN 和压入 `T`。

设计要点：这里的立即数是有符号且窄的，而 32 位的 `ADDI` 把十二位用于无符号值。压缩形式只有五位立即数的空间，符号扩展让这五位既能表示小的正增量，也能表示小的负增量。

<!-- PTO-READER-BLOCK: scalar-c-addi-mechanism role=mechanism -->
## 结果形成方式

`simm5` 被符号扩展到 `PTO_XLEN`，得到 `-16` 至 `15` 的加数，再按 `2^PTO_XLEN` 取模加到快照的源上。和被作为最新的 `T` 项压入。

设计要点：符号扩展发生在加法之前，因此 `c.addi a0, -1, ->t` 是减一。这个压缩指令族中没有减法助记符；编码用负立即数来表达它。

设计要点：编码零是数值零而非省略，因此 `c.addi a0, 0, ->t` 是把不变的源作为新的 `T` 项重新发布，而不是什么都不做。

定宽加法是全域定义的：它会回绕，不会引发算术异常。

<!-- PTO-READER-BLOCK: scalar-c-addi-inputs role=inputs-outputs -->
## 输入与目标

- `SrcL` 是 Reg5 源：编码 `0..23` 选择绝对 GPR，`24..27` 选择 `T#1..T#4`，`28..31` 选择 `U#1..U#4`，且不消费队列项。
- `simm5` 是有符号 5 位加数。
- 目标固定为 `T`：每次成功执行恰好压入一个 XLEN 结果。

设计要点：`SrcL` 的编码零读取架构零 GPR，因此 `c.addi zero, 5, ->t` 是纯粹压入常数、不依赖任何寄存器。

<!-- PTO-READER-BLOCK: scalar-c-addi-effects role=effects -->
## 效果与顺序

`SrcL` 和立即数在 `T` 压入之前解析，因此源不可能观察到该指令即将压入的值。压入会移动队列：新值成为 `T#1`，原 `T#4` 被丢弃。

压入之后，`TPC` 前进 `2` 字节。GPR、`U` 项、内存、保留状态、描述符、数值状态、指令束、特权、谓词和控制流状态都不改变。

<!-- PTO-READER-BLOCK: scalar-c-addi-constraints role=constraints -->
## 合法性与故障边界

每个编码取值都已分配：全部 `32` 个 `SrcL` 编码以及 `-16` 至 `15` 的每个 `simm5` 取值。没有非法立即数。

所选 `T` 或 `U` 源不可用会在压入之前、`TPC` 前进之前以及任何其他效果之前引发 `Fault_IllegalInstruction`。无法译码的 16 位形式在 `PC` 处引发 `Fault_IllegalInstruction`，不适用于当前指令束的指令在 `TPC` 处引发 `Fault_BundleControl`。

设计要点：由于立即数有符号且取值全部已分配，调用者永远不需要第二个助记符来减去一个小常数，`C.ADDI` 也没有任何编码被保留给未来的减法形式。

<!-- PTO-READER-BLOCK: scalar-c-addi-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

当 `T#1` 保存 `5`、`simm5=-2` 时，`c.addi t#1, -2, ->t` 把 `3` 压入 `T#1`，并把旧值 `5` 移到 `T#2`。当 `SrcL` 指向架构零 GPR、`simm5=15` 时，压入值为 `15`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
c.addi srcL, simm, ->t
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| c_addi_16_3050744f2322 | C16 | 16 | 0x000c / 0x003f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| c_addi_16_3050744f2322 | SrcL | 5 | encoding-defined | [{"instruction_lsb":6,"value_lsb":0,"width":5}] |
| c_addi_16_3050744f2322 | simm5 | 5 | signed | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| c_addi_16_3050744f2322 | SrcL | 5 | 0–31 | none | none | Reg5 addend | Encoded zero reads the architectural zero GPR. |
| c_addi_16_3050744f2322 | simm5 | 5 | 0–31 | none | none | signed five-bit addend | Encoded zero supplies numeric zero. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 addend |
| simm5 | signed five-bit addend |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/C.ADDI.asl -->
```asl
readonly func InstructionContractOperation_C_ADDI() => ScalarOperation
begin
    return ScalarOperation_C_ADDI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/C.ADDI.asl -->
```asl
readonly func InstructionContractHandler_C_ADDI() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinary;
end;

pure func InstructionContractResult_C_ADDI(
    left: Word,
    encoded_immediate: bits(5))
    => Word
begin
    let immediate = SignExtend{PTO_XLEN}(encoded_immediate);
    return ScalarBinary(
        ScalarBinary_ADD,
        left,
        immediate);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL and signed simm5 are required encoded fields; neither can be omitted.
- The destination is not encoded: every successful form pushes exactly one result to T.

## Legality

- SrcL codes 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consumption.
- Every simm5 encoding is assigned and denotes a signed integer from -16 through +15.

## State effects

- Sign-extend simm5 to XLEN and add it to SrcL modulo 2^PTO_XLEN.
- Push exactly one XLEN result to T without consuming the source. Existing T entries shift toward older indices.
- No GPR, U queue, memory, reservation, descriptor, numeric-status, block, privilege, predicate, or other control state changes. Successful execution advances TPC by two bytes.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot SrcL and sign-extend simm5 before pushing the destination.
- Push the result as the newest T entry, then advance TPC by two bytes.

## Exceptions

- Fixed-width addition is total and raises no arithmetic exception.
- An unavailable selected T/U source raises Fault_IllegalInstruction before the T push, before TPC advances, and before any other effect.

## Examples

- c.addi t#1, -1, ->t
