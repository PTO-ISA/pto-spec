<!-- GENERATED FROM: asl/tile/model/execution/postprocess.asl -->
# Postprocess

**Normative ASL source:** `asl/tile/model/execution/postprocess.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-EXECUTION-POSTPROCESS}

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/execution/postprocess.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-EXECUTION-POSTPROCESS","surface":"tile","classification":["model","execution","postprocess"],"depends_on":["PTO-TILE-MODEL-EXECUTION-CUBE"]}
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

impdef func TileProfileMatrixReductionStep(
    current: Word, candidate: Word, max_abs: boolean,
    data_type: TileDataType) => Word
begin
    return candidate;
end;

readonly func BundleMatrixDestinationAt(ordinal: integer {0..2}) => TileIndex
begin
    var seen: integer {0..3} = 0;
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 looplimit 16 do
        if _BundleTileBindings[[binding]].valid &&
           _BundleTileBindings[[binding]].destination_valid then
            if seen == ordinal then return _BundleTileBindings[[binding]].destination; end;
            seen = (seen + 1) as integer {0..3};
        end;
    end;
    return 0;
end;

readonly func BundleMatrixSourceAt(ordinal: integer {0..7}) => TileIndex
begin
    var seen: integer {0..8} = 0;
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 looplimit 16 do
        if _BundleTileBindings[[binding]].valid then
            if _BundleTileBindings[[binding]].source0_valid then
                if seen == ordinal then return _BundleTileBindings[[binding]].source0; end;
                seen = (seen + 1) as integer {0..8};
            end;
            if _BundleTileBindings[[binding]].source1_valid then
                if seen == ordinal then return _BundleTileBindings[[binding]].source1; end;
                seen = (seen + 1) as integer {0..8};
            end;
        end;
    end;
    return 0;
end;

readonly func BundleMatrixStaticSourceCount(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => integer {0..5}
begin
    return (if TileOperandPresent(operation, TileOperand_source0) then 1 else 0) +
           (if TileOperandPresent(operation, TileOperand_source1) then 1 else 0) +
           (if TileOperandPresent(operation, TileOperand_source2) then 1 else 0) +
           (if TileOperandPresent(operation, TileOperand_source3) then 1 else 0) +
           (if TileOperandPresent(operation, TileOperand_source4) then 1 else 0);
end;

readonly func BundleMatrixOperationIndex() => integer {0..PTO_TILE_OPERATION_COUNT-1}
begin
    let decoded = DecodeTileOperation(TileDecode_CUBE,
        BundleOperationDecodeCode(_BundleOperation));
    assert decoded != PTO_TILE_OPERATION_COUNT;
    return decoded as integer {0..PTO_TILE_OPERATION_COUNT-1};
end;

func MatrixRowMaxResult(input: TileInfo, destination: TileIndex,
                        rowmax_input: TileIndex, has_input: boolean) => TileInfo
begin
    var output = _Tiles[[destination]];
    var payload = output.payload;
    for row = 0 to input.valid_rows - 1 looplimit 65536 do
        let first = TileLinearIndex(input, row as integer {0..65535}, 0);
        var value = input.payload[[first]];
        for column = 1 to input.valid_columns - 1 looplimit 65536 do
            let element = TileLinearIndex(input, row as integer {0..65535}, column as integer {0..65535});
            value = TileProfileMatrixReductionStep(value, input.payload[[element]],
                _BundleFixedPointAttributes.max_abs_en, input.data_type);
        end;
        if has_input then
            let input_element = TileLinearIndex(_Tiles[[rowmax_input]], row as integer {0..65535}, 0);
            value = TileProfileMatrixReductionStep(_Tiles[[rowmax_input]].payload[[input_element]], value,
                _BundleFixedPointAttributes.max_abs_en, input.data_type);
        end;
        let output_element = TileLinearIndex(output, row as integer {0..65535}, 0);
        payload[[output_element]] = value;
    end;
    output.payload = payload;
    return MarkLocalTileValidRegionDefined(output);
end;

func MatrixGroupMaxResult(input: TileInfo, destination: TileIndex) => TileInfo
begin
    var output = _Tiles[[destination]];
    var payload = output.payload;
    let group_n = BundleFPATRGroupN(_BundleFixedPointAttributes.group_n_code);
    for row = 0 to input.valid_rows - 1 looplimit 65536 do
        for group = 0 to output.valid_columns - 1 looplimit 65536 do
            let first_column = group * group_n;
            let first = TileLinearIndex(input, row as integer {0..65535}, first_column as integer {0..65535});
            var value = input.payload[[first]];
            for offset = 1 to group_n - 1 looplimit 128 do
                let column = first_column + offset;
                if column < input.valid_columns then
                    let element = TileLinearIndex(input, row as integer {0..65535}, column as integer {0..65535});
                    value = TileProfileMatrixReductionStep(value, input.payload[[element]],
                        _BundleFixedPointAttributes.max_abs_en, input.data_type);
                end;
            end;
            let output_element = TileLinearIndex(output, row as integer {0..65535}, group as integer {0..65535});
            payload[[output_element]] = value;
        end;
    end;
    output.payload = payload;
    return MarkLocalTileValidRegionDefined(output);
end;

func MatrixPostProcessResult(input: TileInfo) => TileInfo
begin
    if !_BundleFixedPointAttributes.valid then return input; end;
    var result = input;
    var payload = input.payload;
    let selected_type = TileDataTypeFromEncoding(ZeroExtend{PTO_XLEN}(CurrentBundleTileOperationDataTypeCode()));
    let accumulator_type = TileMatrixAccumulatorDataType(selected_type);
    let output_type = if UInt(_BundleFixedPointAttributes.pre_quant_mode) == 0 then accumulator_type
        else BundleFPATROutputType(_BundleFixedPointAttributes.pre_quant_mode);
    let operation = BundleMatrixOperationIndex();
    let operands = BundleTileInstructionOperands(operation);
    let numeric_control = ResolveTileNumericExecutionControl(operation, operands);
    let static_sources = BundleMatrixStaticSourceCount(operation);
    let quant_source_ordinal = static_sources +
        (if _BundleFixedPointAttributes.row_max_en && _BundleFixedPointAttributes.row_max_init then 1 else 0);
    let relu_source_ordinal = quant_source_ordinal +
        (if BundleFPATRModeUsesVectorParameter(_BundleFixedPointAttributes.pre_quant_mode) then 1 else 0);
    let quant_tile = BundleMatrixSourceAt(quant_source_ordinal as integer {0..7});
    let relu_tile = BundleMatrixSourceAt(relu_source_ordinal as integer {0..7});
    for row = 0 to input.valid_rows - 1 looplimit 65536 do
        for column = 0 to input.valid_columns - 1 looplimit 65536 do
            let element = TileLinearIndex(input, row as integer {0..65535},
                column as integer {0..65535});
            let quant_param = if BundleFPATRModeUsesVectorParameter(_BundleFixedPointAttributes.pre_quant_mode) then
                _Tiles[[quant_tile]].payload[[TileLinearIndex(_Tiles[[quant_tile]], 0,
                    column as integer {0..65535})]]
                else if BundleFPATRModeUsesScalarParameter(
                    _BundleFixedPointAttributes.pre_quant_mode) then operands.post_quant_param
                else Zeros{PTO_XLEN} + 1;
        let relu_param = if BundleFPATRReluModeUsesVectorParameter(
                _BundleFixedPointAttributes.relu_mode) then
                _Tiles[[relu_tile]].payload[[TileLinearIndex(_Tiles[[relu_tile]], 0,
                    column as integer {0..65535})]] else operands.post_lrelu_param;
            payload[[element]] = TileProfileMatrixPostProcess(payload[[element]],
                _BundleFixedPointAttributes.pre_quant_mode, _BundleFixedPointAttributes.relu_mode,
                _BundleFixedPointAttributes.group_n_code, output_type, quant_param, relu_param,
                numeric_control);
        end;
    end;
    result.data_type = output_type;
    result.payload = payload;
    return result;
end;

func CommitMatrixResult(destination: TileIndex, result: TileInfo)
begin
    let operation = BundleMatrixOperationIndex();
    let static_sources = BundleMatrixStaticSourceCount(operation);
    let rowmax_input = BundleMatrixSourceAt(static_sources as integer {0..7});
    let processed = MatrixPostProcessResult(result);
    let rowmax_destination = BundleMatrixDestinationAt(1);
    let group_destination = if _BundleFixedPointAttributes.row_max_en then BundleMatrixDestinationAt(2)
        else BundleMatrixDestinationAt(1);
    let row_result = if _BundleFixedPointAttributes.row_max_en then
        MatrixRowMaxResult(result, rowmax_destination, rowmax_input, _BundleFixedPointAttributes.row_max_init)
        else _Tiles[[0]];
    let group_result = if _BundleFixedPointAttributes.group_max_en then
        MatrixGroupMaxResult(result, group_destination) else _Tiles[[0]];
    // Prepare every output from pre-commit state, then publish as one group.
    _Tiles[[destination]] = processed;
    if _BundleFixedPointAttributes.row_max_en then _Tiles[[rowmax_destination]] = row_result; end;
    if _BundleFixedPointAttributes.group_max_en then _Tiles[[group_destination]] = group_result; end;
end;
```
<!-- GENERATED-ASL-END: unit -->

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
