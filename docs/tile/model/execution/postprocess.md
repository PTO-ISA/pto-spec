<!-- GENERATED FROM: asl/tile/model/execution/postprocess.asl -->
# Postprocess

**Normative ASL source:** `asl/tile/model/execution/postprocess.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-EXECUTION-POSTPROCESS}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-execution-postprocess-purpose role=purpose-scope -->
## Purpose and scope

This unit finishes a CUBE matrix operation. It routes the B.FPATR post-processing operands, converts every valid D element when B.FPATR is present, computes the optional RowMax and GroupMax outputs, and publishes all outputs together.

Its entry point is `CommitMatrixResult`. The CUBE execution unit calls it for every form that does not select raw-partial output.

<!-- PTO-READER-BLOCK: tile-model-execution-postprocess-concepts role=concepts-state -->
## Concepts and visible state

- B.FPATR is the matrix post-processing command. Its fields include PreQuantMode, ReluMode, GroupNCode, RowMaxEn, GroupMaxEn, RowMaxInit, and MaxAbsEn.
- The effective type is the D type after conversion. `BundleFPATREffectiveDataType` keeps the accumulator type when PreQuantMode is 0.
- RowMaxOut holds one maximum per row. GroupMaxOut holds one maximum per group of GroupN columns.

Extra sources follow the mathematical sources in this order: RowMaxIn when RowMaxEn and RowMaxInit are both set, then the vector quantization Tile, then the vector ReLU Tile. D is destination 0, RowMaxOut is destination 1, and GroupMaxOut is the next destination.

<!-- PTO-READER-BLOCK: tile-model-execution-postprocess-rules role=rules-interactions -->
## Rules and interactions

`MatrixPostProcessResult` returns its input unchanged when no B.FPATR is present. Otherwise it visits every valid element and calls `TileProfileMatrixPostProcessWithFlags`.

The quantization parameter comes from column `column` of the vector Tile, from the scalar operand, or is the constant 1, depending on PreQuantMode. The ReLU parameter comes from the vector Tile when ReluMode is 3 and from the scalar operand otherwise.

`MatrixRowMaxResult` starts each row with column 0 and folds columns 1 to N-1 in increasing order. With RowMaxInit, it then folds in RowMaxIn for that row. `MatrixGroupMaxResult` folds each group of GroupN columns the same way, in increasing column order and stopping at the last valid column; it has no input Tile to fold in.

Each fold step uses `TileProfileMatrixReductionStepWithFlags`. With MaxAbsEn it takes the absolute value of both operands first, then applies the ordinary MAX step.

`CommitMatrixResult` computes D, RowMaxOut, and GroupMaxOut from pre-commit state. It then writes all enabled outputs and records the OR of all their flags.

Design point: the reductions consume the final encoded D values, not the raw accumulator. RowMax therefore equals what a program would compute from the published D.

Design point: every output is prepared from pre-commit state before any is written. RowMaxIn and the output Tiles are read before D is published, and D, the enabled reduction outputs, and the flags then change together as one commit.

<!-- PTO-READER-BLOCK: tile-model-execution-postprocess-boundaries role=boundaries -->
## Architectural boundaries

Legality restricts RowMax and GroupMax to an effective type of FP32, FP16, or BF16. For those types, MAX follows the floating min/max rules, and only a signaling NaN raises NV.

The reduction outputs are marked defined only in their valid region. `MatrixPostProcessResult` changes the D type in its record and leaves definedness as the product set it.

The `TileProfileMatrixPostProcess` and `TileProfileMatrixReductionStep` wrappers drop flags; no caller of either was found in the ASL.

<!-- PTO-READER-BLOCK: tile-model-execution-postprocess-example role=example-usage -->
## Non-normative reading example

An FP32 TMATMUL has PreQuantMode 0, ReluMode 0, RowMaxEn 1, and RowMaxInit 1. Row 0 of D is 3.0, -7.0, 5.0, and RowMaxIn row 0 is 6.0.

1. Post-processing leaves D unchanged, because both modes are 0.
2. Without MaxAbsEn, the row fold gives max(3.0, -7.0) = 3.0, then max(3.0, 5.0) = 5.0.
3. Folding in RowMaxIn gives max(6.0, 5.0) = 6.0, so RowMaxOut row 0 is 6.0.
4. With MaxAbsEn, the fold uses 3.0, 7.0, and 5.0, so it reaches 7.0 before RowMaxIn and publishes 7.0.

<!-- PTO-READER-BLOCK: tile-model-execution-postprocess-related role=related-owners-navigation -->
## Related owners

- [Matrix post-processing](matrix-postprocess.md) owns the per-element conversion and activation.
- [CUBE execution](cube.md) produces the result that this unit commits.
- [Matrix post-processing legality](../legality/matrix-postprocess.md) checks operand counts and effective types.
- [B.FPATR](../../../block/attributes/B.FPATR.md) defines the mode fields.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/execution/postprocess.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-EXECUTION-POSTPROCESS","surface":"tile","classification":["model","execution","postprocess"],"depends_on":["PTO-TILE-MODEL-EXECUTION-CUBE","PTO-TILE-MODEL-LEGALITY-MATRIX-POSTPROCESS"]}
// Complete-bundle B.FPATR post-processing.  Numeric conversion and activation
// remain behind the named profile hooks while this unit owns operand routing,
// reductions, and atomic auxiliary-output publication.

func TileProfileMatrixPostProcess(
    value: Word, pre_quant_mode: bits(6), relu_mode: bits(3),
    group_n_code: bits(4), output_type: TileDataType,
    quant_param: Word, relu_param: Word,
    control: NumericExecutionControl) => Word
begin
    let (result, -) = TileProfileMatrixPostProcessWithFlags(
        value, pre_quant_mode, relu_mode, group_n_code,
        output_type, quant_param, relu_param, control);
    return result;
end;

func TileProfileMatrixPostProcessWithFlags(
    value: Word, pre_quant_mode: bits(6), relu_mode: bits(3),
    group_n_code: bits(4), output_type: TileDataType,
    quant_param: Word, relu_param: Word,
    control: NumericExecutionControl) => (Word, bits(5))
begin
    let effective_control = MatrixFPATREffectiveControl(
        pre_quant_mode, control);
    return MatrixPostQuantBaseWithFlags(
        value, pre_quant_mode, output_type, relu_mode,
        quant_param, relu_param, effective_control);
end;

func TileProfileMatrixReductionStep(
    current: Word, candidate: Word, max_abs: boolean,
    data_type: TileDataType) => Word
begin
    let (result, -) = TileProfileMatrixReductionStepWithFlags(
        current, candidate, max_abs, data_type);
    return result;
end;

func TileProfileMatrixReductionStepWithFlags(
    current: Word, candidate: Word, max_abs: boolean,
    data_type: TileDataType) => (Word, bits(5))
begin
    let (lhs_abs, lhs_flags) = if max_abs then
        MatrixReductionAbsoluteWithFlags(current, data_type)
    else
        (current, Zeros{5});
    let (rhs_abs, rhs_flags) = if max_abs then
        MatrixReductionAbsoluteWithFlags(candidate, data_type)
    else
        (candidate, Zeros{5});
    let lhs = if max_abs then lhs_abs else current;
    let rhs = if max_abs then rhs_abs else candidate;
    let (selected, -, flags) = TileReductionStepWithFlags(
        TileReduction_MAX, data_type, lhs, rhs);
    return (selected, flags OR lhs_flags OR rhs_flags);
end;

readonly func BundleMatrixLocalMathematicalSourceCount() => integer {0..6}
begin
    let function = UInt(_BundleOperation.selector[4:0]);
    let left_type = TileDataTypeFromEncoding(
        CurrentBundleTileOperationDataTypeCode() as TileDataTypeEncoding);
    let right_type = if _BundleDataAttributesPresent then
        TileDataTypeFromEncoding(
            _BundleDataAttributes.data_type as TileDataTypeEncoding)
        else left_type;
    let base = TileMatrixLocalMathematicalSourceCount(
        function, left_type, right_type, BundleSharedBindingCount());
    return (base +
        (if _BundleFixedPointAttributes.c_scale_en then 1 else 0))
        as integer {0..6};
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
    let output_type = BundleFPATREffectiveDataType(
        _BundleFixedPointAttributes.pre_quant_mode, intermediate_type);
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
    let quant_tile = BundleMatrixSourceAt(quant_source_ordinal as integer {0..8});
    let relu_tile = BundleMatrixSourceAt(relu_source_ordinal as integer {0..8});
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
    result.predicate_basis_type = output_type;
    result.payload = payload;
    return (result, flags);
end;

func CommitMatrixResult(destination: TileIndex, result: TileInfo,
                        intermediate_type: TileDataType)
begin
    let mathematical_sources = BundleMatrixLocalMathematicalSourceCount();
    let rowmax_input = BundleMatrixSourceAt(
        mathematical_sources as integer {0..8});
    let (processed, process_flags) = MatrixPostProcessResult(
        result, intermediate_type);
    let rowmax_destination = BundleMatrixDestinationAt(1);
    let group_destination = if _BundleFixedPointAttributes.row_max_en then BundleMatrixDestinationAt(2)
        else BundleMatrixDestinationAt(1);
    let (row_result, row_flags) = if _BundleFixedPointAttributes.row_max_en then
        MatrixRowMaxResult(
            processed, rowmax_destination, rowmax_input,
            _BundleFixedPointAttributes.row_max_init,
            processed.data_type)
        else (_Tiles[[0]], Zeros{5});
    let (group_result, group_flags) = if _BundleFixedPointAttributes.group_max_en then
        MatrixGroupMaxResult(
            processed, group_destination, processed.data_type)
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
