<!-- GENERATED FROM: asl/tile/model/legality/predicate-carriers.asl -->
# Predicate Carriers

**Normative ASL source:** `asl/tile/model/legality/predicate-carriers.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-LEGALITY-PREDICATE-CARRIERS}

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/legality/predicate-carriers.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-LEGALITY-PREDICATE-CARRIERS","surface":"tile","classification":["model","legality","predicate-carriers"],"depends_on":["PTO-TILE-MODEL-LEGALITY-DESCRIPTOR-SHAPE"]}

pure func TileCubePredicateDataTypeSupported(
    data_type: TileDataType) => boolean
begin
    return data_type == TileDataType_FP32 ||
           data_type == TileDataType_TF32 ||
           data_type == TileDataType_HF32 ||
           data_type == TileDataType_FP16 ||
           data_type == TileDataType_BF16 ||
           data_type == TileDataType_E4M3 ||
           data_type == TileDataType_E5M2 ||
           data_type == TileDataType_S32 ||
           data_type == TileDataType_S16 ||
           data_type == TileDataType_S8 ||
           data_type == TileDataType_U32 ||
           data_type == TileDataType_U16 ||
           data_type == TileDataType_U8;
end;

pure func TileCubePredicateGPRDataTypeSupported(
    data_type: TileDataType) => boolean
begin
    return TileElementBits(data_type) == 32 ||
           TileElementBits(data_type) == 16 ||
           data_type == TileDataType_U8;
end;

pure func TileCubePredicateFieldCount(
    data_type: TileDataType, layout: TileLayout) => integer {1..8}
begin
    assert TileCubePredicateGPRDataTypeSupported(data_type);
    if layout == TileLayout_CUBE_M32 then return 2; end;
    assert layout == TileLayout_CUBE_M16;
    return if TileElementBits(data_type) == 32 then 2 else 4;
end;

pure func TileCubePredicateRowBits(
    layout: TileLayout) => integer {16,32}
begin
    return if layout == TileLayout_CUBE_M32 then 32 else 16;
end;

readonly func TileCubePredicateGPRShapeLegal(index: TileIndex) => boolean
begin
    let tile = _Tiles[[index]];
    if !TileCubeDescriptorLegal(tile) ||
       !TileCubePredicateGPRDataTypeSupported(tile.data_type) then
        return FALSE;
    end;
    let words = if tile.data_type == TileDataType_U8 then 2 else 1;
    return tile.valid_rows <= TileCubePredicateRowBits(tile.layout) &&
           tile.valid_columns <=
               TileCubePredicateFieldCount(tile.data_type, tile.layout) * words;
end;

readonly func TileCubeNumericContentsDefined(index: TileIndex) => boolean
begin
    let tile = _Tiles[[index]];
    return TileCubeDescriptorLegal(tile) &&
           tile.storage_kind == TileStorage_Numeric &&
           tile.contents_defined &&
           TileCubePredicateDataTypeSupported(tile.data_type);
end;

readonly func TileCubeNumericSourceLegal(index: TileIndex) => boolean
begin
    let tile = _Tiles[[index]];
    if !TileCubeNumericContentsDefined(index) then
        return FALSE;
    end;
    for row = 0 to tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to tile.valid_columns - 1 looplimit 65536 do
            let element = TileLogicalLinearIndex(
                tile, row as integer {0..65535},
                column as integer {0..65535});
            if !TileNumericEncodingValid(
                   tile.data_type,
                   TileReadLogicalElement(tile, element)) then
                return FALSE;
            end;
        end;
    end;
    return TRUE;
end;

readonly func TileCubeNumericShapeAndTypeMatch(
    left: TileIndex, right: TileIndex) => boolean
begin
    let left_tile = _Tiles[[left]];
    let right_tile = _Tiles[[right]];
    return TileCubeDescriptorLegal(left_tile) &&
           TileCubeDescriptorLegal(right_tile) &&
           left_tile.storage_kind == TileStorage_Numeric &&
           right_tile.storage_kind == TileStorage_Numeric &&
           left_tile.rows == right_tile.rows &&
           left_tile.columns == right_tile.columns &&
           left_tile.valid_rows == right_tile.valid_rows &&
           left_tile.valid_columns == right_tile.valid_columns &&
           left_tile.data_type == right_tile.data_type &&
           left_tile.layout == right_tile.layout;
end;

readonly func TilePredicateCellDescriptorLegal(index: TileIndex) => boolean
begin
    let tile = _Tiles[[index]];
    return tile.allocated &&
           tile.storage_kind == TileStorage_PredicateCell &&
           tile.data_type == TileDataType_U8 &&
           tile.location == TileLocation_Matrix &&
           TileCubePredicateDataTypeSupported(tile.predicate_basis_type) &&
           TileCubeDescriptorShapeLegal(
               tile.capacity_bytes, tile.valid_rows, tile.valid_columns,
               tile.data_type, tile.layout) &&
           tile.rows == TileCubeStorageRows(
               tile.layout, tile.valid_rows, tile.data_type) &&
           tile.columns == TileCubeStorageColumns(
               tile.layout, tile.valid_columns, tile.data_type) &&
           tile.cube_k_repeat == TileCubeKRepeat(
               tile.layout, tile.valid_rows, tile.valid_columns,
               tile.data_type) &&
           tile.cube_n_repeat == TileCubeNRepeat(
               tile.layout, tile.valid_rows, tile.valid_columns,
               tile.data_type) &&
           tile.cube_cell_count == TileCubeCellCount(
               tile.layout, tile.valid_rows, tile.valid_columns,
               tile.data_type) &&
           tile.cube_storage_bytes == TileCubeRequiredBytes(
               tile.layout, tile.valid_rows, tile.valid_columns,
               tile.data_type) &&
           tile.cube_storage_bytes <= tile.capacity_bytes;
end;

readonly func TilePredicateCellShapeMatchesNumeric(
    predicate: TileIndex, numeric: TileIndex) => boolean
begin
    let mask = _Tiles[[predicate]];
    let source = _Tiles[[numeric]];
    return TilePredicateCellDescriptorLegal(predicate) &&
           TileCubeDescriptorLegal(source) &&
           mask.predicate_basis_type == source.data_type &&
           mask.valid_rows == source.valid_rows &&
           mask.valid_columns == source.valid_columns &&
           mask.layout == source.layout;
end;

readonly func TilePredicateCellValuesLegal(index: TileIndex) => boolean
begin
    let tile = _Tiles[[index]];
    if !TilePredicateCellDescriptorLegal(index) ||
       !tile.contents_defined then return FALSE; end;
    for row = 0 to tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to tile.valid_columns - 1 looplimit 65536 do
            let element = TileLogicalLinearIndex(
                tile, row as integer {0..65535},
                column as integer {0..65535});
            let value = TileReadLogicalElement(tile, element)[7:0];
            if value != '00000000' && value != '00000001' then
                return FALSE;
            end;
        end;
    end;
    return TRUE;
end;

func PredicateCellWithPadding(
    tile: TileInfo, pad_value: TilePadValue) => TileInfo
begin
    var result = tile;
    assert result.storage_kind == TileStorage_PredicateCell;
    let padding_defined = pad_value != TilePad_Null;
    let padding = if pad_value == TilePad_Max then
        Zeros{PTO_XLEN} + 1 else Zeros{PTO_XLEN};
    for row = 0 to result.rows - 1 looplimit 65536 do
        for column = 0 to result.columns - 1 looplimit 65536 do
            if row >= result.valid_rows || column >= result.valid_columns then
                let element = TileLogicalLinearIndex(
                    result, row as integer {0..65535},
                    column as integer {0..65535});
                result = TileInfoWithLogicalElementAndDefined(
                    result, element, padding, padding_defined);
            end;
        end;
    end;
    return result;
end;
```
<!-- GENERATED-ASL-END: unit -->
