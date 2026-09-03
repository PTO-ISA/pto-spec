<!-- GENERATED FROM: asl/tile/model/legality/reduction-and-expansion.asl -->
# Reduction And Expansion

**Normative ASL source:** `asl/tile/model/legality/reduction-and-expansion.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-LEGALITY-REDUCTION-AND-EXPANSION}

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/legality/reduction-and-expansion.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-LEGALITY-REDUCTION-AND-EXPANSION","surface":"tile","classification":["model","legality","reduction-and-expansion"],"depends_on":["PTO-TILE-MODEL-LEGALITY-OPERAND-SCHEMA"]}

pure func TileReductionAndExpansionLayoutSupported(layout: TileLayout)
    => boolean
begin
    return layout == TileLayout_RowMajor ||
           layout == TileLayout_CUBE_M16 ||
           layout == TileLayout_CUBE_M32;
end;

pure func TileReductionAndExpansionRowLimitLegal(
    layout: TileLayout, valid_rows: integer {0..65535}) => boolean
begin
    if layout == TileLayout_CUBE_M16 then return valid_rows <= 16; end;
    if layout == TileLayout_CUBE_M32 then return valid_rows <= 32; end;
    return TileReductionAndExpansionLayoutSupported(layout);
end;

readonly func TileReductionAndExpansionDescriptorLegal(index: TileIndex)
    => boolean
begin
    let tile = _Tiles[[index]];
    if !TileReductionAndExpansionLayoutSupported(tile.layout) then
        return FALSE;
    end;
    if tile.layout == TileLayout_RowMajor then
        return TileDescriptorLegal(index);
    end;
    return TileCubeDescriptorLegal(tile);
end;

readonly func TileReductionAndExpansionSourceContentsDefined(index: TileIndex)
    => boolean
begin
    let tile = _Tiles[[index]];
    if !TileReductionAndExpansionDescriptorLegal(index) ||
       tile.storage_kind != TileStorage_Numeric ||
       !tile.contents_defined then
        return FALSE;
    end;
    return TRUE;
end;

readonly func TileReductionAndExpansionSourceLegal(index: TileIndex)
    => boolean
begin
    let tile = _Tiles[[index]];
    if !TileReductionAndExpansionSourceContentsDefined(index) then
        return FALSE;
    end;
    if tile.layout == TileLayout_RowMajor then
        return TileSourceEncodingsValid(index);
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

readonly func TileReductionAndExpansionLogicalShapeMatch(
    left: TileIndex, right: TileIndex) => boolean
begin
    if !TileReductionAndExpansionDescriptorLegal(left) ||
       !TileReductionAndExpansionDescriptorLegal(right) then
        return FALSE;
    end;
    let left_tile = _Tiles[[left]];
    let right_tile = _Tiles[[right]];
    return left_tile.valid_rows == right_tile.valid_rows &&
           left_tile.valid_columns == right_tile.valid_columns &&
           left_tile.layout == right_tile.layout;
end;

readonly func TileReductionSourceCapacityLegal(index: TileIndex) => boolean
begin
    return _Tiles[[index]].capacity_bytes <= 2048;
end;

readonly func TileOperandsLegal_ExecuteTileFillScalar(
    destination: TileIndex, scalar: Word) => boolean
begin
    return TileReductionAndExpansionDescriptorLegal(destination) &&
           TileReductionAndExpansionRowLimitLegal(
               _Tiles[[destination]].layout,
               _Tiles[[destination]].valid_rows) &&
           _Tiles[[destination]].storage_kind == TileStorage_Numeric &&
           TileFillPadDataTypeSupported(
               _Tiles[[destination]].data_type);
end;

readonly func TileOperandsLegal_ExecuteTileReduction(
    operation: TileReductionOperation,
    axis: TileAxis,
    destination: TileIndex,
    source: TileIndex) => boolean
begin
    if destination == source ||
       !TileReductionAndExpansionDescriptorLegal(destination) ||
       !TileReductionAndExpansionSourceLegal(source) then
        return FALSE;
    end;

    let destination_tile = _Tiles[[destination]];
    let source_tile = _Tiles[[source]];
    let index_reduction =
        operation == TileReduction_ARGMIN ||
        operation == TileReduction_ARGMAX;
    let source_type_legal =
        if index_reduction then
            TileArgReductionSourceDataTypeSupported(source_tile.data_type)
        else
            TileVecArithmeticDataTypeSupported(source_tile.data_type);
    if destination_tile.storage_kind != TileStorage_Numeric ||
       source_tile.storage_kind != TileStorage_Numeric ||
       destination_tile.layout != source_tile.layout ||
       source_tile.valid_rows == 0 ||
       source_tile.valid_columns == 0 ||
       !TileReductionAndExpansionRowLimitLegal(
           source_tile.layout, source_tile.valid_rows) ||
       !TileReductionAndExpansionRowLimitLegal(
           destination_tile.layout, destination_tile.valid_rows) ||
       !source_type_legal ||
       !TileReductionSourceCapacityLegal(source) then
        return FALSE;
    end;

    if index_reduction then
        if destination_tile.data_type != TileDataType_U32 then
            return FALSE;
        end;
    elsif destination_tile.data_type != source_tile.data_type then
        return FALSE;
    end;

    if axis == TileAxis_Row then
        return destination_tile.valid_rows == source_tile.valid_rows &&
               destination_tile.valid_columns == 1;
    end;
    return destination_tile.valid_rows == 1 &&
           destination_tile.valid_columns == source_tile.valid_columns;
end;

pure func TileExpandExpdifTypePairLegal(
    source_type: TileDataType,
    destination_type: TileDataType) => boolean
begin
    return (source_type == TileDataType_FP16 &&
            (destination_type == TileDataType_FP16 ||
             destination_type == TileDataType_FP32)) ||
           (source_type == TileDataType_BF16 &&
            (destination_type == TileDataType_BF16 ||
             destination_type == TileDataType_FP32)) ||
           (source_type == TileDataType_FP32 &&
            destination_type == TileDataType_FP32);
end;

readonly func TileOperandsLegal_ExecuteTileExpand(
    operation: TileExpandOperation,
    axis: TileAxis,
    destination: TileIndex,
    source: TileIndex,
    broadcast_source: TileIndex) => boolean
begin
    let copy = operation == TileExpand_COPY;
    if !TileReductionAndExpansionDescriptorLegal(destination) ||
       !(if copy then
             TileReductionAndExpansionSourceContentsDefined(source) &&
             TileReductionAndExpansionSourceContentsDefined(broadcast_source)
         else
             TileReductionAndExpansionSourceLegal(source) &&
             TileReductionAndExpansionSourceLegal(broadcast_source)) then
        return FALSE;
    end;

    let destination_tile = _Tiles[[destination]];
    let source_tile = _Tiles[[source]];
    let broadcast_tile = _Tiles[[broadcast_source]];
    let expdif = operation == TileExpand_EXPDIF;
    let operation_type_legal =
        if operation == TileExpand_COPY then
            TileVecArithmeticDataTypeSupported(destination_tile.data_type)
        else if expdif then
            TileExpandExpdifTypePairLegal(
                source_tile.data_type, destination_tile.data_type)
        else
            TileVecArithmeticDataTypeSupported(destination_tile.data_type);
    if destination_tile.storage_kind != TileStorage_Numeric ||
       destination_tile.valid_rows == 0 ||
       destination_tile.valid_columns == 0 ||
       !TileReductionAndExpansionRowLimitLegal(
           destination_tile.layout, destination_tile.valid_rows) ||
       !operation_type_legal ||
       broadcast_tile.storage_kind != TileStorage_Numeric ||
       broadcast_tile.data_type !=
           (if expdif then source_tile.data_type
            else destination_tile.data_type) ||
       broadcast_tile.layout != destination_tile.layout ||
       !TileReductionAndExpansionRowLimitLegal(
           broadcast_tile.layout, broadcast_tile.valid_rows) then
        return FALSE;
    end;

    if operation == TileExpand_COPY then
        if source != broadcast_source then
            return FALSE;
        end;
    elsif !TileReductionAndExpansionLogicalShapeMatch(destination, source) ||
          source_tile.storage_kind != TileStorage_Numeric ||
          (!expdif && source_tile.data_type != destination_tile.data_type) ||
          !TileReductionAndExpansionRowLimitLegal(
              source_tile.layout, source_tile.valid_rows) then
        return FALSE;
    end;

    let broadcast_shape_legal =
        if axis == TileAxis_Row then
            broadcast_tile.valid_rows == destination_tile.valid_rows &&
            broadcast_tile.valid_columns == 1
        else
            broadcast_tile.valid_rows == 1 &&
            broadcast_tile.valid_columns == destination_tile.valid_columns;
    if !broadcast_shape_legal then
        return FALSE;
    end;

    if operation == TileExpand_DIV &&
       TileDataTypeIsInteger(destination_tile.data_type) then
        return TileBroadcastPayloadNonzero(
            axis, source, broadcast_source);
    end;
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: unit -->
