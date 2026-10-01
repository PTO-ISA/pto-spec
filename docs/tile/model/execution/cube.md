<!-- GENERATED FROM: asl/tile/model/execution/cube.asl -->
# CUBE

**Normative ASL source:** `asl/tile/model/execution/cube.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-EXECUTION-CUBE}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-execution-cube-purpose role=purpose-scope -->
## Purpose and scope

This unit computes the CUBE matrix product for the TMATMUL and TGEMV families. It builds the raw accumulator result, adds an optional bias, and then hands the result to a commit helper.

The complete-bundle path in `ExecuteBundleTMATMULOperation` calls `TMATMULShared` for ordinary forms and `TMATMULMXSharedWithOptionalScales` for MX forms. The unit also defines one direct function per mnemonic, from `TMATMUL` to `TGEMV_MX_ACC`, and `TMATMULMXShared`. No ASL caller of those functions was found.

<!-- PTO-READER-BLOCK: tile-model-execution-cube-concepts role=concepts-state -->
## Concepts and visible state

- A is the left source with M rows and K columns. B is the right source with K rows and N columns.
- C is the explicit accumulator input of ACC forms. D is the destination.
- The accumulator type comes from `TileMatrixAccumulatorDataType`: S32 for signed inputs, U32 for unsigned inputs, and FP32 otherwise.
- D must have the accumulator type, or the `BundleFPATROutputType` of the selected PreQuantMode when that mode is nonzero.
- MX forms add per-group scales. A group covers 32 inner elements, or 64 for HiF4X2.

<!-- PTO-READER-BLOCK: tile-model-execution-cube-rules role=rules-interactions -->
## Rules and interactions

For each result row and column, the sum starts from `MatrixInitialAccumulatorValue`. That value is zero without accumulation, the C element with accumulation, and the scaled C element when CScale is enabled.

The inner index then runs from 0 to K-1 in increasing order. Each step calls `TileProfileMatrixAccumulate` for ordinary forms or `TileProfileMatrixScaledAccumulate` for MX forms.

The FP32 reference path applies when the accumulator type is FP32, both inputs are FP32, TF32, HF32, FP16, or BF16, all three carriers are finite, and, for MX forms, neither scale is present. It rounds the product to FP32 and then rounds the sum to FP32; ordinary forms use RMode and Sat from B.DATR, MX forms use the default control. In every other case, including integer types and infinite or NaN operands, the ordinary helper returns `accumulator + MultiplyWord(left, right)` on the raw element carriers, and the MX helper first multiplies each input by its scale when that scale is present.

`MatrixBiasResult` adds one bias row element per column after the product. When both the value and the bias are finite FP32, it rounds their sum with the default control; otherwise it adds carriers.

With CCTRL bit 0 set, `CommitMatrixRawPartial` publishes the raw accumulator-type result and skips post-processing and auxiliary outputs. Otherwise `CommitMatrixResult` in the post-processing unit publishes D.

Design point: A, B, and C are read into private copies before any destination write, and the result is built in a private `TileInfo`. The header comment states the consequence: when D names C, the operation reads the old C and writes the new D.

Design point: the FP32 path rounds twice per inner step and walks K in a fixed order, so the result is not a fused multiply-add and the model gives one deterministic result for each input.

Design point: `MarkLocalTileValidRegionDefined` clears every defined bit and then marks only the valid region. No PadValue is applied, so D's padding stays undefined.

<!-- PTO-READER-BLOCK: tile-model-execution-cube-boundaries role=boundaries -->
## Architectural boundaries

The helpers assert their shape and type rules. The bundle preflight in `ExecuteBundleTMATMULOperation` checks them before any source snapshot, so a legal program does not reach a failing assert.

On the bundle path, `ExecuteBundleTMATMULOperation` raises Fault_TileLegality when a TGEMV form has M other than 1; the direct TGEMV functions assert 1 valid row. CScale is legal only for TMATMUL_ACC and TMATMUL_MX_ACC; its schema is a U8 CUBE_M32 Tile with M rows and 1 column, and legality also requires an FP32 accumulator.

Accumulation and bias discard numeric status flags. Only CScale and post-processing record flags.

<!-- PTO-READER-BLOCK: tile-model-execution-cube-example role=example-usage -->
## Non-normative reading example

Consider an FP32 TMATMUL_ACC with M=1, N=1, and K=2:

```text
TMATMUL_ACC <M=1, N=1, K=2, FP32>, AccTile, SrcTile0, SrcTile1, ->DstTile<Size>
```

1. The left source row is 1.0 and 2.0. The right source column is 3.0 and 4.0. The accumulator element is 10.0.
2. The sum starts at 10.0. Step 0 adds 1.0 x 3.0 = 3.0, giving 13.0.
3. Step 1 adds 2.0 x 4.0 = 8.0, giving 21.0. Every value is exact, so no rounding occurs.
4. With CScale enabled and exponent 1, the start value is 10.0 / 2 = 5.0, and the result is 16.0.

<!-- PTO-READER-BLOCK: tile-model-execution-cube-related role=related-owners-navigation -->
## Related owners

- [Matrix scale](matrix-scale.md) owns the initial accumulator value, CScale, and the accumulate helpers.
- [Post-processing](postprocess.md) owns `CommitMatrixResult` and the auxiliary outputs.
- [Internal accumulator](internal-accumulator.md) owns the non-binding CCTRL cache hints.
- [CUBE TMATMUL dispatch](../../../block/model/dispatch/cube-tmatmul.md) performs preflight and selects the shared entry point.
- [Matrix operands](../legality/matrix-operands.md) owns accumulator, bias, and CScale legality.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/execution/cube.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-EXECUTION-CUBE","surface":"tile","classification":["model","execution","cube"],"depends_on":["PTO-TILE-MODEL-MEMORY-RESTART","PTO-TILE-MODEL-EXECUTION-MATRIX-SCALE"]}
// PTO-REQ-CUBE-001: profile-defined matrix arithmetic with portable integer
// defaults. CUBE operations name their Local destination D explicitly. ACC
// forms also name their Local accumulator input C explicitly;
// C is snapshotted before D is written so D == C has read-old/write-new
// behavior.
func MarkLocalTileValidRegionDefined(tile: TileInfo) => TileInfo
begin
    let zero_packed_tile_elements = ZeroPackedTileDefinedElements();
    var result = tile;
    result.defined_elements = Zeros{PTO_MODEL_TILE_ELEMENTS};
    result.packed_defined_elements = zero_packed_tile_elements;
    for row = 0 to result.valid_rows - 1 looplimit 65536 do
        for column = 0 to result.valid_columns - 1 looplimit 65536 do
            let element = TileStorageIndex(result,
                row as integer {0..65535}, column as integer {0..65535});
            result.defined_elements[element] = '1';
        end;
    end;
    result.defined_valid_elements =
        (result.valid_rows * result.valid_columns) as integer {0..524288};
    result.contents_defined = TRUE;
    return result;
end;
func MatrixProductResultFromTiles(destination: TileIndex,
                                  destination_tile: TileInfo,
                                  accumulator: TileIndex,
                                  left_tile: TileInfo,
                                  right_tile: TileInfo,
                                  accumulate: boolean,
                                  c_scale: TileIndex,
                                  c_scale_present: boolean) => TileInfo
begin
    let zero_packed_tile_elements = ZeroPackedTileDefinedElements();
    let accumulator_tile = _Tiles[[accumulator]];
    let selected_data_type = TileDataTypeFromEncoding(
        CurrentBundleTileOperationDataTypeCode() as TileDataTypeEncoding);
    let accumulator_data_type =
        TileMatrixAccumulatorDataType(selected_data_type);
    let expected_destination_type = if _BundleFixedPointAttributes.valid &&
        UInt(_BundleFixedPointAttributes.pre_quant_mode) != 0 then
        BundleFPATROutputType(_BundleFixedPointAttributes.pre_quant_mode)
    else accumulator_data_type;
    let output_converted = _BundleFixedPointAttributes.valid &&
        UInt(_BundleFixedPointAttributes.pre_quant_mode) != 0;
    assert left_tile.allocated && left_tile.contents_defined;
    assert right_tile.allocated && right_tile.contents_defined;
    assert left_tile.valid_columns == right_tile.valid_rows;
    assert destination_tile.allocated;
    assert destination_tile.valid_rows == left_tile.valid_rows;
    assert destination_tile.valid_columns == right_tile.valid_columns;
    assert destination_tile.data_type == expected_destination_type;
    if accumulate then
        assert accumulator_tile.allocated && accumulator_tile.contents_defined;
        assert accumulator_tile.valid_rows == left_tile.valid_rows;
        assert accumulator_tile.valid_columns == right_tile.valid_columns;
        assert accumulator_tile.data_type == accumulator_data_type;
        assert accumulator_tile.layout == destination_tile.layout;
        assert output_converted ||
               accumulator_tile.capacity_bytes == destination_tile.capacity_bytes;
    end;
    if c_scale_present then
        assert accumulate &&
               TileMatrixLocalCScaleSchemaLegal(
                   c_scale,
                   left_tile.valid_rows as integer {1..65535});
    end;
    let left_payload = left_tile.payload;
    let right_payload = right_tile.payload;
    var result: TileInfo = destination_tile;
    result.contents_defined = FALSE;
    result.defined_elements = Zeros{PTO_MODEL_TILE_ELEMENTS};
    result.defined_valid_elements = 0;
    result.packed_defined_elements = zero_packed_tile_elements;
    var result_payload: TilePayload = destination_tile.payload;
    let control = NumericExecutionControl {
        rounding_mode = DecodeBundleRoundingSelection(
            _BundleDataAttributes.rounding_mode).rounding_mode,
        saturating = _BundleDataAttributes.saturating
    };
    for row = 0 to left_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to right_tile.valid_columns - 1 looplimit 65536 do
            let result_element = TileStorageIndex(result,
                row as integer {0..65535}, column as integer {0..65535});
            var sum = MatrixInitialAccumulatorValue(
                accumulator_tile, accumulate,
                row as integer {0..65535}, column as integer {0..65535},
                c_scale, c_scale_present);
            for inner = 0 to left_tile.valid_columns - 1 looplimit 65536 do
                let left_element = TileStorageIndex(left_tile,
                    row as integer {0..65535}, inner as integer {0..65535});
                let right_element = TileStorageIndex(right_tile,
                    inner as integer {0..65535}, column as integer {0..65535});
                sum = TileProfileMatrixAccumulate(sum,
                    left_payload[[left_element]], right_payload[[right_element]],
                    accumulator_data_type, left_tile.data_type,
                    right_tile.data_type, control);
            end;
            result_payload[[result_element]] = sum;
        end;
    end;
    result.payload = result_payload;
    return MarkLocalTileValidRegionDefined(result);
end;
func MatrixProductResult(destination: TileIndex, accumulator: TileIndex,
                         left: TileIndex, right: TileIndex,
                         accumulate: boolean) => TileInfo
begin
    return MatrixProductResultFromTiles(destination, _Tiles[[destination]],
        accumulator, _Tiles[[left]], _Tiles[[right]], accumulate,
        0, FALSE);
end;
func MatrixBiasResult(input: TileInfo, bias: TileIndex,
                      intermediate_type: TileDataType) => TileInfo
begin
    let bias_tile = _Tiles[[bias]];
    let bias_payload = bias_tile.payload;
    assert bias_tile.allocated && bias_tile.contents_defined;
    assert TileCubeDescriptorLegal(bias_tile);
    assert bias_tile.valid_rows == 1;
    assert bias_tile.valid_columns == input.valid_columns;
    assert bias_tile.layout == TileLayout_CUBE_N8;
    assert bias_tile.data_type == intermediate_type;
    var result = input;
    var result_payload = input.payload;
    for row = 0 to input.valid_rows - 1 looplimit 65536 do
        for column = 0 to input.valid_columns - 1 looplimit 65536 do
            let result_element = TileLogicalLinearIndex(input,
                row as integer {0..65535}, column as integer {0..65535});
            let bias_element = TileLogicalLinearIndex(bias_tile,
                0, column as integer {0..65535});
            result_payload[[result_element]] = TileProfileMatrixBias(
                input.payload[[result_element]], bias_payload[[bias_element]],
                intermediate_type, bias_tile.data_type);
        end;
    end;
    result.payload = result_payload;
    return result;
end;
func MatrixMXProductResultFromTiles(destination: TileIndex,
                                    destination_tile: TileInfo,
                                    accumulator: TileIndex,
                                    left_tile: TileInfo,
                                    left_scale_tile: TileInfo,
                                    left_scale_present: boolean,
                                    right_tile: TileInfo,
                                    right_scale_tile: TileInfo,
                                    right_scale_present: boolean,
                                    accumulate: boolean,
                                    c_scale: TileIndex,
                                    c_scale_present: boolean) => TileInfo
begin
    let zero_packed_tile_elements = ZeroPackedTileDefinedElements();
    let accumulator_tile = _Tiles[[accumulator]];
    let selected_data_type = TileDataTypeFromEncoding(
        CurrentBundleTileOperationDataTypeCode() as TileDataTypeEncoding);
    let accumulator_data_type =
        TileMatrixAccumulatorDataType(selected_data_type);
    let expected_destination_type = if _BundleFixedPointAttributes.valid &&
        UInt(_BundleFixedPointAttributes.pre_quant_mode) != 0 then
        BundleFPATROutputType(_BundleFixedPointAttributes.pre_quant_mode)
    else accumulator_data_type;
    let output_converted = _BundleFixedPointAttributes.valid &&
        UInt(_BundleFixedPointAttributes.pre_quant_mode) != 0;
    assert left_tile.allocated && left_tile.contents_defined;
    assert right_tile.allocated && right_tile.contents_defined;
    assert !left_scale_present ||
           (left_scale_tile.allocated && left_scale_tile.contents_defined);
    assert !right_scale_present ||
           (right_scale_tile.allocated && right_scale_tile.contents_defined);
    assert left_tile.valid_columns == right_tile.valid_rows;
    assert destination_tile.allocated;
    assert destination_tile.valid_rows == left_tile.valid_rows;
    assert destination_tile.valid_columns == right_tile.valid_columns;
    assert destination_tile.data_type == expected_destination_type;
    if accumulate then
        assert accumulator_tile.allocated && accumulator_tile.contents_defined;
        assert accumulator_tile.valid_rows == left_tile.valid_rows;
        assert accumulator_tile.valid_columns == right_tile.valid_columns;
        assert accumulator_tile.data_type == accumulator_data_type;
        assert accumulator_tile.layout == destination_tile.layout;
        assert output_converted ||
               accumulator_tile.capacity_bytes == destination_tile.capacity_bytes;
    end;
    if c_scale_present then
        assert accumulate &&
               TileMatrixLocalCScaleSchemaLegal(
                   c_scale,
                   left_tile.valid_rows as integer {1..65535});
    end;
    let left_payload = left_tile.payload;
    let right_payload = right_tile.payload;
    let left_scale_payload = left_scale_tile.payload;
    let right_scale_payload = right_scale_tile.payload;
    var result: TileInfo = destination_tile;
    result.contents_defined = FALSE;
    result.defined_elements = Zeros{PTO_MODEL_TILE_ELEMENTS};
    result.defined_valid_elements = 0;
    result.packed_defined_elements = zero_packed_tile_elements;
    var result_payload = destination_tile.payload;
    for row = 0 to left_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to right_tile.valid_columns - 1 looplimit 65536 do
            let result_element = TileStorageIndex(result,
                row as integer {0..65535}, column as integer {0..65535});
            var sum = MatrixInitialAccumulatorValue(
                accumulator_tile, accumulate,
                row as integer {0..65535}, column as integer {0..65535},
                c_scale, c_scale_present);
            for inner = 0 to left_tile.valid_columns - 1 looplimit 65536 do
                let left_element = TileStorageIndex(left_tile,
                    row as integer {0..65535}, inner as integer {0..65535});
                let right_element = TileStorageIndex(right_tile,
                    inner as integer {0..65535}, column as integer {0..65535});
                let left_scale_element = if left_scale_present then
                    MatrixLeftScaleElement(
                        left_scale_tile, left_tile.data_type,
                        row as integer {0..65535},
                        inner as integer {0..65535})
                else
                    0;
                let right_scale_element = if right_scale_present then
                    MatrixRightScaleElement(
                        right_scale_tile, right_tile.data_type,
                        column as integer {0..65535},
                        inner as integer {0..65535})
                else
                    0;
                let left_scale_value = if left_scale_present then
                    left_scale_payload[[left_scale_element]]
                else
                    Zeros{PTO_XLEN};
                let right_scale_value = if right_scale_present then
                    right_scale_payload[[right_scale_element]]
                else
                    Zeros{PTO_XLEN};
                sum = TileProfileMatrixScaledAccumulate(
                    sum, left_payload[[left_element]],
                    right_payload[[right_element]],
                    left_scale_value, right_scale_value,
                    left_scale_present, right_scale_present,
                    accumulator_data_type, left_tile.data_type,
                    right_tile.data_type, left_scale_tile.data_type,
                    right_scale_tile.data_type);
            end;
            result_payload[[result_element]] = sum;
        end;
    end;
    result.payload = result_payload;
    return MarkLocalTileValidRegionDefined(result);
end;
func MatrixMXProductResult(destination: TileIndex, accumulator: TileIndex,
                           left: TileIndex, left_scale: TileIndex,
                           right: TileIndex, right_scale: TileIndex,
                           accumulate: boolean) => TileInfo
begin
    let left_scale_present =
        TileMXInputTypeNeedsScale(_Tiles[[left]].data_type);
    let right_scale_present =
        TileMXInputTypeNeedsScale(_Tiles[[right]].data_type);
    return MatrixMXProductResultFromTiles(
        destination, _Tiles[[destination]], accumulator,
        _Tiles[[left]], _Tiles[[left_scale]], left_scale_present,
        _Tiles[[right]], _Tiles[[right_scale]], right_scale_present,
        accumulate, 0, FALSE);
end;
func MatrixMXProductResultWithOptionalScales(
    destination: TileIndex, destination_tile: TileInfo, accumulator: TileIndex,
    left: TileInfo, left_scale: TileInfo, left_scale_present: boolean,
    right: TileInfo, right_scale: TileInfo, right_scale_present: boolean,
    accumulate: boolean,
    c_scale: TileIndex, c_scale_present: boolean) => TileInfo
begin
    return MatrixMXProductResultFromTiles(destination, destination_tile,
        accumulator, left, left_scale, left_scale_present, right, right_scale,
        right_scale_present, accumulate, c_scale, c_scale_present);
end;
func CommitMatrixRawPartial(destination: TileIndex, result: TileInfo,
                              accumulator_type: TileDataType)
begin
    // Spill uses the destination object reserved by complete preflight.  This
    // publishes only the raw accumulator result and deliberately bypasses
    // MatrixPostProcessResult and all auxiliary output publication.
    assert result.allocated && result.contents_defined;
    assert result.data_type == accumulator_type;
    _Tiles[[destination]] = result;
end;
func TMATMULShared(destination: TileIndex, destination_tile: TileInfo,
                   accumulator: TileIndex,
                   left: TileInfo, right: TileInfo,
                   bias: TileIndex, use_bias: boolean,
                   accumulate: boolean,
                   c_scale: TileIndex, c_scale_present: boolean,
                   partial_output: boolean)
begin
    let intermediate_type = TileOrdinaryMatrixAccumulatorType(
        left.data_type, right.data_type);
    let product = MatrixProductResultFromTiles(destination, destination_tile,
        accumulator, left, right, accumulate, c_scale, c_scale_present);
    let result = if use_bias then
        MatrixBiasResult(product, bias, intermediate_type)
        else product;
    if partial_output then
        CommitMatrixRawPartial(destination, result, intermediate_type);
    else CommitMatrixResult(destination, result, intermediate_type); end;
end;
func TMATMULMXShared(destination: TileIndex, accumulator: TileIndex,
                     left: TileInfo, left_scale: TileInfo,
                     right: TileInfo, right_scale: TileInfo,
                     bias: TileIndex, use_bias: boolean,
                     accumulate: boolean)
begin
    let intermediate_type = TileDataType_FP32;
    let product = MatrixMXProductResultFromTiles(
        destination, _Tiles[[destination]], accumulator,
        left, left_scale, TRUE, right, right_scale, TRUE,
        accumulate, 0, FALSE);
    let result = if use_bias then
        MatrixBiasResult(product, bias, intermediate_type)
        else product;
    CommitMatrixResult(destination, result, intermediate_type);
end;
func TMATMULMXSharedWithOptionalScales(
    destination: TileIndex, destination_tile: TileInfo, accumulator: TileIndex,
    left: TileInfo, left_scale: TileInfo, left_scale_present: boolean,
    right: TileInfo, right_scale: TileInfo, right_scale_present: boolean,
    bias: TileIndex, use_bias: boolean, accumulate: boolean,
    c_scale: TileIndex, c_scale_present: boolean,
    partial_output: boolean)
begin
    let intermediate_type = TileDataType_FP32;
    let product = MatrixMXProductResultWithOptionalScales(
        destination, destination_tile, accumulator,
        left, left_scale, left_scale_present,
        right, right_scale, right_scale_present,
        accumulate, c_scale, c_scale_present);
    let result = if use_bias then
        MatrixBiasResult(product, bias, intermediate_type)
        else product;
    if partial_output then
        CommitMatrixRawPartial(destination, result, intermediate_type);
    else CommitMatrixResult(destination, result, intermediate_type); end;
end;
func TMATMUL(destination: TileIndex, left: TileIndex, right: TileIndex)
begin
    let result = MatrixProductResult(destination, destination,
        left, right, FALSE);
    CommitMatrixResult(destination, result,
        TileOrdinaryMatrixAccumulatorType(
            _Tiles[[left]].data_type, _Tiles[[right]].data_type));
end;
func TMATMUL_BIAS(destination: TileIndex, left: TileIndex, right: TileIndex,
                  bias: TileIndex)
begin
    let intermediate_type = TileOrdinaryMatrixAccumulatorType(
        _Tiles[[left]].data_type, _Tiles[[right]].data_type);
    let product = MatrixProductResult(destination, destination,
        left, right, FALSE);
    let result = MatrixBiasResult(product, bias, intermediate_type);
    CommitMatrixResult(destination, result, intermediate_type);
end;
func TMATMUL_ACC(destination: TileIndex, accumulator: TileIndex,
                 left: TileIndex, right: TileIndex)
begin
    let result = MatrixProductResult(destination, accumulator,
        left, right, TRUE);
    CommitMatrixResult(destination, result,
        TileOrdinaryMatrixAccumulatorType(
            _Tiles[[left]].data_type, _Tiles[[right]].data_type));
end;
func TMATMUL_MX(destination: TileIndex, left: TileIndex,
                left_scale: TileIndex, right: TileIndex,
                right_scale: TileIndex)
begin
    let result = MatrixMXProductResult(destination, destination,
        left, left_scale, right, right_scale, FALSE);
    CommitMatrixResult(destination, result, TileDataType_FP32);
end;
func TMATMUL_MX_BIAS(destination: TileIndex, left: TileIndex,
                     left_scale: TileIndex, right: TileIndex,
                     right_scale: TileIndex,
                     bias: TileIndex)
begin
    let product = MatrixMXProductResult(destination, destination,
        left, left_scale, right, right_scale, FALSE);
    let result = MatrixBiasResult(product, bias, TileDataType_FP32);
    CommitMatrixResult(destination, result, TileDataType_FP32);
end;
func TMATMUL_MX_ACC(destination: TileIndex, accumulator: TileIndex,
                    left: TileIndex, left_scale: TileIndex,
                    right: TileIndex, right_scale: TileIndex)
begin
    let result = MatrixMXProductResult(destination, accumulator,
        left, left_scale, right, right_scale, TRUE);
    CommitMatrixResult(destination, result, TileDataType_FP32);
end;
func TGEMV(destination: TileIndex, left_vector: TileIndex,
           right_matrix: TileIndex)
begin
    assert _Tiles[[left_vector]].valid_rows == 1;
    let result = MatrixProductResult(destination, destination,
        left_vector, right_matrix, FALSE);
    CommitMatrixResult(destination, result,
        TileOrdinaryMatrixAccumulatorType(
            _Tiles[[left_vector]].data_type,
            _Tiles[[right_matrix]].data_type));
end;
func TGEMV_BIAS(destination: TileIndex, left_vector: TileIndex,
                right_matrix: TileIndex, bias: TileIndex)
begin
    let intermediate_type = TileOrdinaryMatrixAccumulatorType(
        _Tiles[[left_vector]].data_type,
        _Tiles[[right_matrix]].data_type);
    assert _Tiles[[left_vector]].valid_rows == 1;
    let product = MatrixProductResult(destination, destination,
        left_vector, right_matrix, FALSE);
    let result = MatrixBiasResult(product, bias, intermediate_type);
    CommitMatrixResult(destination, result, intermediate_type);
end;
func TGEMV_ACC(destination: TileIndex, accumulator: TileIndex,
               left_vector: TileIndex, right_matrix: TileIndex)
begin
    assert _Tiles[[left_vector]].valid_rows == 1;
    let result = MatrixProductResult(destination, accumulator,
        left_vector, right_matrix, TRUE);
    CommitMatrixResult(destination, result,
        TileOrdinaryMatrixAccumulatorType(
            _Tiles[[left_vector]].data_type,
            _Tiles[[right_matrix]].data_type));
end;
func TGEMV_MX(destination: TileIndex, left_vector: TileIndex,
              left_scale: TileIndex, right_matrix: TileIndex,
              right_scale: TileIndex)
begin
    assert _Tiles[[left_vector]].valid_rows == 1;
    let result = MatrixMXProductResult(destination, destination,
        left_vector, left_scale, right_matrix, right_scale, FALSE);
    CommitMatrixResult(destination, result, TileDataType_FP32);
end;

func TGEMV_MX_BIAS(destination: TileIndex, left_vector: TileIndex,
                   left_scale: TileIndex, right_matrix: TileIndex,
                   right_scale: TileIndex,
                   bias: TileIndex)
begin
    assert _Tiles[[left_vector]].valid_rows == 1;
    let product = MatrixMXProductResult(destination, destination,
        left_vector, left_scale, right_matrix, right_scale, FALSE);
    let result = MatrixBiasResult(product, bias, TileDataType_FP32);
    CommitMatrixResult(destination, result, TileDataType_FP32);
end;

func TGEMV_MX_ACC(destination: TileIndex, accumulator: TileIndex,
                  left_vector: TileIndex, left_scale: TileIndex,
                  right_matrix: TileIndex, right_scale: TileIndex)
begin
    assert _Tiles[[left_vector]].valid_rows == 1;
    let result = MatrixMXProductResult(destination, accumulator,
        left_vector, left_scale, right_matrix, right_scale, TRUE);
    CommitMatrixResult(destination, result, TileDataType_FP32);
end;
```
<!-- GENERATED-ASL-END: unit -->
