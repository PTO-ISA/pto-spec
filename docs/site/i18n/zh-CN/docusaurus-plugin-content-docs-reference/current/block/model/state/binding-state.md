<!-- GENERATED FROM: asl/block/model/state/binding-state.asl -->
# Binding State

**Normative ASL source:** `asl/block/model/state/binding-state.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-STATE-BINDING-STATE}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-state-binding-state-purpose role=purpose-scope -->
## 用途与范围

本单元为指令束绑定状态这一概念命名。它自身不包含可执行 ASL。其唯一内容是对描述符状态单元的依赖，因此实际的绑定状态由它所依赖的单元定义。

请把本页当作一张地图，用来查找绑定状态位于何处。

<!-- PTO-READER-BLOCK: block-model-state-binding-state-concepts role=concepts-state -->
## 概念与可见状态

绑定把指令束操作的一个操作数角色连接到一个架构寄存器或 Tile。指令束持有三个绑定数组：

- `_BundleScalarBindings`：32 个条目，由 `B.IOR` 填写。每个条目命名一个目标 GPR 和至多三个源 GPR。
- `_BundleTileBindings`：16 个条目，由 `B.IOT` 填写。每个条目命名至多两个源 Tile、一个可选的带大小码的目标 hand、一个 PE 掩码和一个 `last` 标志。
- `_BundleSharedBindings`：4 个条目，由 `B.IOS` 填写。每个条目命名一个 Shared Tile、一个大小码和一个 PE 掩码。

记录类型位于[状态类型](types.md)中，这些变量是[控制状态](control-state.md)的成员。

<!-- PTO-READER-BLOCK: block-model-state-binding-state-rules role=rules-interactions -->
## 规则与交互

`B.IOT` 把每个条目追加到第一个空闲的 Tile 绑定槽位。在设置了 `last` 的条目之后，序列即被关闭，再出现的 `B.IOT` 会引发 `Fault_BundleControl`。第 17 个条目会引发 `Fault_TileLegality`。

设计要点：Tile 绑定按命令顺序保存。操作 schema 读取这个有序序列，把源和目标分配给操作数角色，因此程序写入 `B.IOT` 命令的顺序就是操作数被消费的顺序。`last` 标志标记序列的结束位置。

设计要点：绑定只记录选择。目标分配推迟到提交时，在操作 schema 检查完整的绑定集合之后进行。因此，一个最终被证明非法的绑定此时尚未分配任何 Tile。

<!-- PTO-READER-BLOCK: block-model-state-binding-state-boundaries role=boundaries -->
## 架构边界

三个绑定数组都会在每个指令束开始时以及提交之后由 `ClearBundleHeaderState` 清除。它们从不延续到另一个指令束。

本页不定义某个操作需要哪些操作数角色。这由分派 schema 单元定义。

<!-- PTO-READER-BLOCK: block-model-state-binding-state-example role=example-usage -->
## 非规范阅读示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

一个二元 Tile 操作使用一个 `B.IOT` 条目，其中含两个源、目标 hand `T`，并设置了 `last`。该条目落在 Tile 绑定槽位 0 中并关闭序列。提交时，schema 从槽位 0 读取两个源和目标。

<!-- PTO-READER-BLOCK: block-model-state-binding-state-related role=related-owners-navigation -->
## 相关所有者

- [Tile 绑定](../operands/tile-bindings.md)、[标量绑定](../operands/scalar-bindings.md)和 [Shared 绑定](../operands/shared-bindings.md)定义写入者。
- [描述符状态](descriptor-state.md)定义清除操作。
- [B.IOT](../../operands/B.IOT.md)、[B.IOR](../../operands/B.IOR.md) 和 [B.IOS](../../operands/B.IOS.md) 是绑定命令。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/state/binding-state.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-STATE-BINDING-STATE","surface":"block","classification":["model","state","binding-state"],"depends_on":["PTO-BLOCK-MODEL-STATE-DESCRIPTOR-STATE"]}
// This unit owns the named block-model concept; executable state is defined by its dependencies.
```
<!-- GENERATED-ASL-END: unit -->
