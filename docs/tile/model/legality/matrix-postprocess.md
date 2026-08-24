<!-- GENERATED FROM: asl/tile/model/legality/matrix-postprocess.asl -->
# Matrix Postprocess

**Normative ASL source:** `asl/tile/model/legality/matrix-postprocess.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-LEGALITY-MATRIX-POSTPROCESS}

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/legality/matrix-postprocess.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-LEGALITY-MATRIX-POSTPROCESS","surface":"tile","classification":["model","legality","matrix-postprocess"],"depends_on":["PTO-BLOCK-B-FPATR","PTO-BLOCK-MODEL-OPERANDS-SUBVIEW-DESCRIPTOR","PTO-BLOCK-MODEL-OPERANDS-TILE-BINDINGS","PTO-TILE-MODEL-LEGALITY-MATRIX-SHAPE"]}
// PTO-REQ-CUBE-POSTPROCESS-001: auxiliary Matrix operands are completely
// descriptor- and payload-preflighted before source snapshots or allocation.

readonly func BundleMatrixDestinationAt(
    ordinal: integer {0..2}) => TileIndex
begin
    var seen: integer {0..3} = 0;
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 looplimit 16 do
        if _BundleTileBindings[[binding]].valid &&
           _BundleTileBindings[[binding]].destination_valid then
            if seen == ordinal then
                return _BundleTileBindings[[binding]].destination;
            end;
            seen = (seen + 1) as integer {0..3};
        end;
    end;
    return 0;
end;

readonly func BundleMatrixSourceAt(ordinal: integer {0..7}) => TileIndex
begin
    var seen: integer {0..8} = 0;
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 looplimit 16 do
        if _BundleTileBindings[[binding]].valid then
            if _BundleTileBindings[[binding]].source0_valid then
                if seen == ordinal then
                    return BundleTileSourceIndex(
                        binding as BundleTileBindingIndex, FALSE);
                end;
                seen = (seen + 1) as integer {0..8};
            end;
            if _BundleTileBindings[[binding]].source1_valid then
                if seen == ordinal then
                    return BundleTileSourceIndex(
                        binding as BundleTileBindingIndex, TRUE);
                end;
                seen = (seen + 1) as integer {0..8};
            end;
        end;
    end;
    return 0;
end;

readonly func TileMatrixAuxiliarySourceSchemaLegal(
    source: TileIndex,
    valid_rows: integer {1..65535},
    valid_columns: integer {1..65535},
    data_type: TileDataType) => boolean
begin
    let tile = _Tiles[[source]];
    return TileSourceContentsDefined(source) &&
           TileInfoDescriptorLegal(tile) &&
           tile.valid_rows == valid_rows &&
           tile.valid_columns == valid_columns &&
           tile.data_type == data_type &&
           tile.layout == TileLayout_RowMajor &&
           tile.location == TileLocation_Any;
end;

readonly func TileMatrixVectorQuantContentsLegal(
    source: TileIndex, mode: bits(6)) => boolean
begin
    let tile = _Tiles[[source]];
    for column = 0 to tile.valid_columns - 1 looplimit 65536 do
        let element = TileLogicalLinearIndex(
            tile, 0, column as integer {0..65535});
        if !BundleFPATRQuantParameterWordLegal(
               mode, TileReadLogicalElement(tile, element)) then
            return FALSE;
        end;
    end;
    return TRUE;
end;

readonly func TileMatrixVectorReluContentsLegal(
    source: TileIndex) => boolean
begin
    let tile = _Tiles[[source]];
    for column = 0 to tile.valid_columns - 1 looplimit 65536 do
        let element = TileLogicalLinearIndex(
            tile, 0, column as integer {0..65535});
        if !BundleFPATRReluParameterWordLegal(
               TileReadLogicalElement(tile, element)) then
            return FALSE;
        end;
    end;
    return TRUE;
end;

readonly func BundleMatrixPostProcessSourcesLegal(
    mathematical_sources: integer {0..5},
    m: integer {1..65535},
    n: integer {1..65535},
    accumulator_type: TileDataType) => boolean
begin
    if !BundleFPATRAccumulatorTypeLegal(
           _BundleFixedPointAttributes.pre_quant_mode,
           accumulator_type) then
        return FALSE;
    end;
    var ordinal = mathematical_sources as integer {0..7};
    if _BundleFixedPointAttributes.row_max_en &&
       _BundleFixedPointAttributes.row_max_init then
        let row_max = BundleMatrixSourceAt(ordinal);
        if !TileMatrixAuxiliarySourceSchemaLegal(
               row_max, m, 1, accumulator_type) then
            return FALSE;
        end;
        ordinal = (ordinal + 1) as integer {0..7};
    end;

    if BundleFPATRModeUsesVectorParameter(
           _BundleFixedPointAttributes.pre_quant_mode) then
        let quant = BundleMatrixSourceAt(ordinal);
        if !TileMatrixAuxiliarySourceSchemaLegal(
               quant, 1, n, TileDataType_U64) ||
           !TileMatrixVectorQuantContentsLegal(
               quant, _BundleFixedPointAttributes.pre_quant_mode) then
            return FALSE;
        end;
        ordinal = (ordinal + 1) as integer {0..7};
    end;

    if BundleFPATRReluModeUsesVectorParameter(
           _BundleFixedPointAttributes.relu_mode) then
        let relu = BundleMatrixSourceAt(ordinal);
        if !TileMatrixAuxiliarySourceSchemaLegal(
               relu, 1, n, TileDataType_U64) ||
           !TileMatrixVectorReluContentsLegal(relu) then
            return FALSE;
        end;
    end;
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: unit -->

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
