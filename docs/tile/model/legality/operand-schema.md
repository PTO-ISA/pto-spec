<!-- GENERATED FROM: asl/tile/model/legality/operand-schema.asl -->
# Operand Schema

**Normative ASL source:** `asl/tile/model/legality/operand-schema.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-LEGALITY-OPERAND-SCHEMA}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-legality-operand-schema-purpose role=purpose-scope -->
## Purpose and scope

This unit defines the operand legality predicates for the elementwise, comparison, select, generation, and conversion handlers. Each predicate, named with the `TileOperandsLegal_` prefix and the handler name, returns TRUE only when every operand descriptor, type, layout, and required source value is acceptable.

The `PTO-INSTRUCTION` metadata names these predicates as legality handlers, for example:

- `TileOperandsLegal_ExecuteTileBinary` for TADD, TSUB, TMUL, TDIV, TREM, TMAX, TMIN, TAND, TOR, TXOR, TSHL, and TSHR.
- `TileOperandsLegal_ExecuteTileUnary` for TABS, TNEG, TNOT, TRELU, TEXP, TLOG, TRECIP, TSQRT, and TRSQRT.
- `TileOperandsLegal_ExecuteTileScalar` for the twelve Tile-scalar operations such as TADDS and TSHLS.
- The compare and select predicates for TCMP, TCMPS, TSEL, and TSELS, plus `TileOperandsLegal_TCI`, `TileOperandsLegal_TTRI`, and `TileOperandsLegal_TCVT`.

<!-- PTO-READER-BLOCK: tile-model-legality-operand-schema-concepts role=concepts-state -->
## Concepts and visible state

The predicates are `readonly`. They read `_Tiles`, the selected bundle operation, and the bundle ExecutionMask state, and write nothing.

The operation type is the bundle DataType when a Tile operation is selected with a valid DataType. Otherwise the binary, unary, and scalar predicates use the destination's backing type. The compare and select wrappers instead call `ResolveTileCarrierOperationType`, which rejects an active bundle without a resolvable type.

`TileElementwiseDescriptorLegal` checks CUBE Tiles with `TileCubeDescriptorLegal` and other Tiles with `TileDescriptorLegal`. `TileElementwiseShapeMatch` then requires equal rows, columns, valid rows, valid columns, layout, and storage kind.

<!-- PTO-READER-BLOCK: tile-model-legality-operand-schema-rules role=rules-interactions -->
## Rules and interactions

`TileOperandsLegal_ExecuteTileBinary` rejects EXPDIF, requires matching shapes for both sources and the destination, requires the destination type to equal the operation type, and requires each source backing to satisfy `TileCarrierWidthCompatible`. For the twelve closed operations it also checks source definedness, the operation's type set, an elementwise layout, an integer right source for shifts, and valid encodings except for AND, OR, XOR, SHL, and SHR.

Design point: integer TDIV and TREM additionally require `TilePayloadNonzero` on the divisor. The divisor is read in preflight, so a zero active divisor rejects the bundle before any destination element is written.

`TileOperandsLegal_ExecuteTileUnary` requires TNOT sources to have the destination's exact backing type and an integer type. The other unary operations accept a same-width backing and check definedness, type set, layout, and encodings.

`TileOperandsLegal_ExecuteTileScalar` normalizes the scalar to the operation width and, except for the raw logical operations, requires a valid encoding. Integer TDIVS and TREMS accept a zero scalar only when an ExecutionMask leaves no active coordinate.

Compare predicates branch on the source layout. For CUBE_M16 and CUBE_M32 sources, the destination must be a predicate cell whose basis type is the operation type. Otherwise each source must pass `TileRowMajorNumericCarrierLegal` and the destination must be a bit-packed predicate Tile. Select predicates use the same split for their mask operand.

`TileOperandsLegal_TCVT` requires equal valid shapes, a supported conversion pair and rounding mode, and a same-width backing for the source operation type. A CUBE_M16 or CUBE_M32 source keeps its layout and may change physical size. Other conversions keep rows and columns and reject a CUBE destination and canonicalization.

Design point: for the handlers that own source definedness, the generated dispatcher does not add its own `TileSourceContentsDefined` checks. These predicates use ExecutionMask-aware definedness helpers such as `TileElementwiseSourceContentsDefined`, so under an ExecutionMask only active source coordinates must be defined.

<!-- PTO-READER-BLOCK: tile-model-legality-operand-schema-boundaries role=boundaries -->
## Architectural boundaries

Legality runs before execution. The generated dispatcher calls the handler's `TileOperandsLegal_` predicate and raises `Fault_TileLegality` without calling the handler when it returns FALSE. The execute functions then assert a subset of the same conditions.

Legality admits types that some numeric helpers assert against. Binary predicates admit TF32, HF32, E4M3, and E5M2 through `TileVecArithmeticDataTypeSupported`, but floating ADD, SUB, MUL, and DIV use `ScalarFPBinaryProfile`, which accepts only FP64, FP32, FP16, and BF16. Floating TREM and the SFU unary operations use helpers that accept only FP32, FP16, and BF16.

`TileOperandsLegal_TRESHAPE`, `TileOperandsLegal_TINTERLEAVE`, and `TileOperandsLegal_TDEINTERLEAVE` are defined here but have no caller in `asl/`.

<!-- PTO-READER-BLOCK: tile-model-legality-operand-schema-example role=example-usage -->
## Non-normative reading example

Consider TDIV with operation type S32, no ExecutionMask, and three RowMajor 16 x 16 Tiles with valid region 16 x 10. The left source (dividend) is S32 and the right source (divisor) is U32.

- Shapes match, and the destination type is S32.
- `TileCarrierWidthCompatible(U32, S32)` is TRUE, so the right source is read as S32.
- S32 is in the arithmetic set, RowMajor is an elementwise layout, and both sources are defined.
- The divisor has 16 x 10 = 160 valid elements. If any of them is zero, `TilePayloadNonzero` returns FALSE and the bundle faults before any destination element is written.

<!-- PTO-READER-BLOCK: tile-model-legality-operand-schema-related role=related-owners-navigation -->
## Related owners

- [Data type and layout tables](dtype-layout.md) owns the type sets and carrier-width relation.
- [ExecutionMask source schema](execution-mask-source-schema.md) owns active-coordinate definedness and encoding checks.
- [Predicate carriers](predicate-carriers.md) owns the CUBE and predicate cell helpers used by compare and select.
- [Allocation capacity](allocation-capacity.md) owns `TilePayloadNonzero`.
- [Elementwise execution](../execution/elementwise.md) shows what runs after these checks pass.
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
