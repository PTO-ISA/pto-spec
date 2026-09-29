<!-- GENERATED FROM: asl/tile/model/legality/matrix-postprocess.asl -->
# Matrix Postprocess

**Normative ASL source:** `asl/tile/model/legality/matrix-postprocess.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-LEGALITY-MATRIX-POSTPROCESS}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-legality-matrix-postprocess-purpose role=purpose-scope -->
## 用途与范围

本单元检查 CUBE Matrix 后处理所需的辅助 Local 源。后处理是 `B.FPATR` 在乘积之后选择的可选工作：输出量化（`PreQuantMode`）、激活（`ReluMode`）以及行或组最大值归约（`RowMaxEn`、`GroupMaxEn`）。

入口是 `BundleMatrixPostProcessSourcesLegal`。`ExecuteBundleTMATMULOperation` 对每种 `TMATMUL` 与 `TGEMV` 形式，在数学源通过之后调用它。本单元还定义：

- `TileMatrixLocalRowMaxSchemaLegal`，用于 RowMaxIn 源。
- `TileMatrixLocalVectorParameterSchemaLegal`，用于逐列的量化与 PReLU 参数 Tile。
- `TileMatrixVectorQuantContentsLegal` 与 `TileMatrixVectorReluContentsLegal`，检查参数载荷字。
- 三个流访问函数：`BundleMatrixSourceAt`、`BundleMatrixArchitecturalSourceAt` 与 `BundleMatrixDestinationAt`。

<!-- PTO-READER-BLOCK: tile-model-legality-matrix-postprocess-concepts role=concepts-state -->
## 概念与可见状态

访问函数按顺序对指令束 Tile 绑定计数。`BundleMatrixSourceAt(n)` 返回第 n 个有效源，`source0` 先于 `source1`，并优先返回已物化的子视图 Tile。`BundleMatrixArchitecturalSourceAt(n)` 则返回派生子视图的父 Tile；块派发用它把 CScale 源与目标 hand 比较。`BundleMatrixDestinationAt(n)` 返回第 n 个有效目标，因此 D 是序号 0，RowMaxOut 与 GroupMaxOut 随后。

有效类型是后处理看到的类型。`PreQuantMode` 为 0 时，它就是累加器类型本身（FP32、S32 或 U32）。模式非零时，它是 `BundleFPATROutputType` 给出的该模式输出类型。

向量参数 Tile 的有效形状为 [1, N]，类型为 `U64`，布局为 `CUBE_N8`。如 NDF 条款 `PTO-CUBE-AUX-CELLREG-001` 所述，这是唯一接受 `U64` CUBE 存储的 Matrix 角色。

<!-- PTO-READER-BLOCK: tile-model-legality-matrix-postprocess-rules role=rules-interactions -->
## 规则与交互

`BundleMatrixPostProcessSourcesLegal` 依次检查：

1. 累加器类型必须与 `PreQuantMode` 相符：模式 0 接受 FP32、S32 或 U32；`BundleFPATRModeUsesS32Accumulator` 列出的模式需要 S32；其他合法的非零模式需要 FP32。
2. 若设置了 `RowMaxEn` 或 `GroupMaxEn`，有效类型必须是 FP32、FP16 或 BF16。
3. 若同时设置了 `RowMaxEn` 与 `RowMaxInit`，下一个源是 RowMaxIn：有效形状 [M, 1]、有效类型，以及解析出的主 M 布局（`CUBE_M16` 或 `CUBE_M32`）。
4. 若模式使用向量参数，下一个源是量化 Tile。其 N 个字中的每一个都必须按该模式通过 `BundleFPATRQuantParameterWordLegal`。
5. 若 `ReluMode` 为 3（向量 PReLU），下一个源是 PReLU Tile。每个字的位 63 到 19 必须为零，且承载正零或正规格化的 FP19 值。

序号从 Local 数学源的数量（存在 CScale 时包括 CScale）开始，因此这些源总是排在乘积操作数之后。

设计要点：预检不仅检查描述符，也检查参数载荷。因此保留位与非法 FP19 值会在快照任何源或分配 D 之前以 `Fault_TileLegality` 被拒绝，而不是在写结果时才被发现。

设计要点：归约只接受 FP32、FP16 或 BF16 有效类型。模式 0 下的 U32 或 S32 累加器、S8 之类的整数输出模式，或 HiF8、E4M3 之类的 8 位浮点输出模式，都不能启用 `RowMaxEn` 或 `GroupMaxEn`。

<!-- PTO-READER-BLOCK: tile-model-legality-matrix-postprocess-boundaries role=boundaries -->
## 架构边界

此检查是 `ExecuteBundleTMATMULOperation` 中最后一项源检查。它在 Local 数学源、别名检查与 M 布局解析之后运行，并在 `ResolveBundleTMATMULDestination` 分配 D 之前运行。结果为 FALSE 时引发 `Fault_TileLegality`。

本单元不检查 `B.FPATR` 字段编码、由 GPR 携带的标量参数，也不检查目标 RowMaxOut 与 GroupMaxOut。它们分别由 `B.FPATR` 单元、操作数绑定与 CUBE 目标解析器负责。后处理执行单元之后读取相同的源序号。

<!-- PTO-READER-BLOCK: tile-model-legality-matrix-postprocess-example role=example-usage -->
## 非规范阅读示例

考虑一个全 Local 的 `TMATMUL`，A 与 B 为 FP16，M = 16，N = 24，`PreQuantMode` 0，`ReluMode` 3，并设置了 `RowMaxEn` 与 `RowMaxInit`。假设 `B.FPATR` 字段检查接受这一组合。

- 累加器类型为 FP32，模式 0 接受它。有效类型为 FP32，归约接受它。
- 共有 2 个数学源，因此序号 2 是 RowMaxIn：[16, 1]、FP32、使用 A 的 M 布局。
- 序号 3 是 PReLU Tile：[1, 24]、`U64`、`CUBE_N8`。全部 24 个字都会被检查；任何在位 18 以上有置位的字都会失败。

若改为 S8 输入且 `PreQuantMode` 为 2，累加器为 S32，模式 2 接受它，但有效类型为 S8。此时设置 `RowMaxEn` 会在检查模式 2 同样需要的量化 Tile 之前就在规则 2 处失败。

本示例只用于演示当前 ASL 所有者，不替代规范操作。

<!-- PTO-READER-BLOCK: tile-model-legality-matrix-postprocess-related role=related-owners-navigation -->
## 相关所有者

- [B.FPATR](../../../block/attributes/B.FPATR.md) 负责模式表与参数字检查。
- [FP19](../../../arch/data-types/fp19.md) 定义参数值类别。
- [Matrix 操作数](matrix-operands.md) 检查排在这些源之前的源。
- [后处理执行](../execution/postprocess.md) 应用量化、激活与归约。
- [CUBE TMATMUL 派发](../../../block/model/dispatch/cube-tmatmul.md) 调用此检查。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/legality/matrix-postprocess.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-LEGALITY-MATRIX-POSTPROCESS","surface":"tile","classification":["model","legality","matrix-postprocess"],"depends_on":["PTO-BLOCK-B-FPATR","PTO-BLOCK-MODEL-OPERANDS-SUBVIEW-DESCRIPTOR","PTO-BLOCK-MODEL-OPERANDS-TILE-BINDINGS","PTO-TILE-MODEL-LEGALITY-MATRIX-SHAPE"]}
// PTO-REQ-CUBE-POSTPROCESS-001: auxiliary Matrix operands are completely
// descriptor- and payload-preflighted before source snapshots or allocation.
// NDF-BEGIN: PTO-CUBE-AUX-CELLREG-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// Local Matrix auxiliary Tiles are orientation-specific CellReg data:
// RowMaxIn/Out and GroupMaxOut use EffectiveDType and the resolved primary
// M16/M32 layout, with their physical geometry and capacity derived from that
// effective type;
// Bias and vector quant/PReLU parameters use CUBE_N8 with logical [1,N].
// Vector parameters retain U64 carriers, whose only CellReg geometry is
// CUBE_N8 K2 x N8; only vector parameter sources and ND2N8 U64 TLOAD may use
// it. All other U64 CUBE producers and consumers remain illegal.
// NDF-END: PTO-CUBE-AUX-CELLREG-001

readonly func BundleMatrixDestinationAt(
    ordinal: integer {0..2}) => TileIndex
begin
    var seen: integer {0..3} = 0;
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 looplimit 16 do
        if _BundleTileBindings[[binding]].valid &&
           _BundleTileBindings[[binding]].destination_valid then
            if seen == ordinal then
                return _BundleTileBindings[[binding]].destination;
            end;
            seen = (seen + 1) as integer {0..3};
        end;
    end;
    return 0;
end;

readonly func BundleMatrixSourceAt(ordinal: integer {0..8}) => TileIndex
begin
    var seen: integer {0..9} = 0;
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 looplimit 16 do
        if _BundleTileBindings[[binding]].valid then
            if _BundleTileBindings[[binding]].source0_valid then
                if seen == ordinal then
                    return BundleTileSourceIndex(
                        binding as BundleTileBindingIndex, FALSE);
                end;
                seen = (seen + 1) as integer {0..9};
            end;
            if _BundleTileBindings[[binding]].source1_valid then
                if seen == ordinal then
                    return BundleTileSourceIndex(
                        binding as BundleTileBindingIndex, TRUE);
                end;
                seen = (seen + 1) as integer {0..9};
            end;
        end;
    end;
    return 0;
end;

readonly func BundleMatrixArchitecturalSourceAt(
    ordinal: integer {0..8}) => TileIndex
begin
    var seen: integer {0..9} = 0;
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 looplimit 16 do
        if _BundleTileBindings[[binding]].valid then
            if _BundleTileBindings[[binding]].source0_valid then
                if seen == ordinal then
                    return BundleTileArchitecturalSourceIndex(
                        binding as BundleTileBindingIndex, FALSE);
                end;
                seen = (seen + 1) as integer {0..9};
            end;
            if _BundleTileBindings[[binding]].source1_valid then
                if seen == ordinal then
                    return BundleTileArchitecturalSourceIndex(
                        binding as BundleTileBindingIndex, TRUE);
                end;
                seen = (seen + 1) as integer {0..9};
            end;
        end;
    end;
    return 0;
end;

readonly func TileMatrixLocalRowMaxSchemaLegal(
    source: TileIndex,
    valid_rows: integer {1..65535},
    effective_type: TileDataType,
    expected_layout: TileLayout) => boolean
begin
    let tile = _Tiles[[source]];
    return tile.contents_defined && TileCubeDescriptorLegal(tile) &&
           tile.valid_rows == valid_rows &&
           tile.valid_columns == 1 &&
           tile.data_type == effective_type &&
           tile.layout == expected_layout &&
           (expected_layout == TileLayout_CUBE_M16 ||
            expected_layout == TileLayout_CUBE_M32);
end;

readonly func TileMatrixLocalVectorParameterSchemaLegal(
    source: TileIndex,
    n: integer {1..65535}) => boolean
begin
    let tile = _Tiles[[source]];
    return tile.contents_defined && TileCubeDescriptorLegal(tile) &&
           tile.valid_rows == 1 &&
           tile.valid_columns == n &&
           tile.data_type == TileDataType_U64 &&
           tile.layout == TileLayout_CUBE_N8;
end;

readonly func TileMatrixVectorQuantContentsLegal(
    source: TileIndex, mode: bits(6)) => boolean
begin
    let tile = _Tiles[[source]];
    for column = 0 to tile.valid_columns - 1 looplimit 65536 do
        let element = TileLogicalLinearIndex(
            tile, 0, column as integer {0..65535});
        if !BundleFPATRQuantParameterWordLegal(
               mode, TileReadLogicalElement(tile, element)) then
            return FALSE;
        end;
    end;
    return TRUE;
end;

readonly func TileMatrixVectorReluContentsLegal(
    source: TileIndex) => boolean
begin
    let tile = _Tiles[[source]];
    for column = 0 to tile.valid_columns - 1 looplimit 65536 do
        let element = TileLogicalLinearIndex(
            tile, 0, column as integer {0..65535});
        if !BundleFPATRReluParameterWordLegal(
               TileReadLogicalElement(tile, element)) then
            return FALSE;
        end;
    end;
    return TRUE;
end;

readonly func BundleMatrixPostProcessSourcesLegal(
    mathematical_sources: integer {0..6},
    m: integer {1..65535},
    n: integer {1..65535},
    accumulator_type: TileDataType,
    primary_layout: TileLayout) => boolean
begin
    if !BundleFPATRAccumulatorTypeLegal(
           _BundleFixedPointAttributes.pre_quant_mode,
           accumulator_type) then
        return FALSE;
    end;
    let effective_type = BundleFPATREffectiveDataType(
        _BundleFixedPointAttributes.pre_quant_mode, accumulator_type);
    if (_BundleFixedPointAttributes.row_max_en ||
        _BundleFixedPointAttributes.group_max_en) &&
       !BundleFPATRReductionDataTypeLegal(effective_type) then
        return FALSE;
    end;
    var ordinal = mathematical_sources as integer {0..8};
    if _BundleFixedPointAttributes.row_max_en &&
       _BundleFixedPointAttributes.row_max_init then
        let row_max = BundleMatrixSourceAt(ordinal);
        if !TileMatrixLocalRowMaxSchemaLegal(
               row_max, m, effective_type, primary_layout) then
            return FALSE;
        end;
        ordinal = (ordinal + 1) as integer {0..8};
    end;

    if BundleFPATRModeUsesVectorParameter(
           _BundleFixedPointAttributes.pre_quant_mode) then
        let quant = BundleMatrixSourceAt(ordinal);
        if !TileMatrixLocalVectorParameterSchemaLegal(
               quant, n) ||
           !TileMatrixVectorQuantContentsLegal(
               quant, _BundleFixedPointAttributes.pre_quant_mode) then
            return FALSE;
        end;
        ordinal = (ordinal + 1) as integer {0..8};
    end;

    if BundleFPATRReluModeUsesVectorParameter(
           _BundleFixedPointAttributes.relu_mode) then
        let relu = BundleMatrixSourceAt(ordinal);
        if !TileMatrixLocalVectorParameterSchemaLegal(
               relu, n) ||
           !TileMatrixVectorReluContentsLegal(relu) then
            return FALSE;
        end;
    end;
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: unit -->
