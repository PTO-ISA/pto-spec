<!-- GENERATED FROM: asl/tile/model/execution/fused-multiply-add.asl -->
# Fused Multiply Add

**Normative ASL source:** `asl/tile/model/execution/fused-multiply-add.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-EXECUTION-FUSED-MULTIPLY-ADD}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-execution-fused-multiply-add-purpose role=purpose-scope -->
## Purpose and scope

This unit owns `TFMA`, the handler for the TFMA instruction. For every active valid coordinate it computes left times right plus addend, with the same data type for all three sources and the destination.

It also owns the per-element helper `TileFixedFusedMultiplyAddValue`, which the TFMA instruction page names as its value contract.

<!-- PTO-READER-BLOCK: tile-model-execution-fused-multiply-add-concepts role=concepts-state -->
## Concepts and visible state

The handler has four Tile operands: the destination, the left source, the right source, and the addend. `TileOperandsLegal_TFMA` requires the same shape, layout, and data type for all four. The layout must be RowMajor, CUBE_M16, or CUBE_M32.

The element result is a value plus five status flags, NV, DZ, OF, UF, and NX from bit 0 to bit 4. The handler ORs the flags of active elements.

<!-- PTO-READER-BLOCK: tile-model-execution-fused-multiply-add-rules role=rules-interactions -->
## Rules and interactions

For an integer type, each source is read as an unsigned element of the element width. The result is the low bits of the product plus the addend, with no flags. Signed and unsigned types therefore produce the same bit pattern.

For a floating type, three invalid cases are resolved first:

- Any signaling NaN source.
- Zero times infinity in either order.
- An infinite product added to an infinite addend of the opposite sign.

Each returns the canonical quiet NaN with NV. Other inputs go to `ScalarFPFusedProfile` with RNE rounding.

Design point: all three sources are snapshotted before any write. The handler copies the destination and the three source `TileInfo` records before the loop and builds the result privately. A destination that names a source therefore reads old values.

Design point: publication happens once. The valid payload, the valid-region definedness, and the padding are computed on the private copy and become visible together. The flags are recorded with `ScalarFPRecordFlags` after publication.

<!-- PTO-READER-BLOCK: tile-model-execution-fused-multiply-add-boundaries role=boundaries -->
## Architectural boundaries

Operand legality is checked before the handler runs, and the handler itself raises no fault. For floating types, legality also requires the encoding of every valid source element to be valid, counting only active elements when an ExecutionMask is in force.

Under an ExecutionMask, an inactive coordinate reads no source and takes the ZERO or MERGE value. It contributes no flags.

`TileFusedMultiplyAddDataTypeSupported` admits the 16 arithmetic types. `ScalarFPFusedProfile` asserts that the type is FP64, FP32, or FP16. For the other floating types that legality admits, only the three invalid cases produce a result, the canonical quiet NaN; every other input reaches `ScalarFPFusedProfile`, whose assertion admits only FP64, FP32, and FP16.

<!-- PTO-READER-BLOCK: tile-model-execution-fused-multiply-add-example role=example-usage -->
## Non-normative reading example

Take TFMA on a U8 Tile of 32 by 4 elements with one valid row and no ExecutionMask:

```text
TFMA <Row=32, Col=4, ValidRow=1, U8>, T#1, T#2, T#3, ->T<128B>
```

The first valid column holds left 20, right 13, and addend 7.

1. The product is 20 x 13 = 260.
2. Adding the addend gives 267.
3. The U8 element keeps the low eight bits: 267 - 256 = 11.

The destination element is 11 and no flag is recorded. In an S8 Tile the same bit patterns would produce the same result bits.

The TFMA generated legality list names only FP16, FP32, and BF16, so this U8 case illustrates the executable ASL value helper rather than a form that list admits.

<!-- PTO-READER-BLOCK: tile-model-execution-fused-multiply-add-related role=related-owners-navigation -->
## Related owners

- [TFMA](../../elementwise-tile-tile/arithmetic/TFMA.md) is the instruction that reaches this handler.
- [Indexed layout legality](../legality/indexed-layout.md) owns `TileOperandsLegal_TFMA`.
- [Scalar floating point](../../../scalar/model/fsu/scalar-fp.md) owns `ScalarFPFusedProfile`.
- [Elementwise execution](elementwise.md) owns the shared element normalization helpers.
- [Execution-mask state](execution-mask-state.md) owns inactive coordinate handling.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/execution/fused-multiply-add.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-EXECUTION-FUSED-MULTIPLY-ADD","surface":"tile","classification":["model","execution","fused-multiply-add"],"depends_on":["PTO-TILE-MODEL-EXECUTION-ELEMENTWISE","PTO-TILE-MODEL-LEGALITY-INDEXED-LAYOUT","PTO-SCALAR-MODEL-FSU-SCALAR-FP"]}
func TileProfileFusedMultiplyAdd(
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

func TileProfileFusedInvalidResult(
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
            var result = Zeros{PTO_XLEN};
            var element_flags = Zeros{5};
            if BundleExecutionMaskActiveAt(
                   destination_tile.layout, row as integer {0..65535},
                   column as integer {0..65535}) then
                let (active_result, active_flags) =
                    TileFixedFusedMultiplyAddValue(
                        destination_tile.data_type,
                        TileReadLogicalElement(left_tile, element),
                        TileReadLogicalElement(right_tile, element),
                        TileReadLogicalElement(addend_tile, element));
                result = active_result;
                element_flags = active_flags;
            else
                result = BundleExecutionMaskDestinationValue(
                    destination_tile.layout, row as integer {0..65535},
                    column as integer {0..65535}, Zeros{PTO_XLEN});
            end;
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
