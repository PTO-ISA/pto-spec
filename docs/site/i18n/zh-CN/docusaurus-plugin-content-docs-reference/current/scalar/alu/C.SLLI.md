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

`C.SLLI` 是一条 16 位标量 ALU 指令。它按照完整 XLEN 值移位规则对源值执行逻辑左移；当前指令契约定义结果发布路径以及任何额外状态效果。

<!-- PTO-READER-BLOCK: scalar-c-slli-mechanism role=mechanism -->
## 结果形成方式

执行时先对编码输入做快照，然后按照完整 XLEN 值移位规则对源值执行逻辑左移，最后才产生目标效果。

- 立即数宽度与扩展规则由下方编码字段确定；除非生成契约给出其他零值含义，编码零提供数值零。
- 结果发布使用当前指令契约为该助记符确定的位宽与扩展规则。

<!-- PTO-READER-BLOCK: scalar-c-slli-inputs role=inputs-outputs -->
## 输入与目标

- `uimm5` 是 5 位无符号字段，携带无符号五位逻辑左移量。

这些角色来自当前指令契约；T/U 源只被读取和快照，不会因源选择而出队。编码零的精确含义列在下方生成的默认值章节中。

<!-- PTO-READER-BLOCK: scalar-c-slli-effects role=effects -->
## 效果与顺序

所有标量源都在发布前完成快照；指令完成时恰好向 T 推入一个结果。

该 ALU 操作不产生内存效果。成功完成架构效果后，`TPC` 前进 2 字节。

该操作不会产生隐藏的标量发布目标或隐式内存访问。架构变化仅限于当前契约列出的状态效果。

<!-- PTO-READER-BLOCK: scalar-c-slli-constraints role=constraints -->
## 合法性与故障边界

编码移位量的 6 位全部已分配，范围为 `0..63`；该移位按固定位宽获得总定义，不产生算术异常。

下方生成的合法性表是已分配字段值、保留编码和目标丢弃编码的权威说明。解码与源可用性检查先于架构效果完成。

<!-- PTO-READER-BLOCK: scalar-c-slli-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

以一个小型 `C.SLLI` 示例说明：源值 `1` 左移 `3` 位后得到 `8`。
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
