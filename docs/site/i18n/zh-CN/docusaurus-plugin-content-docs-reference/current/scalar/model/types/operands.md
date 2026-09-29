<!-- GENERATED FROM: asl/scalar/model/types/operands.asl -->
# Operands

**Normative ASL source:** `asl/scalar/model/types/operands.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-SCALAR-MODEL-TYPES-OPERANDS}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-model-types-operands-purpose role=purpose-scope -->
## 用途与范围

本单元定义 5 位标量寄存器码（Reg5 选择子）在作为源读取或作为目标写入时的含义。已译码的标量寄存器操作数经过这些函数，若干指令束分派单元也使用它们。

它定义：

- `ScalarSourceSelectorLegal` 和 `ScalarDestinationSelectorLegal`，决定选择子是否可用；
- `ScalarImplicitSourceOperandsLegal`，检查某些压缩形式的隐式 T#1 源；
- `ReadScalarRegisterOperand` 和 `ReadPEAbsoluteGPROperand`，读取值；
- `WriteScalarDestination` 和 `WriteCompressedTResult`，发布结果。

<!-- PTO-READER-BLOCK: scalar-model-types-operands-concepts role=concepts-state -->
## 概念与可见状态

共有 `PTO_ABSOLUTE_GPR_COUNT`（24）个绝对 GPR。GPR 0 总是读作零，对它的写入被丢弃。

T 队列和 U 队列各保存 `PTO_TEMPORARY_QUEUE_DEPTH`（4）个带有效位的条目。索引 0 是最新条目。压入会把每个条目向旧的方向移动一位，丢弃最旧的条目，并把新值作为有效条目存入索引 0。

Reg5 选择子在两个方向上含义不同：

| 编码 | 作为源 | 作为目标 |
| --- | --- | --- |
| 0 | GPR 0，读作零 | 丢弃 |
| 1 到 23 | GPR 1 到 23 | 写 GPR 1 到 23 |
| 24 到 27 | T#1 到 T#4 | 丢弃 |
| 28 和 29 | U#1 和 U#2 | 丢弃 |
| 30 | U#3 | 压入 U |
| 31 | U#4 | 压入 T |

<!-- PTO-READER-BLOCK: scalar-model-types-operands-rules role=rules-interactions -->
## 规则与交互

GPR 源总是合法。队列源仅在该条目的有效位置位时合法。`ScalarDestinationSelectorLegal` 接受所有编码。

读取队列条目不会移除它。在本单元中，只有压入才会改变队列。

设计要点：队列读取不消耗条目。同一条目可以供多条指令使用，读取队列后发生故障的指令也没有改变该队列。在本单元中，条目只有在之后又发生四次压入时才被移出队列。

`C.SDI`、`C.SLLI`、`C.SRLI` 和 `C.SWI` 读取 T#1，但不在字段中指明它，`ScalarImplicitSourceOperandsLegal` 要求它们的 T#1 有效。`C.CMP.EQI` 和 `C.CMP.NEI` 也隐式读取 T#1，但该函数不检查它们。

设计要点：对这四个运算，可用性在顶层合法性检查期间、族处理函数运行之前检查。若 T#1 为空，指令会在任何处理函数效果之前引发 `Fault_IllegalInstruction`，而不是读取陈旧值。

`WriteCompressedTResult` 总是压入 T。使用它的压缩形式（例如 `C.LDI` 和 `C.SLLI`）没有目标字段；`C.MOVI` 和 `C.MOVR` 则写入编码的 `RegDst`。

<!-- PTO-READER-BLOCK: scalar-model-types-operands-boundaries role=boundaries -->
## 架构边界

`ReadPEAbsoluteGPROperand` 断言选择子小于 24，并读取指定 PE 的 GPR。其注释说明，共享运算把一个编码选择子应用到每个 PE 自己的寄存器文件。指令束分派单元会调用它，例如 `scalar-schema` 和各 `tlsu-*` 单元。

生成的各形式函数 `ScalarRegisterOperandsLegal` 对形式的每个 Reg5 字段调用这两个选择子合法性函数。

队列状态属于执行上下文，`ResetProfileState` 在复位时清除它。本单元只负责读取和压入。

<!-- PTO-READER-BLOCK: scalar-model-types-operands-example role=example-usage -->
## 非规范阅读示例

初始时 T 队列在 T#1 到 T#4 保存 A、B、C 和 D，全部有效，U 为空。

- 读取选择子 25 的指令得到 B。T 队列不变。
- 读取选择子 28 的指令无法通过合法性检查，因为 U#1 无效。
- `WriteScalarDestination(31, X)` 把 X 压入 T。T#1 为 X，T#2 为 A，T#3 为 B，T#4 为 C，D 被移出。
- `WriteScalarDestination(26, Y)` 不做任何事，因为 26 是丢弃编码。

<!-- PTO-READER-BLOCK: scalar-model-types-operands-related role=related-owners-navigation -->
## 相关所有者

- [执行上下文](../../../arch/programming-model/execution-context.md)拥有 T 和 U 队列以及 `PushTemporaryQueue`。
- [标量寄存器](../../../arch/programming-model/scalar-registers.md)拥有 `ReadGPR` 和 `WriteGPR`。
- [标量顶层分派](../dispatch/top-level.md)运行合法性检查。
- [运算类型](operations.md)是另一个标量类型单元。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/scalar/model/types/operands.asl -->
```asl
// PTO-UNIT: {"id":"PTO-SCALAR-MODEL-TYPES-OPERANDS","surface":"scalar","classification":["model","types","operands"],"depends_on":["PTO-SCALAR-MODEL-TYPES-OPERATIONS","PTO-ARCH-PROGRAMMING-MODEL-SCALAR-REGISTERS"]}
// PTO-REQ-SCALAR-OPERAND-001: one-level Reg5 source and destination behavior.

