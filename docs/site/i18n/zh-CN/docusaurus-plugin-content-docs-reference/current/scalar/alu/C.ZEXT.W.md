<!-- GENERATED FROM: asl/scalar/alu/C.ZEXT.W.asl -->
# C.ZEXT.W

**Normative ASL source:** `asl/scalar/alu/C.ZEXT.W.asl`

C.ZEXT.W zero-extends SrcL[31:0] to XLEN and pushes the result to T.

## Normative identity {#PTO-INST-SCALAR-C-ZEXT-W}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-c-zext-w-purpose role=purpose -->
## C.ZEXT.W 的作用

`C.ZEXT.W` 原样保留一个 Reg5 源的低 32 位，清除位 `31` 以上的每一位结果位，并把 XLEN 结果压入 `T`。

设计要点：被清除的区域是位 `32` 到 `PTO_XLEN` 顶端之间的全部位，因此在 64 位的 `PTO_XLEN` 上，这条指令把补码字转换成无符号字值。低字本身是被复制，而不是被解释。

<!-- PTO-READER-BLOCK: scalar-c-zext-w-mechanism role=mechanism -->
## 结果形成方式

共享扩展辅助函数取 `value[31:0]` 并零扩展到 `PTO_XLEN`。与 `C.ZEXT.B` 和 `C.ZEXT.H` 不同，所选字段正好是字边界，因此当 `PTO_XLEN` 为 64 时，发布值的位 `63:32` 总是零。

设计要点：由于位 `31:0` 原样保留，对低字已经等于全值的源来说，`C.ZEXT.W` 并不是空操作。只有当源的高半部分本来就是零时它才是恒等操作；否则它去掉的就是那个高半部分。

<!-- PTO-READER-BLOCK: scalar-c-zext-w-inputs role=inputs-outputs -->
## 输入与目标

- `SrcL` 是唯一被编码的操作数：Reg5 编码 `0..23` 选择绝对 GPR，`24..27` 选择 `T#1..T#4`，`28..31` 选择 `U#1..U#4`，读取时不消费队列项。
- 目标固定为 `T`；压缩形式中不存在目标字段。

设计要点：`SrcL` 的编码零读取架构零 GPR，因此 `c.zext.w zero, ->t` 压入 `0`。指定 `T#1` 的源在压入之前读取，所以 `c.zext.w t#1, ->t` 清除的是旧 `T#1` 的高半部分，而不是读取它即将压入的值。

<!-- PTO-READER-BLOCK: scalar-c-zext-w-effects role=effects -->
## 效果与顺序

源快照发生在目标效果之前。随后的压入把队列向更旧的索引方向移动：零扩展后的值成为 `T#1`，原 `T#4` 被丢弃。

压入之后，`TPC` 前进 `2` 字节。不会写任何 GPR，`U` 项、内存、保留状态、描述符、数值状态、指令束、特权、分支目标和其他控制状态都不改变。

<!-- PTO-READER-BLOCK: scalar-c-zext-w-constraints role=constraints -->
## 合法性与故障边界

`0` 至 `31` 的每个 `SrcL` 编码都已分配，固定编码位必须匹配规范形式。无论源值是什么，扩展都是全域定义的，不会引发算术异常。

所选 `T` 或 `U` 源不可用会在目标效果之前、`TPC` 前进之前引发 `Fault_IllegalInstruction`。无法译码的 16 位形式在 `PC` 处引发 `Fault_IllegalInstruction`，不适用于当前指令束的指令在 `TPC` 处引发 `Fault_BundleControl`。

设计要点：这是一个改变宽度的助记符，却没有宽度操作数，也没有非法源范围，因此本指南的故障边界完全没有算术情形。每个可达故障都在任何目标效果之前判定。

<!-- PTO-READER-BLOCK: scalar-c-zext-w-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

当 `T#1` 保存 `-1`（即全 1 的 XLEN 值）时，`c.zext.w t#1, ->t` 压入 `4294967295`，并把旧的全 1 值移到 `T#2`。当 `a0` 保存 `0x00000000FFFFFFFF` 时，压入值同样是 `0xFFFFFFFF`，因为高半部分本来就是零。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
c.zext.w srcL, ->t
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| c_zext_w_16_e8bc051c7e8c | C16 | 16 | 0x681c / 0xf83f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| c_zext_w_16_e8bc051c7e8c | SrcL | 5 | encoding-defined | [{"instruction_lsb":6,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| c_zext_w_16_e8bc051c7e8c | SrcL | 5 | 0–31 | none | none | Reg5 source | Encoded zero reads the architectural zero GPR. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/C.ZEXT.W.asl -->
```asl
readonly func InstructionContractOperation_C_ZEXT_W() => ScalarOperation
begin
    return ScalarOperation_C_ZEXT_W;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/C.ZEXT.W.asl -->
```asl
readonly func InstructionContractHandler_C_ZEXT_W() => ScalarSemanticHandler
begin
    return ScalarHandler_ExtendScalarValue;
end;

pure func InstructionContractResult_C_ZEXT_W(value: Word)
    => Word
begin
    return ExtendScalarValue(
        value,
        32,
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

- Zero-fill every result bit above source bit 31.
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

- c.zext.w srcl, ->t
