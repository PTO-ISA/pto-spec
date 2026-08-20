<!-- GENERATED FROM: asl/tile/model/legality/matrix-operands.asl -->
# Matrix Operands

**Normative ASL source:** `asl/tile/model/legality/matrix-operands.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-LEGALITY-MATRIX-OPERANDS}

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/legality/matrix-operands.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-LEGALITY-MATRIX-OPERANDS","surface":"tile","classification":["model","legality","matrix-operands"],"depends_on":["PTO-TILE-MODEL-LEGALITY-MATRIX-CUBE-PRIMARY","PTO-TILE-MODEL-LEGALITY-MATRIX-POSTPROCESS"]}
// PTO-REQ-CUBE-OPERANDS-001: every Local matrix source descriptor is checked
// in stream order before any Local or Shared payload is snapshotted.

readonly func TileMatrixLocalOperandSchemaLegal(
    source: TileIndex,
    valid_rows: integer {1..65535},
    valid_columns: integer {1..65535},
    data_type: TileDataType) => boolean
begin
    let tile = _Tiles[[source]];
    return TileSourceContentsDefined(source) &&
           IsNonzeroPowerOfTwo(tile.rows) &&
           IsNonzeroPowerOfTwo(tile.columns) &&
           tile.valid_rows == valid_rows &&
           tile.valid_columns == valid_columns &&
           tile.data_type == data_type &&
           tile.layout == TileLayout_RowMajor &&
           tile.location == TileLocation_Matrix;
end;

readonly func TileMatrixLocalScaleSchemaLegal(
    source: TileIndex,
    valid_rows: integer {1..65535},
    valid_columns: integer {1..65535}) => boolean
begin
    let tile = _Tiles[[source]];
    return TileSourceContentsDefined(source) &&
           tile.valid_rows == valid_rows &&
           tile.valid_columns == valid_columns &&
           tile.data_type == TileDataType_E8M0 &&
           tile.layout == TileLayout_RowMajor;
end;

readonly func TileMatrixLocalBiasSchemaLegal(
    source: TileIndex,
    n: integer {1..65535},
    accumulator_type: TileDataType) => boolean
begin
    let tile = _Tiles[[source]];
    return TileSourceContentsDefined(source) &&
           tile.valid_rows == 1 &&
           tile.valid_columns == n &&
           tile.data_type == accumulator_type &&
           tile.layout == TileLayout_RowMajor;
end;

readonly func TileMatrixInfoAccumulatorSchemaLegal(
    accumulator: TileIndex,
    m: integer {1..65535},
    n: integer {1..65535},
    result_type: TileDataType,
    destination_capacity: integer {0..262144}) => boolean
begin
    let tile = _Tiles[[accumulator]];
    let output_converted =
        UInt(_BundleFixedPointAttributes.pre_quant_mode) != 0;
    return TileSourceContentsDefined(accumulator) &&
           TileInfoDescriptorLegal(tile) &&
           tile.valid_rows == m &&
           tile.valid_columns == n &&
           tile.data_type == result_type &&
           tile.layout == TileLayout_RowMajor &&
           tile.location == TileLocation_Matrix &&
           (output_converted ||
            tile.capacity_bytes == destination_capacity);
end;

readonly func BundleMatrixLocalMathematicalSourcesLegal(
    function: integer {0..31},
    left_type: TileDataType,
    right_type: TileDataType,
    m: integer {1..65535},
    n: integer {1..65535},
    k: integer {1..65535},
    shared_count: integer {0..4},
    accumulator_type: TileDataType,
    destination_capacity: integer {0..262144}) => boolean
begin
    let left_scale_present = TileMatrixFunctionUsesMX(function) &&
        TileMXInputTypeNeedsScale(left_type);
    let right_scale_present = TileMatrixFunctionUsesMX(function) &&
        TileMXInputTypeNeedsScale(right_type);
    let scale_blocks = ((k + 31) DIVRM 32)
        as integer {1..2048};
    var ordinal: integer {0..5} = 0;
    let right_group = TileMatrixRightGroupSourceCount(
        function, right_type);
    let local_left_present = shared_count == 0 ||
        shared_count == right_group;
    let left_ordinal = if TileMatrixFunctionUsesAccumulator(function)
        then 1 else 0;
    let local_m_layout = if local_left_present then
        _Tiles[[BundleMatrixSourceAt(
            left_ordinal as integer {0..7})]].layout
        else if TileMatrixFunctionUsesAccumulator(function) then
            _Tiles[[BundleMatrixSourceAt(0)]].layout
        else TileLayout_RowMajor;

    if TileMatrixFunctionUsesAccumulator(function) then
        let accumulator = BundleMatrixSourceAt(
            ordinal as integer {0..7});
        let accumulator_legal = TileMatrixLocalCubeAccumulatorSchemaLegal(
            accumulator, m, n, accumulator_type,
            local_m_layout, destination_capacity);
        if !accumulator_legal then
            return FALSE;
        end;
        ordinal = (ordinal + 1) as integer {0..5};
    end;

    if shared_count == 0 || shared_count == right_group then
        let left = BundleMatrixSourceAt(
            ordinal as integer {0..7});
        let left_legal = TileMatrixLocalMOperandSchemaLegal(
            left, m, k, left_type);
        if !left_legal then
            return FALSE;
        end;
        ordinal = (ordinal + 1) as integer {0..5};
        if left_scale_present then
            let left_scale = BundleMatrixSourceAt(
                ordinal as integer {0..7});
            if !TileMatrixLocalScaleSchemaLegal(
                   left_scale, m, scale_blocks) then
                return FALSE;
            end;
            ordinal = (ordinal + 1) as integer {0..5};
        end;
    end;

    if shared_count == 0 then
        let right = BundleMatrixSourceAt(
            ordinal as integer {0..7});
        let right_legal = TileMatrixLocalNOperandSchemaLegal(
            right, k, n, right_type);
        if !right_legal then
            return FALSE;
        end;
        ordinal = (ordinal + 1) as integer {0..5};
        if right_scale_present then
            let right_scale = BundleMatrixSourceAt(
                ordinal as integer {0..7});
            if !TileMatrixLocalScaleSchemaLegal(
                   right_scale, scale_blocks, n) then
                return FALSE;
            end;
            ordinal = (ordinal + 1) as integer {0..5};
        end;
    end;

    if TileMatrixFunctionUsesBias(function) then
        let bias = BundleMatrixSourceAt(
            ordinal as integer {0..7});
        if !TileMatrixLocalBiasSchemaLegal(
               bias, n, accumulator_type) then
            return FALSE;
        end;
    end;
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: unit -->

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
