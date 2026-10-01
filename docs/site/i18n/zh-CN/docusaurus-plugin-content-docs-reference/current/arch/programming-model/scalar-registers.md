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

本单元定义标量通用寄存器（GPR）的读写方式。一个 Core 中的四个 PE 各有自己私有的一组 `24` 个 64 位 GPR。

访问路径有两条：一条针对当前正在执行的 PE，另一条显式指定 PE。

<!-- PTO-READER-BLOCK: arch-scalar-registers-concepts-state role=concepts-state -->
## 当前代理与每 PE 访问

`ReadGPR` 和 `WriteGPR` 使用 `_CurrentMemoryAgent`（正在执行的 PE 的标识）委托给 `ReadPEGPR` 和 `WritePEGPR`。每 PE 辅助函数同时用选定的内存代理标识和 GPR 索引访问 `_PEGPRs`。

设计要点：指令编码的是 GPR 编号，而不是 PE。因此同一个已编码选择器会在正在执行的 PE 自己的文件中解析。当一个操作涉及多个 PE 时，例如 Shared Tile 内存操作，ASL 会通过每 PE 辅助函数分别从每个 PE 的文件中读取该选择器，使每个 PE 都能提供自己的基址或步长。

<!-- PTO-READER-BLOCK: arch-scalar-registers-rules-interactions role=rules-interactions -->
## 零寄存器行为

每个 PE 的 GPR 索引 `0` 都读作 `Zeros{PTO_XLEN}`。写索引 `0` 不产生状态效果。

对于每个非零索引，读取返回所选 `_PEGPRs` 条目，写入则用给定 `Word` 替换同一条目。

设计要点：索引 `0` 既可作为恒零源，也可作为丢弃结果的目标。由于两个辅助函数都在访问 `_PEGPRs` 之前检查索引，任何写入序列都无法使索引 `0` 读出零以外的值。

<!-- PTO-READER-BLOCK: arch-scalar-registers-boundaries role=boundaries -->
## 架构边界

当前代理包装函数不会把一次写入广播到多个 PE。它们只选择 `_CurrentMemoryAgent`；显式跨 PE 检查或更新需要使用每 PE 辅助函数。

这些辅助函数只涵盖选择器 `0` 到 `23`。标量选择器 `24` 到 `31` 命名的是临时队列位置而不是 GPR，由标量操作数所有者处理。

<!-- PTO-READER-BLOCK: arch-scalar-registers-example-usage role=example-usage -->
## 非规范别名示例

假设当前内存代理是 PE1。用 `WriteGPR` 向非零索引写值，会改变 PE1 对应的 `_PEGPRs` 元素；通过 `ReadPEGPR` 读取 PE0 的同一索引则是另一次状态查找。

如果同一程序在 PE1 上向 GPR 索引 `0` 写入 `0x5`，随后对索引 `0` 的 `ReadGPR` 仍返回零。

<!-- PTO-READER-BLOCK: arch-scalar-registers-related-owners role=related-owners-navigation -->
## 相关所有者

- [Core PE 拓扑](core-pe-topology.md)定义命名空间数量和语义 PE 标识。
- [标量操作数](../../scalar/model/types/operands.md)把五位选择器映射到 GPR 和临时队列位置。
- [程序计数器](../state/program-counter.md)拥有 PC、TPC 和 BPC 访问，而不是把它们放入 GPR 数组。
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
