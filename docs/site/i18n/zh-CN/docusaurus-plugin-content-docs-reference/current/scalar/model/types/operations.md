<!-- GENERATED FROM: asl/scalar/model/types/operations.asl -->
# Operations

**Normative ASL source:** `asl/scalar/model/types/operations.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-SCALAR-MODEL-TYPES-OPERATIONS}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-model-types-operations-purpose role=purpose-scope -->
## 用途与范围

本单元声明标量模型共用的四个枚举。它不包含函数；每个值的行为由使用它的单元定义。

| 枚举 | 取值 | 行为所有者 |
| --- | --- | --- |
| `ScalarBinaryOperation` | 12 种整数运算 | [ALU 语义](../alu/semantics.md) |
| `ScalarRightModifier` | 4 种右操作数变换 | [ALU 语义](../alu/semantics.md) |
| `ExecutionControlRequest` | 4 种调度请求 | [SYS 语义](../sys/semantics.md) |
| `ScalarCondition` | 8 种比较条件 | [BRU 语义](../bru/semantics.md) |

<!-- PTO-READER-BLOCK: scalar-model-types-operations-concepts role=concepts-state -->
## 概念与可见状态

`ScalarBinaryOperation` 列出 `ADD`、`SUB`、`AND`、`OR`、`XOR`，移位 `SLL`、`SRL` 和 `SRA`，以及最小值和最大值运算 `MIN`、`MINU`、`MAX` 和 `MAXU`。后缀 U 表示无符号比较。

`ScalarRightModifier` 列出 `ScalarRight_None`、`ScalarRight_SignedWord`、`ScalarRight_UnsignedWord` 和 `ScalarRight_NegateOrNot`。

`ExecutionControlRequest` 列出 `ExecutionControl_SendEvent`、`ExecutionControl_WaitEvent`、`ExecutionControl_WaitInterrupt` 和 `ExecutionControl_WaitTimeout`。

`ScalarCondition` 列出 `EQ`、`NE`、`LT`、`GE`、`LTU`、`GEU`、`Z` 和 `NZ`。

这些类型都不保存状态。它们是译码和分派传给语义辅助函数的名称；`ExecuteControlRequest` 把请求记录在 `_LastControlRequest` 中。

<!-- PTO-READER-BLOCK: scalar-model-types-operations-rules role=rules-interactions -->
## 规则与交互

`ScalarRight_NegateOrNot` 是一个值、两种含义。`ApplyScalarRightModifier` 对逻辑族把它视为按位 NOT，其他情况下视为取负。

设计要点：二元译码对 NOT 和取负返回同一个值。ALU 分派传入 `logical_family`，因此由运算决定具体变换。这与汇编后缀一致：AND、OR 和 XOR 用 `.not`，ADD 和 SUB 用 `.neg`。

编码字段值并不等于枚举位置。例如，二元 ALU 译码把原始 `11` 映射为 `ScalarRight_None`，而比较译码把原始 `00` 映射为它。[标量译码辅助函数](../dispatch/decode.md)拥有这些映射。

`SYS` 分派把 `BSE`、`BWE`、`BWI` 和 `BWT` 依次映射为四种控制请求。

<!-- PTO-READER-BLOCK: scalar-model-types-operations-boundaries role=boundaries -->
## 架构边界

`ConditionHolds` 定义了 `Z` 和 `NZ`，但 BRU 分派中的 `ScalarConditionForOperation` 从不返回它们。当前 ASL 中没有已译码的标量形式选择它们。

`ScalarBinaryW` 以断言拒绝 `MIN`、`MINU`、`MAX` 和 `MAXU`。已译码分派只在 64 位形式中使用这四个运算。

本单元声明依赖指令分类单元；这些枚举都不直接引用它。

<!-- PTO-READER-BLOCK: scalar-model-types-operations-example role=example-usage -->
## 非规范阅读示例

`SrcRType` 原始值为 `10` 的 `XOR` 以 `ScalarBinary_XOR` 且 `logical_family` 为 TRUE 到达 `ExecuteDecodedBinary`。

- 二元译码把 `10` 映射为 `ScalarRight_NegateOrNot`。
- 由于该族是逻辑族，右操作数被按位取反。
- 左操作数为 0x0F、右操作数为 0x0F 且 `shamt` 为 0 时，右操作数变为 0xFFFFFFFFFFFFFFF0，结果为 0xFFFFFFFFFFFFFFFF。

同一原始值用于 `ADD` 时会改为对右操作数取负，得到 0x0F + (-0x0F) = 0。

<!-- PTO-READER-BLOCK: scalar-model-types-operations-related role=related-owners-navigation -->
## 相关所有者

- [ALU 语义](../alu/semantics.md)赋予 `ScalarBinaryOperation` 和 `ScalarRightModifier` 含义。
- [BRU 语义](../bru/semantics.md)求值 `ScalarCondition`。
- [SYS 语义](../sys/semantics.md)记录 `ExecutionControlRequest`。
- [指令分类](../../../arch/overview/instruction-classification.md)是声明的依赖。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/scalar/model/types/operations.asl -->
```asl
// PTO-UNIT: {"id":"PTO-SCALAR-MODEL-TYPES-OPERATIONS","surface":"scalar","classification":["model","types","operations"],"depends_on":["PTO-ARCH-OVERVIEW-INSTRUCTION-CLASSIFICATION"]}
type ScalarBinaryOperation of enumeration {
    ScalarBinary_ADD,
    ScalarBinary_SUB,
    ScalarBinary_AND,
    ScalarBinary_OR,
    ScalarBinary_XOR,
    ScalarBinary_SLL,
    ScalarBinary_SRL,
    ScalarBinary_SRA,
    ScalarBinary_MIN,
    ScalarBinary_MINU,
    ScalarBinary_MAX,
    ScalarBinary_MAXU
};

type ScalarRightModifier of enumeration {
    ScalarRight_None,
    ScalarRight_SignedWord,
    ScalarRight_UnsignedWord,
    ScalarRight_NegateOrNot
};

type ExecutionControlRequest of enumeration {
    ExecutionControl_SendEvent,
    ExecutionControl_WaitEvent,
    ExecutionControl_WaitInterrupt,
    ExecutionControl_WaitTimeout
};

type ScalarCondition of enumeration {
    ScalarCondition_EQ,
    ScalarCondition_NE,
    ScalarCondition_LT,
    ScalarCondition_GE,
    ScalarCondition_LTU,
    ScalarCondition_GEU,
    ScalarCondition_Z,
    ScalarCondition_NZ
};
```
<!-- GENERATED-ASL-END: unit -->
