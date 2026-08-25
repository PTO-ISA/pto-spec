<!-- GENERATED FROM: asl/arch/programming-model/core-pe-topology.asl -->
# Core PE Topology

**Normative ASL source:** `asl/arch/programming-model/core-pe-topology.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-PROGRAMMING-MODEL-CORE-PE-TOPOLOGY}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-core-pe-topology-purpose-scope role=purpose-scope -->
## 用途与范围

本单元汇集 PTO 编程模型使用的固定命名空间大小，并定义语义 PE 标识与四位 PE 掩码之间的表示桥接规则。

需要核对数量或从标识换算掩码索引时，应查看本页。本单元不定义指令行为或内存排序。

<!-- PTO-READER-BLOCK: arch-core-pe-topology-concepts-state role=concepts-state -->
## 命名空间与标识

标量命名空间有 `32` 个寄存器编码，其中包括 `24` 个绝对 GPR，以及两个深度为 `4` 的临时队列。本单元还固定了 `8` 个宽度为 `32` 的谓词寄存器、`16` 个 ACR、`64` 个 Tile 寄存器和 `64` 个 Shared Tile 寄存器。

语义 PE 标识是从 `0` 到 `3` 的整数，通常读作 PE0 到 PE3。

<!-- PTO-READER-BLOCK: arch-core-pe-topology-rules-interactions role=rules-interactions -->
## 标识到掩码的规则

`PTOPEMaskBitOfPEIdentity` 用 `3` 减去语义 PE 标识，得到对应的掩码索引。

之所以需要这个桥接，是因为 PE0 位于四位架构掩码的最高位：PE0 映射到位 `3`，PE1 映射到位 `2`，PE2 映射到位 `1`，PE3 映射到位 `0`。

<!-- PTO-READER-BLOCK: arch-core-pe-topology-boundaries role=boundaries -->
## 模型边界

`PTO_MODEL_MEMORY_AGENTS` 和 `PTO_MODEL_MEMORY_EVENTS` 把可执行模型分别定为 `4` 个代理和 `16` 个事件。其 `PTO_MODEL_` 前缀表明这些是模型边界；本页不会把这些值泛化成额外的实现要求。

<!-- PTO-READER-BLOCK: arch-core-pe-topology-example-usage role=example-usage -->
## 非规范索引示例

当读者从语义 PE2 出发时，应先应用桥接再索引掩码：`3 - 2` 得到掩码位 `1`。直接把 `2` 当作位索引会选中错误的语义 PE。

<!-- PTO-READER-BLOCK: arch-core-pe-topology-related-owners role=related-owners-navigation -->
## 相关所有者

- [架构概览](../overview/architecture.md)是建立顶层架构标识的依赖项。
- [标量寄存器](scalar-registers.md)使用当前内存代理标识执行每 PE GPR 访问。
- [Tile 寄存器](tile-registers.md)是具名的 Tile 寄存器编程模型所有者。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/programming-model/core-pe-topology.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-PROGRAMMING-MODEL-CORE-PE-TOPOLOGY","surface":"arch","classification":["programming-model","core-pe-topology"],"depends_on":["PTO-ARCH-OVERVIEW-ARCHITECTURE"]}
// The five-bit scalar namespace contains 24 absolute GPRs and two four-entry
// bundle-local temporary queues (T and U).
constant PTO_SCALAR_REGISTER_COUNT = 32;
constant PTO_ABSOLUTE_GPR_COUNT = 24;
constant PTO_TEMPORARY_QUEUE_DEPTH = 4;
constant PTO_PREDICATE_REGISTER_COUNT = 8;
constant PTO_PREDICATE_WIDTH = 32;
constant PTO_ACR_COUNT = 16;
constant PTO_TILE_REGISTER_COUNT = 64;
constant PTO_SHARED_TILE_COUNT = 64;
constant PTO_MODEL_MEMORY_AGENTS = 4;
constant PTO_MODEL_MEMORY_EVENTS = 16;

// Fixed semantic PE identities are numbered PE0..PE3.  The architectural
// four-bit mask keeps PE0 in its high bit, so consumers that index a mask by
// semantic PE identity must use this explicit representation bridge.
pure func PTOPEMaskBitOfPEIdentity(
    pe_identity: integer {0..3}) => integer {0,1,2,3}
begin
    return (3 - pe_identity) as integer {0,1,2,3};
end;
```
<!-- GENERATED-ASL-END: unit -->
