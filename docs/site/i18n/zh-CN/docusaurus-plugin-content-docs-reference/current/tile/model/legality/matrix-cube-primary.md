<!-- GENERATED FROM: asl/tile/model/legality/matrix-cube-primary.asl -->
# Matrix CUBE Primary

**Normative ASL source:** `asl/tile/model/legality/matrix-cube-primary.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-LEGALITY-MATRIX-CUBE-PRIMARY}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-legality-matrix-cube-primary-purpose role=purpose-scope -->
## 用途与范围

本单元负责 CUBE Matrix 族 Local 主操作数的描述符检查，该族包括 `TMATMUL`、`TGEMV` 及其 `_BIAS`、`_ACC` 与 `_MX` 变体。主操作数是参与乘积的矩阵：A（左侧 M x K 矩阵）、B（右侧 K x N 矩阵）、C（`_ACC` 形式的显式累加器输入）以及 D（目标）。

它定义六个谓词：

- `TileMatrixMLayoutLegal` 把 M 侧布局与 M 维度配对检查。
- `TileMatrixLocalPrimaryInfoLegal` 是 A、B 与 C 检查共用的描述符检查；D 由块派发中的 CUBE 目标解析器检查。
- `TileMatrixCubeInfosMatchDimensions` 按 M、N、K 检查一对 Local A 与 Local B。
- `TileMatrixLocalMOperandSchemaLegal` 与 `TileMatrixLocalNOperandSchemaLegal` 分别检查一个 A 源或一个 B 源。
- `TileMatrixLocalCubeAccumulatorSchemaLegal` 检查 C 源。

它们都是只读的。它们返回布尔值，不改变任何状态。

<!-- PTO-READER-BLOCK: tile-model-legality-matrix-cube-primary-concepts role=concepts-state -->
## 概念与可见状态

CUBE 布局把 Tile 存储为固定大小的单元，而不是普通的行。M 侧布局是 `CUBE_M16` 与 `CUBE_M32`，其物理行数恰为 16 或 32。N 侧布局是 `CUBE_N8`。

`TileMatrixMLayoutLegal` 在 `CUBE_M16` 且 M 不大于 16，或 `CUBE_M32` 且 M 不大于 32 时返回 TRUE。其他布局一律返回 FALSE。

`TileMatrixLocalPrimaryInfoLegal` 读取一个 `TileInfo` 记录，并要求以下全部成立：

- `TileCubeDescriptorLegal` 成立，即 Tile 已分配、为数值类型，且其记录的 CUBE 重复数、单元数与字节数与形状一致。
- `contents_defined` 为 TRUE。
- `valid_rows`、`valid_columns`、`data_type` 与 `layout` 精确等于期望值。

设计要点：已定义性测试是描述符检查的一部分。已分配但从未写入的 Tile 在此处失败，因此 Matrix 操作会在读取任何生产者未定义的载荷之前被拒绝。

<!-- PTO-READER-BLOCK: tile-model-legality-matrix-cube-primary-rules role=rules-interactions -->
## 规则与交互

各角色规则遵循 NDF 条款 `PTO-CUBE-LOCAL-MATRIX-001`：

- A 的有效形状必须为 [M, K]，使用其自身类型，且布局须被 `TileMatrixMLayoutLegal` 接受。
- B 的有效形状必须为 [K, N]，布局为 `CUBE_N8`。
- C 的有效形状必须为 [M, N]，使用结果类型，并使用调用者给出的期望 M 布局。

`TileMatrixCubeInfosMatchDimensions` 在 M、N 或 K 为 0 时立即返回 FALSE，之后应用上述 A 与 B 规则。

`TileMatrixLocalCubeAccumulatorSchemaLegal` 额外增加一条容量规则。当 `_BundleFixedPointAttributes` 中的 `pre_quant_mode` 为 0 时，C 的容量必须等于 D 的容量。当非零的预量化模式对输出做转换时，两者容量可以不同。

设计要点：形状检查把有效行数与有效列数同 M、N、K 比较，而不是同由容量推导出的行数比较。M 布局只把 M 限制在 16 或 32 以内。正是这样，M、N、K 维度才如 NDF 条款所要求的那样与每 PE 的 TSize 无关。

设计要点：Matrix 主操作数永远不会以 `U64` 被接受。`TileMatrixCubeInfosMatchDimensions` 从描述符本身取得每个期望类型，因此单独使用时它会接受 `U64` 的 `CUBE_N8` B。它的调用者还会用 `TileOrdinaryMatrixInputTypeSupported` 或 `TileMXInputTypeSupported` 比较类型，而这两个列表都不包含 `U64`。`CUBE_N8` 与 `U64` 的组合留给辅助向量参数使用。

<!-- PTO-READER-BLOCK: tile-model-legality-matrix-cube-primary-boundaries role=boundaries -->
## 架构边界

这些谓词在预检阶段运行。在指令束路径中，`ExecuteBundleTMATMULOperation` 在分配 D 或快照任何源之前，经由 `BundleMatrixLocalMathematicalSourcesLegal` 调用它们。结果为 FALSE 时引发 `Fault_TileLegality`。

在当前 ASL 中经 grep 核实的其他调用者：

- `TileMatrixMLayoutLegal` 还在 CUBE 目标解析器中检查 D 的布局，并在 `BundleMatrixCooperativeMLayout` 中检查解析出的布局。
- `TileMatrixCubeInfosMatchDimensions` 为直接 Tile 合法性处理函数支撑 `TileMatrixShapeLegal`，是 `TileMatrixInfoOptionalScalesLegal` 中主操作数形状的可选判定之一，并在全 Local 指令束预检之后出现在一个 `assert` 中。
- `TileMatrixLocalCubeAccumulatorSchemaLegal` 在指令束路径中分配之后也被 `assert` 断言。

Shared 主操作数由块派发中的 Shared Matrix schema检查，不在此处检查。

<!-- PTO-READER-BLOCK: tile-model-legality-matrix-cube-primary-example role=example-usage -->
## 非规范阅读示例

考虑一个全 Local 的 `TMATMUL`，M = 20，N = 24，K = 40，A 与 B 都是 FP16。

- 布局为 `CUBE_M16` 的 A 不合法：20 大于 16。
- 布局为 `CUBE_M32` 的 A 通过布局规则，因为 20 不大于 32。其描述符需要有效形状 [20, 40]、FP16 以及 32 个物理行。
- B 需要有效形状 [40, 24]、FP16 以及布局 `CUBE_N8`。
- 若 B 已分配但尚无生产者写入，则 `contents_defined` 为 FALSE，指令束在分配 D 之前以 `Fault_TileLegality` 故障。

本示例只用于演示当前 ASL 所有者，不替代规范操作。

<!-- PTO-READER-BLOCK: tile-model-legality-matrix-cube-primary-related role=related-owners-navigation -->
## 相关所有者

- [CUBE 单元几何](../shape/cube-cell.md) 负责 `TileCubeDescriptorLegal` 的输入与单元计数。
- [Matrix 操作数](matrix-operands.md) 遍历 Local 源流并调用这些检查。
- [Matrix 形状](matrix-shape.md) 在 `TileMatrixCubeInfosMatchDimensions` 之上构建直接 Tile 合法性处理函数。
- [CUBE TMATMUL 派发](../../../block/model/dispatch/cube-tmatmul.md) 展示预检顺序。
- [TMATMUL](../../matrix-and-matrix-vector/matrix-matrix/TMATMUL.md) 是参考指令。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/legality/matrix-cube-primary.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-LEGALITY-MATRIX-CUBE-PRIMARY","surface":"tile","classification":["model","legality","matrix-cube-primary"],"depends_on":["PTO-TILE-MODEL-LEGALITY-MATRIX-SHAPE"]}

// NDF-BEGIN: PTO-CUBE-LOCAL-MATRIX-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// Local Matrix primary A, C, and D MUST use one compatible CUBE_M16 or
// CUBE_M32 layout, primary B MUST use CUBE_N8, and their logical M/N/K
// dimensions MUST remain independent of per-PE TSize. Matrix primary roles
// never authorize U64 CUBE descriptors; CUBE_N8/U64 is auxiliary-only.
// NDF-END: PTO-CUBE-LOCAL-MATRIX-001

pure func TileMatrixMLayoutLegal(
    layout: TileLayout,
    m: integer {1..65535}) => boolean
begin
    return (layout == TileLayout_CUBE_M16 && m <= 16) ||
           (layout == TileLayout_CUBE_M32 && m <= 32);
end;

readonly func TileMatrixLocalPrimaryInfoLegal(
    tile: TileInfo,
    valid_rows: integer {1..65535},
    valid_columns: integer {1..65535},
    data_type: TileDataType,
    expected_layout: TileLayout) => boolean
begin
    return TileCubeDescriptorLegal(tile) && tile.contents_defined &&
           tile.valid_rows == valid_rows &&
           tile.valid_columns == valid_columns &&
           tile.data_type == data_type &&
           tile.layout == expected_layout;
end;

readonly func TileMatrixCubeInfosMatchDimensions(
    left: TileInfo, right: TileInfo,
    m: integer {0..65535}, n: integer {0..65535},
    k: integer {0..65535}) => boolean
begin
    if m == 0 || n == 0 || k == 0 then return FALSE; end;
    let positive_m = m as integer {1..65535};
    let positive_n = n as integer {1..65535};
    let positive_k = k as integer {1..65535};
    return TileMatrixMLayoutLegal(left.layout, positive_m) &&
           TileMatrixLocalPrimaryInfoLegal(
               left, positive_m, positive_k,
               left.data_type, left.layout) &&
           TileMatrixLocalPrimaryInfoLegal(
               right, positive_k, positive_n,
               right.data_type, TileLayout_CUBE_N8);
end;

readonly func TileMatrixLocalMOperandSchemaLegal(
    source: TileIndex,
    valid_rows: integer {1..65535},
    valid_columns: integer {1..65535},
    data_type: TileDataType) => boolean
begin
    let tile = _Tiles[[source]];
    return TileMatrixMLayoutLegal(tile.layout, valid_rows) &&
           TileMatrixLocalPrimaryInfoLegal(
               tile, valid_rows, valid_columns, data_type, tile.layout);
end;

readonly func TileMatrixLocalNOperandSchemaLegal(
    source: TileIndex,
    valid_rows: integer {1..65535},
    valid_columns: integer {1..65535},
    data_type: TileDataType) => boolean
begin
    return TileMatrixLocalPrimaryInfoLegal(
        _Tiles[[source]], valid_rows, valid_columns,
        data_type, TileLayout_CUBE_N8);
end;

readonly func TileMatrixLocalCubeAccumulatorSchemaLegal(
    accumulator: TileIndex,
    m: integer {1..65535},
    n: integer {1..65535},
    result_type: TileDataType,
    expected_layout: TileLayout,
    destination_capacity: integer {0..262144}) => boolean
begin
    let tile = _Tiles[[accumulator]];
    let output_converted =
        UInt(_BundleFixedPointAttributes.pre_quant_mode) != 0;
    return TileMatrixLocalPrimaryInfoLegal(
               tile, m, n, result_type, expected_layout) &&
           (output_converted ||
            tile.capacity_bytes == destination_capacity);
end;
```
<!-- GENERATED-ASL-END: unit -->
