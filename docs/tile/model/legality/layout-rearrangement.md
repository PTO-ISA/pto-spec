<!-- GENERATED FROM: asl/tile/model/legality/layout-rearrangement.asl -->
# Layout Rearrangement

**Normative ASL source:** `asl/tile/model/legality/layout-rearrangement.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-LEGALITY-LAYOUT-REARRANGEMENT}

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/legality/layout-rearrangement.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-LEGALITY-LAYOUT-REARRANGEMENT","surface":"tile","classification":["model","legality","layout-rearrangement"],"depends_on":["PTO-TILE-MODEL-LEGALITY-DTYPE-LAYOUT"]}

readonly func TileOperandsLegal_TFILLPAD(
    destination: TileIndex,
    source: TileIndex,
    padding: Word) => boolean
begin
    if !TileDescriptorLegal(destination) ||
       !TileSourceContentsDefined(source) then
        return FALSE;
    end;
    let destination_tile = _Tiles[[destination]];
    let source_tile = _Tiles[[source]];
    if !TileCarrierOnlyDataTypeSupported(source_tile.data_type) &&
       !TileSourceEncodingsValid(source) then
        return FALSE;
    end;
    return destination_tile.storage_kind == TileStorage_Numeric &&
           source_tile.storage_kind == TileStorage_Numeric &&
           TileCarrierOnlyDataTypeSupported(destination_tile.data_type) &&
           destination_tile.data_type == source_tile.data_type &&
           TileLayoutShapeLegal(destination_tile) &&
           TileLayoutShapeLegal(source_tile) &&
           destination_tile.rows >= source_tile.rows &&
           destination_tile.columns >= source_tile.columns &&
           destination_tile.valid_rows >= source_tile.valid_rows &&
           destination_tile.valid_columns >= source_tile.valid_columns;
end;

readonly func TileOperandsLegal_TEXTRACT(
    destination: TileIndex,
    source: TileIndex,
    row_offset: integer {0..65535},
    column_offset: integer {0..65535}) => boolean
begin
    if !TileDescriptorLegal(destination) ||
       !TileSourceContentsDefined(source) then
        return FALSE;
    end;
    let destination_tile = _Tiles[[destination]];
    let source_tile = _Tiles[[source]];
    if !TileCarrierOnlyDataTypeSupported(source_tile.data_type) &&
       !TileSourceEncodingsValid(source) then
        return FALSE;
    end;
    return destination_tile.storage_kind == TileStorage_Numeric &&
           source_tile.storage_kind == TileStorage_Numeric &&
           TileCarrierOrMove24BaselineDataTypeSupported(
               destination_tile.data_type) &&
           destination_tile.data_type == source_tile.data_type &&
           TileLayoutShapeLegal(destination_tile) &&
           TileLayoutShapeLegal(source_tile) &&
           row_offset + destination_tile.valid_rows <=
               source_tile.valid_rows &&
           column_offset + destination_tile.valid_columns <=
               source_tile.valid_columns;
end;

readonly func TileOperandsLegal_TINSERT(
    destination: TileIndex,
    old_destination: TileIndex,
    source: TileIndex,
    row_offset: integer {0..65535},
    column_offset: integer {0..65535}) => boolean
begin
    if !TileDescriptorLegal(destination) ||
       !TileSourceContentsDefined(old_destination) ||
       !TileSourceContentsDefined(source) then
        return FALSE;
    end;
    let destination_tile = _Tiles[[destination]];
    let old_tile = _Tiles[[old_destination]];
    let source_tile = _Tiles[[source]];
    if (!TileCarrierOnlyDataTypeSupported(old_tile.data_type) &&
        !TileSourceEncodingsValid(old_destination)) ||
       (!TileCarrierOnlyDataTypeSupported(source_tile.data_type) &&
        !TileSourceEncodingsValid(source)) then
        return FALSE;
    end;
    return destination_tile.storage_kind == TileStorage_Numeric &&
           old_tile.storage_kind == TileStorage_Numeric &&
           source_tile.storage_kind == TileStorage_Numeric &&
           TileCarrierOrMove24BaselineDataTypeSupported(
               destination_tile.data_type) &&
           TileShapeAndTypeMatch(destination, old_destination) &&
           destination_tile.data_type == source_tile.data_type &&
           TileLayoutShapeLegal(destination_tile) &&
           TileLayoutShapeLegal(old_tile) &&
           TileLayoutShapeLegal(source_tile) &&
           row_offset + source_tile.valid_rows <=
               destination_tile.valid_rows &&
           column_offset + source_tile.valid_columns <=
               destination_tile.valid_columns;
end;

readonly func TileOperandsLegal_TTRANS(
    destination: TileIndex,
    source: TileIndex) => boolean
begin
    if !TileDescriptorLegal(destination) ||
       !TileSourceContentsDefined(source) then
        return FALSE;
    end;
    let destination_tile = _Tiles[[destination]];
    let source_tile = _Tiles[[source]];
    if !TileCarrierOnlyDataTypeSupported(source_tile.data_type) &&
       !TileSourceEncodingsValid(source) then
        return FALSE;
    end;
    return destination_tile.storage_kind == TileStorage_Numeric &&
           source_tile.storage_kind == TileStorage_Numeric &&
           TileCarrierOrMove24BaselineDataTypeSupported(
               destination_tile.data_type) &&
           destination_tile.valid_rows == source_tile.valid_columns &&
           destination_tile.valid_columns == source_tile.valid_rows &&
           destination_tile.data_type == source_tile.data_type &&
           TileLayoutShapeLegal(destination_tile) &&
           TileLayoutShapeLegal(source_tile);
end;

readonly func TileOperandsLegal_TCONCAT(
    destination: TileIndex,
    source_left: TileIndex,
    source_right: TileIndex) => boolean
begin
    if !TileDescriptorLegal(destination) ||
       !TileSourceContentsDefined(source_left) ||
       !TileSourceContentsDefined(source_right) ||
       _Tiles[[destination]].data_type != _Tiles[[source_left]].data_type ||
       _Tiles[[destination]].data_type != _Tiles[[source_right]].data_type then
        return FALSE;
    end;
    let destination_tile = _Tiles[[destination]];
    let left_tile = _Tiles[[source_left]];
    let right_tile = _Tiles[[source_right]];
    if !TileCarrierOnlyDataTypeSupported(left_tile.data_type) &&
       (!TileSourceEncodingsValid(source_left) ||
        !TileSourceEncodingsValid(source_right)) then
        return FALSE;
    end;
    return destination_tile.storage_kind == TileStorage_Numeric &&
           left_tile.storage_kind == TileStorage_Numeric &&
           right_tile.storage_kind == TileStorage_Numeric &&
           TileCarrierOrMove24BaselineDataTypeSupported(
               destination_tile.data_type) &&
           left_tile.valid_rows > 0 &&
           left_tile.valid_rows == right_tile.valid_rows &&
           destination_tile.valid_rows == left_tile.valid_rows &&
           destination_tile.valid_columns ==
               left_tile.valid_columns + right_tile.valid_columns &&
           TileLayoutShapeLegal(destination_tile) &&
           TileLayoutShapeLegal(left_tile) &&
           TileLayoutShapeLegal(right_tile);
end;
```
<!-- GENERATED-ASL-END: unit -->
