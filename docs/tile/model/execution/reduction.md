<!-- GENERATED FROM: asl/tile/model/execution/reduction.asl -->
# Reduction

**Normative ASL source:** `asl/tile/model/execution/reduction.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-EXECUTION-REDUCTION}

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

impdef func TileProfileReductionInitial(
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

impdef func TileProfileReductionStep(
    operation: TileReductionOperation,
    data_type: TileDataType,
    accumulator: Word,
    value: Word) => (Word, boolean)
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
    assert TileOperandsLegal_ExecuteTileReduction(
        operation,
        axis,
        destination,
        source);

    let source_tile = _Tiles[[source]];
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
            source_tile.data_type,
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
                        source_tile.data_type,
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

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
