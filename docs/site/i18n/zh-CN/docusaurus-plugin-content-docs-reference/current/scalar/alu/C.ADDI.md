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

`C.ADDI` 是一条 16 位标量 ALU 指令。它按照完整 XLEN 值结果规则执行加法；当前指令契约定义结果发布路径以及任何额外状态效果。

<!-- PTO-READER-BLOCK: scalar-c-addi-mechanism role=mechanism -->
## 结果形成方式

执行时先对编码输入做快照，然后按照完整 XLEN 值结果规则执行加法，最后才产生目标效果。

- 立即数宽度与扩展规则由下方编码字段确定；除非生成契约给出其他零值含义，编码零提供数值零。
- 结果发布使用当前指令契约为该助记符确定的位宽与扩展规则。

<!-- PTO-READER-BLOCK: scalar-c-addi-inputs role=inputs-outputs -->
## 输入与目标

- `SrcL` 是 5 位字段，通过 Reg5 选择一个加数。
- `simm5` 是 5 位有符号字段，携带有符号五位加数。

这些角色来自当前指令契约；T/U 源只被读取和快照，不会因源选择而出队。编码零的精确含义列在下方生成的默认值章节中。

<!-- PTO-READER-BLOCK: scalar-c-addi-effects role=effects -->
## 效果与顺序

所有标量源都在发布前完成快照；指令完成时恰好向 T 推入一个结果。

该 ALU 操作不产生内存效果。成功完成架构效果后，`TPC` 前进 2 字节。

该操作不会产生隐藏的标量发布目标或隐式内存访问。架构变化仅限于当前契约列出的状态效果。

<!-- PTO-READER-BLOCK: scalar-c-addi-constraints role=constraints -->
## 合法性与故障边界

固定宽度算术按当前操作规则回绕，不产生算术异常；固定编码位不匹配或所选 T/U 源不可用时，会在结果发布和 `TPC` 前进之前触发 `Fault_IllegalInstruction`。

下方生成的合法性表是已分配字段值、保留编码和目标丢弃编码的权威说明。解码与源可用性检查先于架构效果完成。

<!-- PTO-READER-BLOCK: scalar-c-addi-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

以一个小型 `C.ADDI` 示例说明：`SrcL=7` 与 `simm5=3` 产生 `10`。
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
