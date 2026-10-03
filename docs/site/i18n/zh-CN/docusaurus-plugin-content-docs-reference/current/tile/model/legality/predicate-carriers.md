<!-- GENERATED FROM: asl/tile/model/legality/predicate-carriers.asl -->
# Predicate Carriers

**Normative ASL source:** `asl/tile/model/legality/predicate-carriers.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-LEGALITY-PREDICATE-CARRIERS}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-legality-predicate-carriers-purpose role=purpose-scope -->
## 用途与范围

本单元定义谓词载体的合法性辅助函数。谓词载体是为每个 Tile 坐标保存一个真或假值的对象。它涵盖三种载体形式，以及产生或消费它们的数值 CUBE 源。

- 谓词单元是具有 `TileStorage_PredicateCell`、U8 元素且值为 0 或 1 的 CUBE_M16 或 CUBE_M32 Tile。
- GPR 谓词载体是一个或两个通用寄存器，其各位保存 CUBE 比较的结果。
- 索引转移掩码是 MGATHER_MASK 与 MSCATTER_MASK 读取的 U8 掩码 Tile。

其调用者包括 operand-schema 中的 TCMP、TCMPS、TSEL 与 TSELS 谓词、执行 predicate-carriers 单元中的 CUBE GPR 比较与选择谓词、ExecutionMask 绑定检查，以及带掩码的索引转移。

<!-- PTO-READER-BLOCK: tile-model-legality-predicate-carriers-concepts role=concepts-state -->
## 概念与可见状态

谓词单元记录一个 `predicate_basis_type`：即产生它的那次比较所用的操作类型。它自身的 `data_type` 总是 U8，其 CUBE 几何按 U8 计算。`TilePredicateCellDescriptorLegal` 要求基础类型属于 `TileCubePredicateDataTypeSupported`，并要求存储的 CUBE 重复数、单元数与字节数等于按其形状重新计算的值。

`TileCubePredicateDataTypeSupported` 在既有浮点和 8、16、32 位整数集合之外，还接受 `FP64`、`S64` 与 `U64`。64 位数值 basis 只在 `CUBE_M32` 下合法；谓词载体本身仍是具有相同逻辑形状和布局的 U8 PredicateCell Tile。

对 GPR 载体，`TileCubePredicateRowBits` 对 CUBE_M16 给出 16 行，对 CUBE_M32 给出 32 行。`TileCubePredicateFieldCount` 给出每个寄存器的列数：CUBE_M32 为 2；CUBE_M16 下 32 位类型为 2，其他为 4。8 位类型使用两个寄存器，使列数上限加倍。

<!-- PTO-READER-BLOCK: tile-model-legality-predicate-carriers-rules role=rules-interactions -->
## 规则与交互

`TileCubeNumericContentsDefined` 检查 CUBE 数值源。没有 ExecutionMask 时它返回 `contents_defined`。存在掩码时，源必须与掩码的布局和有效形状一致，且每个活动坐标都必须已定义。`TileCubeNumericSourceLegalAs` 另外要求同位宽，并要求每个活动坐标在操作类型下编码有效。

`TilePredicateCellShapeMatchesNumericAs` 把谓词单元与数值源配对。源后备必须与操作类型位宽兼容，单元的基础类型必须等于操作类型，有效形状与布局必须一致。

`TilePredicateCellOperationValuesLegal` 与 `IndexedTLSUPredicateValuesLegal` 读取掩码值。每个被检查的坐标都必须已定义，并且必须保存字节 `0x00` 或 `0x01`。没有 ExecutionMask 时检查每个有效坐标；存在掩码时只检查活动坐标。

设计要点：`0x00` 或 `0x01` 以外的掩码字节会使这些谓词返回 FALSE，因此指令束在掩码被消费之前就被拒绝。`ReadIndexedTLSUPredicate` 只读取第 0 位，并先断言 `IndexedTLSUPredicateValuesLegal`，因此 `0x03` 之类的字节永远不会被悄悄读作真。

`IndexedTLSUPredicateDescriptorLegal` 接受以下形式的 U8 掩码：RowMajor 数值 Tile、CUBE 谓词单元或 CUBE 数值 U8 Tile。

设计要点：`TileExecutionMaskPredicateCellShapeLegal` 只比较布局与有效形状，不比较基础类型。执行 predicate-carriers 单元中的需求 `PTO-REQ-TEPL-PREDICATE-CARRIER-001` 规定，通用 ExecutionMask 消费不得要求生产者的基础类型等于消费者的操作类型。由 FP32 比较产生的掩码可以控制具有相同布局与形状的 FP16 操作。

<!-- PTO-READER-BLOCK: tile-model-legality-predicate-carriers-boundaries role=boundaries -->
## 架构边界

这些辅助函数都是检查。`PredicateCellWithPadding` 是这里唯一的状态变换：它把谓词单元有效区域之外的坐标在 `Max` 时填 1，在 `Zero` 或 `Min` 时填 0，在 `Null` 时保持未定义。CUBE 谓词单元比较函数 `ExecuteTileCompareCellAs` 与 `ExecuteTileCompareCellScalarAs` 在写入单元之前调用它。

`ReadIndexedTLSUPredicate` 断言掩码合法并返回元素的第 0 位。gather 与 scatter 只在预检通过后调用它。

部分辅助函数目前在 `asl/` 中没有调用者，例如 `TileCubePredicateGPRShapeLegal`、`TileCubeNumericSourceLegal`、`TileCubeNumericShapeAndTypeMatch` 与 `TilePredicateCellShapeMatchesNumeric`。

<!-- PTO-READER-BLOCK: tile-model-legality-predicate-carriers-example role=example-usage -->
## 非规范阅读示例

一个 TCMPS 从 CUBE_M16 源把结果写入 GPR，操作类型为 FP16，有效区域为 16 x 4。

- FP16 通过 `TileCubePredicateGPRDataTypeSupported`。
- 行：16 不超过 `TileCubePredicateRowBits(CUBE_M16)` = 16。
- 列：FP16 为 16 位，因此字段数为 4，使用一个寄存器；4 不超过 4 x 1。
- 结果填满 16 x 4 = 64 位，位号为 `row + field * 16`。

若 CUBE_M16 源为 U8，则使用两个寄存器，因此最多 4 x 2 = 8 列合法。若 CUBE_M16 中为 FP32，字段数为 2，因此 16 x 4 的有效区域被拒绝。

<!-- PTO-READER-BLOCK: tile-model-legality-predicate-carriers-related role=related-owners-navigation -->
## 相关所有者

- [执行谓词载体](../execution/predicate-carriers.md) 在 CUBE 比较与选择中使用 GPR 辅助函数。
- [操作数 schema](operand-schema.md) 在 TCMP、TCMPS、TSEL 与 TSELS 中使用谓词单元辅助函数。
- [内存 schema](memory-schema.md) 在带掩码转移中使用 `IndexedTLSUPredicateValuesLegal`。
- [描述符形状](descriptor-shape.md) 定义 `TileCubeDescriptorLegal`。
- [ExecutionMask schema](../../../block/model/dispatch/execution-mask-schema.md) 在指令束层面检查 ExecutionMask 载体。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/legality/predicate-carriers.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-LEGALITY-PREDICATE-CARRIERS","surface":"tile","classification":["model","legality","predicate-carriers"],"depends_on":["PTO-TILE-MODEL-EXECUTION-MASK-STATE","PTO-TILE-MODEL-LEGALITY-DESCRIPTOR-SHAPE"]}

pure func TileCubePredicateDataTypeSupported(
    data_type: TileDataType) => boolean
begin
    return data_type == TileDataType_FP64 ||
           data_type == TileDataType_FP32 ||
           data_type == TileDataType_TF32 ||
           data_type == TileDataType_HF32 ||
           data_type == TileDataType_FP16 ||
           data_type == TileDataType_BF16 ||
           data_type == TileDataType_E4M3 ||
           data_type == TileDataType_E5M2 ||
           data_type == TileDataType_S64 ||
           data_type == TileDataType_S32 ||
           data_type == TileDataType_S16 ||
           data_type == TileDataType_S8 ||
           data_type == TileDataType_U64 ||
           data_type == TileDataType_U32 ||
           data_type == TileDataType_U16 ||
           data_type == TileDataType_U8;
end;

pure func TileCubePredicateGPRDataTypeSupported(
    data_type: TileDataType) => boolean
begin
    return TileElementBits(data_type) == 64 ||
           TileElementBits(data_type) == 32 ||
           TileElementBits(data_type) == 16 ||
           data_type == TileDataType_U8 ||
           data_type == TileDataType_S8 ||
           data_type == TileDataType_E4M3 ||
           data_type == TileDataType_E5M2;
end;

pure func TileCubePredicateFieldCount(
    data_type: TileDataType, layout: TileLayout) => integer {1..8}
begin
    assert TileCubePredicateGPRDataTypeSupported(data_type);
    if layout == TileLayout_CUBE_M32 then return 2; end;
    assert layout == TileLayout_CUBE_M16;
    return if TileElementBits(data_type) == 32 then 2 else 4;
end;

pure func TileCubePredicateRowBits(
    layout: TileLayout) => integer {16,32}
begin
    return if layout == TileLayout_CUBE_M32 then 32 else 16;
end;

readonly func TileCubePredicateGPRShapeLegal(index: TileIndex) => boolean
begin
    let tile = _Tiles[[index]];
    if !TileCubeDescriptorLegal(tile) ||
       !TileCubePredicateGPRDataTypeSupported(tile.data_type) then
        return FALSE;
    end;
    let words = if TileElementBits(tile.data_type) == 8 then 2 else 1;
    return tile.valid_rows <= TileCubePredicateRowBits(tile.layout) &&
           tile.valid_columns <=
               TileCubePredicateFieldCount(tile.data_type, tile.layout) * words;
end;

readonly func TileCubeNumericContentsDefined(index: TileIndex) => boolean
begin
    let tile = _Tiles[[index]];
    if !TileCubeDescriptorLegal(tile) ||
       tile.storage_kind != TileStorage_Numeric ||
       !TileCubePredicateDataTypeSupported(tile.data_type) then
        return FALSE;
    end;
    if !_BundleExecutionMask.valid then return tile.contents_defined; end;
    if tile.layout != _BundleExecutionMask.layout ||
       tile.valid_rows != _BundleExecutionMask.valid_rows ||
       tile.valid_columns != _BundleExecutionMask.valid_columns then
        return FALSE;
    end;
    for row = 0 to tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to tile.valid_columns - 1 looplimit 65536 do
            if BundleExecutionMaskActiveAt(
                   tile.layout, row as integer {0..65535},
                   column as integer {0..65535}) &&
               !TileElementDefined(index, row as integer {0..65535},
                   column as integer {0..65535}) then
                return FALSE;
            end;
        end;
    end;
    return TRUE;
end;

readonly func TileCubeNumericSourceLegal(index: TileIndex) => boolean
begin
    let tile = _Tiles[[index]];
    if !TileCubeNumericContentsDefined(index) then
        return FALSE;
    end;
    for row = 0 to tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to tile.valid_columns - 1 looplimit 65536 do
            if BundleExecutionMaskActiveAt(
                   tile.layout, row as integer {0..65535},
                   column as integer {0..65535}) then
                let element = TileLogicalLinearIndex(
                    tile, row as integer {0..65535},
                    column as integer {0..65535});
                if !TileNumericEncodingValid(
                       tile.data_type,
                       TileReadLogicalElement(tile, element)) then
                    return FALSE;
                end;
            end;
        end;
    end;
    return TRUE;
end;

readonly func TileCubeNumericShapeMatch(
    left: TileIndex, right: TileIndex) => boolean
begin
    let left_tile = _Tiles[[left]];
    let right_tile = _Tiles[[right]];
    return TileCubeDescriptorLegal(left_tile) &&
           TileCubeDescriptorLegal(right_tile) &&
           left_tile.storage_kind == TileStorage_Numeric &&
           right_tile.storage_kind == TileStorage_Numeric &&
           left_tile.rows == right_tile.rows &&
           left_tile.columns == right_tile.columns &&
           left_tile.valid_rows == right_tile.valid_rows &&
           left_tile.valid_columns == right_tile.valid_columns &&
           left_tile.layout == right_tile.layout;
end;

readonly func TileCubeNumericSourceEncodingsValidAs(
    index: TileIndex, operation_type: TileDataType) => boolean
begin
    let tile = _Tiles[[index]];
    if !TileCubeNumericContentsDefined(index) ||
       !TileCarrierWidthCompatible(tile.data_type, operation_type) then
        return FALSE;
    end;
    for row = 0 to tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to tile.valid_columns - 1 looplimit 65536 do
            if BundleExecutionMaskActiveAt(
                   tile.layout, row as integer {0..65535},
                   column as integer {0..65535}) then
                let element = TileLogicalLinearIndex(
                    tile, row as integer {0..65535},
                    column as integer {0..65535});
                if !TileNumericEncodingValid(
                       operation_type,
                       TileReadLogicalElement(tile, element)) then
                    return FALSE;
                end;
            end;
        end;
    end;
    return TRUE;
end;

readonly func TileCubeNumericSourceLegalAs(
    index: TileIndex, operation_type: TileDataType) => boolean
begin
    return TileCubeNumericSourceEncodingsValidAs(index, operation_type);
end;

readonly func TileCubeNumericShapeAndTypeMatch(
    left: TileIndex, right: TileIndex) => boolean
begin
    let left_tile = _Tiles[[left]];
    let right_tile = _Tiles[[right]];
    return TileCubeDescriptorLegal(left_tile) &&
           TileCubeDescriptorLegal(right_tile) &&
           left_tile.storage_kind == TileStorage_Numeric &&
           right_tile.storage_kind == TileStorage_Numeric &&
           left_tile.rows == right_tile.rows &&
           left_tile.columns == right_tile.columns &&
           left_tile.valid_rows == right_tile.valid_rows &&
           left_tile.valid_columns == right_tile.valid_columns &&
           left_tile.data_type == right_tile.data_type &&
           left_tile.layout == right_tile.layout;
end;

readonly func TileCubePredicateGPRShapeLegalAs(
    index: TileIndex, operation_type: TileDataType) => boolean
begin
    let tile = _Tiles[[index]];
    if !TileCubeDescriptorLegal(tile) ||
       !TileCubePredicateGPRDataTypeSupported(operation_type) ||
       !TileCarrierWidthCompatible(tile.data_type, operation_type) then
        return FALSE;
    end;
    let words = if TileElementBits(operation_type) == 8 then 2 else 1;
    return tile.valid_rows <= TileCubePredicateRowBits(tile.layout) &&
           tile.valid_columns <=
               TileCubePredicateFieldCount(operation_type, tile.layout) * words;
end;

readonly func TilePredicateCellDescriptorLegal(index: TileIndex) => boolean
begin
    let tile = _Tiles[[index]];
    return tile.allocated &&
           tile.storage_kind == TileStorage_PredicateCell &&
           tile.data_type == TileDataType_U8 &&
           TileCubePredicateDataTypeSupported(tile.predicate_basis_type) &&
           TileCubeLayoutDataTypeSupported(
               tile.layout, tile.predicate_basis_type) &&
           TileCubeDescriptorShapeAndPhysicalLegal(
               tile.capacity_bytes, tile.rows, tile.columns,
               tile.valid_rows, tile.valid_columns,
               tile.data_type, tile.layout) &&
           tile.cube_k_repeat == TileCubePhysicalKRepeat(
               tile.layout, tile.rows, tile.columns, tile.data_type) &&
           tile.cube_n_repeat == TileCubePhysicalNRepeat(
               tile.layout, tile.rows, tile.columns, tile.data_type) &&
           tile.cube_cell_count == TileCubePhysicalCellCount(
               tile.layout, tile.rows, tile.columns, tile.data_type) &&
           tile.cube_storage_bytes == TileCubePhysicalRequiredBytes(
               tile.layout, tile.rows, tile.columns, tile.data_type) &&
           tile.cube_storage_bytes <= tile.capacity_bytes;
end;

readonly func TilePredicateCellShapeMatchesNumeric(
    predicate: TileIndex, numeric: TileIndex) => boolean
begin
    let mask = _Tiles[[predicate]];
    let source = _Tiles[[numeric]];
    return TilePredicateCellDescriptorLegal(predicate) &&
           TileCubeDescriptorLegal(source) &&
           mask.predicate_basis_type == source.data_type &&
           mask.valid_rows == source.valid_rows &&
           mask.valid_columns == source.valid_columns &&
           mask.layout == source.layout;
end;

readonly func TilePredicateCellShapeMatchesNumericAs(
    predicate: TileIndex, numeric: TileIndex,
    operation_type: TileDataType) => boolean
begin
    let mask = _Tiles[[predicate]];
    let source = _Tiles[[numeric]];
    return TilePredicateCellDescriptorLegal(predicate) &&
           TileCubeDescriptorLegal(source) &&
           TileCarrierWidthCompatible(source.data_type, operation_type) &&
           mask.predicate_basis_type == operation_type &&
           mask.valid_rows == source.valid_rows &&
           mask.valid_columns == source.valid_columns &&
           mask.layout == source.layout;
end;

readonly func TileExecutionMaskPredicateCellShapeLegal(
    predicate: TileIndex, layout: TileLayout,
    valid_rows: integer {1..65535},
    valid_columns: integer {1..65535}) => boolean
begin
    let mask = _Tiles[[predicate]];
    return TilePredicateCellDescriptorLegal(predicate) &&
           (layout == TileLayout_CUBE_M16 ||
            layout == TileLayout_CUBE_M32) &&
           mask.layout == layout &&
           mask.valid_rows == valid_rows &&
           mask.valid_columns == valid_columns &&
           TilePredicateCellValuesLegal(predicate);
end;

readonly func TilePredicateCellValuesLegal(index: TileIndex) => boolean
begin
    let tile = _Tiles[[index]];
    if !TilePredicateCellDescriptorLegal(index) ||
       !tile.contents_defined then return FALSE; end;
    for row = 0 to tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to tile.valid_columns - 1 looplimit 65536 do
            let element = TileLogicalLinearIndex(
                tile, row as integer {0..65535},
                column as integer {0..65535});
            let value = TileReadLogicalElement(tile, element)[7:0];
            if value != '00000000' && value != '00000001' then
                return FALSE;
            end;
        end;
    end;
    return TRUE;
end;

readonly func TilePredicateCellOperationValuesLegal(index: TileIndex) => boolean
begin
    let tile = _Tiles[[index]];
    if !TilePredicateCellDescriptorLegal(index) then return FALSE; end;
    if !_BundleExecutionMask.valid && !tile.contents_defined then
        return FALSE;
    end;
    if _BundleExecutionMask.valid &&
       (tile.layout != _BundleExecutionMask.layout ||
        tile.valid_rows != _BundleExecutionMask.valid_rows ||
        tile.valid_columns != _BundleExecutionMask.valid_columns) then
        return FALSE;
    end;
    for row = 0 to tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to tile.valid_columns - 1 looplimit 65536 do
            if !_BundleExecutionMask.valid ||
               BundleExecutionMaskActiveAt(
                   tile.layout, row as integer {0..65535},
                   column as integer {0..65535}) then
                if !TileElementDefined(index, row as integer {0..65535},
                       column as integer {0..65535}) then
                    return FALSE;
                end;
                let element = TileLogicalLinearIndex(
                    tile, row as integer {0..65535},
                    column as integer {0..65535});
                let value = TileReadLogicalElement(tile, element)[7:0];
                if value != '00000000' && value != '00000001' then
                    return FALSE;
                end;
            end;
        end;
    end;
    return TRUE;
end;

readonly func IndexedTLSUPredicateDescriptorLegal(index: TileIndex) => boolean
begin
    let tile = _Tiles[[index]];
    if tile.data_type != TileDataType_U8 ||
       !IndexedTLSULayoutSupported(tile.layout) then
        return FALSE;
    end;
    if tile.layout == TileLayout_RowMajor then
        return tile.storage_kind == TileStorage_Numeric &&
               TileDescriptorLegal(index);
    end;
    if tile.storage_kind == TileStorage_PredicateCell then
        return TilePredicateCellDescriptorLegal(index);
    end;
    return tile.storage_kind == TileStorage_Numeric &&
           TileCubeDescriptorLegal(tile);
end;

readonly func IndexedTLSUPredicateValuesLegal(index: TileIndex) => boolean
begin
    let tile = _Tiles[[index]];
    if !IndexedTLSUPredicateDescriptorLegal(index) then return FALSE; end;
    if !_BundleExecutionMask.valid && !tile.contents_defined then
        return FALSE;
    end;
    if _BundleExecutionMask.valid &&
       (tile.layout != _BundleExecutionMask.layout ||
        tile.valid_rows != _BundleExecutionMask.valid_rows ||
        tile.valid_columns != _BundleExecutionMask.valid_columns) then
        return FALSE;
    end;
    for row = 0 to tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to tile.valid_columns - 1 looplimit 65536 do
            if !_BundleExecutionMask.valid ||
               BundleExecutionMaskActiveAt(
                   tile.layout, row as integer {0..65535},
                   column as integer {0..65535}) then
                if !TileElementDefined(index, row as integer {0..65535},
                       column as integer {0..65535}) then
                    return FALSE;
                end;
                let element = TileLogicalLinearIndex(
                    tile, row as integer {0..65535},
                    column as integer {0..65535});
                let value = TileReadLogicalElement(tile, element)[7:0];
                if value != '00000000' && value != '00000001' then
                    return FALSE;
                end;
            end;
        end;
    end;
    return TRUE;
end;

readonly func ReadIndexedTLSUPredicate(
    index: TileIndex, row: integer {0..65535},
    column: integer {0..65535}) => boolean
begin
    let tile = _Tiles[[index]];
    assert IndexedTLSUPredicateValuesLegal(index);
    let element = TileLogicalLinearIndex(tile, row, column);
    return TileReadLogicalElement(tile, element)[0] == '1';
end;

func PredicateCellWithPadding(
    tile: TileInfo, pad_value: TilePadValue) => TileInfo
begin
    var result = tile;
    assert result.storage_kind == TileStorage_PredicateCell;
    let padding_defined = pad_value != TilePad_Null;
    let padding = if pad_value == TilePad_Max then
        Zeros{PTO_XLEN} + 1 else Zeros{PTO_XLEN};
    for row = 0 to result.rows - 1 looplimit 65536 do
        for column = 0 to result.columns - 1 looplimit 65536 do
            if row >= result.valid_rows || column >= result.valid_columns then
                let element = TileLogicalLinearIndex(
                    result, row as integer {0..65535},
                    column as integer {0..65535});
                result = TileInfoWithLogicalElementAndDefined(
                    result, element, padding, padding_defined);
            end;
        end;
    end;
    return result;
end;
```
<!-- GENERATED-ASL-END: unit -->
