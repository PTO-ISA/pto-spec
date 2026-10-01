<!-- GENERATED FROM: asl/arch/programming-model/predicate-registers.asl -->
# Predicate Registers

**Normative ASL source:** `asl/arch/programming-model/predicate-registers.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-PROGRAMMING-MODEL-PREDICATE-REGISTERS}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-predicate-registers-purpose-scope role=purpose-scope -->
## 用途与范围

PTO 有八个谓词寄存器 P0 到 P7，每个宽 `32` 位。本单元定义它们的读写方式，并记录当前没有任何 PTO 指令编码消费它们。

这些寄存器是 `PTO-STATE-ARCH-PROGRAM-CONTROL` 中的架构状态。复位把它们清为零，陷阱捕获与恢复会保存并恢复整个数组。

<!-- PTO-READER-BLOCK: arch-predicate-registers-concepts-state role=concepts-state -->
## 谓词寄存器视图

`ReadPredicateRegister` 对谓词寄存器索引 `0` 返回全一。其他索引从 `_PredicateRegisters` 中读取所存元素。

`WritePredicateRegister` 只在索引不为 `0` 时存储值。

<!-- PTO-READER-BLOCK: arch-predicate-registers-rules-interactions role=rules-interactions -->
## 常量谓词与消费者

读写规则共同使 P0 成为恒定的全一谓词：写 P0 不产生状态效果，读 P0 也不依赖后备数组。

设计要点：由于读取忽略后备元素，P0 在任何状态下都读作全一。即使陷阱恢复替换了整个 `_PredicateRegisters` 数组，也无法改变 P0 的读取结果。

`PredicateRegisterHasInstructionConsumer` 对所有谓词索引都返回 `FALSE`，因为当前 PTO 指令编码没有 P0 到 P7 的消费者。

<!-- PTO-READER-BLOCK: arch-predicate-registers-boundaries role=boundaries -->
## 架构边界

没有指令消费者是本所有者中的编码陈述。消费者查询不会改变 `ReadPredicateRegister` 和 `WritePredicateRegister` 定义的读写行为。

谓词寄存器不是 Tile ExecutionMask。ExecutionMask 为一个指令束选择活动 Tile 元素。它由 GPR 或谓词 Tile 承载，位于 `PTO-STATE-BLOCK-CONTROL` 中，并随指令束头状态一起被清除。

设计要点：两种机制的生存期不同。`BSTART` 和指令束停止都会清除头状态，因此 ExecutionMask 不会延续到后续指令束。P0 到 P7 跨指令束保持，并随陷阱上下文保存和恢复。当前没有指令消费 P0 到 P7，因此写入它们永远不会屏蔽 Tile 操作。

<!-- PTO-READER-BLOCK: arch-predicate-registers-example-usage role=example-usage -->
## 非规范状态示例

如果测试向 P0 写入非零模式后再读取 P0，读取结果仍是全一 `PredicateWord`。把同样的值写入 P1 后，则可以从 P1 读回。

复位后，P1 到 P7 读作零，P0 读作全一。

<!-- PTO-READER-BLOCK: arch-predicate-registers-related-owners role=related-owners-navigation -->
## 相关所有者

- [执行上下文](execution-context.md)拥有本页使用的谓词后备状态。
- [陷阱上下文](../state/trap-context.md)把谓词数组作为可移植陷阱上下文的一部分保存并恢复。
- [Core PE 拓扑](core-pe-topology.md)声明本单元使用的谓词寄存器数量和宽度。
- [执行掩码状态](../../tile/model/execution/execution-mask-state.md)拥有指令束局部的 Tile ExecutionMask，它与这些寄存器相互独立。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/programming-model/predicate-registers.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-PROGRAMMING-MODEL-PREDICATE-REGISTERS","surface":"arch","classification":["programming-model","predicate-registers"],"depends_on":["PTO-ARCH-PROGRAMMING-MODEL-EXECUTION-CONTEXT"]}
readonly func ReadPredicateRegister(index: PredicateIndex) => PredicateWord
begin
    return if index == 0 then Ones{PTO_PREDICATE_WIDTH}
           else _PredicateRegisters[[index]];
end;

func WritePredicateRegister(index: PredicateIndex, value: PredicateWord)
begin
    if index != 0 then
        _PredicateRegisters[[index]] = value;
    end;
end;

pure func PredicateRegisterHasInstructionConsumer(index: PredicateIndex)
        => boolean
begin
    // PTO has no instruction encoding that consumes P0..P7.
    return FALSE;
end;
```
<!-- GENERATED-ASL-END: unit -->
