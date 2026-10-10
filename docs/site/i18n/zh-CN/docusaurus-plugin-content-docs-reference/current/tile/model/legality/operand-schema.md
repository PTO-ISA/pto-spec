<!-- GENERATED FROM: asl/tile/model/legality/operand-schema.asl -->
# Operand Schema

**Normative ASL source:** `asl/tile/model/legality/operand-schema.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-LEGALITY-OPERAND-SCHEMA}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-legality-operand-schema-purpose role=purpose-scope -->
## 用途与范围

本单元定义逐元素、比较、选择、生成与转换处理器的操作数合法性谓词。每个谓词以 `TileOperandsLegal_` 前缀加处理器名命名，只有在所有操作数描述符、类型、布局以及所需的源值都可接受时才返回 TRUE。

`PTO-INSTRUCTION` 元数据把这些谓词列为合法性处理器，例如：

- `TileOperandsLegal_ExecuteTileBinary` 用于 TADD、TSUB、TMUL、TDIV、TREM、TMAX、TMIN、TAND、TOR、TXOR、TSHL 与 TSHR。
- `TileOperandsLegal_ExecuteTileUnary` 用于 TABS、TNEG、TNOT、TRELU、TEXP、TLOG、TRECIP、TSQRT 与 TRSQRT。
- `TileOperandsLegal_ExecuteTileScalar` 用于十二个 Tile-标量操作，例如 TADDS 与 TSHLS。
- 用于 TCMP、TCMPS、TSEL 与 TSELS 的比较与选择谓词，以及 `TileOperandsLegal_TCI`、`TileOperandsLegal_TTRI` 与 `TileOperandsLegal_TCVT`。

<!-- PTO-READER-BLOCK: tile-model-legality-operand-schema-concepts role=concepts-state -->
## 概念与可见状态

这些谓词都是 `readonly`。它们读取 `_Tiles`、所选的指令束操作以及指令束 ExecutionMask 状态，不写任何内容。

当选中了带有有效 DataType 的 Tile 操作时，操作类型就是该指令束 DataType。否则二元、一元与标量谓词使用目标的后备类型。比较与选择包装函数则调用 `ResolveTileCarrierOperationType`，它会拒绝没有可解析类型的活动指令束。

`TileElementwiseDescriptorLegal` 用 `TileCubeDescriptorLegal` 检查 CUBE Tile，用 `TileDescriptorLegal` 检查其他 Tile。随后 `TileElementwiseShapeMatch` 要求行数、列数、有效行数、有效列数、布局与存储种类都相等。

<!-- PTO-READER-BLOCK: tile-model-legality-operand-schema-rules role=rules-interactions -->
## 规则与交互

`TileOperandsLegal_ExecuteTileBinary` 拒绝 EXPDIF，要求两个源与目标形状匹配，要求目标类型等于操作类型，并要求每个源后备满足 `TileCarrierWidthCompatible`。对十二个封闭操作，它还检查源已定义性、该操作的类型集合、逐元素布局、移位操作的右源为整数，以及除 AND、OR、XOR、SHL 与 SHR 以外的编码有效性。

设计要点：整数 TDIV 与 TREM 还要求除数满足 `TilePayloadNonzero`。除数在预检中被读取，因此活动的零除数会在写入任何目标元素之前拒绝该指令束。

`TileOperandsLegal_ExecuteTileUnary` 要求 TNOT 的源与目标后备类型完全相同且为整数类型。其他一元操作接受同位宽后备，并检查已定义性、类型集合、布局与编码。

`TileOperandsLegal_ExecuteTileScalar` 把标量规范化为操作位宽，并且除原始逻辑操作外要求编码有效。整数 TDIVS 与 TREMS 只有在 ExecutionMask 不留下任何活动坐标时才接受零标量。

比较谓词按源布局分支。对 CUBE_M16 与 CUBE_M32 源，目标必须是基础类型等于操作类型的谓词单元。否则每个源都必须通过 `TileRowMajorNumericCarrierLegal`，目标必须是位打包的谓词 Tile。选择谓词对其掩码操作数使用相同的划分。

`TileOperandsLegal_TCVT` 要求有效形状相等、转换类型对与舍入模式受支持，并要求源后备与源操作类型同位宽。CUBE_M16 或 CUBE_M32 源保持其布局，物理大小可以改变。其他转换保持行数与列数，并拒绝 CUBE 目标和规范化。

设计要点：对于自行负责源已定义性的处理器，生成的分派器不会额外添加 `TileSourceContentsDefined` 检查。这些谓词使用 `TileElementwiseSourceContentsDefined` 等感知 ExecutionMask 的已定义性辅助函数，因此在 ExecutionMask 下只有活动源坐标必须已定义。

<!-- PTO-READER-BLOCK: tile-model-legality-operand-schema-boundaries role=boundaries -->
## 架构边界

合法性检查在执行之前运行。生成的分派器调用处理器对应的 `TileOperandsLegal_` 谓词，当其返回 FALSE 时产生 `Fault_TileLegality`，且不调用处理器。执行函数随后断言其中一部分相同条件。

数值合法性按操作区分。TADD 与 TDIV 保留 16 类型宽域，而其已验证浮点有限路径覆盖 `FP64`、`FP32`、`FP16` 与 `BF16`；既有 `TF32`、`HF32`、`E4M3` 与 `E5M2` 有限结果缺口保持不变。TSUB、TMUL、TREM、TMIN 与 TMAX 使用各自较窄的精确 owner 集合，并在 owner 接受时包含 FP64。SFU 组中，TEXP 保留八种浮点合法类型，但同样只有四种已验证有限路径和四种有限结果缺口；TLOG、TRECIP、TSQRT 与 TRSQRT 恰好接受这四种可执行类型。

`TileOperandsLegal_TRESHAPE`、`TileOperandsLegal_TINTERLEAVE` 与 `TileOperandsLegal_TDEINTERLEAVE` 在此定义，但在 `asl/` 中没有调用者。

<!-- PTO-READER-BLOCK: tile-model-legality-operand-schema-example role=example-usage -->
## 非规范阅读示例

考虑操作类型为 S32、没有 ExecutionMask 的 TDIV，三个 RowMajor 16 x 16 Tile 的有效区域均为 16 x 10。左源（被除数）为 S32，右源（除数）为 U32。

- 形状匹配，目标类型为 S32。
- `TileCarrierWidthCompatible(U32, S32)` 为 TRUE，因此右源按 S32 读取。
- S32 属于算术集合，RowMajor 是逐元素布局，两个源都已定义。
- 除数有 16 x 10 = 160 个有效元素。只要其中任一为零，`TilePayloadNonzero` 就返回 FALSE，指令束在写入任何目标元素之前产生故障。

<!-- PTO-READER-BLOCK: tile-model-legality-operand-schema-related role=related-owners-navigation -->
## 相关所有者

- [数据类型与布局表](dtype-layout.md) 定义类型集合与载体位宽关系。
- [ExecutionMask 源 schema](execution-mask-source-schema.md) 定义活动坐标已定义性与编码检查。
- [谓词载体](predicate-carriers.md) 定义比较与选择所用的 CUBE 与谓词单元辅助函数。
- [分配容量](allocation-capacity.md) 定义 `TilePayloadNonzero`。
- [逐元素执行](../execution/elementwise.md) 展示这些检查通过后运行的内容。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/legality/operand-schema.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-LEGALITY-OPERAND-SCHEMA","surface":"tile","classification":["model","legality","operand-schema"],"depends_on":["PTO-TILE-MODEL-EXECUTION-UNARY","PTO-TILE-MODEL-LEGALITY-ALLOCATION-CAPACITY","PTO-TILE-MODEL-LEGALITY-EXECUTION-MASK-SOURCE-SCHEMA","PTO-TILE-MODEL-LEGALITY-PREDICATE-CARRIERS"]}
readonly func TileElementwiseDescriptorLegal(index: TileIndex) => boolean
begin
    let tile = _Tiles[[index]];
    if TileLayoutIsCube(tile.layout) then
        return TileCubeDescriptorLegal(tile);
    end;
    return TileDescriptorLegal(index);
end;
readonly func TileElementwiseShapeMatch(left: TileIndex, right: TileIndex) => boolean
begin
    if !TileElementwiseDescriptorLegal(left) || !TileElementwiseDescriptorLegal(right) then return FALSE; end;
    return _Tiles[[left]].rows == _Tiles[[right]].rows && _Tiles[[left]].columns == _Tiles[[right]].columns &&
           _Tiles[[left]].valid_rows == _Tiles[[right]].valid_rows && _Tiles[[left]].valid_columns == _Tiles[[right]].valid_columns &&
           _Tiles[[left]].layout == _Tiles[[right]].layout && _Tiles[[left]].storage_kind == _Tiles[[right]].storage_kind;
end;
readonly func TileElementwiseShapeAndTypeMatch(left: TileIndex, right: TileIndex) => boolean
begin
    if !TileElementwiseDescriptorLegal(left) || !TileElementwiseDescriptorLegal(right) then return FALSE; end;
    return _Tiles[[left]].rows == _Tiles[[right]].rows && _Tiles[[left]].columns == _Tiles[[right]].columns &&
           _Tiles[[left]].valid_rows == _Tiles[[right]].valid_rows && _Tiles[[left]].valid_columns == _Tiles[[right]].valid_columns &&
           _Tiles[[left]].layout == _Tiles[[right]].layout && _Tiles[[left]].storage_kind == _Tiles[[right]].storage_kind &&
           _Tiles[[left]].data_type == _Tiles[[right]].data_type;
end;
readonly func TileRowMajorNumericCarrierLegal(
    index: TileIndex, operation_type: TileDataType) => boolean
begin
    let tile = _Tiles[[index]];
    return TileDescriptorLegal(index) &&
           tile.storage_kind == TileStorage_Numeric &&
           tile.layout == TileLayout_RowMajor &&
           TileTeplRawCarrierTypeSupported(tile.data_type) &&
           !TileDataTypeIsFourBit(tile.data_type) &&
           TileCarrierWidthCompatible(tile.data_type, operation_type);
end;

readonly func TileOperandsLegal_ExecuteTileBinary(
    op: TileBinaryOperation, destination: TileIndex,
    source_left: TileIndex, source_right: TileIndex) => boolean
begin
    if op == TileBinary_EXPDIF then return FALSE; end;
    let operation_type = if BundleTileOperationSelected() &&
        _BundleOperation.data_type_valid then TileDataTypeFromEncoding(
            _BundleOperation.data_type as TileDataTypeEncoding)
        else _Tiles[[destination]].data_type;
    let raw_carrier = op == TileBinary_AND || op == TileBinary_OR ||
                      op == TileBinary_XOR || op == TileBinary_SHL ||
                      op == TileBinary_SHR;
    if !TileElementwiseShapeMatch(source_left, source_right) ||
       !TileElementwiseShapeMatch(destination, source_left) ||
       _Tiles[[destination]].data_type != operation_type ||
       !TileCarrierWidthCompatible(
           _Tiles[[source_left]].data_type, operation_type) ||
       !TileCarrierWidthCompatible(
           _Tiles[[source_right]].data_type, operation_type) then
        return FALSE;
    end;
    if TileBinaryUsesClosedElementwiseContract(op) then
        if !TileElementwiseSourceContentsDefined(source_left) ||
           !TileElementwiseSourceContentsDefined(source_right) ||
           !TileBinaryDataTypeSupported(op, operation_type) ||
           !TileElementwiseLayoutSupported(_Tiles[[source_left]].layout) then
            return FALSE;
        end;
        if (op == TileBinary_SHL || op == TileBinary_SHR) &&
           !TileDataTypeIsInteger(_Tiles[[source_right]].data_type) then
            return FALSE;
        end;
        if !raw_carrier &&
           (!TileElementwiseSourceEncodingsValidAs(
                source_left, operation_type) ||
            !TileElementwiseSourceEncodingsValidAs(
                source_right, operation_type)) then
            return FALSE;
        end;
    end;
    if (op == TileBinary_DIV || op == TileBinary_REM) &&
       TileDataTypeIsInteger(operation_type) then
        return TilePayloadNonzero(source_right);
    end;
    return TRUE;
end;
readonly func TileOperandsLegal_ExecuteTileUnary(
    op: TileUnaryOperation, destination: TileIndex, source: TileIndex) => boolean
begin
    let operation_type = if BundleTileOperationSelected() &&
        _BundleOperation.data_type_valid then TileDataTypeFromEncoding(
            _BundleOperation.data_type as TileDataTypeEncoding)
        else _Tiles[[destination]].data_type;
    if op == TileUnary_NOT then
        return TileElementwiseShapeAndTypeMatch(destination, source) &&
               _Tiles[[destination]].data_type == operation_type &&
               TileVecScalarIntegerDataTypeSupported(operation_type) &&
               TileElementwiseLayoutSupported(_Tiles[[source]].layout) &&
               TileElementwiseSourceContentsDefined(source);
    end;
    if !TileElementwiseShapeMatch(destination, source) ||
       _Tiles[[destination]].data_type != operation_type ||
       !TileCarrierWidthCompatible(
           _Tiles[[source]].data_type, operation_type) then
        return FALSE;
    end;
    if TileUnaryUsesCompleteElementwiseSchema(op) then
        return TileElementwiseSourceContentsDefined(source) &&
               TileUnaryDataTypeSupported(op, operation_type) &&
               TileElementwiseLayoutSupported(_Tiles[[source]].layout) &&
               TileElementwiseSourceEncodingsValidAs(source, operation_type);
    end;
    return TRUE;
end;
readonly func TileOperandsLegal_ExecuteTileScalar(
    op: TileBinaryOperation, destination: TileIndex,
    source: TileIndex, scalar: Word) => boolean
begin
    if op == TileBinary_EXPDIF then return FALSE; end;
    let operation_type = if BundleTileOperationSelected() &&
        _BundleOperation.data_type_valid then TileDataTypeFromEncoding(
            _BundleOperation.data_type as TileDataTypeEncoding)
        else _Tiles[[destination]].data_type;
    let carrier_logical = op == TileBinary_AND || op == TileBinary_OR ||
                          op == TileBinary_XOR || op == TileBinary_SHL ||
                          op == TileBinary_SHR;
    if !TileElementwiseShapeMatch(destination, source) ||
       _Tiles[[source]].storage_kind != TileStorage_Numeric ||
       _Tiles[[destination]].data_type != operation_type ||
       !TileCarrierWidthCompatible(
           _Tiles[[source]].data_type, operation_type) ||
       !TileElementwiseLayoutSupported(_Tiles[[source]].layout) ||
       !TileBinaryDataTypeSupported(op, operation_type) ||
       !TileElementwiseSourceContentsDefined(source) then
        return FALSE;
    end;
    if !carrier_logical &&
       !TileElementwiseSourceEncodingsValidAs(source, operation_type) then
        return FALSE;
    end;
    let normalized_scalar = TileRawElementValue(scalar, operation_type);
    if !carrier_logical &&
       !TileNumericEncodingValid(operation_type, normalized_scalar) then
        return FALSE;
    end;
    if (op == TileBinary_DIV || op == TileBinary_REM) &&
       TileDataTypeIsInteger(operation_type) then
        return !IsZero(TileIntegerOperandValue(
                   normalized_scalar, operation_type)) ||
               !BundleExecutionMaskHasActiveCoordinate();
    end;
    return TRUE;
end;
readonly func TileOperandsLegal_ExecuteTileCompareAs(
    destination: TileIndex, source_left: TileIndex, source_right: TileIndex,
    comparison: TileComparison, operation_type: TileDataType) => boolean
begin
    if _Tiles[[source_left]].layout == TileLayout_CUBE_M16 ||
       _Tiles[[source_left]].layout == TileLayout_CUBE_M32 then
        return TileCompareDataTypeSupported(operation_type) &&
               TileCubePredicateDataTypeSupported(operation_type) &&
               TileCubeNumericShapeMatch(source_left, source_right) &&
               TileCubeNumericSourceLegalAs(source_left, operation_type) &&
               TileCubeNumericSourceLegalAs(source_right, operation_type) &&
               TilePredicateCellShapeMatchesNumericAs(
                   destination, source_left, operation_type);
    end;
    return TileCompareDataTypeSupported(operation_type) &&
           TileRowMajorNumericCarrierLegal(source_left, operation_type) &&
           TileRowMajorNumericCarrierLegal(source_right, operation_type) &&
           TileLogicalShapeMatch(source_left, source_right) &&
           TileElementwiseSourceContentsDefined(source_left) &&
           TileElementwiseSourceContentsDefined(source_right) &&
           TileElementwiseSourceEncodingsValidAs(source_left, operation_type) &&
           TileElementwiseSourceEncodingsValidAs(source_right, operation_type) &&
           TileLogicalShapeMatch(destination, source_left) &&
           _Tiles[[destination]].storage_kind == TileStorage_Predicate;
end;
readonly func TileOperandsLegal_ExecuteTileCompare(
    destination: TileIndex, source_left: TileIndex, source_right: TileIndex,
    comparison: TileComparison) => boolean
begin
    let (operation_type_valid, operation_type) = ResolveTileCarrierOperationType(_Tiles[[source_left]].data_type);
    return operation_type_valid &&
           TileOperandsLegal_ExecuteTileCompareAs(destination, source_left, source_right, comparison, operation_type);
end;
readonly func TileOperandsLegal_ExecuteTileCompareScalarAs(
    destination: TileIndex, source: TileIndex, scalar: Word,
    comparison: TileComparison, operation_type: TileDataType) => boolean
begin
    if _Tiles[[source]].layout == TileLayout_CUBE_M16 ||
       _Tiles[[source]].layout == TileLayout_CUBE_M32 then
        return TileCompareDataTypeSupported(operation_type) &&
               TileCubePredicateDataTypeSupported(operation_type) &&
               TileCubeNumericSourceLegalAs(source, operation_type) &&
               TileNumericEncodingValid(
                   operation_type,
                   TileRawElementValue(scalar, operation_type)) &&
               TilePredicateCellShapeMatchesNumericAs(
                   destination, source, operation_type);
    end;
    return TileCompareDataTypeSupported(operation_type) &&
           TileRowMajorNumericCarrierLegal(source, operation_type) &&
           TileElementwiseSourceContentsDefined(source) &&
           TileElementwiseSourceEncodingsValidAs(source, operation_type) &&
           TileNumericEncodingValid(
               operation_type,
               TileRawElementValue(scalar, operation_type)) &&
           TileLogicalShapeMatch(destination, source) &&
           _Tiles[[destination]].storage_kind == TileStorage_Predicate;
end;
readonly func TileOperandsLegal_ExecuteTileCompareScalar(
    destination: TileIndex, source: TileIndex, scalar: Word,
    comparison: TileComparison) => boolean
begin
    let (operation_type_valid, operation_type) = ResolveTileCarrierOperationType(_Tiles[[source]].data_type);
    return operation_type_valid &&
           TileOperandsLegal_ExecuteTileCompareScalarAs(destination, source, scalar, comparison, operation_type);
end;
readonly func TileOperandsLegal_ExecuteTileSelectAs(
    destination: TileIndex, mask: TileIndex,
    source_true: TileIndex, source_false: TileIndex,
    operation_type: TileDataType) => boolean
begin
    if _Tiles[[source_true]].layout == TileLayout_CUBE_M16 ||
       _Tiles[[source_true]].layout == TileLayout_CUBE_M32 then
        return TileSelectDataTypeSupported(operation_type) &&
               TileCubePredicateDataTypeSupported(operation_type) &&
               TileCubeNumericShapeMatch(source_true, source_false) &&
               TileCubeNumericContentsDefined(source_true) &&
               TileCubeNumericContentsDefined(source_false) &&
               TileCarrierWidthCompatible(
                   _Tiles[[source_true]].data_type, operation_type) &&
               TileCarrierWidthCompatible(
                   _Tiles[[source_false]].data_type, operation_type) &&
               TilePredicateCellOperationValuesLegal(mask) &&
               TilePredicateCellShapeMatchesNumericAs(
                   mask, source_true, operation_type) &&
               TileCubeDescriptorLegal(_Tiles[[destination]]) &&
               _Tiles[[destination]].storage_kind == TileStorage_Numeric &&
               _Tiles[[destination]].data_type == operation_type &&
               TileCubeNumericShapeMatch(destination, source_true);
    end;
    return TileSelectDataTypeSupported(operation_type) &&
           TileRowMajorNumericCarrierLegal(source_true, operation_type) &&
           TileRowMajorNumericCarrierLegal(source_false, operation_type) &&
           TileLogicalShapeMatch(source_true, source_false) &&
           TileElementwiseSourceContentsDefined(source_true) &&
           TileElementwiseSourceContentsDefined(source_false) &&
           TilePredicateValuesLegal(mask) &&
           TileLogicalShapeMatch(mask, source_true) &&
           TileLogicalShapeMatch(destination, source_true) &&
           _Tiles[[destination]].storage_kind == TileStorage_Numeric &&
           _Tiles[[destination]].data_type == operation_type;
end;
readonly func TileOperandsLegal_ExecuteTileSelect(
    destination: TileIndex, mask: TileIndex,
    source_true: TileIndex, source_false: TileIndex) => boolean
begin
    let (operation_type_valid, operation_type) =
        ResolveTileCarrierOperationType(_Tiles[[destination]].data_type);
    return operation_type_valid &&
           TileOperandsLegal_ExecuteTileSelectAs(
               destination, mask, source_true, source_false, operation_type);
end;
readonly func TileOperandsLegal_ExecuteTileSelectScalarAs(
    destination: TileIndex, mask: TileIndex,
    source_true: TileIndex, scalar_false: Word,
    operation_type: TileDataType) => boolean
begin
    if _Tiles[[source_true]].layout == TileLayout_CUBE_M16 ||
       _Tiles[[source_true]].layout == TileLayout_CUBE_M32 then
        return TileSelectDataTypeSupported(operation_type) &&
               TileCubePredicateDataTypeSupported(operation_type) &&
               TileCubeNumericContentsDefined(source_true) &&
               TileCarrierWidthCompatible(
                   _Tiles[[source_true]].data_type, operation_type) &&
               TilePredicateCellOperationValuesLegal(mask) &&
               TilePredicateCellShapeMatchesNumericAs(
                   mask, source_true, operation_type) &&
               TileCubeDescriptorLegal(_Tiles[[destination]]) &&
               _Tiles[[destination]].storage_kind == TileStorage_Numeric &&
               _Tiles[[destination]].data_type == operation_type &&
               TileCubeNumericShapeMatch(destination, source_true);
    end;
    return TileSelectDataTypeSupported(operation_type) &&
           TileRowMajorNumericCarrierLegal(source_true, operation_type) &&
           TileElementwiseSourceContentsDefined(source_true) &&
           TilePredicateValuesLegal(mask) &&
           TileLogicalShapeMatch(mask, source_true) &&
           TileLogicalShapeMatch(destination, source_true) &&
           _Tiles[[destination]].storage_kind == TileStorage_Numeric &&
           _Tiles[[destination]].data_type == operation_type;
end;
readonly func TileOperandsLegal_ExecuteTileSelectScalar(
    destination: TileIndex, mask: TileIndex,
    source_true: TileIndex, scalar_false: Word) => boolean
begin
    let (operation_type_valid, operation_type) =
        ResolveTileCarrierOperationType(_Tiles[[destination]].data_type);
    return operation_type_valid &&
           TileOperandsLegal_ExecuteTileSelectScalarAs(
               destination, mask, source_true, scalar_false, operation_type);
end;
readonly func TileOperandsLegal_TCI(
    destination: TileIndex, start: Word, descending: boolean) => boolean
begin
    if !TileDescriptorLegal(destination) then return FALSE; end;
    let tile = _Tiles[[destination]];
    return TileTCIDataTypeSupported(tile.data_type) &&
           tile.storage_kind == TileStorage_Numeric &&
           tile.layout == TileLayout_RowMajor &&
           tile.valid_rows == 1 &&
           tile.valid_columns >= 1 &&
           tile.columns >= tile.valid_columns;
end;
readonly func TileOperandsLegal_TTRI(
    destination: TileIndex, upper: boolean,
    diagonal: integer {-65535..65535}) => boolean
begin
    if !TileDescriptorLegal(destination) then return FALSE; end;
    let tile = _Tiles[[destination]];
    return TileTTRIDataTypeSupported(tile.data_type) &&
           tile.storage_kind == TileStorage_Numeric &&
           tile.layout == TileLayout_RowMajor &&
           tile.valid_rows >= 1 &&
           tile.valid_columns >= 1 &&
           tile.rows >= tile.valid_rows &&
           tile.columns >= tile.valid_columns;
end;
readonly func TileTCVTSourceContentsDefined(index: TileIndex) => boolean
begin
    let tile = _Tiles[[index]];
    if _BundleExecutionMask.valid then
        return TileElementwiseSourceContentsDefined(index);
    end;
    if TileLayoutIsCube(tile.layout) then
        return TileCubeDescriptorLegal(tile) && tile.contents_defined;
    end;
    return TileSourceContentsDefined(index);
end;
readonly func TileTCVTSourceEncodingsValidAs(
    index: TileIndex, operation_type: TileDataType) => boolean
begin
    let tile = _Tiles[[index]];
    if _BundleExecutionMask.valid then
        return TileElementwiseSourceEncodingsValidAs(index, operation_type);
    end;
    if !TileTCVTSourceContentsDefined(index) ||
       !TileCarrierWidthCompatible(tile.data_type, operation_type) then
        return FALSE;
    end;
    for row = 0 to tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to tile.valid_columns - 1 looplimit 65536 do
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
    return TRUE;
end;
readonly func TileTCVTSourceEncodingsValid(index: TileIndex) => boolean
begin
    return TileTCVTSourceEncodingsValidAs(index, _Tiles[[index]].data_type);
end;
readonly func TileOperandsLegal_TCVT(destination: TileIndex,
                                     source: TileIndex,
                                     control: NumericExecutionControl) => boolean
begin
    let destination_tile = _Tiles[[destination]];
    let source_tile = _Tiles[[source]];
    let source_operation_type = if BundleTileOperationSelected() &&
        _BundleOperation.data_type_valid then TileDataTypeFromEncoding(
            _BundleOperation.data_type as TileDataTypeEncoding)
        else source_tile.data_type;
    if (if TileLayoutIsCube(destination_tile.layout) then
            !TileCubeDescriptorLegal(destination_tile)
        else !TileDescriptorLegal(destination)) ||
       !TileTCVTSourceContentsDefined(source) ||
       !TileTCVTSourceEncodingsValidAs(source, source_operation_type) then
        return FALSE;
    end;
    if !TileCarrierWidthCompatible(
           source_tile.data_type, source_operation_type) ||
       !HardwareTCVTTypePairSupported(
           source_operation_type,
           destination_tile.data_type) ||
       !HardwareTCVTRoundingModeSupported(
           source_operation_type, destination_tile.data_type,
           control.rounding_mode) then
        return FALSE;
    end;
    if destination_tile.valid_rows != source_tile.valid_rows ||
       destination_tile.valid_columns != source_tile.valid_columns then
        return FALSE;
    end;
    let source_cube_m_layout =
        source_tile.layout == TileLayout_CUBE_M16 ||
        source_tile.layout == TileLayout_CUBE_M32;
    if source_cube_m_layout then
        // A CUBE M-format conversion preserves the physical matrix format
        // while allowing the element width, and therefore the CELL count and
        // minimum legal TSize, to change.
        return !CurrentBundleCanonicalize() &&
               CurrentBundleDataLayout() == TileDataLayout_NORM &&
               destination_tile.layout == source_tile.layout &&
               TileCubeDescriptorShapeLegal(
                   source_tile.capacity_bytes, source_tile.valid_rows,
                   source_tile.valid_columns, source_tile.data_type,
                   source_tile.layout) &&
               TileCubeDescriptorShapeLegal(
                   destination_tile.capacity_bytes, destination_tile.valid_rows,
                   destination_tile.valid_columns, destination_tile.data_type,
                   destination_tile.layout);
    end;
    if destination_tile.rows != source_tile.rows ||
       destination_tile.columns != source_tile.columns then return FALSE; end;
    if TileLayoutIsCube(destination_tile.layout) then
        return FALSE;
    end;
    if CurrentBundleCanonicalize() then
        return FALSE;
    end;
    return source_tile.layout == CurrentBundleTileSourceLayout() &&
           destination_tile.layout == CurrentBundleTileLayout();
end;
readonly func TileOperandsLegal_TRESHAPE(destination: TileIndex, source: TileIndex) => boolean begin
    return TileDescriptorLegal(destination) && TileDescriptorLegal(source) &&
           _Tiles[[destination]].rows * _Tiles[[destination]].columns == _Tiles[[source]].rows * _Tiles[[source]].columns &&
           _Tiles[[destination]].valid_rows * _Tiles[[destination]].valid_columns == _Tiles[[source]].valid_rows * _Tiles[[source]].valid_columns &&
           _Tiles[[destination]].data_type == _Tiles[[source]].data_type;
end;
readonly func TileOperandsLegal_TINTERLEAVE(destination: TileIndex, source_even: TileIndex, source_odd: TileIndex) => boolean
begin
    if !TileDescriptorLegal(destination) || !TileDescriptorLegal(source_even) || !TileDescriptorLegal(source_odd) then return FALSE; end;
    let extent: integer = _Tiles[[source_even]].valid_rows * _Tiles[[source_even]].valid_columns;
    return extent <= PTO_MODEL_TILE_ELEMENTS DIV 2 && extent == _Tiles[[source_odd]].valid_rows * _Tiles[[source_odd]].valid_columns &&
           _Tiles[[destination]].valid_rows * _Tiles[[destination]].valid_columns == extent * 2 &&
           _Tiles[[destination]].data_type == _Tiles[[source_even]].data_type && _Tiles[[destination]].data_type == _Tiles[[source_odd]].data_type &&
           _Tiles[[destination]].layout == _Tiles[[source_even]].layout && _Tiles[[destination]].layout == _Tiles[[source_odd]].layout;
end;
readonly func TileOperandsLegal_TDEINTERLEAVE(destination_even: TileIndex, destination_odd: TileIndex, source: TileIndex) => boolean
begin
    if destination_even == destination_odd then return FALSE; end;
    if !TileDescriptorLegal(destination_even) || !TileDescriptorLegal(destination_odd) || !TileDescriptorLegal(source) then return FALSE; end;
    let extent: integer = _Tiles[[destination_even]].valid_rows * _Tiles[[destination_even]].valid_columns;
    return extent <= PTO_MODEL_TILE_ELEMENTS DIV 2 && extent == _Tiles[[destination_odd]].valid_rows * _Tiles[[destination_odd]].valid_columns &&
           _Tiles[[source]].valid_rows * _Tiles[[source]].valid_columns == extent * 2 &&
           _Tiles[[destination_even]].data_type == _Tiles[[source]].data_type && _Tiles[[destination_odd]].data_type == _Tiles[[source]].data_type &&
           _Tiles[[destination_even]].layout == _Tiles[[source]].layout && _Tiles[[destination_odd]].layout == _Tiles[[source]].layout;
end;
```
<!-- GENERATED-ASL-END: unit -->
