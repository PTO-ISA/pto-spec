<!-- GENERATED FROM: asl/tile/model/execution/matrix-scale.asl -->
# Matrix Scale

**Normative ASL source:** `asl/tile/model/execution/matrix-scale.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-EXECUTION-MATRIX-SCALE}

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/execution/matrix-scale.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-EXECUTION-MATRIX-SCALE","surface":"tile","classification":["model","execution","matrix-scale"],"depends_on":["PTO-TILE-MODEL-LEGALITY-MATRIX-OPERANDS"]}

impdef func TileProfileMatrixCScale(value: Word, exponent: bits(8)) => Word
begin
    return value;
end;

func MatrixInitialAccumulatorValue(
    accumulator: TileInfo,
    accumulate: boolean,
    row: integer {0..65535},
    column: integer {0..65535},
    c_scale: TileIndex,
    c_scale_present: boolean) => Word
begin
    if !accumulate then return Zeros{PTO_XLEN}; end;
    let accumulator_element = TileStorageIndex(accumulator, row, column);
    let value = accumulator.payload[[accumulator_element]];
    if !c_scale_present then return value; end;
    let scale_element = TileStorageIndex(_Tiles[[c_scale]], row, 0);
    return TileProfileMatrixCScale(
        value, _Tiles[[c_scale]].payload[[scale_element]][7:0]);
end;

readonly func MatrixLeftScaleElement(
    scale: TileInfo,
    primary_type: TileDataType,
    row: integer {0..65535},
    inner: integer {0..65535}) => ModelTileElementIndex
begin
    let group = (inner DIVRM TileMXScaleGroupSize(primary_type))
        as integer {0..65535};
    return TileStorageIndex(scale, row, group);
end;

readonly func MatrixRightScaleElement(
    scale: TileInfo,
    primary_type: TileDataType,
    column: integer {0..65535},
    inner: integer {0..65535}) => ModelTileElementIndex
begin
    let group = (inner DIVRM TileMXScaleGroupSize(primary_type))
        as integer {0..65535};
    if scale.layout == TileLayout_CUBE_M32 then
        return TileStorageIndex(scale, column, group);
    end;
    return TileStorageIndex(scale, group, column);
end;
```
<!-- GENERATED-ASL-END: unit -->

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
