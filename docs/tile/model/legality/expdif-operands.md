<!-- GENERATED FROM: asl/tile/model/legality/expdif-operands.asl -->
# Expdif Operands

**Normative ASL source:** `asl/tile/model/legality/expdif-operands.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-LEGALITY-EXPDIF-OPERANDS}

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/legality/expdif-operands.asl -->
```asl
// PTO-UNIT: {"classification":["model","legality","expdif-operands"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-DESCRIPTOR-LEGALITY","PTO-BLOCK-MODEL-STATE-CONTROL-STATE","PTO-TILE-MODEL-LEGALITY-DTYPE-LAYOUT","PTO-TILE-MODEL-LEGALITY-OPERAND-SCHEMA"],"id":"PTO-TILE-MODEL-LEGALITY-EXPDIF-OPERANDS","surface":"tile"}
readonly func TileExpdifSourceOperationType(source0: TileIndex)
    => (boolean, TileDataType)
begin
    if BundleTileOperationSelected() then
        if !_BundleOperation.data_type_valid then
            return (FALSE, TileDataType_FP64);
        end;
        return (
            TRUE,
            TileDataTypeFromEncoding(
                CurrentBundleTileOperationDataTypeCode()
                    as TileDataTypeEncoding));
    end;
    return (TRUE, _Tiles[[source0]].data_type);
end;

readonly func TileExpdifBundleGeometryMatches(index: TileIndex)
    => boolean
begin
    if !BundleTileOperationSelected() then return TRUE; end;
    let valid_columns_raw = UInt(_BundleDimensions[[0]]);
    let valid_rows_raw = if _BundleDimensionPresent[[1]] then
        UInt(_BundleDimensions[[1]]) else 1;
    let columns_raw = if _BundleDimensionPresent[[2]] then
        UInt(_BundleDimensions[[2]]) else valid_columns_raw;
    if valid_columns_raw < 1 || valid_columns_raw > 65535 ||
       valid_rows_raw < 1 || valid_rows_raw > 65535 ||
       columns_raw < 1 || columns_raw > 65535 then
        return FALSE;
    end;
    let valid_columns = valid_columns_raw as integer {1..65535};
    let valid_rows = valid_rows_raw as integer {1..65535};
    let columns = columns_raw as integer {1..65535};
    let tile = _Tiles[[index]];
    let selected_layout = CurrentBundleTileLayout();
    let expected_columns = if TileLayoutIsCube(selected_layout) then
        TileCubeStorageColumns(selected_layout, columns, tile.data_type)
    else
        columns;
    return tile.layout == selected_layout &&
           tile.valid_rows == valid_rows &&
           tile.valid_columns == valid_columns &&
           tile.columns == expected_columns;
end;

readonly func TileExpdifLogicalShapeMatch(
    left: TileIndex, right: TileIndex) => boolean
begin
    return _Tiles[[left]].valid_rows == _Tiles[[right]].valid_rows &&
           _Tiles[[left]].valid_columns == _Tiles[[right]].valid_columns &&
           _Tiles[[left]].layout == _Tiles[[right]].layout;
end;

readonly func TileExpdifSourcesLegal(
    source0: TileIndex, source1: TileIndex) => boolean
begin
    let (operation_type_valid, operation_type) =
        TileExpdifSourceOperationType(source0);
    if !operation_type_valid then return FALSE; end;
    let selected_layout = if BundleTileOperationSelected() then
        CurrentBundleTileLayout()
    else
        _Tiles[[source0]].layout;
    if !TileElementwiseLayoutSupported(selected_layout) ||
       _Tiles[[source0]].storage_kind != TileStorage_Numeric ||
       _Tiles[[source1]].storage_kind != TileStorage_Numeric ||
       _Tiles[[source0]].layout != selected_layout ||
       _Tiles[[source1]].layout != selected_layout ||
       !TileExpdifLogicalShapeMatch(source0, source1) ||
       !TileElementwiseDescriptorLegal(source0) ||
       !TileElementwiseDescriptorLegal(source1) ||
       !TileExpdifBundleGeometryMatches(source0) ||
       !TileExpdifBundleGeometryMatches(source1) ||
       !TileElementwiseSourceEncodingsValidAs(source0, operation_type) ||
       !TileElementwiseSourceEncodingsValidAs(source1, operation_type) then
        return FALSE;
    end;
    return TRUE;
end;

readonly func TileOperandsLegal_ExecuteTileExpdif(
    destination: TileIndex,
    source0: TileIndex,
    source1: TileIndex) => boolean
begin
    let (operation_type_valid, operation_type) =
        TileExpdifSourceOperationType(source0);
    let destination_tile = _Tiles[[destination]];
    let selected_layout = if BundleTileOperationSelected() then
        CurrentBundleTileLayout()
    else
        _Tiles[[source0]].layout;
    if !operation_type_valid ||
       !TileExpdifTypePairLegal(operation_type,
           destination_tile.data_type) ||
       !TileExpdifSourcesLegal(source0, source1) ||
       destination_tile.storage_kind != TileStorage_Numeric ||
       destination_tile.layout != selected_layout ||
       !TileElementwiseDescriptorLegal(destination) ||
       !TileExpdifBundleGeometryMatches(destination) ||
       !TileExpdifLogicalShapeMatch(destination, source0) then
        return FALSE;
    end;
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: unit -->
