<!-- GENERATED FROM: asl/scalar/sys/ASSERT.asl -->
# ASSERT

**Normative ASL source:** `asl/scalar/sys/ASSERT.asl`

ASSERT raises the architecture assertion trap exactly when its snapshotted scalar condition is zero.

## Normative identity {#PTO-INST-SCALAR-ASSERT}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-assert-purpose role=purpose -->
## ASSERT 的作用

`ASSERT` 是一次架构断言检查。它读取一个标量值，并在该值恰好为零时引发断言陷阱。非零值被静默接受。

它没有目的位置：只可能有两种结果，即正常退休和断言陷阱。

<!-- PTO-READER-BLOCK: scalar-assert-mechanism role=mechanism -->
## 指令如何放置与执行

本指令是活动 SYS 块体中的一个标量操作。标量分派器先检查是否存在活动指令束，以及其块体是否活动且块类型为 System；处于这种块之外的 SYS 形式会以 `Fault_BundleControl` 被拒绝，这发生在任何编码字段检查之前，也发生在任何架构效果之前。

随后检查编码合法性与源可用性，之后处理程序才运行。

处理程序读取一次 `SrcL` 并测试它是否为零。零会引发 `Fault_Assert`，并以请求发生处作为故障地址。任何非零值都通过测试，包括低位为零但高位被置位的值。

设计要点：检查施加在源的快照上，而不是施加在标志或条件寄存器上。这使断言自成一体：决定结果的值正是程序算入该寄存器的值，计算与检查之间没有隐藏状态。

<!-- PTO-READER-BLOCK: scalar-assert-inputs-outputs role=inputs-outputs -->
## 输入与输出

- `SrcL` 是源选择器。编码零指名架构零 GPR，其读取值始终是 XLEN 零，因此零选择器总是引发断言陷阱。
- 源选择器 `0`..`23` 读取 GPR，`24`..`27` 读取 `T#1`..`T#4`，`28`..`31` 读取 `U#1`..`U#4`。读取临时队列不会消费或重排它。
- 没有目的字段，因此该指令绝不写 GPR，也绝不压入 `T` 或 `U`。

<!-- PTO-READER-BLOCK: scalar-assert-effects role=effects -->
## 架构效果

源为零时，该指令引发 `Fault_Assert`，不推进 `TPC`，也不退休任何东西；陷阱入口把故障地址记录为请求发生处。源非零时，唯一的效果是成功退休，`TPC` 前进 `4` 字节。

在两种结果下，源寄存器以及它指名的任何队列表项都不变：该指令只读取，从不写入。

该指令没有内存效果，也不留下保留状态，因此它不可能是后续原子操作或链接加载操作失败的原因。

<!-- PTO-READER-BLOCK: scalar-assert-constraints role=constraints -->
## 放置与拒绝

无效的块放置首先被拒绝，以 `Fault_BundleControl` 报出，此时连编码字段都还没有被考虑。

每个可用的 Reg5 源选择器都是已分配编码，因此没有保留的源选择器。指名不可用 `T` 或 `U` 槽的选择器会在零值测试运行之前以 `Fault_IllegalInstruction` 被拒绝，这使故障顺序保持稳定：不可用的源绝不会被报告为断言失败。

<!-- PTO-READER-BLOCK: scalar-assert-example role=example -->
## 非规范示例

当 `a0` 保存任何非零值时，`assert a0` 正常退休。当 `a0` 保存 XLEN 零时，该指令在自身所在位置引发 `Fault_Assert`，`TPC` 保持在原处。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
assert SrcL
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| assert_32_f05d67874ae5 | L32 | 32 | 0x0000102b / 0xfff07fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| assert_32_f05d67874ae5 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| assert_32_f05d67874ae5 | SrcL | 5 | 0–31 | none | none | Reg5 source: R0..R23, T#1..T#4, or U#1..U#4 | Encoded zero names the architectural zero GPR. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 source: R0..R23, T#1..T#4, or U#1..U#4 |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/ASSERT.asl -->
```asl
readonly func InstructionContractOperation_ASSERT()
    => ScalarOperation
begin
    return ScalarOperation_ASSERT;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
ASSERT executes as one scalar operation in the body of an active SYS block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/ASSERT.asl -->
```asl
readonly func InstructionContractHandler_ASSERT()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ArchitectureAssert;
end;

pure func InstructionContractRequiresSystemBlock_ASSERT()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractFaultsWhenZero_ASSERT()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractPreservesSource_ASSERT()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every displayed operand is encoded explicitly. Encoded zero is an assigned value and never denotes omission.

## Legality

- Every fixed bit and explicit field constraint is checked before operation semantics.
- Every available Reg5 source selector is assigned.

## State effects

- Snapshot SrcL; zero raises Fault_Assert at the faulting PC and nonzero performs no effect other than successful retirement.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Check block placement and encoded legality before source reads or architectural effects.
- Snapshot every scalar source before the selected system effect, then advance TPC only after success.

## Exceptions

- Invalid block placement raises Illegal Block Exception before encoded-field legality or effects.
- A reserved encoding or rejected access raises Illegal Instruction before destination, queue, system-state, or TPC effects.

## Examples

- assert SrcL
