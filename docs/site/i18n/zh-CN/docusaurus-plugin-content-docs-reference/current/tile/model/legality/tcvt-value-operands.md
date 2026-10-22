<!-- GENERATED FROM: asl/tile/model/legality/tcvt-value-operands.asl -->
# Tcvt Value Operands

**Normative ASL source:** `asl/tile/model/legality/tcvt-value-operands.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-LEGALITY-TCVT-VALUE-OPERANDS}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/legality/tcvt-value-operands.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-LEGALITY-TCVT-VALUE-OPERANDS","surface":"tile","classification":["model","legality","tcvt-value-operands"],"depends_on":["PTO-TILE-MODEL-LEGALITY-OPERAND-SCHEMA","PTO-TILE-MODEL-STATE-TYPES"]}

readonly func TileOperandsLegal_TCVTToValue(
    destination: TileOutputValueTarget, source: TileIndex,
    control: NumericExecutionControl) => boolean
begin
    let destination_tile = destination.value;
    let source_tile = _Tiles[[source]];
    let source_operation_type = if BundleTileOperationSelected() &&
        _BundleOperation.data_type_valid then TileDataTypeFromEncoding(
            _BundleOperation.data_type as TileDataTypeEncoding)
        else source_tile.data_type;
    if (if TileLayoutIsCube(destination_tile.layout) then
            !TileCubeDescriptorLegal(destination_tile)
        else !TileDescriptorPhysicalShapeLegal(
            destination_tile.capacity_bytes, destination_tile.rows,
            destination_tile.columns, destination_tile.valid_rows,
            destination_tile.valid_columns, destination_tile.data_type)) ||
       !TileTCVTSourceContentsDefined(source) ||
       !TileTCVTSourceEncodingsValidAs(source, source_operation_type) ||
       !TileCarrierWidthCompatible(source_tile.data_type,
           source_operation_type) ||
       !HardwareTCVTTypePairSupported(source_operation_type,
           destination_tile.data_type) ||
       !HardwareTCVTRoundingModeSupported(source_operation_type,
           destination_tile.data_type, control.rounding_mode) ||
       destination_tile.valid_rows != source_tile.valid_rows ||
       destination_tile.valid_columns != source_tile.valid_columns then
        return FALSE;
    end;
    let source_cube_m_layout =
        source_tile.layout == TileLayout_CUBE_M16 ||
        source_tile.layout == TileLayout_CUBE_M32;
    if source_cube_m_layout then
        return !CurrentBundleCanonicalize() &&
               CurrentBundleDataLayout() == TileDataLayout_NORM &&
               destination_tile.layout == source_tile.layout &&
               TileCubeDescriptorShapeLegal(
                   source_tile.capacity_bytes, source_tile.valid_rows,
                   source_tile.valid_columns, source_tile.data_type,
                   source_tile.layout) &&
               TileCubeDescriptorShapeAndPhysicalLegal(
                   destination_tile.capacity_bytes, destination_tile.rows,
                   destination_tile.columns, destination_tile.valid_rows,
                   destination_tile.valid_columns,
                   destination_tile.data_type, destination_tile.layout);
    end;
    if destination_tile.rows != source_tile.rows ||
       destination_tile.columns != source_tile.columns ||
       TileLayoutIsCube(destination_tile.layout) ||
       CurrentBundleCanonicalize() then
        return FALSE;
    end;
    return source_tile.layout == CurrentBundleTileSourceLayout() &&
           destination_tile.layout == CurrentBundleTileLayout();
end;
```
<!-- GENERATED-ASL-END: unit -->
