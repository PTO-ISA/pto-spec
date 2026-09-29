<!-- GENERATED FROM: asl/block/model/dispatch/execution-mask-schema.asl -->
# Execution Mask Schema

**Normative ASL source:** `asl/block/model/dispatch/execution-mask-schema.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-EXECUTION-MASK-SCHEMA}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-dispatch-execution-mask-schema-purpose role=purpose-scope -->
## 用途与范围

本单元判断 Tile 指令束是否携带执行掩码，检查载体的形状，并捕获其值。执行掩码是逐元素的活跃位：非活跃元素保留目标的旧值（merge）或变为零，由 `B.DATR` 选择。

掩码有两种载体之一：

- GPR 载体，即通过 `B.IOR` 绑定且设置了执行掩码标志的一个或两个通用寄存器；
- 谓词 Tile 载体，即位于操作普通源之后的一个额外 `B.IOT` 源，其存储种类为 `TileStorage_PredicateCell`。

<!-- PTO-READER-BLOCK: block-model-dispatch-execution-mask-schema-concepts role=concepts-state -->
## 概念与可见状态

本单元写入 `_BundleExecutionMask`：`valid`、`carrier`、坐标域（`layout`、`valid_rows`、`valid_columns`）、`word_count`、`predicate_tile`、`predicate_source_ordinal`、`invert`、`zero_inactive`，并在合并准备时写入 `merge_base` 和 `merge_base_valid`。`invert` 和 `zero_inactive` 复制自 `B.DATR` 的 `PredInv` 和 `Zero` 字段。

坐标域是掩码覆盖的网格。对大多数操作，它是第一个普通源的有效形状和布局。当第一个源是谓词单元时，`TSEL` 和 `TSELS` 使用第二个源。`TGATHER`、`TSCATTER`、`MSCATTER` 和 `MSCATTER_MASK` 使用第二个源。CUBE 传输和封闭扩展操作使用 `LB0` 和 `LB1`。`TPACK` 和 `TUNPACK` 以每行的 32 位字数计列。

<!-- PTO-READER-BLOCK: block-model-dispatch-execution-mask-schema-rules role=rules-interactions -->
## 规则与交互

`MarkSelectedBundleExecutionMaskCarrier` 先清除掩码。若任一标量绑定设置了执行掩码标志，则选择 GPR 载体。其绑定 schema 必须合法，其坐标布局必须是 `CUBE_M16` 或 `CUBE_M32`。对大多数操作，坐标域必须放得下：有效行数最多为 16 或 32，有效列数不超过谓词字段数乘以字数。`TPACK` 和 `TUNPACK` 改用位计数规则。否则，当本地源数量恰好比普通源数量多一个且最后一个源是谓词单元时，选择谓词 Tile 载体。它的形状必须与坐标域一致，其值必须为 0 或 1。

随后 `CaptureSelectedBundleExecutionMask` 记录掩码值。对于谓词 Tile，它把坐标域中每个元素的位 0 复制到 `predicate_tile_snapshot`。对于 GPR 载体，它读取寄存器值。

`PrepareSelectedBundleExecutionMaskMerge` 只在掩码有效、采用 merge 语义且存在目标时运行。它取目标 hand 上最新的 Tile 作为合并基底。该 Tile 必须已分配、已定义且是合法的 CUBE 描述符，并且必须与期望的布局、有效形状和类型一致。

当 PE 掩码不为零时，Tile 执行分派对可使用掩码的操作依次调用标记与捕获，且在任何专用处理程序或通用 schema 检查之前进行。它在专用内存处理程序运行之前调用合并准备，或在通用路径上于目标分配之前调用。三者中任一失败都会引发 `Fault_TileLegality`。

设计要点：掩码在目标分配之前被捕获。谓词载体契约要求在与之重叠的谓词目标被分配或发布之前对载体做快照。此后活跃性从 `predicate_tile_snapshot` 或捕获的 GPR 字读取，而不是从载体 Tile 读取，因此在指令束执行期间分配、写入或发布目标都无法改变哪些元素是活跃的。

设计要点：merge 从目标 hand 上最新的 Tile 读取旧值，而不是从新目标读取。Local 目标是一个新寄存器，因此该 hand 的先前值位于现有 Tile 中。合并准备在分配之前检查该 Tile，随后非活跃元素从它复制值。

<!-- PTO-READER-BLOCK: block-model-dispatch-execution-mask-schema-boundaries role=boundaries -->
## 架构边界

本单元不决定哪些操作可以携带掩码；这由 `TileOperationExecutionMaskEligible` 决定。它也不检查 `B.DATR` 掩码字段与载体是否相容；这由紧随捕获之后的 `BundleExecutionMaskDataAttributesLegal` 完成。掩码的逐元素使用，包括 merge 与置零，属于 Tile 执行掩码所有者。

<!-- PTO-READER-BLOCK: block-model-dispatch-execution-mask-schema-example role=example-usage -->
## 非规范阅读示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

一个 `TADD` 指令束在 `B.IOT` 中绑定三个本地源：左源、右源和一个谓词单元。`TADD` 有 2 个普通源，因此 3 个本地源会选择谓词 Tile 载体，`predicate_source_ordinal` 为 2。若左源是 16 个有效行、32 个有效列的 `CUBE_M16` Tile，则谓词单元也必须是 `CUBE_M16`，有效元素为 16 乘 32。捕获会复制这 512 位。

当 `B.DATR` 的 `Zero` 清零时，合并准备要求目标 hand 上最新的 Tile 是已定义的 `CUBE_M16` 数值 Tile，类型为有效数据类型。其有效形状必须等于 `LB1` 乘 `LB0` 的形状；当 `B.DIM` 把 `LB1` 设为 16、把 `LB0` 设为 32 时，此处为 16 乘 32。

<!-- PTO-READER-BLOCK: block-model-dispatch-execution-mask-schema-related role=related-owners-navigation -->
## 相关所有者

- [Tile 执行分派](tile-execution.md) 调用标记、捕获与合并准备。
- [标量 schema](scalar-schema.md) 拥有 GPR 载体的绑定 schema 与字数。
- [执行掩码](../../../tile/model/execution/execution-mask.md) 记录捕获的掩码状态。
- [谓词载体](../../../tile/model/legality/predicate-carriers.md) 拥有谓词单元的形状与值检查。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/execution-mask-schema.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-EXECUTION-MASK-SCHEMA","surface":"block","classification":["model","dispatch","execution-mask-schema"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-SCALAR-SCHEMA","PTO-BLOCK-MODEL-OPERANDS-SUBVIEW-DESCRIPTOR","PTO-TILE-MODEL-EXECUTION-MASK","PTO-TILE-MODEL-EXECUTION-PREDICATE-CARRIERS","PTO-TILE-MODEL-LEGALITY-LAYOUT-REARRANGEMENT","PTO-TILE-MODEL-LEGALITY-PREDICATE-CARRIERS"]}
readonly func BundleExecutionMaskLocalTileSourceCount() => integer {0..32}
begin
    var count: integer {0..32} = 0;
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if _BundleTileBindings[[binding]].valid then
            if _BundleTileBindings[[binding]].source0_valid then
                count = (count + 1) as integer {0..32};
            end;
            if _BundleTileBindings[[binding]].source1_valid then
                count = (count + 1) as integer {0..32};
            end;
        end;
    end;
    return count;
end;

readonly func BundleExecutionMaskOrdinaryTileSourceCount(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => integer {0..9}
begin
    let decoded = TileOperationOfIndex(operation);
    let encoded_sources = BundleExecutionMaskLocalTileSourceCount();
    if decoded == TileOperation_TGPR2T then return 0; end;
    if decoded == TileOperation_TCMP then return 2; end;
    if decoded == TileOperation_TCMPS then return 1; end;
    if decoded == TileOperation_TSEL then
        if encoded_sources <= 2 then return 2; end;
        if _Tiles[[BundleTileSourceIndex(0, FALSE)]].storage_kind ==
           TileStorage_PredicateCell then return 3; end;
        return 2;
    end;
    if decoded == TileOperation_TSELS then
        if encoded_sources <= 1 then return 1; end;
        if _Tiles[[BundleTileSourceIndex(0, FALSE)]].storage_kind ==
           TileStorage_PredicateCell then return 2; end;
        return 1;
    end;
    var count: integer {0..9} = 0;
    if TileOperandPresent(operation, TileOperand_source0) then count = (count + 1) as integer {0..9}; end;
    if TileOperandPresent(operation, TileOperand_source1) then count = (count + 1) as integer {0..9}; end;
    if TileOperandPresent(operation, TileOperand_source2) then count = (count + 1) as integer {0..9}; end;
    if TileOperandPresent(operation, TileOperand_source3) then count = (count + 1) as integer {0..9}; end;
    if TileOperandPresent(operation, TileOperand_source4) then count = (count + 1) as integer {0..9}; end;
    return count;
end;

readonly func BundleExecutionMaskTileSourceAt(ordinal: integer {0..31})
    => TileIndex
begin
    var seen: integer {0..31} = 0;
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if _BundleTileBindings[[binding]].valid then
            if _BundleTileBindings[[binding]].source0_valid then
                if seen == ordinal then
                    return BundleTileSourceIndex(binding as BundleTileBindingIndex, FALSE);
                end;
                seen = (seen + 1) as integer {0..31};
            end;
            if _BundleTileBindings[[binding]].source1_valid then
                if seen == ordinal then
                    return BundleTileSourceIndex(binding as BundleTileBindingIndex, TRUE);
                end;
                seen = (seen + 1) as integer {0..31};
            end;
        end;
    end;
    return 0;
end;

readonly func BundleExecutionMaskCoordinateSourceOrdinal(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1})
    => integer {0..31}
begin
    let decoded = TileOperationOfIndex(operation);
    if decoded == TileOperation_TSEL || decoded == TileOperation_TSELS then
        let first = BundleExecutionMaskTileSourceAt(0);
        return if _Tiles[[first]].storage_kind == TileStorage_PredicateCell
            then 1 else 0;
    end;
    if decoded == TileOperation_TGATHER ||
       decoded == TileOperation_TSCATTER ||
       decoded == TileOperation_MSCATTER ||
       decoded == TileOperation_MSCATTER_MASK then
        return 1;
    end;
    return 0;
end;

readonly func BundleExecutionMaskCoordinateValidRows(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1})
    => integer
begin
    if BundleCubeTransportSelected() then
        return UInt(_BundleDimensions[[1]]);
    end;
    if TileOperationUsesClosedExpansionSchema(operation) then
        return UInt(_BundleDimensions[[1]]);
    end;
    let ordinary = BundleExecutionMaskOrdinaryTileSourceCount(operation);
    if ordinary != 0 then
        return _Tiles[[BundleExecutionMaskTileSourceAt(
            BundleExecutionMaskCoordinateSourceOrdinal(operation))]].valid_rows;
    end;
    let rows = UInt(_BundleDimensions[[1]]);
    return if rows == 0 then 1 else rows;
end;

readonly func BundleExecutionMaskCoordinateValidColumns(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1})
    => integer
begin
    let decoded = TileOperationOfIndex(operation);
    if BundleCubeTransportSelected() then
        return UInt(_BundleDimensions[[0]]);
    end;
    if decoded == TileOperation_TPACK || decoded == TileOperation_TUNPACK then
        let source = BundleExecutionMaskTileSourceAt(0);
        return TileCellRearrangementWordsPerRow(_Tiles[[source]])
            as integer {0..65535};
    end;
    if TileOperationUsesClosedExpansionSchema(operation) then
        return UInt(_BundleDimensions[[0]]);
    end;
    let ordinary = BundleExecutionMaskOrdinaryTileSourceCount(operation);
    if ordinary != 0 then
        return _Tiles[[BundleExecutionMaskTileSourceAt(
            BundleExecutionMaskCoordinateSourceOrdinal(operation))]].valid_columns;
    end;
    return UInt(_BundleDimensions[[0]]);
end;

readonly func BundleExecutionMaskCoordinateLayout(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => TileLayout
begin
    if BundleCubeTransportSelected() then
        return TileDataLayoutCubeLayout(_BundleDataAttributes.data_layout);
    end;
    if BundleExecutionMaskOrdinaryTileSourceCount(operation) != 0 then
        return _Tiles[[BundleExecutionMaskTileSourceAt(
            BundleExecutionMaskCoordinateSourceOrdinal(operation))]].layout;
    end;
    return CurrentBundleTileLayout();
end;

readonly func BundleExecutionMaskTileCarrierPresent(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    if !TileOperationExecutionMaskEligible(operation) ||
       _BundleScalarBindings[[0]].execution_mask_present ||
       _BundleScalarBindings[[1]].execution_mask_present then return FALSE; end;
    let ordinary = BundleExecutionMaskOrdinaryTileSourceCount(operation);
    if BundleExecutionMaskLocalTileSourceCount() != ordinary + 1 then return FALSE; end;
    return _Tiles[[BundleExecutionMaskTileSourceAt(ordinary)]]
        .storage_kind == TileStorage_PredicateCell;
end;

readonly func BundleExecutionMaskTileCarrierSchemaLegal(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    if !BundleExecutionMaskTileCarrierPresent(operation) then return TRUE; end;
    let ordinary = BundleExecutionMaskOrdinaryTileSourceCount(operation);
    let predicate = BundleExecutionMaskTileSourceAt(ordinary);
    var consumer_layout = BundleExecutionMaskCoordinateLayout(operation);
    let valid_rows_raw = BundleExecutionMaskCoordinateValidRows(operation);
    let valid_columns_raw = BundleExecutionMaskCoordinateValidColumns(operation);
    if valid_rows_raw < 1 || valid_rows_raw > 65535 ||
       valid_columns_raw < 1 || valid_columns_raw > 65535 then return FALSE; end;
    let valid_rows = valid_rows_raw as integer {1..65535};
    let valid_columns = valid_columns_raw as integer {1..65535};
    if ordinary != 0 then
        consumer_layout = _Tiles[[BundleExecutionMaskTileSourceAt(
            BundleExecutionMaskCoordinateSourceOrdinal(operation))]].layout;
    end;
    return TileExecutionMaskPredicateCellShapeLegal(
        predicate, consumer_layout, valid_rows, valid_columns);
end;

readonly func BundleExecutionMaskGPRCarrierShapeLegal(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    let ordinary = BundleExecutionMaskOrdinaryTileSourceCount(operation);
    let coordinate_layout = BundleExecutionMaskCoordinateLayout(operation);
    if coordinate_layout != TileLayout_CUBE_M16 &&
       coordinate_layout != TileLayout_CUBE_M32 then return FALSE; end;
    let valid_rows_raw = BundleExecutionMaskCoordinateValidRows(operation);
    let valid_columns_raw = BundleExecutionMaskCoordinateValidColumns(operation);
    if valid_rows_raw < 1 || valid_rows_raw > 65535 ||
       valid_columns_raw < 1 || valid_columns_raw > 65535 then return FALSE; end;
    let valid_rows = valid_rows_raw as integer {1..65535};
    let valid_columns = valid_columns_raw as integer {1..65535};
    let data_type = TileDataTypeFromEncoding(
        CurrentBundleTileOperationDataTypeCode() as TileDataTypeEncoding);
    let words = BundleExecutionMaskGPRWordCount(operation);
    if TileOperationOfIndex(operation) == TileOperation_TPACK ||
       TileOperationOfIndex(operation) == TileOperation_TUNPACK then
        if valid_rows > TileCubePredicateRowBits(coordinate_layout) then
            return FALSE;
        end;
        let final_bit = ((valid_columns - 1) *
            TileCubePredicateRowBits(coordinate_layout) + valid_rows)
            as integer {0..4194303};
        return final_bit <= words * 64;
    end;
    if !TileCubePredicateGPRDataTypeSupported(data_type) then return FALSE; end;
    return valid_rows <= TileCubePredicateRowBits(coordinate_layout) &&
           valid_columns <= TileCubePredicateFieldCount(
               data_type, coordinate_layout) * words;
end;

func MarkSelectedBundleExecutionMaskCarrier(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    _BundleExecutionMask.valid = FALSE;
    _BundleExecutionMask.carrier = BundleExecutionMask_None;
    if _BundleScalarBindings[[0]].execution_mask_present ||
       _BundleScalarBindings[[1]].execution_mask_present then
        if !BundleExecutionMaskGPRBindingSchemaLegal(operation) ||
           !BundleExecutionMaskGPRCarrierShapeLegal(operation) then
            return FALSE;
        end;
        _BundleExecutionMask.valid = TRUE;
        _BundleExecutionMask.carrier = BundleExecutionMask_GPR;
        _BundleExecutionMask.word_count =
            BundleExecutionMaskGPRWordCount(operation);
        _BundleExecutionMask.layout =
            BundleExecutionMaskCoordinateLayout(operation);
        _BundleExecutionMask.valid_rows =
            BundleExecutionMaskCoordinateValidRows(operation) as integer {1..65535};
        _BundleExecutionMask.valid_columns =
            BundleExecutionMaskCoordinateValidColumns(operation) as integer {1..65535};
        _BundleExecutionMask.invert = _BundleDataAttributes.execution_mask_invert;
        _BundleExecutionMask.zero_inactive = _BundleDataAttributes.execution_mask_zero;
        return TRUE;
    end;
    if BundleExecutionMaskTileCarrierPresent(operation) then
        if !BundleExecutionMaskTileCarrierSchemaLegal(operation) then return FALSE; end;
        let ordinary = BundleExecutionMaskOrdinaryTileSourceCount(operation);
        let predicate = BundleExecutionMaskTileSourceAt(ordinary);
        let tile = _Tiles[[predicate]];
        _BundleExecutionMask.valid = TRUE;
        _BundleExecutionMask.carrier = BundleExecutionMask_PredicateTile;
        _BundleExecutionMask.predicate_tile = predicate;
        _BundleExecutionMask.predicate_source_ordinal = ordinary;
        _BundleExecutionMask.word_count = 0;
        _BundleExecutionMask.layout = tile.layout;
        _BundleExecutionMask.valid_rows =
            BundleExecutionMaskCoordinateValidRows(operation) as integer {1..65535};
        _BundleExecutionMask.valid_columns =
            BundleExecutionMaskCoordinateValidColumns(operation) as integer {1..65535};
        _BundleExecutionMask.invert = _BundleDataAttributes.execution_mask_invert;
        _BundleExecutionMask.zero_inactive = _BundleDataAttributes.execution_mask_zero;
    end;
    return TRUE;
end;

func CaptureSelectedBundleExecutionMask(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    if !_BundleExecutionMask.valid then return TRUE; end;
    if _BundleExecutionMask.carrier == BundleExecutionMask_PredicateTile then
        let ordinal = _BundleExecutionMask.predicate_source_ordinal;
        let predicate = _BundleExecutionMask.predicate_tile;
        let layout = _BundleExecutionMask.layout;
        let rows = _BundleExecutionMask.valid_rows;
        let columns = _BundleExecutionMask.valid_columns;
        CaptureBundleExecutionMaskPredicateTile(
            predicate, layout,
            rows as integer {1..65535},
            columns as integer {1..65535});
        _BundleExecutionMask.predicate_source_ordinal = ordinal;
        return TRUE;
    end;
    let operation_sources = BundleExecutionMaskOperationGPRSourceCount(operation);
    let mask_low = ReadScalarRegisterOperand(
        BundleExecutionMaskGPRSourceSelector(operation_sources));
    let mask_high = if _BundleExecutionMask.word_count == 2 then
        ReadScalarRegisterOperand(
            BundleExecutionMaskGPRSourceSelector(
                (operation_sources + 1) as integer {0..5}))
        else Zeros{PTO_XLEN};
    let layout = _BundleExecutionMask.layout;
    let rows = _BundleExecutionMask.valid_rows;
    let columns = _BundleExecutionMask.valid_columns;
    let words = _BundleExecutionMask.word_count;
    CaptureBundleExecutionMaskGPR(
        mask_low, mask_high, words as integer {1..2}, layout,
        rows as integer {1..65535},
        columns as integer {1..65535});
    return TRUE;
end;

func PrepareSelectedBundleExecutionMaskMerge(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    if !_BundleExecutionMask.valid || _BundleExecutionMask.zero_inactive then
        return TRUE;
    end;
    var destination_binding: integer {0..15} = 0;
    var destination_found = FALSE;
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if _BundleTileBindings[[binding]].valid &&
           _BundleTileBindings[[binding]].destination_valid then
            destination_binding = binding as integer {0..15};
            destination_found = TRUE;
        end;
    end;
    if !destination_found then return TRUE; end;
    let hand = UInt(_BundleTileBindings[[destination_binding]].destination_hand)
        as integer {0..3};
    if _TileRelativeValid[[hand]][0] == '0' then return FALSE; end;
    let base = _TileRelativeOrder[[hand]][[0]];
    let tile = _Tiles[[base]];
    if !tile.allocated || !tile.contents_defined ||
       !TileCubeDescriptorLegal(tile) then return FALSE; end;

    let decoded = TileOperationOfIndex(operation);
    let coordinate_destination =
        decoded == TileOperation_TCMP || decoded == TileOperation_TCMPS ||
        decoded == TileOperation_TSEL || decoded == TileOperation_TSELS;
    let source_backed_destination =
        decoded == TileOperation_TMOV ||
        decoded == TileOperation_TPERMUTE || decoded == TileOperation_TSHUF;
    let source_layout_destination = source_backed_destination ||
        decoded == TileOperation_TCVT;
    let pack_unpack =
        decoded == TileOperation_TPACK || decoded == TileOperation_TUNPACK;
    let source = BundleExecutionMaskTileSourceAt(0);
    let source_tile = _Tiles[[source]];
    let (result_type_valid, result_type) = ResolveBundleEffectiveDataType();
    let result_elements_per_word =
        if result_type == TileDataType_U8 then 4
        else if result_type == TileDataType_U16 then 2
        else if result_type == TileDataType_U32 then 1
        else 0;
    let packed_columns_unbounded = if pack_unpack then
        (TileCellRearrangementWordsPerRow(source_tile) *
            result_elements_per_word) as integer {0..262144}
        else 0;
    if !result_type_valid ||
       (pack_unpack &&
        (result_elements_per_word == 0 ||
         packed_columns_unbounded > 65535)) then
        return FALSE;
    end;
    let expected_rows = if coordinate_destination then
        _BundleExecutionMask.valid_rows
        else if source_backed_destination || pack_unpack then
            source_tile.valid_rows
        else BundleDestinationValidRows(FALSE, 0);
    let expected_columns = if coordinate_destination then
        _BundleExecutionMask.valid_columns
        else if source_backed_destination then source_tile.valid_columns
        else if pack_unpack then
            packed_columns_unbounded as integer {0..65535}
        else BundleDestinationValidColumns(FALSE, 0);
    let expected_layout = if coordinate_destination then
        _BundleExecutionMask.layout
        else if source_layout_destination || pack_unpack then source_tile.layout
        else BundleExecutionMaskCoordinateLayout(operation);
    if tile.layout != expected_layout ||
       tile.valid_rows != expected_rows ||
       tile.valid_columns != expected_columns then
        return FALSE;
    end;
    if decoded == TileOperation_TCMP || decoded == TileOperation_TCMPS then
        if !TilePredicateCellDescriptorLegal(base) ||
           tile.predicate_basis_type != result_type then return FALSE; end;
    else
        if tile.storage_kind != TileStorage_Numeric ||
           tile.data_type != result_type then
            return FALSE;
        end;
    end;
    _BundleExecutionMask.merge_base = base;
    _BundleExecutionMask.merge_base_valid = TRUE;
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: unit -->
