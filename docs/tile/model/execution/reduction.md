<!-- GENERATED FROM: asl/tile/model/execution/reduction.asl -->
# Reduction

**Normative ASL source:** `asl/tile/model/execution/reduction.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-EXECUTION-REDUCTION}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-execution-reduction-purpose role=purpose-scope -->
## Purpose and scope

This unit owns `ExecuteTileReduction`, the shared handler for row and column reductions. It is reached by TROWSUM, TROWPROD, TROWMIN, TROWMAX, TROWARGMIN, and TROWARGMAX, and by the six matching TCOL forms.

A row reduction produces one value per valid row. A column reduction produces one value per valid column.

<!-- PTO-READER-BLOCK: tile-model-execution-reduction-concepts role=concepts-state -->
## Concepts and visible state

The operation type is the bundle's selected DataType, or the source Tile's `data_type` when no bundle operation is selected.

The outer index walks the kept axis and the inner index walks the reduced axis. Each outer position starts an accumulator:

- SUM starts at an all-zero encoding and PRODUCT starts at the one encoding of the type. Both then fold every inner element from index 0.
- MIN, MAX, ARGMIN, and ARGMAX start with the first element and fold from inner index 1.

Each step calls `TileProfileBinaryWithFlags` with ADD, MUL, MIN, or MAX. The flags NV, DZ, OF, UF, and NX, from bit 0 to bit 4, are ORed across all steps.

<!-- PTO-READER-BLOCK: tile-model-execution-reduction-rules role=rules-interactions -->
## Rules and interactions

The fold is strictly sequential in increasing inner index. Floating SUM and PRODUCT round after every step, so the order is part of the result.

ARGMIN and ARGMAX track an index. A step updates it only when the result equals the new element and differs from the old accumulator. A later element with the same encoding as the accumulator leaves the result unchanged, so the first index of a bit-identical extreme is kept. Floating signed zeros are not ties: for example, TROWARGMAX moves to a later +0 after a -0 because MAX returns +0. The destination stores that index as a U32 value.

The destination is a single column for a row reduction and a single row for a column reduction. After the loop the handler marks the valid region defined, applies the bundle padding, records the ORed flags, and publishes the destination.

Design point: legality rejects a destination that names the source. The handler reads a snapshot of the source and builds the result privately, so no element of the source is overwritten while it is still needed.

Design point: MIN and MAX start from the first element, so every step compares two source values and the result is one of them, except that two NaN inputs give the canonical quiet NaN. SUM and PRODUCT start from an identity, so every source element passes through exactly one ADD or MUL step.

<!-- PTO-READER-BLOCK: tile-model-execution-reduction-boundaries role=boundaries -->
## Architectural boundaries

The reduction operations are not in `TileOperationExecutionMaskEligible`, so an ExecutionMask cannot be bound to them. The handler reads every valid source element.

ARGMIN and ARGMAX accept S32, U32, FP32, S16, U16, FP16, BF16, S8, and U8 sources. Other reductions accept the 16 arithmetic types, but floating ADD and MUL go through `ScalarFPBinaryProfile`, which accepts FP64, FP32, FP16, and BF16.

<!-- PTO-READER-BLOCK: tile-model-execution-reduction-example role=example-usage -->
## Non-normative reading example

Take TROWARGMAX on an S32 RowMajor source with one valid row of four columns:

```text
TROWARGMAX <Row=32, Col=4, ValidRow=1, S32>, T#1, ->T<128B>
```

The source row is 3, 7, 7, 2.

1. The accumulator starts at 3 with index 0.
2. Inner 1: MAX of 3 and 7 is 7, which equals the new element and differs from 3, so the index becomes 1.
3. Inner 2: MAX of 7 and 7 is 7, which equals the old accumulator, so the index stays 1.
4. Inner 3: MAX of 7 and 2 is 7, so the index stays 1.

The destination element is U32 1. A TROWSUM of the same row starts at 0 and gives 0 + 3 + 7 + 7 + 2 = 19.

<!-- PTO-READER-BLOCK: tile-model-execution-reduction-related role=related-owners-navigation -->
## Related owners

- [Reduction and expansion legality](../legality/reduction-and-expansion.md) owns the shape and type checks.
- [Elementwise execution](elementwise.md) owns the binary step helper.
- [Expansion execution](expansion.md) owns the matching broadcast operations.
- [Predicate carriers](predicate-carriers.md) owns the ExecutionMask eligibility list.
- [Numeric status](../../../arch/state/numeric-status.md) owns the sticky flags.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/execution/reduction.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-EXECUTION-REDUCTION","surface":"tile","classification":["model","execution","reduction"],"depends_on":["PTO-TILE-MODEL-EXECUTION-ELEMENTWISE"]}
// PTO-REQ-TEPL-REDUCE-001: exact row, column, and index reductions.

pure func TileReductionOneEncoding(
    data_type: TileDataType) => Word
begin
    case data_type of
        when TileDataType_FP64 =>
            return Zeros{PTO_XLEN} + 0x3ff0000000000000;
        when TileDataType_FP32, TileDataType_TF32,
             TileDataType_HF32 =>
            return Zeros{PTO_XLEN} + 0x3f800000;
        when TileDataType_FP16 =>
            return Zeros{PTO_XLEN} + 0x3c00;
        when TileDataType_BF16 =>
            return Zeros{PTO_XLEN} + 0x3f80;
        when TileDataType_E4M3 =>
            return Zeros{PTO_XLEN} + 0x38;
        when TileDataType_E5M2 =>
            return Zeros{PTO_XLEN} + 0x3c;
        when TileDataType_S64, TileDataType_S32,
             TileDataType_S16, TileDataType_S8,
             TileDataType_U64, TileDataType_U32,
             TileDataType_U16, TileDataType_U8 =>
            return Zeros{PTO_XLEN} + 1;
        otherwise =>
            unreachable;
    end;
end;

pure func TileReductionInitialValue(
    operation: TileReductionOperation,
    data_type: TileDataType,
    first: Word) => Word
begin
    case operation of
        when TileReduction_SUM =>
            return Zeros{PTO_XLEN};
        when TileReduction_PRODUCT =>
            return TileReductionOneEncoding(data_type);
        when TileReduction_MIN, TileReduction_MAX,
             TileReduction_ARGMIN, TileReduction_ARGMAX =>
            return first;
    end;
end;

func TileProfileReductionInitial(
    operation: TileReductionOperation,
    data_type: TileDataType,
    first: Word) => Word
begin
    return TileReductionInitialValue(
        operation,
        data_type,
        first);
end;

func TileReductionStepWithFlags(
    operation: TileReductionOperation,
    data_type: TileDataType,
    accumulator: Word,
    value: Word) => (Word, boolean, bits(5))
begin
    var binary_operation: TileBinaryOperation;
    case operation of
        when TileReduction_SUM =>
            binary_operation = TileBinary_ADD;
        when TileReduction_PRODUCT =>
            binary_operation = TileBinary_MUL;
        when TileReduction_MIN, TileReduction_ARGMIN =>
            binary_operation = TileBinary_MIN;
        when TileReduction_MAX, TileReduction_ARGMAX =>
            binary_operation = TileBinary_MAX;
    end;

    let (result, flags) = TileProfileBinaryWithFlags(
        binary_operation,
        data_type,
        accumulator,
        value);
    let selected =
        result == value && result != accumulator;
    return (result, selected, flags);
end;

func TileProfileReductionStep(
    operation: TileReductionOperation,
    data_type: TileDataType,
    accumulator: Word, value: Word) => (Word, boolean)
begin
    let (result, selected, -) = TileReductionStepWithFlags(
        operation,
        data_type,
        accumulator,
        value);
    return (result, selected);
end;

func ExecuteTileReduction(
    operation: TileReductionOperation,
    axis: TileAxis,
    destination: TileIndex,
    source: TileIndex)
begin
    let source_tile = _Tiles[[source]];
    let (operation_type_valid, operation_type) =
        ResolveTileSelectedOperationType(source_tile.data_type);
    assert operation_type_valid;
    assert TileOperandsLegal_ExecuteTileReduction(
        operation,
        axis,
        destination,
        source);

    var result_tile = _Tiles[[destination]];
    var accumulated_flags = Zeros{5};
    let outer_count =
        if axis == TileAxis_Row then
            source_tile.valid_rows
        else
            source_tile.valid_columns;
    let inner_count =
        if axis == TileAxis_Row then
            source_tile.valid_columns
        else
            source_tile.valid_rows;

    for outer = 0 to outer_count - 1 looplimit 65536 do
        let first_row =
            if axis == TileAxis_Row then outer else 0;
        let first_column =
            if axis == TileAxis_Row then 0 else outer;
        let first_element = TileLogicalLinearIndex(
            source_tile,
            first_row as integer {0..65535},
            first_column as integer {0..65535});
        var accumulator = TileProfileReductionInitial(
            operation,
            operation_type,
            TileReadLogicalElement(source_tile, first_element));
        var selected_index: integer {0..65535} = 0;
        let identity_reduction =
            operation == TileReduction_SUM ||
            operation == TileReduction_PRODUCT;
        let first_inner =
            if identity_reduction then 0 else 1;

        if first_inner < inner_count then
            for inner = first_inner to inner_count - 1
                looplimit 65536 do
                let row =
                    if axis == TileAxis_Row then outer else inner;
                let column =
                    if axis == TileAxis_Row then inner else outer;
                let element = TileLogicalLinearIndex(
                    source_tile,
                    row as integer {0..65535},
                    column as integer {0..65535});
                let (next, selected, element_flags) =
                    TileReductionStepWithFlags(
                        operation,
                        operation_type,
                        accumulator,
                        TileReadLogicalElement(source_tile, element));
                accumulator = next;
                accumulated_flags =
                    accumulated_flags OR element_flags;
                if selected &&
                   (operation == TileReduction_ARGMIN ||
                    operation == TileReduction_ARGMAX) then
                    selected_index =
                        inner as integer {0..65535};
                end;
            end;
        end;

        let destination_row =
            if axis == TileAxis_Row then outer else 0;
        let destination_column =
            if axis == TileAxis_Row then 0 else outer;
        let destination_element = TileLogicalLinearIndex(
            result_tile,
            destination_row as integer {0..65535},
            destination_column as integer {0..65535});
        if operation == TileReduction_ARGMIN ||
           operation == TileReduction_ARGMAX then
            result_tile = TileInfoWithLogicalElement(result_tile,
                destination_element, NaturalToWord(
                    selected_index as integer {0..262144}));
        else
            result_tile = TileInfoWithLogicalElement(result_tile,
                destination_element, accumulator);
        end;
    end;

    result_tile = TileWithValidRegionDefined(result_tile);
    result_tile = TileWithPadding(
        result_tile,
        CurrentBundlePadValue());
    RecordNumericStatusFlags(accumulated_flags);
    _Tiles[[destination]] = result_tile;
end;
```
<!-- GENERATED-ASL-END: unit -->
