<!-- GENERATED FROM: asl/scalar/alu/C.ZEXT.B.asl -->
# C.ZEXT.B

**Normative ASL source:** `asl/scalar/alu/C.ZEXT.B.asl`

C.ZEXT.B zero-extends SrcL[7:0] to XLEN and pushes the result to T.

## Normative identity {#PTO-INST-SCALAR-C-ZEXT-B}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-c-zext-b-purpose role=purpose -->
## C.ZEXT.B 的作用

`C.ZEXT.B` 取一个 Reg5 源的低字节，把位 `7` 以上的每一位结果位填零，并把 XLEN 结果压入 `T`。

设计要点：宽度是助记符的一部分，而不是被编码的字段，因此 `C.ZEXT.B`、`C.ZEXT.H` 和 `C.ZEXT.W` 是三个独立的 16 位形式，它们的固定位不同。改变宽度的程序就是改变操作码。

<!-- PTO-READER-BLOCK: scalar-c-zext-b-mechanism role=mechanism -->
## 结果形成方式

共享扩展辅助函数取 `value[7:0]` 并零扩展到 `PTO_XLEN`。源的位 `8` 及以上被丢弃而不是被判断，因此发布值总在 `0..255` 之内。

设计要点：同一个辅助函数也为有符号对应形式 `C.SEXT.B` 服务；调用中唯一的区别是扩展标志，这里是 `FALSE`。可观察的区别是：`C.ZEXT.B` 不可能发布大于 `255` 的值，而同一字节的符号扩展形式可以发布高半部分全为 1 的值。

<!-- PTO-READER-BLOCK: scalar-c-zext-b-inputs role=inputs-outputs -->
## 输入与目标

- `SrcL` 是 Reg5 源：编码 `0..23` 选择绝对 GPR，`24..27` 选择 `T#1..T#4`，`28..31` 选择 `U#1..U#4`，读取时不消费队列项。
- 这个形式不存在立即数字段和目标字段：压缩编码把目标固定为 `T`。

设计要点：`SrcL` 的编码零读取架构零 GPR，因此 `c.zext.b zero, ->t` 压入 `0`，不依赖任何寄存器；由于字节选择，这也是零源唯一可能的结果。

<!-- PTO-READER-BLOCK: scalar-c-zext-b-effects role=effects -->
## 效果与顺序

`SrcL` 在目标效果之前快照，因此指定 `T#1` 的源按指令执行前的值读取。随后的压入把队列向更旧的索引方向移动，新值成为 `T#1`，原 `T#4` 被丢弃。

压入之后，`TPC` 前进 `2` 字节。不会写任何 GPR，`U` 项、内存、保留状态、描述符、数值状态、指令束、特权、分支目标和其他控制状态都不改变。

<!-- PTO-READER-BLOCK: scalar-c-zext-b-constraints role=constraints -->
## 合法性与故障边界

`0` 至 `31` 的每个 `SrcL` 编码都已分配，固定编码位必须匹配规范形式。扩展是全域定义的定宽操作，对任何源值都不会引发算术异常。

所选 `T` 或 `U` 源不可用会在目标效果之前、`TPC` 前进之前引发 `Fault_IllegalInstruction`。无法译码的 16 位形式在 `PC` 处引发 `Fault_IllegalInstruction`，不适用于当前指令束的指令在 `TPC` 处引发 `Fault_BundleControl`。

设计要点：没有需要拒绝的非法操作数取值，因为源选择器映射是完备的，而字节截断对每个 XLEN 输入都有定义。唯一与源有关的故障是请求队列并不持有的队列项。

<!-- PTO-READER-BLOCK: scalar-c-zext-b-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

当 `a0` 保存 `0x1234`、`T#1` 保存 `0x7F` 时，`c.zext.b a0, ->t` 压入 `0x34`，并把旧的 `0x7F` 移到 `T#2`。源为全 1 时压入值是 `255`，永远不会是 `-1`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
c.zext.b srcL, ->t
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| c_zext_b_16_7ea1a59fa2da | C16 | 16 | 0x581c / 0xf83f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| c_zext_b_16_7ea1a59fa2da | SrcL | 5 | encoding-defined | [{"instruction_lsb":6,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| c_zext_b_16_7ea1a59fa2da | SrcL | 5 | 0–31 | none | none | Reg5 source | Encoded zero reads the architectural zero GPR. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/C.ZEXT.B.asl -->
```asl
readonly func InstructionContractOperation_C_ZEXT_B() => ScalarOperation
begin
    return ScalarOperation_C_ZEXT_B;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/C.ZEXT.B.asl -->
```asl
readonly func InstructionContractHandler_C_ZEXT_B() => ScalarSemanticHandler
begin
    return ScalarHandler_ExtendScalarValue;
end;

pure func InstructionContractResult_C_ZEXT_B(value: Word)
    => Word
begin
    return ExtendScalarValue(
        value,
        8,
        FALSE);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every encoded source, immediate, and explicit destination field is required; no field can be omitted.
- The mnemonic fixes immediate signedness, selected source width, and implicit-versus-explicit destination behavior.

## Legality

- SrcL codes 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consumption.
- The compressed form has no destination field and always pushes exactly one result to T.
- Every encoded operand value is assigned; fixed encoding bits must match the canonical form.

## State effects

- Zero-fill every result bit above source bit 7.
- Push the complete XLEN result to T. The source queue is non-consuming, and no explicit destination encoding exists.
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

- c.zext.b srcl, ->t
