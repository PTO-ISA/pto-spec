<!-- GENERATED FROM: asl/tile/model/execution/comparison.asl -->
# Comparison

**Normative ASL source:** `asl/tile/model/execution/comparison.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-EXECUTION-COMPARISON}

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/execution/comparison.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-EXECUTION-COMPARISON","surface":"tile","classification":["model","execution","comparison"],"depends_on":["PTO-TILE-MODEL-EXECUTION-ELEMENTWISE","PTO-TILE-MODEL-LEGALITY-PREDICATE-CARRIERS"]}
// PTO-REQ-TEPL-COMPARISON-001: packed predicate compare and select semantics.
pure func TileCompareDataTypeSupported(data_type: TileDataType) => boolean
begin
    return TileVecArithmeticDataTypeSupported(data_type);
end;
pure func TileSelectDataTypeSupported(data_type: TileDataType) => boolean
begin
    return TileVecArithmeticDataTypeSupported(data_type);
end;
pure func TileCompareBoolean(
    comparison: TileComparison,
    left_less: boolean,
    equal: boolean) => boolean
begin
    case comparison of
        when TileComparison_EQ => return equal;
        when TileComparison_NE => return !equal;
        when TileComparison_LT => return left_less;
        when TileComparison_LE => return left_less || equal;
        when TileComparison_GT => return !left_less && !equal;
        when TileComparison_GE => return !left_less || equal;
    end;
end;
pure func TileFloatingOrderKey(
    data_type: TileDataType,
    value: Word) => Word
begin
    var carrier = value;
    var sign_mask = Zeros{PTO_XLEN};
    var width_mask = Ones{PTO_XLEN};
    if data_type == TileDataType_FP64 then
        sign_mask = Zeros{PTO_XLEN} + 0x8000000000000000;
    elsif data_type == TileDataType_FP32 ||
          data_type == TileDataType_TF32 ||
          data_type == TileDataType_HF32 then
        carrier = ZeroExtend{PTO_XLEN}(value[31:0]);
        sign_mask = Zeros{PTO_XLEN} + 0x80000000;
        width_mask = Zeros{PTO_XLEN} + 0xffffffff;
    elsif data_type == TileDataType_FP16 ||
          data_type == TileDataType_BF16 then
        carrier = ZeroExtend{PTO_XLEN}(value[15:0]);
        sign_mask = Zeros{PTO_XLEN} + 0x8000;
        width_mask = Zeros{PTO_XLEN} + 0xffff;
    elsif data_type == TileDataType_E4M3 ||
          data_type == TileDataType_E5M2 then
        carrier = ZeroExtend{PTO_XLEN}(value[7:0]);
        sign_mask = Zeros{PTO_XLEN} + 0x80;
        width_mask = Zeros{PTO_XLEN} + 0xff;
    else
        unreachable;
    end;
    if (carrier AND sign_mask) != Zeros{PTO_XLEN} then
        return (NOT carrier) AND width_mask;
    end;
    return carrier OR sign_mask;
end;
impdef func TileProfileFloatingCompare(
    comparison: TileComparison,
    data_type: TileDataType,
    left: Word,
    right: Word) => (boolean, bits(5))
begin
    let left_class = TileNumericValueClass(data_type, left);
    let right_class = TileNumericValueClass(data_type, right);
    let signaling_nan =
        left_class == NumericValue_SignalingNaN ||
        right_class == NumericValue_SignalingNaN;
    if NumericValueClassIsNaN(left_class) ||
       NumericValueClassIsNaN(right_class) then
        return (
            comparison == TileComparison_NE,
            if signaling_nan then Zeros{5} + 1 else Zeros{5});
    end;
    let both_zero = NumericValueClassIsZero(left_class) &&
        NumericValueClassIsZero(right_class);
    let equal = both_zero || left == right;
    let left_less = if both_zero then FALSE else
        UInt(TileFloatingOrderKey(data_type, left)) <
        UInt(TileFloatingOrderKey(data_type, right));
    return (TileCompareBoolean(comparison, left_less, equal), Zeros{5});
end;

readonly impdef func TileProfilePredicateNullGPRPadding() => Word
begin
    // Portable reference default for architecturally unspecified Null bits.
    return Zeros{PTO_XLEN};
end;

readonly func TilePredicateGPRPaddingValue() => Word
begin
    case CurrentBundlePadValue() of
        when TilePad_Zero, TilePad_Min => return Zeros{PTO_XLEN};
        when TilePad_Max => return Ones{PTO_XLEN};
        when TilePad_Null => return TileProfilePredicateNullGPRPadding();
    end;
end;

func TileCompareElement(
    comparison: TileComparison,
    data_type: TileDataType,
    left: Word,
    right: Word) => (boolean, bits(5))
begin
    assert TileCompareDataTypeSupported(data_type);
    if TileDataTypeIsFloating(data_type) then
        return TileProfileFloatingCompare(
            comparison,
            data_type,
            left,
            right);
    end;
    let left_value = TileIntegerOperandValue(left, data_type);
    let right_value = TileIntegerOperandValue(right, data_type);
    let equal = left_value == right_value;
    let left_less = if TileDataTypeIsSigned(data_type) then
        SInt(left_value) < SInt(right_value) else
        UInt(left_value) < UInt(right_value);
    return (TileCompareBoolean(comparison, left_less, equal), Zeros{5});
end;
func ExecuteTileCompare(destination: TileIndex, source_left: TileIndex,
                        source_right: TileIndex, comparison: TileComparison)
begin
    assert TileOperandsLegal_ExecuteTileCompare(
        destination,
        source_left,
        source_right,
        comparison);
    let left_tile = _Tiles[[source_left]];
    if TileLayoutIsCube(left_tile.layout) then
        ExecuteTileCompareCell(destination, source_left, source_right, comparison);
        return;
    end;
    let right_tile = _Tiles[[source_right]];
    var result = _Tiles[[destination]];
    var flags = Zeros{5};
    for row = 0 to left_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to left_tile.valid_columns - 1 looplimit 65536 do
            let element = TileLogicalLinearIndex(left_tile,
                row as integer {0..65535}, column as integer {0..65535});
            let (predicate, element_flags) = TileCompareElement(
                comparison,
                left_tile.data_type,
                TileReadLogicalElement(left_tile, element),
                TileReadLogicalElement(right_tile, element));
            result = TileInfoWithPredicateBit(
                result,
                row as integer {0..65535},
                column as integer {0..65535},
                predicate);
            flags = flags OR element_flags;
        end;
    end;
    result = PredicateTileWithPadding(result, CurrentBundlePadValue());
    RecordNumericStatusFlags(flags);
    _Tiles[[destination]] = result;
end;
func TileProfileCompare(
    comparison: TileComparison,
    data_type: TileDataType,
    left: Word,
    right: Word) => Word
begin
    let (predicate, -) = TileCompareElement(
        comparison,
        data_type,
        left,
        right);
    return if predicate then Zeros{PTO_XLEN} + 1 else Zeros{PTO_XLEN};
end;
func ExecuteTileCompareScalar(destination: TileIndex, source: TileIndex,
                              scalar: Word, comparison: TileComparison)
begin
    assert TileOperandsLegal_ExecuteTileCompareScalar(
        destination,
        source,
        scalar,
        comparison);
    let source_tile = _Tiles[[source]];
    if TileLayoutIsCube(source_tile.layout) then
        ExecuteTileCompareCellScalar(destination, source, scalar, comparison);
        return;
    end;
    var result = _Tiles[[destination]];
    let normalized_scalar = TileRawElementValue(
        scalar,
        source_tile.data_type);
    var flags = Zeros{5};
    for row = 0 to source_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to source_tile.valid_columns - 1 looplimit 65536 do
            let element = TileLogicalLinearIndex(source_tile,
                row as integer {0..65535}, column as integer {0..65535});
            let (predicate, element_flags) = TileCompareElement(
                comparison,
                source_tile.data_type,
                TileReadLogicalElement(source_tile, element),
                normalized_scalar);
            result = TileInfoWithPredicateBit(
                result,
                row as integer {0..65535},
                column as integer {0..65535},
                predicate);
            flags = flags OR element_flags;
        end;
    end;
    result = PredicateTileWithPadding(result, CurrentBundlePadValue());
    RecordNumericStatusFlags(flags);
    _Tiles[[destination]] = result;
end;
func ExecuteTileSelect(destination: TileIndex, mask: TileIndex,
                       source_true: TileIndex, source_false: TileIndex)
begin
    assert TileOperandsLegal_ExecuteTileSelect(
        destination,
        mask,
        source_true,
        source_false);
    let true_tile = _Tiles[[source_true]];
    let false_tile = _Tiles[[source_false]];
    let mask_tile = _Tiles[[mask]];
    var result = _Tiles[[destination]];
    if TileLayoutIsCube(true_tile.layout) then
        for row = 0 to true_tile.valid_rows - 1 looplimit 65536 do
            for column = 0 to true_tile.valid_columns - 1 looplimit 65536 do
                let source_element = TileLogicalLinearIndex(true_tile,
                    row as integer {0..65535}, column as integer {0..65535});
                let destination_element = TileLogicalLinearIndex(result,
                    row as integer {0..65535}, column as integer {0..65535});
                let predicate_element = TileLogicalLinearIndex(mask_tile,
                    row as integer {0..65535}, column as integer {0..65535});
                if TileReadLogicalElement(mask_tile, predicate_element)[7:0] ==
                   '00000001' then
                    result = TileInfoWithLogicalElement(result, destination_element,
                        TileReadLogicalElement(true_tile, source_element));
                else
                    result = TileInfoWithLogicalElement(result, destination_element,
                        TileReadLogicalElement(false_tile, source_element));
                end;
            end;
        end;
        result = TileWithValidRegionDefined(result);
        result = TileWithPadding(result, CurrentBundlePadValue());
        _Tiles[[destination]] = result;
        return;
    end;
    for row = 0 to true_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to true_tile.valid_columns - 1 looplimit 65536 do
            let element = TileLogicalLinearIndex(true_tile,
                row as integer {0..65535}, column as integer {0..65535});
            if TilePredicateBitFromInfo(
                mask_tile,
                row as integer {0..65535},
                column as integer {0..65535}) then
                result = TileInfoWithLogicalElement(result, element,
                    TileReadLogicalElement(true_tile, element));
            else
                result = TileInfoWithLogicalElement(result, element,
                    TileReadLogicalElement(false_tile, element));
            end;
        end;
    end;
    result = TileWithValidRegionDefined(result);
    result = TileWithPadding(result, CurrentBundlePadValue());
    _Tiles[[destination]] = result;
end;
func ExecuteTileSelectScalar(destination: TileIndex, mask: TileIndex,
                             source_true: TileIndex, scalar_false: Word)
begin
    assert TileOperandsLegal_ExecuteTileSelectScalar(
        destination,
        mask,
        source_true,
        scalar_false);
    var result = _Tiles[[destination]];
    let true_tile = _Tiles[[source_true]];
    let mask_tile = _Tiles[[mask]];
    let normalized_scalar = TileRawElementValue(
        scalar_false,
        true_tile.data_type);
    if TileLayoutIsCube(true_tile.layout) then
        for row = 0 to true_tile.valid_rows - 1 looplimit 65536 do
            for column = 0 to true_tile.valid_columns - 1 looplimit 65536 do
                let source_element = TileLogicalLinearIndex(true_tile,
                    row as integer {0..65535}, column as integer {0..65535});
                let destination_element = TileLogicalLinearIndex(result,
                    row as integer {0..65535}, column as integer {0..65535});
                let predicate_element = TileLogicalLinearIndex(mask_tile,
                    row as integer {0..65535}, column as integer {0..65535});
                if TileReadLogicalElement(mask_tile, predicate_element)[7:0] ==
                   '00000001' then
                    result = TileInfoWithLogicalElement(result, destination_element,
                        TileReadLogicalElement(true_tile, source_element));
                else
                    result = TileInfoWithLogicalElement(result,
                        destination_element, normalized_scalar);
                end;
            end;
        end;
        result = TileWithValidRegionDefined(result);
        result = TileWithPadding(result, CurrentBundlePadValue());
        _Tiles[[destination]] = result;
        return;
    end;
    for row = 0 to true_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to true_tile.valid_columns - 1 looplimit 65536 do
            let element = TileLogicalLinearIndex(true_tile,
                row as integer {0..65535}, column as integer {0..65535});
            if TilePredicateBitFromInfo(
                mask_tile,
                row as integer {0..65535},
                column as integer {0..65535}) then
                result = TileInfoWithLogicalElement(result, element,
                    TileReadLogicalElement(true_tile, element));
            else
                result = TileInfoWithLogicalElement(
                    result, element, normalized_scalar);
            end;
        end;
    end;
    result = TileWithValidRegionDefined(result);
    result = TileWithPadding(result, CurrentBundlePadValue());
    _Tiles[[destination]] = result;
end;
// CUBE predicate-carrier extension.  The legacy packed row-major path above is
// intentionally unchanged; these helpers are selected only for CUBE layouts.
pure func TileCubePredicateColumnBase(data_type: TileDataType,
                                      layout: TileLayout,
                                      high: boolean) => integer {0..8}
begin
    if data_type != TileDataType_U8 then return 0; end;
    if layout == TileLayout_CUBE_M32 then return if high then 2 else 0; end;
    return if high then 4 else 0;
end;
readonly func TileOperandsLegal_ExecuteTileCompareGPR(
    source_left: TileIndex, source_right: TileIndex, high: boolean) => boolean
begin
    if !TileCubeNumericShapeAndTypeMatch(source_left, source_right) then
        return FALSE;
    end;
    let left = _Tiles[[source_left]];
    if left.layout != TileLayout_CUBE_M16 && left.layout != TileLayout_CUBE_M32 then
        return FALSE;
    end;
    return TileCubePredicateGPRDataTypeSupported(left.data_type) &&
           TileCubePredicateGPRShapeLegal(source_left) &&
           (left.data_type == TileDataType_U8 || !high) &&
           TileCubeNumericSourceLegal(source_left) &&
           TileCubeNumericSourceLegal(source_right);
end;
func TileCompareCUBEToGPR(source_left: TileIndex, source_right: TileIndex,
                          comparison: TileComparison, high: boolean) => Word
begin
    assert TileOperandsLegal_ExecuteTileCompareGPR(
        source_left, source_right, high);
    let left = _Tiles[[source_left]];
    let width = TileCubePredicateRowBits(left.layout);
    let fields = TileCubePredicateFieldCount(left.data_type, left.layout);
    let base = TileCubePredicateColumnBase(left.data_type, left.layout, high);
    var result = TilePredicateGPRPaddingValue();
    var flags = Zeros{5};
    for field = 0 to fields - 1 looplimit 8 do
        let column = base + field;
        if column < left.valid_columns then
            for row = 0 to width - 1 looplimit 32 do
                if row < left.valid_rows then
                    let element = TileLogicalLinearIndex(left,
                        row as integer {0..65535},
                        column as integer {0..65535});
                    let (predicate, element_flags) = TileCompareElement(
                        comparison, left.data_type,
                        TileReadLogicalElement(left, element),
                        TileReadLogicalElement(
                            _Tiles[[source_right]], element));
                    flags = flags OR element_flags;
                    let result_index = row + field * width;
                    result[result_index] = if predicate then '1' else '0';
                end;
            end;
        end;
    end;
    RecordNumericStatusFlags(flags);
    return result;
end;
func ExecuteTileCompareCell(destination: TileIndex, source_left: TileIndex,
                            source_right: TileIndex, comparison: TileComparison)
begin
    let left = _Tiles[[source_left]];
    var result = _Tiles[[destination]];
    var flags = Zeros{5};
    for row = 0 to left.valid_rows - 1 looplimit 65536 do
        for column = 0 to left.valid_columns - 1 looplimit 65536 do
            let element = TileLogicalLinearIndex(left,
                row as integer {0..65535}, column as integer {0..65535});
            let (predicate, element_flags) = TileCompareElement(
                comparison, left.data_type,
                TileReadLogicalElement(left, element),
                TileReadLogicalElement(_Tiles[[source_right]], element));
            let destination_element = TileLogicalLinearIndex(result,
                row as integer {0..65535}, column as integer {0..65535});
            result = TileInfoWithLogicalElement(result, destination_element,
                if predicate then Zeros{PTO_XLEN} + 1 else Zeros{PTO_XLEN});
            flags = flags OR element_flags;
        end;
    end;
    result = PredicateCellWithPadding(result, CurrentBundlePadValue());
    result.defined_valid_elements =
        (result.valid_rows * result.valid_columns) as integer {0..524288};
    result.contents_defined = TRUE;
    RecordNumericStatusFlags(flags);
    _Tiles[[destination]] = result;
end;
func ExecuteTileCompareCellScalar(destination: TileIndex, source: TileIndex,
                                   scalar: Word, comparison: TileComparison)
begin
    let source_tile = _Tiles[[source]];
    let normalized_scalar = TileRawElementValue(scalar, source_tile.data_type);
    var result = _Tiles[[destination]];
    var flags = Zeros{5};
    for row = 0 to source_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to source_tile.valid_columns - 1 looplimit 65536 do
            let source_element = TileLogicalLinearIndex(source_tile,
                row as integer {0..65535}, column as integer {0..65535});
            let destination_element = TileLogicalLinearIndex(result,
                row as integer {0..65535}, column as integer {0..65535});
            let (predicate, element_flags) = TileCompareElement(
                comparison, source_tile.data_type,
                TileReadLogicalElement(source_tile, source_element),
                normalized_scalar);
            result = TileInfoWithLogicalElement(result, destination_element,
                if predicate then Zeros{PTO_XLEN} + 1 else Zeros{PTO_XLEN});
            flags = flags OR element_flags;
        end;
    end;
    result = PredicateCellWithPadding(result, CurrentBundlePadValue());
    result.defined_valid_elements =
        (result.valid_rows * result.valid_columns) as integer {0..524288};
    result.contents_defined = TRUE;
    RecordNumericStatusFlags(flags);
    _Tiles[[destination]] = result;
end;
```
<!-- GENERATED-ASL-END: unit -->
