<!-- GENERATED FROM: asl/block/model/operands/scalar-bindings.asl -->
# Scalar Bindings

**Normative ASL source:** `asl/block/model/operands/scalar-bindings.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-OPERANDS-SCALAR-BINDINGS}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-operands-scalar-bindings-purpose role=purpose-scope -->
## 用途与范围

本单元拥有两类指令束头部状态的写入函数：指令束参数和标量绑定。标量绑定是一条 `B.IOR` 头部命令留下的记录。它指名指令束操作读取和写入的通用寄存器（GPR）。

本单元只记录选择。它不读取任何 GPR，也不检查任何操作 schema。

<!-- PTO-READER-BLOCK: block-model-operands-scalar-bindings-concepts role=concepts-state -->
## 概念与可见状态

`_BundleScalarBindings` 有 `PTO_BUNDLE_SCALAR_BINDING_COUNT`（32）个条目。每个 `BundleScalarBinding` 条目保存：

- `valid`；
- `destination` 以及 `source0`、`source1`、`source2`，每个都是 5 位寄存器选择子；
- `source_count`，取值 0 到 3；
- `execution_mask_present`。

指令束参数是 `_BundleArgument` 及其 3 位种类 `_BundleArgumentKind`。参数设置函数还会写入架构寄存器 `_CommitArgument`。

<!-- PTO-READER-BLOCK: block-model-operands-scalar-bindings-rules role=rules-interactions -->
## 规则与交互

`SetBundleScalarBinding` 把条目标记为有效，保存四个选择子和 `source_count`，并清除 `execution_mask_present`。`SetBundleScalarBindingWithExecutionMask` 调用它，然后保存传入的 `execution_mask_present` 标志。

调用者是命令分派单元中的 `B.IOR` 处理程序。它先检查指令束处于头部阶段、目标条目空闲、除非选中了多记录流否则条目 0 空闲，以及 TGPR2T 和 TIMG2COL 的流放置规则成立；否则以 `Fault_BundleControl` 故障。然后它写入条目 0；当选中了多记录流（TGPR2T、TIMG2COL 或执行掩码 GPR 流）且条目 0 已有效时，写入条目 1。它传入的 `source_count` 为 3，只有在没有执行掩码时的第二条 TGPR2T 记录为 1。

设计要点：`source_count` 是该记录的编码容量，而不是操作的元数。ASL 注释说明，有效元数总是来自完整的操作 schema，值为零的选择子不会被视为缺省操作数。需要某个源的 schema 会读取该选择子，即使它指名寄存器 0。

设计要点：设置函数不验证选择子，也不读取寄存器。除 `B.IOR` 处理程序中对 TGPR2T 和 TIMG2COL 的放置检查外，选择子合法性和所有值的读取都在稍后、所选操作的 schema 运行时进行，因此 `B.IOR` 命令本身从不读取 GPR。

`SetBundleArgument(value)` 把 `value` 写入 `_BundleArgument` 和 `_CommitArgument`，并把种类设置为 `001`。`SetBundleArgumentKind(kind, value)` 做同样的事，但种类由调用者选择。

<!-- PTO-READER-BLOCK: block-model-operands-scalar-bindings-boundaries role=boundaries -->
## 架构边界

`ClearBundleHeaderState` 在每个指令束开始时以及提交之后清除每个标量绑定、`_BundleArgument` 和 `_BundleArgumentKind`。绑定从不延续到另一个指令束。

在当前 ASL 中，没有命令处理程序调用 `SetBundleArgument` 或 `SetBundleArgumentKind`，命令目录中也没有使用该处理程序的形式。除此之外，指令束参数只由复位、头部清除和陷阱上下文恢复写入。

<!-- PTO-READER-BLOCK: block-model-operands-scalar-bindings-example role=example-usage -->
## 非规范阅读示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

一个 TIMG2COL 指令束带有两条 `B.IOR` 记录。第一条 `B.IOR x10, x0, x0, ->x0` 写入条目 0，`source0` 为 10，`source_count` 为 3。此时条目 0 已有效，因此第二条 `B.IOR x11, x12, x13, ->x0` 写入条目 1。执行单元随后从条目 0 的 `source0` 读取 `GMBase`，从条目 1 读取三个参数字。

<!-- PTO-READER-BLOCK: block-model-operands-scalar-bindings-related role=related-owners-navigation -->
## 相关所有者

- [命令](../dispatch/commands.md)包含调用这些设置函数的 `B.IOR` 处理程序。
- [标量 schema](../dispatch/scalar-schema.md) 选择条目索引并读取选择子。
- [描述符状态](../state/descriptor-state.md)清除这些绑定。
- [B.IOR](../../operands/B.IOR.md) 是命令页面。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/operands/scalar-bindings.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-OPERANDS-SCALAR-BINDINGS","surface":"block","classification":["model","operands","scalar-bindings"],"depends_on":["PTO-BLOCK-MODEL-OPERANDS-SHARED-BINDINGS"]}
func SetBundleArgument(value: Word)
begin
    _BundleArgument = value;
    _BundleArgumentKind = '001';
    _CommitArgument = value;
end;

func SetBundleArgumentKind(kind: bits(3), value: Word)
begin
    _BundleArgumentKind = kind;
    _BundleArgument = value;
    _CommitArgument = value;
end;

func SetBundleScalarBinding(index: BundleScalarBindingIndex,
                           destination: Reg5Selector,
                           source0: Reg5Selector,
                           source1: Reg5Selector,
                           source2: Reg5Selector,
                           source_count: integer {0..3})
begin
    // source_count records the encoded binding capacity for direct helper
    // users.  Architectural effective arity is always derived from the
    // complete operation schema; zero-valued unused selectors are not
    // inferred as absent.
    _BundleScalarBindings[[index]].valid = TRUE;
    _BundleScalarBindings[[index]].destination = destination;
    _BundleScalarBindings[[index]].source0 = source0;
    _BundleScalarBindings[[index]].source1 = source1;
    _BundleScalarBindings[[index]].source2 = source2;
    _BundleScalarBindings[[index]].source_count = source_count;
    _BundleScalarBindings[[index]].execution_mask_present = FALSE;
end;

func SetBundleScalarBindingWithExecutionMask(
    index: BundleScalarBindingIndex,
    destination: Reg5Selector,
    source0: Reg5Selector,
    source1: Reg5Selector,
    source2: Reg5Selector,
    source_count: integer {0..3},
    execution_mask_present: boolean)
begin
    SetBundleScalarBinding(index, destination, source0, source1, source2,
        source_count);
    _BundleScalarBindings[[index]].execution_mask_present =
        execution_mask_present;
end;
```
<!-- GENERATED-ASL-END: unit -->
