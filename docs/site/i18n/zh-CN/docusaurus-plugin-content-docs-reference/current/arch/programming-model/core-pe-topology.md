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

一个 PTO Core 包含四个处理单元（PE），编号为 PE0 到 PE3。本单元固定程序所命名的各寄存器命名空间的大小，并定义 PE 编号如何映射到四位 PE 掩码中的某一位。

需要核对数量和掩码索引时，应查看本页。本单元不定义指令行为或内存排序。

<!-- PTO-READER-BLOCK: arch-core-pe-topology-concepts-state role=concepts-state -->
## 命名空间与标识

| 命名空间 | 数量 | 说明 |
| --- | --- | --- |
| 标量寄存器编码 | `32` | 五位选择器空间 |
| 绝对 GPR | `24` | 选择器 `0` 到 `23` |
| 临时队列 | `2` | T 与 U，每个深度为 `4` |
| 谓词寄存器 | `8` | 每个宽 `32` 位 |
| ACR | `16` | 访问控制环 |
| Local Tile 寄存器 | `64` | `PTO_TILE_REGISTER_COUNT` |
| Shared Tile 寄存器 | `64` | `PTO_SHARED_TILE_COUNT` |

标量命名空间是由 `32` 个编码组成的五位选择器空间：`24` 个绝对 GPR，加上两个指令束局部临时队列 T 与 U 的八个条目。

设计要点：选择器 `24` 到 `31` 不是寄存器。作为源时，它们命名队列位置 `T#1` 到 `T#4` 与 `U#1` 到 `U#4`；作为目标时，`31` 压入 T，`30` 压入 U，`24` 到 `29` 不写入任何内容。这也是 GPR 文件只有 `24` 项而不是 `32` 项的原因。

语义 PE 标识是整数 `0` 到 `3`，读作 PE0 到 PE3。

<!-- PTO-READER-BLOCK: arch-core-pe-topology-rules-interactions role=rules-interactions -->
## 标识到掩码的规则

架构 PE 掩码宽四位，并把 PE0 放在最高位：PE0 映射到位 `3`，PE1 映射到位 `2`，PE2 映射到位 `1`，PE3 映射到位 `0`。

`PTOPEMaskBitOfPEIdentity` 通过计算 `3 - pe_identity` 完成这一映射。

设计要点：这个桥接之所以是显式函数，是因为 PE 编号与位编号方向相反。任何按语义 PE 标识索引掩码的使用者都必须经过该函数，而不能把 PE 编号直接当作位索引。写成二进制字面量时，掩码从左到右依次对应 PE0、PE1、PE2、PE3。

<!-- PTO-READER-BLOCK: arch-core-pe-topology-boundaries role=boundaries -->
## 模型边界

`PTO_MODEL_MEMORY_AGENTS` 和 `PTO_MODEL_MEMORY_EVENTS` 把可执行模型分别定为 `4` 个代理和 `16` 个事件。其 `PTO_MODEL_` 前缀表明这些是模型边界；本页不会把这些值泛化成额外的实现要求。

在可执行模型中，内存代理标识也用于索引每 PE 的标量寄存器文件，因此每个 PE 都有自己的 GPR 文件。

<!-- PTO-READER-BLOCK: arch-core-pe-topology-example-usage role=example-usage -->
## 非规范索引示例

当读者从语义 PE2 出发时，应先应用桥接再索引掩码：`3 - 2` 得到掩码位 `1`。直接把 `2` 当作位索引会选中错误的语义 PE，即 PE1。

因此掩码 `1100` 选中 PE0 和 PE1：位 `3` 是 PE0，位 `2` 是 PE1。掩码 `0001` 只选中 PE3。

<!-- PTO-READER-BLOCK: arch-core-pe-topology-related-owners role=related-owners-navigation -->
## 相关所有者

- [架构概览](../overview/architecture.md)是建立顶层架构标识的依赖项。
- [标量寄存器](scalar-registers.md)使用当前内存代理标识进行每 PE GPR 访问。
- [Tile 寄存器](tile-registers.md)是具名的 Tile 寄存器编程模型所有者。
- [PE 掩码合法性](../../tile/model/legality/pe-mask.md)统计被选中的 PE，并从掩码推导整个 Core 的分配大小。
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
