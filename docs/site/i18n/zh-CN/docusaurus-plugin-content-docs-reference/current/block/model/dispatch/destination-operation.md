<!-- GENERATED FROM: asl/block/model/dispatch/destination-operation.asl -->
# Destination Operation

**Normative ASL source:** `asl/block/model/dispatch/destination-operation.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-DESTINATION-OPERATION}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-dispatch-destination-operation-purpose role=purpose-scope -->
## 用途与范围

本单元定义 `ResolveBundleTileDestinationsForOperation`，它是一个路由函数，决定 Tile 指令束的 Local 目标如何获得形状和数据类型。Local 目标是写作 `->DstTile<Size>` 的 `B.IOT` 目标：指令束给出一个相对 hand 和一个大小，由分派为其分配一个 Local Tile 寄存器。

该路由函数本身不分配。它选择一个解析函数，为其计算形状和类型参数，并返回该解析函数的结果。

<!-- PTO-READER-BLOCK: block-model-dispatch-destination-operation-concepts role=concepts-state -->
## 概念与可见状态

路由函数读取 `_BundleOperation`、指令束维度 `_BundleDimensions`、Tile 绑定，以及已绑定源在 `_Tiles` 中的描述符。它只通过所调用的解析函数和 `SetFault` 写入状态。

指令束维度槽位对应形状字段。`LB0` 是有效列数，`LB1` 是有效行数，`LB2` 是物理列数。

显式形状指路由函数向共享解析函数传入确切的有效行数、有效列数和物理列数。显式类型指它还传入主目标的数据类型。

<!-- PTO-READER-BLOCK: block-model-dispatch-destination-operation-rules role=rules-interactions -->
## 规则与交互

路由函数按以下顺序检查各情形，并使用第一个匹配项。

1. Tile 矩阵指令束立即返回真，并让其目标保持未解析。
2. `TPERMUTE`、`TSHUF`、`TPACK` 和 `TUNPACK` 使用单元重排解析函数。
3. `TMOV` 从维度取得形状，从第一个源的描述符取得类型。
4. 源为 `CUBE_M16` 或 `CUBE_M32` 的 `TCVT` 使用 CUBE `TCVT` 解析函数。
5. 行或列归约从源取得形状。行归约得到 `valid_rows` 乘 1；列归约得到 1 乘 `valid_columns`。返回索引的归约产生 `U32`；其他归约保持源类型。
6. `TCMP` 和 `TCMPS` 解析有效数据类型，并使用谓词目标解析函数。
7. 真值源为 CUBE 的 `TSEL` 和 `TSELS` 使用 CUBE 选择解析函数。
8. `TEXPDIF`、`TROWEXPANDEXPDIF` 和 `TCOLEXPANDEXPDIF` 从指数差类型对中取得目标类型。
9. 不属于二元、一元、`TFMA`、生成、扩展、`TCVT`、比较和 Tile-标量封闭 schema的操作使用不带显式形状的通用解析函数。
10. 其余所有封闭 schema 操作从 `LB0`、`LB1` 和物理列规则取得显式形状，并使用有效数据类型。

当类型无法解析或类型对非法时，情形 6 和 8 引发 `Fault_TileLegality`。

设计要点：矩阵指令束在任何通用解析之前退出。ASL 注释给出原因：CUBE 矩阵处理程序拥有主目标的 M、N、布局和类型。通用 RowMajor 解析会把该目标标记为已分配，从而阻止处理程序把它转换为 CUBE 状态。

设计要点：`TEXPDIF` 也是封闭二元操作，但情形 8 先匹配它。该情形从 `SelectedBundleExponentialDifferenceTypes` 取得目标类型，该函数会再次检查源与目标类型对，并在类型对非法时引发 `Fault_TileLegality`。

<!-- PTO-READER-BLOCK: block-model-dispatch-destination-operation-boundaries role=boundaries -->
## 架构边界

唯一的调用者是 Tile 执行分派。它在操作数计数、封闭 schema、PE 掩码和执行掩码合并检查之后、在验证本地 generation 写者之前调用该路由函数。若路由函数失败，分派会中止该指令束的本地 generation，并丢弃 subview 物化结果。路由函数不验证源操作数；封闭 schema 检查已在更早完成。

<!-- PTO-READER-BLOCK: block-model-dispatch-destination-operation-example role=example-usage -->
## 非规范阅读示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

```text
TADD <Row=8, Col=64, FP32>, T#1, T#2, ->T<2KB>
```

`TADD` 是封闭二元操作，不匹配情形 1 到 9。在情形 10 中，`LB0` 给出 64 个有效列，`LB1` 给出 8 个有效行。物理列数为 64。解析函数收到形状 8 乘 64，类型为 `FP32`。

对 8 乘 64 的 `FP32` 源执行 `TROWMAX` 则匹配情形 5。其目标为 8 乘 1，类型为 `FP32`，物理列数为 1。

<!-- PTO-READER-BLOCK: block-model-dispatch-destination-operation-related role=related-owners-navigation -->
## 相关所有者

- [目标形状](destination-shape.md) 拥有分配目标的共享解析函数。
- [Tile 执行分派](tile-execution.md) 调用该路由函数并处理其失败。
- [谓词目标](predicate-destination.md) 拥有比较与 CUBE 选择解析函数。
- [指数差 schema](expdif-schema.md) 选择 `TEXPDIF` 类型对。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/destination-operation.asl -->
```asl
// PTO-UNIT: {"classification":["model","dispatch","destination-operation"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-BINARY-OP-CLASSIFICATION","PTO-BLOCK-MODEL-DISPATCH-CELL-REARRANGEMENT-SCHEMA","PTO-BLOCK-MODEL-DISPATCH-COMPARISON-SCHEMA","PTO-BLOCK-MODEL-DISPATCH-DESTINATION-SHAPE","PTO-BLOCK-MODEL-DISPATCH-EXPANSION-SCHEMA","PTO-BLOCK-MODEL-DISPATCH-EXPDIF-SCHEMA","PTO-BLOCK-MODEL-DISPATCH-REDUCTION-SCHEMA","PTO-BLOCK-MODEL-DISPATCH-TCVT-DESTINATION","PTO-BLOCK-MODEL-DISPATCH-TCVT-SCHEMA","PTO-BLOCK-MODEL-DISPATCH-TILE-SCALAR-SCHEMA","PTO-TILE-MODEL-LEGALITY-DTYPE-LAYOUT","PTO-TILE-MODEL-LEGALITY-REDUCTION-AND-EXPANSION"],"id":"PTO-BLOCK-MODEL-DISPATCH-DESTINATION-OPERATION","surface":"block"}
func ResolveBundleTileDestinationsForOperation(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    // CUBE matrix handlers own the primary CUBE destination and allocation; leave it unresolved for the authoritative M/N/layout/type handler because generic RowMajor resolution would mark it allocated and prevent conversion.
    if _BundleOperation.valid &&
       _BundleOperation.operation_class == BundleOperation_TileMatrix then
        return TRUE;
    end;
    let decoded_operation = TileOperationOfIndex(operation);
    if decoded_operation == TileOperation_TLEA then
        let (type_valid, destination_type) = ResolveBundleEffectiveDataType();
        if !type_valid then
            SetFault(Fault_TileLegality, ReadTPC());
            return FALSE;
        end;
        let valid_columns = UInt(_BundleDimensions[[0]]) as integer {1..65535};
        let valid_rows = UInt(_BundleDimensions[[1]]) as integer {1..65535};
        let columns = BundleDestinationPhysicalColumns(FALSE, 0)
            as integer {1..65535};
        return ResolveBundleTileDestinationsWithShapeAndType(
            TRUE, valid_rows, valid_columns, columns, TRUE, destination_type);
    end;
    if decoded_operation == TileOperation_TPERMUTE ||
       decoded_operation == TileOperation_TSHUF ||
       decoded_operation == TileOperation_TPACK ||
       decoded_operation == TileOperation_TUNPACK then
        return ResolveBundleCellRearrangementDestination(operation);
    end;
    if TileOperationUsesSourceBackingDestination(decoded_operation) then
        let source = BundleTileSourceIndex(0, FALSE);
        return ResolveBundleTileDestinationsWithShapeAndType(FALSE, 0, 0, 0,
            TRUE, _Tiles[[source]].data_type);
    end;
    if TileOperationUsesClosedTCVTSchema(operation) then
        let source = BundleTileSourceIndex(0, FALSE);
        if _Tiles[[source]].layout == TileLayout_CUBE_M16 ||
           _Tiles[[source]].layout == TileLayout_CUBE_M32 then
            return ResolveBundleTCVTCubeDestination();
        end;
    end;
    if TileOperationUsesClosedReductionSchema(operation) then
        let source = _BundleTileBindings[[0]].source0;
        let source_tile = _Tiles[[source]];
        let row_reduction =
            TileOperationUsesClosedRowReductionSchema(operation);
        let destination_type =
            if TileReductionOperationReturnsIndex(operation) then
                TileDataType_U32
            else
                source_tile.data_type;
        let valid_rows =
            if row_reduction then source_tile.valid_rows else 1;
        let valid_columns =
            if row_reduction then 1 else source_tile.valid_columns;
        let columns =
            if row_reduction then 1 else source_tile.columns;
        return ResolveBundleTileDestinationsWithShapeAndType(
            TRUE,
            valid_rows,
            valid_columns,
            columns,
            TRUE,
            destination_type);
    end;
    if TileOperationUsesClosedTCMPSchema(operation) ||
       TileOperationUsesClosedTCMPSSchema(operation) then
        let (operation_type_valid, operation_type) =
            ResolveBundleEffectiveDataType();
        if !operation_type_valid then
            SetFault(Fault_TileLegality, ReadTPC());
            return FALSE;
        end;
        return ResolveBundlePredicateDestination(operation_type);
    end;
    if (TileOperationUsesClosedTSELSchema(operation) ||
        TileOperationUsesClosedTSELSSchema(operation)) &&
       SelectedBundleComparisonCUBE(
           BundleComparisonSelectTrueSource(operation)) then
        return ResolveBundleCUBESelectDestination(operation);
    end;
    if decoded_operation == TileOperation_TEXPDIF then
        let (types_legal, -, destination_type) =
            SelectedBundleExponentialDifferenceTypes();
        if !types_legal then
            SetFault(Fault_TileLegality, ReadTPC());
            return FALSE;
        end;
        let valid_columns = BundleDestinationValidColumns(FALSE, 0)
            as integer {1..65535};
        let valid_rows = BundleDestinationValidRows(FALSE, 0)
            as integer {1..65535};
        let columns = BundleDestinationPhysicalColumns(FALSE, 0)
            as integer {1..65535};
        return ResolveBundleTileDestinationsWithShapeAndType(
            TRUE, valid_rows, valid_columns, columns,
            TRUE, destination_type);
    end;
    if TileExpansionOperationIsExponentialDifference(operation) then
        let (types_legal, -, destination_type) =
            SelectedBundleExponentialDifferenceTypes();
        if !types_legal then
            SetFault(Fault_TileLegality, ReadTPC());
            return FALSE;
        end;
        let valid_columns = UInt(_BundleDimensions[[0]])
            as integer {1..65535};
        let valid_rows = UInt(_BundleDimensions[[1]]) as integer {1..65535};
        let columns = UInt(_BundleDimensions[[2]]) as integer {1..65535};
        return ResolveBundleTileDestinationsWithShapeAndType(
            TRUE, valid_rows, valid_columns, columns,
            TRUE, destination_type);
    end;
    if !TileOperationUsesClosedBinarySchema(operation) &&
       !TileOperationUsesClosedUnarySchema(operation) &&
       !TileOperationUsesClosedTFMASchema(operation) &&
       !TileOperationUsesClosedGenerationSchema(operation) &&
       !TileOperationUsesClosedExpansionSchema(operation) &&
       !TileOperationUsesClosedTCVTSchema(operation) &&
       !TileOperationUsesClosedComparisonSchema(operation) &&
       !TileOperationUsesClosedTileScalarSchema(operation) then
        return ResolveBundleTileDestinations();
    end;
    let valid_columns = UInt(_BundleDimensions[[0]]) as integer {1..65535};
    let valid_rows = UInt(_BundleDimensions[[1]]) as integer {1..65535};
    let columns = BundleDestinationPhysicalColumns(FALSE, 0)
        as integer {1..65535};
    return ResolveBundleTileDestinationsWithShape(TRUE, valid_rows, valid_columns, columns);
end;
```
<!-- GENERATED-ASL-END: unit -->
