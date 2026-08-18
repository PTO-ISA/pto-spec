<!-- GENERATED FROM: asl/tile/model/execution/comparison.asl -->
# Comparison

**Normative ASL source:** `asl/tile/model/execution/comparison.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-EXECUTION-COMPARISON}

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/execution/comparison.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-EXECUTION-COMPARISON","surface":"tile","classification":["model","execution","comparison"],"depends_on":["PTO-TILE-MODEL-EXECUTION-ELEMENTWISE"]}
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
    let right_tile = _Tiles[[source_right]];
    var result = _Tiles[[destination]];
    let left_payload = left_tile.payload;
    let right_payload = right_tile.payload;
    var flags = Zeros{5};
    for row = 0 to left_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to left_tile.valid_columns - 1 looplimit 65536 do
            let element = TileLinearIndex(left_tile,
                row as integer {0..65535}, column as integer {0..65535});
            let (predicate, element_flags) = TileCompareElement(
                comparison,
                left_tile.data_type,
                left_payload[[element]],
                right_payload[[element]]);
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
    var result = _Tiles[[destination]];
    let payload = source_tile.payload;
    let normalized_scalar = TileRawElementValue(
        scalar,
        source_tile.data_type);
    var flags = Zeros{5};
    for row = 0 to source_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to source_tile.valid_columns - 1 looplimit 65536 do
            let element = TileLinearIndex(source_tile,
                row as integer {0..65535}, column as integer {0..65535});
            let (predicate, element_flags) = TileCompareElement(
                comparison,
                source_tile.data_type,
                payload[[element]],
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
    let true_payload = true_tile.payload;
    let false_payload = false_tile.payload;
    for row = 0 to true_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to true_tile.valid_columns - 1 looplimit 65536 do
            let element = TileLinearIndex(true_tile,
                row as integer {0..65535}, column as integer {0..65535});
            if TilePredicateBitFromInfo(
                mask_tile,
                row as integer {0..65535},
                column as integer {0..65535}) then
                result.payload[[element]] = true_payload[[element]];
            else
                result.payload[[element]] = false_payload[[element]];
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
    let true_payload = true_tile.payload;
    let normalized_scalar = TileRawElementValue(
        scalar_false,
        true_tile.data_type);
    for row = 0 to true_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to true_tile.valid_columns - 1 looplimit 65536 do
            let element = TileLinearIndex(true_tile,
                row as integer {0..65535}, column as integer {0..65535});
            if TilePredicateBitFromInfo(
                mask_tile,
                row as integer {0..65535},
                column as integer {0..65535}) then
                result.payload[[element]] = true_payload[[element]];
            else
                result.payload[[element]] = normalized_scalar;
            end;
        end;
    end;
    result = TileWithValidRegionDefined(result);
    result = TileWithPadding(result, CurrentBundlePadValue());
    _Tiles[[destination]] = result;
end;
```
<!-- GENERATED-ASL-END: unit -->

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
