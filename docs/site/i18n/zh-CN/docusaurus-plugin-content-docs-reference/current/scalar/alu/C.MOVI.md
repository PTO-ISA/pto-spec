<!-- GENERATED FROM: asl/scalar/alu/C.MOVI.asl -->
# C.MOVI

**Normative ASL source:** `asl/scalar/alu/C.MOVI.asl`

C.MOVI sign-extends its encoded five-bit immediate to XLEN and publishes it through RegDst.

## Normative identity {#PTO-INST-SCALAR-C-MOVI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-c-movi-purpose role=purpose -->
## C.MOVI 的作用

`C.MOVI` 把它的 5 位立即数符号扩展到 `PTO_XLEN`，并通过 Reg5 目标发布得到的字。它完全不读取寄存器。

设计要点：`C.MOVI` 是这个压缩指令组中唯一带显式目标字段的形式，因此它可以把常数直接物化到 GPR，而不必压入 `T`。这正是它需要 `RegDst` 字段而 `C.ADD`、`C.AND`、`C.OR` 不需要的原因。

<!-- PTO-READER-BLOCK: scalar-c-movi-mechanism role=mechanism -->
## 结果形成方式

`simm5` 被符号扩展到 `PTO_XLEN`：位 `4` 被复制到 `63..5` 位。随后按 `RegDst` 发布或丢弃该扩展后的字，不对它做任何算术运算。

设计要点：由于立即数是符号扩展的，五位既能表达小的正常数，也能表达小的负常数。`c.movi -1, ->a0` 物化 `18446744073709551615`，即全部 `64` 位都置起，而零扩展规则无法表达它。

设计要点：目标字段通过一条显式编码约束排除了编码 `10`，因为携带 `RegDst=10` 的 16 位模式是 `C.SETRET` 的形式。该约束防止两个压缩形式重叠，因此想写入寄存器 `10` 的程序必须改用别的指令，例如 `c.movr` 或某个 32 位形式。

<!-- PTO-READER-BLOCK: scalar-c-movi-inputs role=inputs-outputs -->
## 输入与目标

- `simm5` 是 `-16` 至 `15` 的有符号 5 位立即数。
- `RegDst` 发布扩展后的值：`1..23` 写入该 GPR，`30` 压入 `U`，`31` 压入 `T`，`0` 与 `24..29` 一起丢弃结果。

设计要点：`simm5` 的编码零是数值零，因此 `c.movi 0, ->a0` 写入 `0`，是压缩的常数零物化。`RegDst` 的编码零表示丢弃而不是写入零 GPR，因此被丢弃的 `C.MOVI` 不改变任何东西。

设计要点：没有源字段，因此 `C.MOVI` 不执行任何源读取，也不可能在源可用性检查上失败。

<!-- PTO-READER-BLOCK: scalar-c-movi-effects role=effects -->
## 效果与顺序

立即数被扩展后一步发布；由于什么都不读取，与其他寄存器之间不存在顺序问题。

发布或丢弃之后，`TPC` 前进 `2` 字节。内存、保留状态、描述符、数值状态、指令束、特权、谓词和控制流状态都不改变；除 `RegDst` 选中的那一次 `T` 或 `U` 压入外，也没有队列移动。

<!-- PTO-READER-BLOCK: scalar-c-movi-constraints role=constraints -->
## 合法性与故障边界

每个 `simm5` 取值都已分配，除 `10` 之外的每个 `RegDst` 编码也都已分配，而被编码约束拒绝的正是 `10`。

固定编码位不匹配（包括 `RegDst` 取值为 `10`）会在目标效果之前、`TPC` 前进之前引发 `Fault_IllegalInstruction`。无法译码的 16 位形式在 `PC` 处引发 `Fault_IllegalInstruction`，不适用于当前指令束的指令在 `TPC` 处引发 `Fault_BundleControl`。

设计要点：物化是全域定义的，因此 `C.MOVI` 从不因操作数取值而触发故障。它唯一被拒绝的操作数是属于另一条指令的目标编码，而该拒绝发生在写入任何内容之前。

<!-- PTO-READER-BLOCK: scalar-c-movi-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

当 `simm5=5` 且 `RegDst` 指向某个 GPR 时，`C.MOVI` 把 `5` 写入该 GPR。当 `simm5=-1` 时，它写入 `18446744073709551615`。当 `RegDst=31` 时，同样的扩展值不是写入寄存器，而是作为最新项压入 `T`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
c.movi simm, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| c_movi_16_2c84faf1bc72 | C16 | 16 | 0x0016 / 0x003f | [{"field":"RegDst","operator":"not-equal","value":10}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| c_movi_16_2c84faf1bc72 | RegDst | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| c_movi_16_2c84faf1bc72 | simm5 | 5 | signed | [{"instruction_lsb":6,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| c_movi_16_2c84faf1bc72 | RegDst | 5 | 0–9, 11–31 | none | 10 | Reg5 destination or discard | Encoded zero discards the result. |
| c_movi_16_2c84faf1bc72 | simm5 | 5 | 0–31 | none | none | signed five-bit immediate | Encoded zero materializes numeric zero. |

- `c_movi_16_2c84faf1bc72.RegDst` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| simm5 | signed five-bit immediate |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/C.MOVI.asl -->
```asl
readonly func InstructionContractOperation_C_MOVI() => ScalarOperation
begin
    return ScalarOperation_C_MOVI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/C.MOVI.asl -->
```asl
readonly func InstructionContractHandler_C_MOVI() => ScalarSemanticHandler
begin
    return ScalarHandler_MoveScalarValue;
end;

pure func InstructionContractResult_C_MOVI(
    encoded_immediate: bits(5))
    => Word
begin
    let immediate = SignExtend{PTO_XLEN}(encoded_immediate);
    return MoveScalarValue(immediate);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every encoded source, immediate, and explicit destination field is required; no field can be omitted.
- The mnemonic fixes immediate signedness, selected source width, and implicit-versus-explicit destination behavior.

## Legality

- RegDst codes 0 and 24..29 discard, codes 1..23 write GPRs, code 30 pushes U, and code 31 pushes T.
- Every encoded operand value is assigned; fixed encoding bits must match the canonical form.

## State effects

- Sign-extend simm5[4] through the complete XLEN result.
- Publish the complete XLEN result through the common Reg5 destination map. Relative sources are non-consuming; only a T or U destination push changes a temporary queue.
- No memory, reservation, descriptor, numeric-status, block, privilege, branch-target, or other control state changes. Successful execution advances TPC by two bytes.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot any Reg5 source before the destination effect.
- Publish the result, then advance TPC by the encoded instruction length.

## Exceptions

- Materialization is a total fixed-width operation and raises no arithmetic exception.
- A fixed-bit mismatch raises Fault_IllegalInstruction before the destination effect and before TPC advances.

## Examples

- c.movi simm, ->{t, u, rd}
