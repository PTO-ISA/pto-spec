<!-- GENERATED FROM: asl/tile/model/execution/postprocess.asl -->
# Postprocess

**Normative ASL source:** `asl/tile/model/execution/postprocess.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-EXECUTION-POSTPROCESS}

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/execution/postprocess.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-EXECUTION-POSTPROCESS","surface":"tile","classification":["model","execution","postprocess"],"depends_on":["PTO-TILE-MODEL-EXECUTION-CUBE","PTO-TILE-MODEL-LEGALITY-MATRIX-POSTPROCESS"]}
// Complete-bundle B.FPATR post-processing.  Numeric conversion and activation
// remain behind the named profile hooks while this unit owns operand routing,
// reductions, and atomic auxiliary-output publication.

impdef func TileProfileMatrixPostProcess(
    value: Word, pre_quant_mode: bits(6), relu_mode: bits(3),
    group_n_code: bits(4), output_type: TileDataType,
    quant_param: Word, relu_param: Word,
    control: NumericExecutionControl) => Word
begin
    return value;
end;

impdef func TileProfileMatrixPostProcessWithFlags(
    value: Word, pre_quant_mode: bits(6), relu_mode: bits(3),
    group_n_code: bits(4), output_type: TileDataType,
    quant_param: Word, relu_param: Word,
    control: NumericExecutionControl) => (Word, bits(5))
begin
    return (value, Zeros{5});
end;

impdef func TileProfileMatrixReductionStep(
    current: Word, candidate: Word, max_abs: boolean,
    data_type: TileDataType) => Word
begin
    return candidate;
end;

impdef func TileProfileMatrixReductionStepWithFlags(
    current: Word, candidate: Word, max_abs: boolean,
    data_type: TileDataType) => (Word, bits(5))
begin
    return (candidate, Zeros{5});
end;

readonly func BundleMatrixLocalMathematicalSourceCount() => integer {0..5}
begin
    let function = UInt(_BundleOperation.selector[4:0]);
    let left_type = TileDataTypeFromEncoding(
        CurrentBundleTileOperationDataTypeCode() as TileDataTypeEncoding);
    let right_type = if _BundleDataAttributesPresent then
        TileDataTypeFromEncoding(
            _BundleDataAttributes.data_type as TileDataTypeEncoding)
        else left_type;
    return TileMatrixLocalMathematicalSourceCount(
        function, left_type, right_type, BundleSharedBindingCount());
end;

readonly func BundleMatrixOperationIndex() => integer {0..PTO_TILE_OPERATION_COUNT-1}
begin
    let decoded = DecodeTileOperation(TileDecode_CUBE,
        BundleOperationDecodeCode(_BundleOperation));
    assert decoded != PTO_TILE_OPERATION_COUNT;
    return decoded as integer {0..PTO_TILE_OPERATION_COUNT-1};
end;

func MatrixRowMaxResult(input: TileInfo, destination: TileIndex,
                        rowmax_input: TileIndex, has_input: boolean,
                        intermediate_type: TileDataType)
                        => (TileInfo, bits(5))
begin
    var output = _Tiles[[destination]];
    var payload = output.payload;
    var flags = Zeros{5};
    for row = 0 to input.valid_rows - 1 looplimit 65536 do
        let first = TileStorageIndex(input, row as integer {0..65535}, 0);
        var value = input.payload[[first]];
        if _BundleFixedPointAttributes.max_abs_en then
            let (initial, initial_flags) =
                TileProfileMatrixReductionStepWithFlags(
                    value, value, TRUE, intermediate_type);
            value = initial;
            flags = flags OR initial_flags;
        end;
        for column = 1 to input.valid_columns - 1 looplimit 65536 do
            let element = TileStorageIndex(input, row as integer {0..65535}, column as integer {0..65535});
            let (next, step_flags) = TileProfileMatrixReductionStepWithFlags(
                value, input.payload[[element]],
                _BundleFixedPointAttributes.max_abs_en, intermediate_type);
            value = next;
            flags = flags OR step_flags;
        end;
        if has_input then
            let input_element = TileStorageIndex(_Tiles[[rowmax_input]], row as integer {0..65535}, 0);
            let (next, step_flags) = TileProfileMatrixReductionStepWithFlags(
                _Tiles[[rowmax_input]].payload[[input_element]], value,
                _BundleFixedPointAttributes.max_abs_en, intermediate_type);
            value = next;
            flags = flags OR step_flags;
        end;
        let output_element = TileStorageIndex(output, row as integer {0..65535}, 0);
        payload[[output_element]] = value;
    end;
    output.payload = payload;
    return (MarkLocalTileValidRegionDefined(output), flags);
end;

func MatrixGroupMaxResult(input: TileInfo, destination: TileIndex,
                          intermediate_type: TileDataType)
    => (TileInfo, bits(5))
begin
    var output = _Tiles[[destination]];
    var payload = output.payload;
    var flags = Zeros{5};
    let group_n = BundleFPATRGroupN(_BundleFixedPointAttributes.group_n_code);
    for row = 0 to input.valid_rows - 1 looplimit 65536 do
        for group = 0 to output.valid_columns - 1 looplimit 65536 do
            let first_column = group * group_n;
            let first = TileStorageIndex(input, row as integer {0..65535}, first_column as integer {0..65535});
            var value = input.payload[[first]];
            if _BundleFixedPointAttributes.max_abs_en then
                let (initial, initial_flags) =
                    TileProfileMatrixReductionStepWithFlags(
                        value, value, TRUE, intermediate_type);
                value = initial;
                flags = flags OR initial_flags;
            end;
            for offset = 1 to group_n - 1 looplimit 128 do
                let column = first_column + offset;
                if column < input.valid_columns then
                    let element = TileStorageIndex(input, row as integer {0..65535}, column as integer {0..65535});
                    let (next, step_flags) =
                        TileProfileMatrixReductionStepWithFlags(
                            value, input.payload[[element]],
                            _BundleFixedPointAttributes.max_abs_en,
                            intermediate_type);
                    value = next;
                    flags = flags OR step_flags;
                end;
            end;
            let output_element = TileStorageIndex(output, row as integer {0..65535}, group as integer {0..65535});
            payload[[output_element]] = value;
        end;
    end;
    output.payload = payload;
    return (MarkLocalTileValidRegionDefined(output), flags);
end;

func MatrixPostProcessResult(input: TileInfo,
                             intermediate_type: TileDataType)
    => (TileInfo, bits(5))
begin
    if !_BundleFixedPointAttributes.valid then
        return (input, Zeros{5});
    end;
    var result = input;
    var payload = input.payload;
    var flags = Zeros{5};
    let output_type = if UInt(
        _BundleFixedPointAttributes.pre_quant_mode) == 0 then
        intermediate_type
    else
        BundleFPATROutputType(_BundleFixedPointAttributes.pre_quant_mode);
    let operation = BundleMatrixOperationIndex();
    let operands = BundleTileInstructionOperands(operation);
    let numeric_control = ResolveTileNumericExecutionControl(operation, operands);
    let mathematical_sources = BundleMatrixLocalMathematicalSourceCount();
    let quant_source_ordinal = mathematical_sources +
        (if _BundleFixedPointAttributes.row_max_en &&
            _BundleFixedPointAttributes.row_max_init then 1 else 0);
    let relu_source_ordinal = quant_source_ordinal +
        (if BundleFPATRModeUsesVectorParameter(
            _BundleFixedPointAttributes.pre_quant_mode) then 1 else 0);
    let quant_tile = BundleMatrixSourceAt(quant_source_ordinal as integer {0..7});
    let relu_tile = BundleMatrixSourceAt(relu_source_ordinal as integer {0..7});
    for row = 0 to input.valid_rows - 1 looplimit 65536 do
        for column = 0 to input.valid_columns - 1 looplimit 65536 do
            let element = TileStorageIndex(input, row as integer {0..65535},
                column as integer {0..65535});
            let quant_param = if BundleFPATRModeUsesVectorParameter(
                _BundleFixedPointAttributes.pre_quant_mode) then
                _Tiles[[quant_tile]].payload[[TileStorageIndex(
                    _Tiles[[quant_tile]], 0,
                    column as integer {0..65535})]]
            else if BundleFPATRModeUsesScalarParameter(
                _BundleFixedPointAttributes.pre_quant_mode) then
                operands.post_quant_param
            else
                Zeros{PTO_XLEN} + 1;
            let relu_param = if BundleFPATRReluModeUsesVectorParameter(
                _BundleFixedPointAttributes.relu_mode) then
                _Tiles[[relu_tile]].payload[[TileStorageIndex(
                    _Tiles[[relu_tile]], 0,
                    column as integer {0..65535})]]
            else
                operands.post_lrelu_param;
            let (processed, element_flags) =
                TileProfileMatrixPostProcessWithFlags(
                payload[[element]],
                _BundleFixedPointAttributes.pre_quant_mode,
                _BundleFixedPointAttributes.relu_mode,
                _BundleFixedPointAttributes.group_n_code,
                output_type, quant_param, relu_param, numeric_control);
            payload[[element]] = processed;
            flags = flags OR element_flags;
        end;
    end;
    result.data_type = output_type;
    result.payload = payload;
    return (result, flags);
end;

func CommitMatrixResult(destination: TileIndex, result: TileInfo,
                        intermediate_type: TileDataType)
begin
    let mathematical_sources = BundleMatrixLocalMathematicalSourceCount();
    let rowmax_input = BundleMatrixSourceAt(
        mathematical_sources as integer {0..7});
    let (processed, process_flags) = MatrixPostProcessResult(
        result, intermediate_type);
    let rowmax_destination = BundleMatrixDestinationAt(1);
    let group_destination = if _BundleFixedPointAttributes.row_max_en then BundleMatrixDestinationAt(2)
        else BundleMatrixDestinationAt(1);
    let (row_result, row_flags) = if _BundleFixedPointAttributes.row_max_en then
        MatrixRowMaxResult(
            result, rowmax_destination, rowmax_input,
            _BundleFixedPointAttributes.row_max_init,
            intermediate_type)
        else (_Tiles[[0]], Zeros{5});
    let (group_result, group_flags) = if _BundleFixedPointAttributes.group_max_en then
        MatrixGroupMaxResult(result, group_destination, intermediate_type)
        else (_Tiles[[0]], Zeros{5});
    // Prepare every output from pre-commit state, then publish as one group.
    _Tiles[[destination]] = processed;
    if _BundleFixedPointAttributes.row_max_en then _Tiles[[rowmax_destination]] = row_result; end;
    if _BundleFixedPointAttributes.group_max_en then _Tiles[[group_destination]] = group_result; end;
    RecordNumericStatusFlags(process_flags OR row_flags OR group_flags);
end;

func CommitMatrixResult(destination: TileIndex, result: TileInfo)
begin
    CommitMatrixResult(destination, result, result.data_type);
end;
```
<!-- GENERATED-ASL-END: unit -->

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
