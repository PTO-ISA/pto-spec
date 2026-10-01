<!-- GENERATED FROM: asl/arch/features/predication.asl -->
# Predication

**Normative ASL source:** `asl/arch/features/predication.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-FEATURES-PREDICATION}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-predication-purpose-scope role=purpose-scope -->
## 目的与范围

归属文件 `asl/arch/features/predication.asl` 只有两行：`PTO-UNIT` 元数据注释，以及一条说明该单元拥有该命名概念、可执行状态由其依赖定义的注释。它不声明类型、函数、常量或状态变量。

所声明的依赖是 `PTO-ARCH-PROGRAMMING-MODEL-PREDICATE-REGISTERS`，谓词状态及其访问函数都定义在那里。

<!-- PTO-READER-BLOCK: arch-predication-concepts-state role=concepts-state -->
## 依赖中的可执行状态

- `ReadPredicateRegister(index: PredicateIndex) => PredicateWord` 在 `index == 0` 时返回 `Ones{PTO_PREDICATE_WIDTH}`，否则返回 `_PredicateRegisters[[index]]`。
- `WritePredicateRegister(index: PredicateIndex, value: PredicateWord)` 只在 `index != 0` 时执行 `_PredicateRegisters[[index]] = value`。
- `PredicateRegisterHasInstructionConsumer(index: PredicateIndex) => boolean` 对每个索引都返回 `FALSE`，其注释说明 PTO 没有任何消费 `P0..P7` 的指令编码。
- `PredicateIndex` 是 `0..PTO_PREDICATE_REGISTER_COUNT-1` 范围内的整数，`PredicateWord` 是 `bits(PTO_PREDICATE_WIDTH)`，其中 `PTO_PREDICATE_REGISTER_COUNT = 8`，`PTO_PREDICATE_WIDTH = 32`。
- 后备存储是 `var _PredicateRegisters : PredicateSnapshot`，即由 `PTO_PREDICATE_REGISTER_COUNT` 个 `PredicateWord` 组成的数组，它是状态 `PTO-STATE-ARCH-PROGRAM-CONTROL` 的成员。

设计要点：索引 `0` 是常量源而不是寄存器。读取 `P0` 返回 `Ones{32}`，写保护会丢弃对 `P0` 的每一次写，因此 `ReadPredicateRegister(0)` 在任何 `WritePredicateRegister(0, value)` 前后都返回同一个值。全一是因此无需存储即可读取的常量，而对 `0` 的写是无操作而不是错误。

设计要点：存储与消费是两个不同的判定。`PredicateRegisterHasInstructionConsumer` 对全部 `8` 个索引都返回 `FALSE`，因此某条指令的谓词效果无法追溯到该依赖；答案只能来自消费该机制的指令自身的解码与操作。

<!-- PTO-READER-BLOCK: arch-predication-rules-interactions role=rules-interactions -->
## 规则与交互

一次写会替换整个 `32` 位 `PredicateWord`。该依赖中不存在部分写、通道掩码或逐元素已定义性标志。

两个函数都不调用 `SetFault`，因此对任何 `PredicateIndex`（包括 `0`）都不会抛出故障。读写都不改变 `_PC`、`_BPC`、指令束标志与故障状态。

`PTO-ARCH-SYSTEM-REGISTERS-ADDRESSING` 中的 `ResetProfileState` 通过给索引 `0` 到 `PTO_PREDICATE_REGISTER_COUNT - 1` 赋值 `Zeros{PTO_PREDICATE_WIDTH}` 来清空该寄存器堆。复位之后立即读取 `P1` 到 `P7` 都会返回 `Zeros{32}`，而读取 `P0` 仍然返回 `Ones{32}`。

`asl/` 下没有任何单元调用这三个函数；本仓库中的调用位于 `tests/asl/arch/programming-model/predicate-registers/` 下的测试中。

<!-- PTO-READER-BLOCK: arch-predication-boundaries role=boundaries -->
## 架构边界

本页不能添加缺失的谓词语义。归属文件中没有任何可供细化的定义，因此关于谓词极性、覆盖范围或抑制效果的新规则必须加入该依赖或某个指令归属单元。

该标记同样不定义默认谓词极性、读取谓词的指令清单，也不定义读取从未写过的寄存器时的故障。该依赖只定义读、写和消费判定，别的一概没有。

设计要点：`P0` 的常量读取与对 `P0` 的丢弃写是由两个函数中的 `index == 0` 与 `index != 0` 判定实现的，而不是通过保留数组元素 `0`。`_PredicateRegisters` 的元素 `0` 依然存在并依然会被复位，但任何读取都无法通过 `ReadPredicateRegister` 观察到它。

<!-- PTO-READER-BLOCK: arch-predication-example-usage role=example-usage -->
## 非规范阅读示例

读者可以直接跟踪一次写的取值：`WritePredicateRegister(1, value)` 执行赋值 `_PredicateRegisters[[1]] = value`，之后 `ReadPredicateRegister(1)` 返回同一个 `PredicateWord`。

对 `0` 做同样的跟踪结果不同：`WritePredicateRegister(0, value)` 不改变数组，而 `ReadPredicateRegister(0)` 无论 `value` 为何都返回 `Ones{32}`。

要判断假谓词是否抑制某条指令，应阅读该指令的解码与操作；`PredicateRegisterHasInstructionConsumer(0)` 与 `PredicateRegisterHasInstructionConsumer(7)` 都返回 `FALSE`，因此该依赖在索引范围的两端都报告没有指令消费者。

<!-- PTO-READER-BLOCK: arch-predication-related-owners role=related-owners-navigation -->
## 相关归属单元

- [谓词寄存器](../programming-model/predicate-registers.md) 定义读、写与消费判定。
- [执行上下文](../programming-model/execution-context.md) 把 `_PredicateRegisters` 声明为 `PTO-STATE-ARCH-PROGRAM-CONTROL` 的成员。
- [整数类型](../data-types/integer.md) 定义 `PredicateIndex` 与 `PredicateWord`。
- [陷阱上下文](../state/trap-context.md) 随陷阱上下文保存与恢复谓词快照。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/features/predication.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-FEATURES-PREDICATION","surface":"arch","classification":["features","predication"],"depends_on":["PTO-ARCH-PROGRAMMING-MODEL-PREDICATE-REGISTERS"]}
// This unit owns the named architecture concept; executable state is defined by its dependencies.
```
<!-- GENERATED-ASL-END: unit -->
