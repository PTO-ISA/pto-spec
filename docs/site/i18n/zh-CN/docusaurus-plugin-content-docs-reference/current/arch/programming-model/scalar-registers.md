<!-- GENERATED FROM: asl/arch/programming-model/scalar-registers.asl -->
# Scalar Registers

**Normative ASL source:** `asl/arch/programming-model/scalar-registers.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-PROGRAMMING-MODEL-SCALAR-REGISTERS}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-scalar-registers-purpose-scope role=purpose-scope -->
## 用途与范围

本单元定义当前内存代理以及显式选择的 PE 的标量 GPR 读写行为。

<!-- PTO-READER-BLOCK: arch-scalar-registers-concepts-state role=concepts-state -->
## 当前代理与每 PE 访问

`ReadGPR` 和 `WriteGPR` 使用 `_CurrentMemoryAgent` 委托给 `ReadPEGPR` 和 `WritePEGPR`。每 PE 辅助函数同时用选定的内存代理标识和 GPR 索引访问 `_PEGPRs`。

<!-- PTO-READER-BLOCK: arch-scalar-registers-rules-interactions role=rules-interactions -->
## 零寄存器行为

每个 PE 的 GPR 索引 `0` 都读作 `Zeros{PTO_XLEN}`。写索引 `0` 不产生状态效果。

对于每个非零索引，读取返回所选 `_PEGPRs` 条目，写入则用给定 `Word` 替换同一条目。

<!-- PTO-READER-BLOCK: arch-scalar-registers-boundaries role=boundaries -->
## 架构边界

当前代理包装函数不会把一次写入广播到多个 PE。它们只选择 `_CurrentMemoryAgent`；显式跨 PE 检查或更新需要使用每 PE 辅助函数。

<!-- PTO-READER-BLOCK: arch-scalar-registers-example-usage role=example-usage -->
## 非规范别名示例

假设当前内存代理是 PE1。用 `WriteGPR` 向非零索引写值，会改变 PE1 对应的 `_PEGPRs` 元素；通过 `ReadPEGPR` 读取 PE0 的同一索引则是另一次状态查找。

<!-- PTO-READER-BLOCK: arch-scalar-registers-related-owners role=related-owners-navigation -->
## 相关所有者

- [Core PE 拓扑](core-pe-topology.md)定义命名空间数量和语义 PE 标识。
- [程序计数器](../state/program-counter.md)拥有 PC、TPC 和 BPC 访问，而不是把它们放进 GPR 数组。
- [中断寄存器](../system-registers/interrupt.md)是本单元声明的依赖项。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/programming-model/scalar-registers.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-PROGRAMMING-MODEL-SCALAR-REGISTERS","surface":"arch","classification":["programming-model","scalar-registers"],"depends_on":["PTO-ARCH-SYSTEM-REGISTERS-INTERRUPT"]}
readonly func ReadGPR(index: GPRIndex) => Word
begin
    return ReadPEGPR(_CurrentMemoryAgent, index);
end;

readonly func ReadPEGPR(pe: MemoryAgentId, index: GPRIndex) => Word
begin
    if index == 0 then
        return Zeros{PTO_XLEN};
    else
        return _PEGPRs[[pe]][[index]];
    end;
end;

func WriteGPR(index: GPRIndex, value: Word)
begin
    WritePEGPR(_CurrentMemoryAgent, index, value);
end;

func WritePEGPR(pe: MemoryAgentId, index: GPRIndex, value: Word)
begin
    if index != 0 then
        _PEGPRs[[pe]][[index]] = value;
    end;
end;
```
<!-- GENERATED-ASL-END: unit -->
