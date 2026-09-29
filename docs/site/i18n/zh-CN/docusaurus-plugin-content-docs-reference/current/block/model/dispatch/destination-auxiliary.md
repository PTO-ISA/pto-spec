<!-- GENERATED FROM: asl/block/model/dispatch/destination-auxiliary.asl -->
# Destination Auxiliary

**Normative ASL source:** `asl/block/model/dispatch/destination-auxiliary.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-DESTINATION-AUXILIARY}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-dispatch-destination-auxiliary-purpose role=purpose-scope -->
## 用途与范围

本单元包含在指令束目标定形和分配过程中使用的小型辅助函数。它不决定存在哪些目标；这由目标形状所有者和 CUBE 目标所有者决定。

它定义五个函数：

- `BundleGroupMaxColumns` 计算 GroupMax 辅助输出的列数。
- `BundleDestinationIsOrdinaryTCVT` 识别非 CUBE 的 `TCVT` 目标。
- `ConfigureBundleTileDestination` 通过正确的分配族写入目标描述符。
- `SmallestTilePhysicalColumns` 返回能容纳某个有效列数的最小 2 的幂。
- `MarkBundleTIMG2COLDestinationsMatrix`，它只包含 `assert TRUE`。

<!-- PTO-READER-BLOCK: block-model-dispatch-destination-auxiliary-concepts role=concepts-state -->
## 概念与可见状态

GroupMax 输出为每组 `group_n` 列存储一个最大值。`BundleGroupMaxColumns` 读取 `_BundleFixedPointAttributes.group_max_en` 和 `group_n_code`。`BundleFPATRGroupN` 把编码 0 到 9 映射为 0、8、16、32、48、64、80、96、112 和 128。当 GroupMax 启用且 `group_n` 非零时，结果是 `columns` 除以 `group_n` 并向上取整。否则原样返回列数。

`ConfigureBundleTileDestination` 是这里唯一写状态的函数。它通过两个分配族之一，写入给定索引的 `_Tiles` 描述符和 `_TileAllocationMasks` 条目。

<!-- PTO-READER-BLOCK: block-model-dispatch-destination-auxiliary-rules role=rules-interactions -->
## 规则与交互

`ConfigureBundleTileDestination` 按其 `tgpr2t` 参数路由。目标形状所有者对 `TGPR2T` 以及任何 `CUBE_M16` 或 `CUBE_M32` 目标布局设置该参数。

- 当 `tgpr2t` 为真时，它以提供的物理行列数调用 `ConfigureCubeTileForMaskWithPhysical`，并返回该调用的结果。
- 否则它调用 `ConfigureTileForMask` 并返回真。当 `preserve_physical_rows` 为真时它传入提供的物理行数，否则传入由容量、列数和类型推导的行数。

设计要点：当形状或容量不合适时，CUBE 分配族返回假，本函数把该结果传给调用者，调用者引发 `Fault_TileAllocation`。普通分配族则断言其前置条件，因此调用者必须在本调用之前验证形状。

设计要点：调用者依据 `BundleDestinationIsOrdinaryTCVT` 设置 `preserve_physical_rows`，并提供源的物理行数。`ConfigureTileForMask` 只有在列数不是 2 的幂且该类型允许奇数物理列时才保留提供的行数；否则它使用由容量推导的行数。因此对于这类奇数列形状，非 CUBE 的 `TCVT` 目标可以保留其源的行数。

`exact_cube_columns` 参数被接受，但在当前函数体中未被读取。

<!-- PTO-READER-BLOCK: block-model-dispatch-destination-auxiliary-boundaries role=boundaries -->
## 架构边界

在当前 ASL 中搜索，找不到 `SmallestTilePhysicalColumns` 或 `MarkBundleTIMG2COLDestinationsMatrix` 的调用者。后者没有效果；其注释说明目标表示由显式布局契约确立，不会物化执行引擎或位置标签。

`BundleGroupMaxColumns` 被使用的例子包括 CUBE 目标所有者和目标形状所有者。它不验证 `group_n_code`；`B.FPATR` 所有者把该编码限制在 0 到 9。

本单元自身不引发故障。

<!-- PTO-READER-BLOCK: block-model-dispatch-destination-auxiliary-example role=example-usage -->
## 非规范阅读示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

假设 `B.FPATR` 设置 `group_max_en` 为真、`group_n_code` 为 3，因此 `group_n` 为 32。对于有 100 列的 D 输出，`BundleGroupMaxColumns(100)` 返回 `ceil(100 / 32)`，即 4。当 `group_max_en` 为假时，它返回 100。

作为对照，`SmallestTilePhysicalColumns(100)` 返回 128，即不小于 100 的最小 2 的幂。

<!-- PTO-READER-BLOCK: block-model-dispatch-destination-auxiliary-related role=related-owners-navigation -->
## 相关所有者

- [目标形状](destination-shape.md) 调用 `ConfigureBundleTileDestination` 和 `BundleDestinationIsOrdinaryTCVT`。
- [CUBE 目标](cube-destination.md) 为矩阵目标组使用 `BundleGroupMaxColumns`。
- [Tile 分配](../../../tile/model/state/allocation.md) 定义两个分配族。
- [B.FPATR](../../attributes/B.FPATR.md) 是 GroupMax 控制的指令页面。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/destination-auxiliary.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-DESTINATION-AUXILIARY","surface":"block","classification":["model","dispatch","destination-auxiliary"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-COMPARISON-SCHEMA"]}
pure func SmallestTilePhysicalColumns(
    valid_columns: integer {1..65535}) => integer {0..65535}
begin
    var columns: integer = 1;
    for exponent = 0 to 15 do
        if valid_columns <= columns then
            return columns as integer {1..32768};
        end;
        columns = columns * 2;
    end;
    return 0;
end;

readonly func BundleGroupMaxColumns(columns: integer {0..65535})
                                      => integer {0..65535}
begin
    let group_n = BundleFPATRGroupN(_BundleFixedPointAttributes.group_n_code);
    if !_BundleFixedPointAttributes.group_max_en || group_n == 0 then
        return columns;
    end;
    assert group_n != 0;
    let nonzero_group_n = group_n as integer {8,16,32,48,64,80,96,112,128};
    return ((columns + (nonzero_group_n - 1)) DIVRM nonzero_group_n)
        as integer {0..65535};
end;

func MarkBundleTIMG2COLDestinationsMatrix()
begin
    // Destination representation is established by the explicit layout
    // contract; no execution-engine/location tag is materialized.
    assert TRUE;
end;

readonly func BundleDestinationIsOrdinaryTCVT(
    decoded_operation: integer {0..PTO_TILE_OPERATION_COUNT},
    cube: boolean) => boolean
begin
    return !cube && decoded_operation != PTO_TILE_OPERATION_COUNT &&
        TileOperationOfIndex(decoded_operation as integer {
            0..PTO_TILE_OPERATION_COUNT-1}) == TileOperation_TCVT;
end;

func ConfigureBundleTileDestination(
    index: TileIndex, capacity_bytes: integer {0..262144},
    physical_rows: integer {0..65535},
    physical_columns: integer {0..65535},
    valid_rows: integer {0..65535}, columns: integer {0..65535},
    valid_columns: integer {0..65535}, data_type: TileDataType,
    layout: TileLayout, allocation_mask: bits(4), tgpr2t: boolean,
    exact_cube_columns: boolean, preserve_physical_rows: boolean)
    => boolean
begin
    if tgpr2t then
        return ConfigureCubeTileForMaskWithPhysical(index, capacity_bytes,
            physical_rows, physical_columns, valid_rows, valid_columns,
            data_type, layout, allocation_mask);
    end;
    ConfigureTileForMask(index, capacity_bytes, if preserve_physical_rows then
        physical_rows else DerivedTileRows(capacity_bytes, columns, data_type), columns,
        valid_rows, valid_columns, data_type, layout,
        allocation_mask);
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: unit -->
