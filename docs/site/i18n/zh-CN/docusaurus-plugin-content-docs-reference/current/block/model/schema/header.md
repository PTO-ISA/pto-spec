<!-- GENERATED FROM: asl/block/model/schema/header.asl -->
# Header

**Normative ASL source:** `asl/block/model/schema/header.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-SCHEMA-HEADER}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-schema-header-purpose role=purpose-scope -->
## 用途与范围

本单元命名指令束头部 schema 这一概念。它不包含可执行 ASL。其唯一内容是对 Tile 绑定操作数单元的依赖，因此头部 schema 由它所依赖的单元定义。

请把本页当作说明指令束头部是什么的指南来阅读。

<!-- PTO-READER-BLOCK: block-model-schema-header-concepts role=concepts-state -->
## 概念与可见状态

头部是指令束中位于 `BSTART` 与第一条主体指令之间的部分。当 `_BundleActive` 为 true 且 `_BundleBodyActive` 为 false 时，头部命令写入逐指令束配置：

- 通过 `B.DIM` 和 `C.B.DIMI` 写入维度；
- 通过 `B.CATR`、`B.DATR`、`B.FPATR` 和 `B.HINT` 写入属性；
- 通过 `B.IOR`、`B.IOT` 和 `B.IOS` 写入绑定，并可使用 `B.SUBVIEW` 和 `B.ASSEMBLE` 等范围修饰命令。

<!-- PTO-READER-BLOCK: block-model-schema-header-rules role=rules-interactions -->
## 规则与交互

指令束中的第一条标量指令进入主体。此后，头部命令会引发 `Fault_BundleControl`，但零参与的 `B.IOT` 或 `B.IOS` 是空操作。

设计要点：配置先收集，在提交时应用。头部命令只记录值和绑定，所选操作在提交时一次性读取完整集合。因此操作 schema 检查看到的是整个头部，并且在分配任何目标 Tile 之前运行。

设计要点：大多数头部记录在每个指令束中只能写入一次，第二次写入会产生故障。头部不能悄悄改变先前命令设置的值。

<!-- PTO-READER-BLOCK: block-model-schema-header-boundaries role=boundaries -->
## 架构边界

本单元不定义任何合法性。放置位置在命令分派中检查，操作数结构在 Tile 绑定和 schema 单元中检查，操作合法性在提交时检查。

整个头部在提交时被清除，因此没有头部值会泄漏到下一个指令束。

<!-- PTO-READER-BLOCK: block-model-schema-header-example role=example-usage -->
## 非规范阅读示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

由 `BSTART.VEC TADD, FP32`、`B.DIM a0, 0, ->LB0` 以及一条带有两个源、一个目标且置位 `last` 的 `B.IOT` 组成的头部是完整的。随后的 `BSTOP` 提交它。若改为把 `B.DIM` 放在标量主体指令之后，则会引发 `Fault_BundleControl`。

<!-- PTO-READER-BLOCK: block-model-schema-header-related role=related-owners-navigation -->
## 相关所有者

- [Tile 绑定](../operands/tile-bindings.md)是本单元的依赖项。
- [命令分派](../dispatch/commands.md)强制执行头部放置规则。
- [维度](dimensions.md)和[属性](attributes.md)定义头部写入器。
- [进入与停止](../lifecycle/enter-stop.md)定义主体进入。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/schema/header.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-SCHEMA-HEADER","surface":"block","classification":["model","schema","header"],"depends_on":["PTO-BLOCK-MODEL-OPERANDS-TILE-BINDINGS"]}
// This unit owns the named block-model concept; executable state is defined by its dependencies.
```
<!-- GENERATED-ASL-END: unit -->