// Reg5 codes 0..23 select absolute GPRs. Codes 24..27 select T#1..T#4
// and codes 28..31 select U#1..U#4. Queue index zero is the newest value.
readonly func ScalarSourceSelectorLegal(selector: Reg5Selector) => boolean
begin
    if selector < PTO_ABSOLUTE_GPR_COUNT then
        return TRUE;
    elsif selector < 28 then
        return TemporaryQueueSourceAvailable(
            TRUE,
            (selector - 24) as TemporaryQueueIndex);
    else
        return TemporaryQueueSourceAvailable(
            FALSE,
            (selector - 28) as TemporaryQueueIndex);
    end;
end;

readonly func ScalarDestinationSelectorLegal(selector: Reg5Selector) => boolean
begin
    return TRUE;
end;

readonly func ScalarImplicitSourceOperandsLegal(
    operation: ScalarOperation)
    => boolean
begin
    case operation of
        when ScalarOperation_C_SDI,
             ScalarOperation_C_SLLI,
             ScalarOperation_C_SRLI =>
            return TemporaryQueueSourceAvailable(TRUE, 0);
        when ScalarOperation_C_SWI =>
            return TemporaryQueueSourceAvailable(TRUE, 0);
        otherwise =>
            return TRUE;
    end;
end;

readonly func ReadScalarRegisterOperand(selector: Reg5Selector) => Word
begin
    if selector < PTO_ABSOLUTE_GPR_COUNT then
        return ReadGPR(selector as GPRIndex);
    elsif selector < 28 then
        return ReadTemporaryQueue(TRUE,
            (selector - 24) as TemporaryQueueIndex);
    else
        return ReadTemporaryQueue(FALSE,
            (selector - 28) as TemporaryQueueIndex);
    end;
end;

// B.IOR uses only absolute GPR selectors.  Shared operations apply one encoded
// selector to each PE's private register file rather than sharing a value
// resolved by the PE that happened to dispatch the block.
readonly func ReadPEAbsoluteGPROperand(pe: MemoryAgentId,
                                      selector: Reg5Selector) => Word
begin
    assert selector < PTO_ABSOLUTE_GPR_COUNT;
    return ReadPEGPR(pe, selector as GPRIndex);
end;

func WriteScalarDestination(selector: Reg5Selector, value: Word)
begin
    if selector < PTO_ABSOLUTE_GPR_COUNT then
        WriteGPR(selector as GPRIndex, value);
    elsif selector == 30 then
        PushTemporaryQueue(FALSE, value);
    elsif selector == 31 then
        PushTemporaryQueue(TRUE, value);
    end;
    // Destination selectors 24..29 are non-writing encodings. Codes 30 and 31
    // are the encoded ->u and ->t queue-push destinations respectively.
end;

func WriteCompressedTResult(value: Word)
begin
    PushTemporaryQueue(TRUE, value);
end;
```
<!-- GENERATED-ASL-END: unit -->
