<!-- GENERATED FROM: asl/tile/model/execution/expdif.asl -->
# Expdif

**Normative ASL source:** `asl/tile/model/execution/expdif.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-EXECUTION-EXPDIF}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-execution-expdif-purpose role=purpose-scope -->
## Purpose and scope

This unit owns the natural-expansion-difference sequence: the exponential of left minus right. `ExecuteTileExpdif` is the handler for the TEXPDIF instruction. `TileExpdifValueWithTypesAndFlags` computes one element and is shared with the TROWEXPANDEXPDIF and TCOLEXPANDEXPDIF broadcast forms through the expansion unit.

It carries the accepted clause `PTO-TILE-MODEL-EXECUTION-MASK-EXPDIF-001`.

<!-- PTO-READER-BLOCK: tile-model-execution-expdif-concepts role=concepts-state -->
## Concepts and visible state

Two types are involved. The source operation type comes from the bundle's selected DataType, or from the first source Tile when no bundle operation is selected. The destination type is the destination Tile's `data_type`.

`TileExpdifTypePairLegal` admits five pairs:

| Source operation type | Destination type |
| --- | --- |
| FP16 | FP16 or FP32 |
| BF16 | BF16 or FP32 |
| FP32 | FP32 |

Each element returns a value and five status flags, NV, DZ, OF, UF, and NX from bit 0 to bit 4.

<!-- PTO-READER-BLOCK: tile-model-execution-expdif-rules role=rules-interactions -->
## Rules and interactions

For a same-type pair, the element is computed in the destination type:

1. SUB left minus right through `TileProfileBinaryWithFlags`.
2. Apply the TEXP special-value rules to the difference.
3. Otherwise compute the finite exponential with `TileProfileUnary`.

The flags of both steps are ORed.

For a mixed pair, both sources are widened exactly to FP32 by `ExactWidenFP16ToFP32` or `ExactWidenBF16ToFP32`. The same SUB and EXP steps then run in FP32. `HardwareNumericMixedExpdifDiscriminator` fixes the result for two specific widened input pairs before those steps.

Design point: the widening is an exact reinterpretation, not TCVT. It preserves the represented value, including NaN payloads, and contributes no conversion status. Only the FP32 SUB and EXP can set flags.

Design point: both source records are captured before any result is built. `ExecuteTileExpdif` copies both source `TileInfo` records and builds the result privately, so a destination that names either source still reads old values.

<!-- PTO-READER-BLOCK: tile-model-execution-expdif-boundaries role=boundaries -->
## Architectural boundaries

Under an ExecutionMask, an inactive coordinate reads no source, performs no arithmetic, and contributes no flags. It takes the ZERO or MERGE value.

After the loop the handler marks the valid region defined, applies the bundle padding, records the ORed flags, and publishes the destination.

Every type in the legal pair set is FP32, FP16, or BF16. Both the SUB helper and the finite EXP helper accept these types.

<!-- PTO-READER-BLOCK: tile-model-execution-expdif-example role=example-usage -->
## Non-normative reading example

Take TEXPDIF with FP32 sources and an FP32 destination of 32 by 4 elements with one valid row:

```text
TEXPDIF <Row=32, Col=4, ValidRow=1, FP32>, T#1, T#2, ->T<512B>
```

Two of the four valid columns show the special paths.

1. Left 3.0, right 3.0: the difference is +0. EXP of a zero is 1.0, encoded `0x3f800000`, with no flags.
2. Left 1.0, right +inf: the difference is -inf with no flags. EXP of -inf is +0, encoded `0x00000000`.

Neither column records a flag, so the sticky status is unchanged by these two elements.

<!-- PTO-READER-BLOCK: tile-model-execution-expdif-related role=related-owners-navigation -->
## Related owners

- [TEXPDIF](../../elementwise-tile-tile/transcendental/TEXPDIF.md) is the instruction that reaches `ExecuteTileExpdif`.
- [EXPDIF operand legality](../legality/expdif-operands.md) owns the source operation type.
- [Expansion execution](expansion.md) reuses the element helper for broadcast forms.
- [Unary execution](unary.md) owns the TEXP special values.
- [Elementwise execution](elementwise.md) owns the SUB helper.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/execution/expdif.asl -->
```asl
// NDF-BEGIN: PTO-TILE-MODEL-EXECUTION-MASK-EXPDIF-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// Predicated TEXPDIF evaluates source encodings, source reads, arithmetic, and numeric-status contribution only for active logical result coordinates. Inactive destination coordinates use the common MERGE/ZERO rule and contribute no numeric flags; the existing source-operation and destination type-pair contract remains unchanged.
// NDF-END: PTO-TILE-MODEL-EXECUTION-MASK-EXPDIF-001
// PTO-UNIT: {"id":"PTO-TILE-MODEL-EXECUTION-EXPDIF","surface":"tile","classification":["model","execution","expdif"],"depends_on":["PTO-TILE-MODEL-EXECUTION-ELEMENTWISE","PTO-TILE-MODEL-EXECUTION-MASK-STATE","PTO-TILE-MODEL-EXECUTION-UNARY","PTO-TILE-MODEL-LEGALITY-DTYPE-LAYOUT","PTO-TILE-MODEL-LEGALITY-OPERAND-SCHEMA"]}
// PTO-REQ-TILE-EXPDIF-001: one typed natural-expansion-difference sequence is
// shared by the binary and broadcast Tile operations.

// Exact FP16/BF16 value widening is an interpretation step, not TCVT. It
// preserves the represented value and contributes no conversion status.
pure func ExactWidenBF16ToFP32(value: Word) => Word
begin
    return LSL(ZeroExtend{PTO_XLEN}(value[15:0]), 16);
end;

