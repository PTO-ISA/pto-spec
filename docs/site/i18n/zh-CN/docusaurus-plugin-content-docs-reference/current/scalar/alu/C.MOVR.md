<!-- GENERATED FROM: asl/scalar/alu/C.MOVR.asl -->
# C.MOVR

**Normative ASL source:** `asl/scalar/alu/C.MOVR.asl`

C.MOVR snapshots a Reg5 source and publishes the complete XLEN value unchanged through RegDst.

## Normative identity {#PTO-INST-SCALAR-C-MOVR}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-c-movr-purpose role=purpose -->
## C.MOVR 的作用

`C.MOVR` 读取一个 Reg5 源，并把完整的 XLEN 值原样通过 Reg5 目标发布。

设计要点：源字段接受 `T#1..T#4`，因此 `c.movr t#1, ->a0` 是把压入的临时结果移入 GPR 的压缩写法。压缩算术形式都压入 `T`，自身无法写寄存器，而这条指令正是补上这一缺口的形式。

<!-- PTO-READER-BLOCK: scalar-c-movr-mechanism role=mechanism -->
## 结果形成方式

源编码被解析，其值在没有任何变换的情况下发布：不做扩展、不做截断、不做算术。若存在目标，目标的 `63..0` 位恰好等于被读取的那些位。

设计要点：这次移动是纯拷贝而不是转换。需要 32 位规范化的程序必须显式请求，例如通过 `c.sext.w` 或 `addiw`。

<!-- PTO-READER-BLOCK: scalar-c-movr-inputs role=inputs-outputs -->
## 输入与目标

- `SrcL` 是 Reg5 源：编码 `0..23` 选择绝对 GPR，`24..27` 选择 `T#1..T#4`，`28..31` 选择 `U#1..U#4`，且不消费队列项。
- `RegDst` 发布该值：`1..23` 写入该 GPR，`30` 压入 `U`，`31` 压入 `T`，`0` 与 `24..29` 一起丢弃结果。

设计要点：`SrcL` 的编码零读取架构零 GPR，因此 `c.movr zero, ->a0` 是压缩的常数零物化。`RegDst` 的编码零丢弃该值而不是写入零 GPR，尽管源仍会被读取和检查。

设计要点：`c.movr t#1, ->t` 合法。它读取原 `T#1`，把副本压入为新的 `T#1`，并把原件移到 `T#2`，这是复制一个临时值的方法。

<!-- PTO-READER-BLOCK: scalar-c-movr-effects role=effects -->
## 效果与顺序

源在写入目标之前读取，因此与源重名的目标仍然发布指令执行前的值。除此之外没有其他变化。

发布或丢弃之后，`TPC` 前进 `2` 字节。内存、保留状态、描述符、数值状态、指令束、特权、谓词和控制流状态都不改变；除 `RegDst` 选中的那一次 `T` 或 `U` 压入外，也没有队列移动。

<!-- PTO-READER-BLOCK: scalar-c-movr-constraints role=constraints -->
## 合法性与故障边界

每个 `SrcL` 编码和每个 `RegDst` 编码都已分配，因此 `C.MOVR` 没有保留的操作数取值。

所选 `T` 或 `U` 源不可用会在目标效果之前、`TPC` 前进之前引发 `Fault_IllegalInstruction`。无法译码的 16 位形式在 `PC` 处引发 `Fault_IllegalInstruction`，不适用于当前指令束的指令在 `TPC` 处引发 `Fault_BundleControl`。

设计要点：拷贝没有可供出错的算术，因此 `C.MOVR` 依赖取值的整个边界就是源可用性。读取未初始化的临时值因此是有定义的陷阱，而不是静默拷贝陈旧数据。

<!-- PTO-READER-BLOCK: scalar-c-movr-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

当 `T#1` 保存 `5` 时，`c.movr t#1, ->a0` 把 `5` 写入 `a0`，并保持 `T#1` 等于 `5`。`c.movr zero, ->a1` 把 `0` 写入 `a1`，且不读取任何可能改变结果的 GPR 值。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
c.movr SrcL, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| c_movr_16_80d2b5f3580b | C16 | 16 | 0x0006 / 0x003f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| c_movr_16_80d2b5f3580b | RegDst | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| c_movr_16_80d2b5f3580b | SrcL | 5 | encoding-defined | [{"instruction_lsb":6,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| c_movr_16_80d2b5f3580b | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| c_movr_16_80d2b5f3580b | SrcL | 5 | 0–31 | none | none | Reg5 source | Encoded zero reads the architectural zero GPR. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | Reg5 source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/C.MOVR.asl -->
```asl
readonly func InstructionContractOperation_C_MOVR() => ScalarOperation
begin
    return ScalarOperation_C_MOVR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/C.MOVR.asl -->
```asl
readonly func InstructionContractHandler_C_MOVR() => ScalarSemanticHandler
begin
    return ScalarHandler_MoveScalarValue;
end;

pure func InstructionContractResult_C_MOVR(value: Word)
    => Word
begin
    return MoveScalarValue(value);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every encoded source, immediate, and explicit destination field is required; no field can be omitted.
- The mnemonic fixes immediate signedness, selected source width, and implicit-versus-explicit destination behavior.

## Legality

- SrcL codes 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consumption.
- RegDst codes 0 and 24..29 discard, codes 1..23 write GPRs, code 30 pushes U, and code 31 pushes T.
- Every encoded operand value is assigned; fixed encoding bits must match the canonical form.

## State effects

- Return the complete snapshotted SrcL value without conversion.
- Publish the complete XLEN result through the common Reg5 destination map. Relative sources are non-consuming; only a T or U destination push changes a temporary queue.
- No memory, reservation, descriptor, numeric-status, block, privilege, branch-target, or other control state changes. Successful execution advances TPC by two bytes.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot any Reg5 source before the destination effect.
- Publish the result, then advance TPC by the encoded instruction length.

## Exceptions

- Materialization, movement, and extension are total fixed-width operations and raise no arithmetic exception.
- An unavailable selected T/U source raises Fault_IllegalInstruction before the destination effect and before TPC advances.

## Examples

- c.movr srcl, ->{t, u, rd}
