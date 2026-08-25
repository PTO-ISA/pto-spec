<!-- GENERATED FROM: asl/tile/model/execution/fused-multiply-add.asl -->
# Fused Multiply Add

**Normative ASL source:** `asl/tile/model/execution/fused-multiply-add.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-EXECUTION-FUSED-MULTIPLY-ADD}

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/execution/fused-multiply-add.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-EXECUTION-FUSED-MULTIPLY-ADD","surface":"tile","classification":["model","execution","fused-multiply-add"],"depends_on":["PTO-TILE-MODEL-EXECUTION-ELEMENTWISE","PTO-TILE-MODEL-LEGALITY-INDEXED-LAYOUT","PTO-SCALAR-MODEL-FSU-PROFILE"]}
impdef func TileProfileFusedMultiplyAdd(
    data_type: TileDataType,
    addend: Word,
    left: Word,
    right: Word) => (Word, bits(5))
begin
    return ScalarFPFusedProfile(
        FloatingFused_MADD,
        DefaultNumericExecutionControl().rounding_mode,
        TileDataTypeToEncoding(data_type),
        addend,
        left,
        right);
end;

impdef func TileProfileFusedInvalidResult(
    data_type: TileDataType,
    left: Word,
    right: Word,
    addend: Word) => (Word, bits(5))
begin
    let (available, quiet_nan) =
        HardwareNumericCanonicalNaNResult(data_type);
    assert available;
    return (quiet_nan, Zeros{5} + 1);
end;

pure func TileNumericClassIsNegative(
    value_class: NumericValueClass) => boolean
begin
    return value_class == NumericValue_NegativeZero ||
           value_class == NumericValue_NegativeSubnormal ||
           value_class == NumericValue_NegativeNormal ||
           value_class == NumericValue_NegativeInfinity;
end;

func TileFixedFusedMultiplyAddValue(
    data_type: TileDataType,
    left: Word,
    right: Word,
    addend: Word) => (Word, bits(5))
begin
    assert TileFusedMultiplyAddDataTypeSupported(data_type);
    if TileDataTypeIsInteger(data_type) then
        let left_element = TileUnsignedElementValue(left, data_type);
        let right_element = TileUnsignedElementValue(right, data_type);
        let addend_element = TileUnsignedElementValue(addend, data_type);
        return (
            TileUnsignedElementValue(
                MultiplyWord(left_element, right_element) + addend_element,
                data_type),
            Zeros{5});
    end;

    assert TileNumericEncodingValid(data_type, left);
    assert TileNumericEncodingValid(data_type, right);
    assert TileNumericEncodingValid(data_type, addend);
    let left_class = TileNumericValueClass(data_type, left);
    let right_class = TileNumericValueClass(data_type, right);
    let addend_class = TileNumericValueClass(data_type, addend);
    let signaling_nan =
        left_class == NumericValue_SignalingNaN ||
        right_class == NumericValue_SignalingNaN ||
        addend_class == NumericValue_SignalingNaN;
    let zero_times_infinity =
        (NumericValueClassIsZero(left_class) &&
         NumericValueClassIsInfinity(right_class)) ||
        (NumericValueClassIsInfinity(left_class) &&
         NumericValueClassIsZero(right_class));
    let product_is_infinite =
        NumericValueClassIsInfinity(left_class) ||
        NumericValueClassIsInfinity(right_class);
    let product_is_negative =
        TileNumericClassIsNegative(left_class) !=
        TileNumericClassIsNegative(right_class);
    let opposite_infinities =
        product_is_infinite &&
        NumericValueClassIsInfinity(addend_class) &&
        product_is_negative != TileNumericClassIsNegative(addend_class);
    if signaling_nan || zero_times_infinity || opposite_infinities then
        return TileProfileFusedInvalidResult(
            data_type,
            left,
            right,
            addend);
    end;
    return TileProfileFusedMultiplyAdd(
        data_type,
        addend,
        left,
        right);
end;

// PTO-REQ-TFMA-001: complete preflight precedes three source snapshots. The
// valid payload, padding definedness, descriptor, and accumulated flags are
// computed privately and become visible only through the final publication.
func TFMA(
    destination: TileIndex,
    source_left: TileIndex,
    source_right: TileIndex,
    addend: TileIndex)
begin
    assert TileOperandsLegal_TFMA(
        destination,
        source_left,
        source_right,
        addend);
    let destination_tile = _Tiles[[destination]];
    let left_tile = _Tiles[[source_left]];
    let right_tile = _Tiles[[source_right]];
    let addend_tile = _Tiles[[addend]];
    var result_tile = destination_tile;
    var flags = Zeros{5};
    for row = 0 to destination_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to destination_tile.valid_columns - 1 looplimit 65536 do
            let element = TileLogicalLinearIndex(
                destination_tile,
                row as integer {0..65535},
                column as integer {0..65535});
            let (result, element_flags) = TileFixedFusedMultiplyAddValue(
                destination_tile.data_type,
                TileReadLogicalElement(left_tile, element),
                TileReadLogicalElement(right_tile, element),
                TileReadLogicalElement(addend_tile, element));
            result_tile = TileInfoWithLogicalElement(result_tile, element,
                result);
            flags = flags OR element_flags;
        end;
    end;
    result_tile = TileWithValidRegionDefined(result_tile);
    result_tile = TileWithPadding(
        result_tile,
        CurrentBundlePadValue());
    _Tiles[[destination]] = result_tile;
    ScalarFPRecordFlags(flags);
end;
```
<!-- GENERATED-ASL-END: unit -->
