---
{
  "schema_version": 1,
  "id": "header.header-intro",
  "kind": "header",
  "title": "Block/Header Model",
  "status": "active",
  "visibility": "public",
  "profile": "pto-isa-0.58.0",
  "family": "Overview",
  "sources": { "davincioo": "header/Intro.md" }
}
---
# Block/Header Model

Block/Header 指令描述块的生命周期、执行类别、操作数绑定、维度与属性以及编码形式。描述符先积累块状态；提交型指令在划分块边界的同时提交前一个块或结束当前块。

## 生命周期

1. `BSTART` 类指令开始新块并提交前一个块。
2. 非提交型 Block/Header 指令补充当前块的状态。
3. `BSTOP` 显式结束当前块；下一条提交型指令也可形成块边界。
4. 标准描述符为 32 位，部分形式提供压缩或扩展编码。

## 当前公开范围

PTO ISA 0.58.0 发布 26 份 active/public Block Intrinsics。TEPL、TLSU、CUBE、STD、FP 与 SYS 的入口分别由 Execution Classes 页面说明；未列入公开集合的历史名称或实验性描述不构成支持声明。

## 文档分类

- **Overview**：整体模型和通用块说明。
- **Lifecycle & Control**：开始、结束、块体定位和提示。
- **Execution Classes**：各执行类别的 BSTART 形式。
- **Operand Bindings**：Tile、Scalar、依赖和协作绑定。
- **Dimensions & Attributes**：维度、数据、控制和浮点属性。
- **Encoding Forms**：压缩、长编码和跨域形式。

具体编码、约束和适用范围以对应指令页面为准。
