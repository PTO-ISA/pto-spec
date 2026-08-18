<!-- GENERATED FROM: asl/tile/model/ordering/sorting.asl -->
# Sorting

**Normative ASL source:** `asl/tile/model/ordering/sorting.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-ORDERING-SORTING}

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/ordering/sorting.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-ORDERING-SORTING","surface":"tile","classification":["model","ordering","sorting"],"depends_on":["PTO-TILE-MODEL-EXECUTION-COMPARISON"]}

pure func TileSortDataTypeSupported(
    data_type: TileDataType) => boolean
begin
    return TileF3DataTypeSupported(data_type);
end;

pure func TileSortValueIsSignalingNaN(
    data_type: TileDataType,
    value: Word) => boolean
begin
    return TileNumericValueClass(data_type, value) ==
        NumericValue_SignalingNaN;
end;

pure func TileSortLeftBefore(
    left: Word,
    right: Word,
    descending: boolean,
    data_type: TileDataType) => boolean
begin
    let left_class = TileNumericValueClass(data_type, left);
    let right_class = TileNumericValueClass(data_type, right);
    let left_nan = NumericValueClassIsNaN(left_class);
    let right_nan = NumericValueClassIsNaN(right_class);

    // Every numeric value precedes every quiet NaN in both directions.
    // Two NaNs retain their incoming order.
    if left_nan then
        return right_nan;
    elsif right_nan then
        return TRUE;
    end;

    let both_zero =
        NumericValueClassIsZero(left_class) &&
        NumericValueClassIsZero(right_class);
    if both_zero || left == right then
        return TRUE;
    end;

    let left_key = TileFloatingOrderKey(data_type, left);
    let right_key = TileFloatingOrderKey(data_type, right);
    if descending then
        return UInt(left_key) > UInt(right_key);
    end;
    return UInt(left_key) < UInt(right_key);
end;

readonly func TileSortSourceValuesLegal(
    source: TileIndex) => boolean
begin
    return TileSourceContentsDefined(source) &&
           TileSourceEncodingsValid(source);
end;

readonly func TileSortSourceHasSignalingNaN(
    source: TileIndex) => boolean
begin
    let source_tile = _Tiles[[source]];
    for row = 0 to source_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to source_tile.valid_columns - 1 looplimit 65536 do
            let element = TileLinearIndex(
                source_tile,
                row as integer {0..65535},
                column as integer {0..65535});
            if TileSortValueIsSignalingNaN(
                   source_tile.data_type,
                   source_tile.payload[[element]]) then
                return TRUE;
            end;
        end;
    end;
    return FALSE;
end;

readonly func TileSortSequenceOrdered(
    source: TileIndex,
    descending: boolean) => boolean
begin
    let source_tile = _Tiles[[source]];
    if source_tile.valid_columns <= 1 then
        return TRUE;
    end;

    for column = 0 to source_tile.valid_columns - 2 looplimit 65536 do
        let left_element = TileLinearIndex(
            source_tile,
            0,
            column as integer {0..65535});
        let right_element = TileLinearIndex(
            source_tile,
            0,
            (column + 1) as integer {0..65535});
        if !TileSortLeftBefore(
               source_tile.payload[[left_element]],
               source_tile.payload[[right_element]],
               descending,
               source_tile.data_type) then
            return FALSE;
        end;
    end;
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: unit -->

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
