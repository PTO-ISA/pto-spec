<!-- GENERATED FROM: asl/tile/model/legality/sorting.asl -->
# Sorting

**Normative ASL source:** `asl/tile/model/legality/sorting.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-LEGALITY-SORTING}

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/legality/sorting.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-LEGALITY-SORTING","surface":"tile","classification":["model","legality","sorting"],"depends_on":["PTO-TILE-MODEL-LEGALITY-OPERAND-SCHEMA","PTO-TILE-MODEL-ORDERING-SORTING"]}

readonly func TileOperandsLegal_TSORT(
    destination: TileIndex,
    destination_indices: TileIndex,
    source: TileIndex,
    sort_width: integer {1..64},
    descending: boolean) => boolean
begin
    if destination == destination_indices ||
       destination == source ||
       destination_indices == source then
        return FALSE;
    end;
    if !TileDescriptorLegal(destination) ||
       !TileDescriptorLegal(destination_indices) ||
       !TileDescriptorLegal(source) then
        return FALSE;
    end;

    let value_type = _Tiles[[source]].data_type;
    if !TileSortDataTypeSupported(value_type) ||
       _Tiles[[destination]].data_type != value_type ||
       _Tiles[[destination_indices]].data_type != TileDataType_U32 then
        return FALSE;
    end;
    if _Tiles[[source]].layout != TileLayout_RowMajor ||
       _Tiles[[destination]].layout != TileLayout_RowMajor ||
       _Tiles[[destination_indices]].layout != TileLayout_RowMajor then
        return FALSE;
    end;
    if _Tiles[[source]].valid_rows == 0 ||
       _Tiles[[source]].valid_columns == 0 ||
       !TileLogicalShapeMatch(destination, source) ||
       !TileLogicalShapeMatch(destination_indices, source) then
        return FALSE;
    end;
    return TileSortSourceValuesLegal(source);
end;

readonly func TileOperandsLegal_TMRGSORT(
    destination: TileIndex,
    source_left: TileIndex,
    source_right: TileIndex,
    descending: boolean) => boolean
begin
    if destination == source_left || destination == source_right then
        return FALSE;
    end;
    if !TileDescriptorLegal(destination) ||
       !TileDescriptorLegal(source_left) ||
       !TileDescriptorLegal(source_right) then
        return FALSE;
    end;

    let left_tile = _Tiles[[source_left]];
    let right_tile = _Tiles[[source_right]];
    let result = _Tiles[[destination]];
    if !TileSortDataTypeSupported(left_tile.data_type) ||
       right_tile.data_type != left_tile.data_type ||
       result.data_type != left_tile.data_type then
        return FALSE;
    end;
    if left_tile.layout != TileLayout_RowMajor ||
       right_tile.layout != TileLayout_RowMajor ||
       result.layout != TileLayout_RowMajor then
        return FALSE;
    end;
    if left_tile.valid_rows != 1 ||
       right_tile.valid_rows != 1 ||
       result.valid_rows != 1 ||
       left_tile.valid_columns == 0 ||
       right_tile.valid_columns == 0 ||
       result.valid_columns !=
           left_tile.valid_columns + right_tile.valid_columns then
        return FALSE;
    end;
    if !TileSortSourceValuesLegal(source_left) ||
       !TileSortSourceValuesLegal(source_right) then
        return FALSE;
    end;
    return TileSortSequenceOrdered(source_left, descending) &&
           TileSortSequenceOrdered(source_right, descending);
end;
```
<!-- GENERATED-ASL-END: unit -->

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
