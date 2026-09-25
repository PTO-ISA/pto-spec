<!-- GENERATED FROM: asl/tile/model/legality/execution-mask-source-schema.asl -->
# Execution Mask Source Schema

**Normative ASL source:** `asl/tile/model/legality/execution-mask-source-schema.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-LEGALITY-EXECUTION-MASK-SOURCE-SCHEMA}

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/legality/execution-mask-source-schema.asl -->
```asl
// NDF-BEGIN: PTO-TILE-MODEL-EXECUTION-MASK-APPLICABILITY-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// ExecutionMask MUST apply only to an operation's already-legal Local CUBE_M16 or CUBE_M32 forms and MUST NOT add layout support. TGATHER and TSCATTER have no baseline CUBE_M16/CUBE_M32 form under their owning indexed-operation schemas; TTRI is RowMajor-only. Any ExecutionMask carrier on those forms MUST reject before operation effects. This census excludes these three names from the applicable forms in the 91-name semantic classification without removing their existing unpredicated forms.
// NDF-END: PTO-TILE-MODEL-EXECUTION-MASK-APPLICABILITY-001
// PTO-UNIT: {"id":"PTO-TILE-MODEL-LEGALITY-EXECUTION-MASK-SOURCE-SCHEMA","surface":"tile","classification":["model","legality","execution-mask-source-schema"],"depends_on":["PTO-TILE-MODEL-DEFINEDNESS-ELEMENTS","PTO-TILE-MODEL-EXECUTION-MASK-STATE","PTO-TILE-MODEL-LEGALITY-DESCRIPTOR-SHAPE","PTO-TILE-MODEL-LEGALITY-DTYPE-LAYOUT","PTO-TILE-MODEL-SHAPE-CUBE-CELL"]}
readonly func TileElementwiseSourceContentsDefined(index: TileIndex)
    => boolean
begin
    let tile = _Tiles[[index]];
    if TileLayoutIsCube(tile.layout) then
        if !TileCubeDescriptorLegal(tile) then return FALSE; end;
    elsif !TileDescriptorLegal(index) then
        return FALSE;
    end;
    if !_BundleExecutionMask.valid then return tile.contents_defined; end;
    if tile.layout != _BundleExecutionMask.layout ||
       tile.valid_rows != _BundleExecutionMask.valid_rows ||
       tile.valid_columns != _BundleExecutionMask.valid_columns then
        return FALSE;
    end;
    for row = 0 to tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to tile.valid_columns - 1 looplimit 65536 do
            if BundleExecutionMaskActiveAt(
                   tile.layout, row as integer {0..65535},
                   column as integer {0..65535}) &&
               !TileElementDefined(index, row as integer {0..65535},
                   column as integer {0..65535}) then
                return FALSE;
            end;
        end;
    end;
    return TRUE;
end;

readonly func TileElementwiseSourceEncodingsValidAs(
    index: TileIndex, operation_type: TileDataType) => boolean
begin
    if !TileElementwiseSourceContentsDefined(index) ||
       !TileCarrierWidthCompatible(
           _Tiles[[index]].data_type, operation_type) then
        return FALSE;
    end;
    let tile = _Tiles[[index]];
    for row = 0 to tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to tile.valid_columns - 1 looplimit 65536 do
            if !_BundleExecutionMask.valid ||
               BundleExecutionMaskActiveAt(
                   tile.layout, row as integer {0..65535},
                   column as integer {0..65535}) then
                let element = TileLogicalLinearIndex(tile,
                    row as integer {0..65535},
                    column as integer {0..65535});
                if !TileNumericEncodingValid(
                       operation_type,
                       TileReadLogicalElement(tile, element)) then
                    return FALSE;
                end;
            end;
        end;
    end;
    return TRUE;
end;

readonly func TileElementwiseSourceEncodingsValid(index: TileIndex)
    => boolean
begin
    if !TileElementwiseSourceContentsDefined(index) then return FALSE; end;
    let tile = _Tiles[[index]];
    for row = 0 to tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to tile.valid_columns - 1 looplimit 65536 do
            if !_BundleExecutionMask.valid ||
               BundleExecutionMaskActiveAt(
                   tile.layout, row as integer {0..65535},
                   column as integer {0..65535}) then
                let element = TileLogicalLinearIndex(tile,
                    row as integer {0..65535},
                    column as integer {0..65535});
                if !TileNumericEncodingValid(
                       tile.data_type,
                       TileReadLogicalElement(tile, element)) then
                    return FALSE;
                end;
            end;
        end;
    end;
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: unit -->
