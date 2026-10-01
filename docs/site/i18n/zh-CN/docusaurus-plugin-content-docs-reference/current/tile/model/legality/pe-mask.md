<!-- GENERATED FROM: asl/tile/model/legality/pe-mask.asl -->
# PE Mask

**Normative ASL source:** `asl/tile/model/legality/pe-mask.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-LEGALITY-PE-MASK}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-legality-pe-mask-purpose role=purpose-scope -->
## 用途与范围

本单元定义两个用于处理四位 PE 掩码的小型纯函数。PE 掩码选择一个核的四个处理单元（PE）中哪些参与操作，或持有某个 Tile 的副本。

- `PEMaskPopulation` 统计掩码中为 `1` 的位数。结果范围为 0 到 4。
- `TileCoreAllocationBytes` 将该计数乘以每 PE 字节数，得到对象在整个核上占用的字节数。

两个函数都不读写架构状态，自身也不会引发故障。调用者在各自的合法性与准入检查中使用这些结果。

<!-- PTO-READER-BLOCK: tile-model-legality-pe-mask-concepts role=concepts-state -->
## 概念与可见状态

掩码把 PE0 放在最高位，因此 `1000` 选择 PE0，`0001` 选择 PE3。按 PE 身份索引掩码的代码必须经过 `PTOPEMaskBitOfPEIdentity`，它返回位 `3 - pe_identity`。

设计要点：`PEMaskPopulation` 只统计置位的位数，因此不需要身份转换。无论采用哪种位序，计数都相同，`1000` 与 `0001` 的计数都为 1。

每 PE 大小与全核大小是不同的量。以掩码 `1100` 分配、容量为 4096 字节的 Tile，在 PE0 和 PE1 中各占用 4096 字节，在整个核上共占用 8192 字节。

<!-- PTO-READER-BLOCK: tile-model-legality-pe-mask-rules role=rules-interactions -->
## 规则与交互

`TileCoreAllocationBytes` 用于全核总量。例如，Local 容量单元中的 `TileCapacityInUse` 对每个已分配的 Local Tile 寄存器累加该值，`TileCapacityInUseExcept` 对除一个被排除寄存器外的所有已分配寄存器累加该值，`InstructionContractCoreCapacity_B_IOT` 用它报告 `B.IOT` 尺寸码的全核容量。

设计要点：新 Local Tile 的准入不使用全核总量。`LocalTileAllocationFitsExcept` 将每个被选中 PE 自己的池与 `TileCapacityLimitBytes` 比较。因此只有当 Tile 能放入它指定的每一个 PE 时才能分配，而不是仅仅放得下这些池的总和。

`PEMaskPopulation` 的用途例如区分单个发起 PE 与协作组：

- Shared Tile 搬运把计数 1 视为单一发起者，Shared Tile 寄存器更新在决定描述符更新如何完成时检查计数是否为 1。
- weight-to-Shared 分派路径把该计数作为被选中 PE 的数量，并据此在单一与协作行为之间选择。
- TIMG2COL 执行与范围修饰符检查 Shared 绑定掩码的计数。

<!-- PTO-READER-BLOCK: tile-model-legality-pe-mask-boundaries role=boundaries -->
## 架构边界

掩码 `0000` 的计数为 0，因此 `TileCoreAllocationBytes` 对它返回 0。这两个函数不判断零掩码是否合法。该判断属于调用者，例如分配转换与指令束操作数检查。

这两个函数不检查 `per_pe_bytes` 是否为合法容量。容量合法性由 `TileCapacityIsLegal` 和 Local 容量单元负责。

<!-- PTO-READER-BLOCK: tile-model-legality-pe-mask-example role=example-usage -->
## 非规范阅读示例

取掩码 `1011`，每 PE 大小为 2048 字节。

- 置位的是 PE0、PE2 和 PE3，因此 `PEMaskPopulation` 返回 3。
- `TileCoreAllocationBytes` 返回 3 x 2048 = 6144 字节。
- 准入仍逐个检查这三个 PE 的池；PE1 不被计费。

使用掩码 `0000` 时，同样的大小得到计数 0 和 0 个全核字节。

<!-- PTO-READER-BLOCK: tile-model-legality-pe-mask-related role=related-owners-navigation -->
## 相关所有者

- [核与 PE 拓扑](../../../arch/programming-model/core-pe-topology.md) 定义 PE 身份与掩码位序。
- [Local 容量](../capacity/local.md) 累加全核字节并检查每 PE 的池。
- [Shared 容量](../capacity/shared.md) 把 Shared Tile 用量加到 Local 总量上。
- [Tile 分配](../state/allocation.md) 使用分配掩码。
- [B.IOT](../../../block/operands/B.IOT.md) 报告尺寸码的每 PE 容量与全核容量。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/legality/pe-mask.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-LEGALITY-PE-MASK","surface":"tile","classification":["model","legality","pe-mask"],"depends_on":["PTO-TILE-MODEL-STATE-TYPES","PTO-ARCH-PROGRAMMING-MODEL-CORE-PE-TOPOLOGY"]}
pure func PEMaskPopulation(pe_mask: bits(4)) => integer {0..4}
begin
    var count: integer {0..4} = 0;
    for lane = 0 to 3 do
        if pe_mask[lane] == '1' then
            count = (count + 1) as integer {0..4};
        end;
    end;
    return count;
end;

pure func TileCoreAllocationBytes(pe_mask: bits(4),
                                  per_pe_bytes: integer) => integer
begin
    return PEMaskPopulation(pe_mask) * per_pe_bytes;
end;
```
<!-- GENERATED-ASL-END: unit -->