pure func ExactWidenFP16ToFP32(value: Word) => Word
begin
    let raw = value[15:0];
    let sign = raw[15];
    let exponent = raw[14:10];
    let fraction = raw[9:0];
    var result: bits(32) = Zeros{32};
    result[31] = sign;
    if exponent == '11111' then
        result[30:23] = Ones{8};
        // Preserve NaN payload and the quiet/signaling bit for FP32 SUB.
        result[22:13] = fraction;
    elsif exponent != Zeros{5} then
        result[30:23] = Zeros{8} + (UInt(exponent) + 112);
        result[22:13] = fraction;
    elsif fraction != Zeros{10} then
        var normalized = fraction;
        var shift_count: integer {0..9} = 0;
        for shift = 0 to 9 looplimit 10 do
            if normalized[9] == '0' then
                normalized = LSL(normalized, 1);
                shift_count = (shift_count + 1) as integer {0..9};
            end;
        end;
        result[30:23] = Zeros{8} + (112 - shift_count);
        result[22:13] = ZeroExtend{10}(normalized[8:0]);
    end;
    return ZeroExtend{PTO_XLEN}(result);
end;

func TileProfileMixedExpdifFP32(
    source_type: TileDataType,
    left: Word,
    right: Word) => (Word, bits(5))
begin
    assert source_type == TileDataType_FP16 ||
           source_type == TileDataType_BF16;
    let (handled, discriminator_result) =
        HardwareNumericMixedExpdifDiscriminator(left, right);
    if handled then return (discriminator_result, Zeros{5}); end;

    let (difference, subtract_flags) = TileProfileBinaryWithFlags(
        TileBinary_SUB,
        TileDataType_FP32,
        left,
        right);
    let (special_handled, special_result, special_flags) =
        TileSFUUnarySpecialValue(
            TileUnary_EXP,
            TileDataType_FP32,
            difference);
    if special_handled then
        return (special_result, subtract_flags OR special_flags);
    end;

    let (profile_result, profile_flags) = TileProfileUnary(
        TileUnary_EXP,
        TileDataType_FP32,
        difference);
    return (profile_result, subtract_flags OR profile_flags);
end;

func TileExpdifValueWithTypesAndFlags(
    source_operation_type: TileDataType,
    destination_type: TileDataType,
    left: Word,
    right: Word) => (Word, bits(5))
begin
    assert TileExpdifTypePairLegal(
        source_operation_type, destination_type);
    if source_operation_type != destination_type then
        assert destination_type == TileDataType_FP32;
        let widened_left = if source_operation_type == TileDataType_FP16 then
            ExactWidenFP16ToFP32(left)
        else
            ExactWidenBF16ToFP32(left);
        let widened_right = if source_operation_type == TileDataType_FP16 then
            ExactWidenFP16ToFP32(right)
        else
            ExactWidenBF16ToFP32(right);
        return TileProfileMixedExpdifFP32(
            source_operation_type, widened_left, widened_right);
    end;

    let (difference, subtract_flags) = TileProfileBinaryWithFlags(
        TileBinary_SUB,
        destination_type,
        left,
        right);
    let (handled, special_result, special_flags) =
        TileSFUUnarySpecialValue(
            TileUnary_EXP,
            destination_type,
            difference);
    if handled then
        return (special_result, subtract_flags OR special_flags);
    end;
    let (profile_result, profile_flags) = TileProfileUnary(
        TileUnary_EXP,
        destination_type,
        difference);
    return (profile_result, subtract_flags OR profile_flags);
end;

func ExecuteTileExpdif(
    destination: TileIndex,
    source0: TileIndex,
    source1: TileIndex)
begin
    assert TileOperandsLegal_ExecuteTileExpdif(
        destination, source0, source1);
    let (operation_type_valid, operation_type) =
        TileExpdifSourceOperationType(source0);
    assert operation_type_valid;
    let left_tile = _Tiles[[source0]];
    let right_tile = _Tiles[[source1]];
    var result_tile = _Tiles[[destination]];
    var accumulated_flags = Zeros{5};

    // Capture both complete source records before constructing any result.
    // The destination may name either old source in the rename model.
    for row = 0 to result_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to result_tile.valid_columns - 1 looplimit 65536 do
            let destination_element = TileLogicalLinearIndex(
                result_tile,
                row as integer {0..65535},
                column as integer {0..65535});
            if BundleExecutionMaskActiveAt(
                   result_tile.layout, row as integer {0..65535},
                   column as integer {0..65535}) then
                let left_element = TileLogicalLinearIndex(
                    left_tile,
                    row as integer {0..65535},
                    column as integer {0..65535});
                let right_element = TileLogicalLinearIndex(
                    right_tile,
                    row as integer {0..65535},
                    column as integer {0..65535});
                let (value, element_flags) = TileExpdifValueWithTypesAndFlags(
                    operation_type,
                    result_tile.data_type,
                    TileReadLogicalElement(left_tile, left_element),
                    TileReadLogicalElement(right_tile, right_element));
                result_tile = TileInfoWithLogicalElement(
                    result_tile, destination_element, value);
                accumulated_flags = accumulated_flags OR element_flags;
            else
                let value = BundleExecutionMaskDestinationValue(
                    result_tile.layout, row as integer {0..65535},
                    column as integer {0..65535}, Zeros{PTO_XLEN});
                result_tile = TileInfoWithLogicalElement(
                    result_tile, destination_element, value);
            end;
        end;
    end;

    result_tile = TileWithValidRegionDefined(result_tile);
    result_tile = TileWithPadding(result_tile, CurrentBundlePadValue());
    RecordNumericStatusFlags(accumulated_flags);
    _Tiles[[destination]] = result_tile;
end;
```
<!-- GENERATED-ASL-END: unit -->
