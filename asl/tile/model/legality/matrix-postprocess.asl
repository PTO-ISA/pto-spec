// PTO-UNIT: {"id":"PTO-TILE-MODEL-LEGALITY-MATRIX-POSTPROCESS","surface":"tile","classification":["model","legality","matrix-postprocess"],"depends_on":["PTO-BLOCK-B-FPATR","PTO-BLOCK-MODEL-OPERANDS-SUBVIEW-DESCRIPTOR","PTO-BLOCK-MODEL-OPERANDS-TILE-BINDINGS","PTO-TILE-MODEL-LEGALITY-MATRIX-SHAPE"]}
// PTO-REQ-CUBE-POSTPROCESS-001: auxiliary Matrix operands are completely
// descriptor- and payload-preflighted before source snapshots or allocation.
// NDF-BEGIN: PTO-CUBE-AUX-CELLREG-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// Local Matrix auxiliary Tiles are orientation-specific CellReg data:
// RowMaxIn/Out and GroupMaxOut use EffectiveDType and the resolved primary
// M16/M32 layout, with their physical geometry and capacity derived from that
// effective type;
// Bias and vector quant/PReLU parameters use CUBE_N8 with logical [1,N].
// Vector parameters retain U64 carriers, whose only CellReg geometry is
// CUBE_N8 K2 x N8; only vector parameter sources and ND2N8 U64 TLOAD may use
// it. All other U64 CUBE producers and consumers remain illegal.
// NDF-END: PTO-CUBE-AUX-CELLREG-001

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

readonly func BundleMatrixSourceAt(ordinal: integer {0..8}) => TileIndex
begin
    var seen: integer {0..9} = 0;
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 looplimit 16 do
        if _BundleTileBindings[[binding]].valid then
            if _BundleTileBindings[[binding]].source0_valid then
                if seen == ordinal then
                    return BundleTileSourceIndex(
                        binding as BundleTileBindingIndex, FALSE);
                end;
                seen = (seen + 1) as integer {0..9};
            end;
            if _BundleTileBindings[[binding]].source1_valid then
                if seen == ordinal then
                    return BundleTileSourceIndex(
                        binding as BundleTileBindingIndex, TRUE);
                end;
                seen = (seen + 1) as integer {0..9};
            end;
        end;
    end;
    return 0;
end;

readonly func BundleMatrixArchitecturalSourceAt(
    ordinal: integer {0..8}) => TileIndex
begin
    var seen: integer {0..9} = 0;
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 looplimit 16 do
        if _BundleTileBindings[[binding]].valid then
            if _BundleTileBindings[[binding]].source0_valid then
                if seen == ordinal then
                    return BundleTileArchitecturalSourceIndex(
                        binding as BundleTileBindingIndex, FALSE);
                end;
                seen = (seen + 1) as integer {0..9};
            end;
            if _BundleTileBindings[[binding]].source1_valid then
                if seen == ordinal then
                    return BundleTileArchitecturalSourceIndex(
                        binding as BundleTileBindingIndex, TRUE);
                end;
                seen = (seen + 1) as integer {0..9};
            end;
        end;
    end;
    return 0;
end;

readonly func TileMatrixLocalRowMaxSchemaLegal(
    source: TileIndex,
    valid_rows: integer {1..65535},
    effective_type: TileDataType,
    expected_layout: TileLayout) => boolean
begin
    let tile = _Tiles[[source]];
    return tile.contents_defined && TileCubeDescriptorLegal(tile) &&
           tile.valid_rows == valid_rows &&
           tile.valid_columns == 1 &&
           tile.data_type == effective_type &&
           tile.layout == expected_layout &&
           (expected_layout == TileLayout_CUBE_M16 ||
            expected_layout == TileLayout_CUBE_M32);
end;

readonly func TileMatrixLocalVectorParameterSchemaLegal(
    source: TileIndex,
    n: integer {1..65535}) => boolean
begin
    let tile = _Tiles[[source]];
    return tile.contents_defined && TileCubeDescriptorLegal(tile) &&
           tile.valid_rows == 1 &&
           tile.valid_columns == n &&
           tile.data_type == TileDataType_U64 &&
           tile.layout == TileLayout_CUBE_N8;
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
    mathematical_sources: integer {0..6},
    m: integer {1..65535},
    n: integer {1..65535},
    accumulator_type: TileDataType,
    primary_layout: TileLayout) => boolean
begin
    if !BundleFPATRAccumulatorTypeLegal(
           _BundleFixedPointAttributes.pre_quant_mode,
           accumulator_type) then
        return FALSE;
    end;
    let effective_type = BundleFPATREffectiveDataType(
        _BundleFixedPointAttributes.pre_quant_mode, accumulator_type);
    if (_BundleFixedPointAttributes.row_max_en ||
        _BundleFixedPointAttributes.group_max_en) &&
       !BundleFPATRReductionDataTypeLegal(effective_type) then
        return FALSE;
    end;
    var ordinal = mathematical_sources as integer {0..8};
    if _BundleFixedPointAttributes.row_max_en &&
       _BundleFixedPointAttributes.row_max_init then
        let row_max = BundleMatrixSourceAt(ordinal);
        if !TileMatrixLocalRowMaxSchemaLegal(
               row_max, m, effective_type, primary_layout) then
            return FALSE;
        end;
        ordinal = (ordinal + 1) as integer {0..8};
    end;

    if BundleFPATRModeUsesVectorParameter(
           _BundleFixedPointAttributes.pre_quant_mode) then
        let quant = BundleMatrixSourceAt(ordinal);
        if !TileMatrixLocalVectorParameterSchemaLegal(
               quant, n) ||
           !TileMatrixVectorQuantContentsLegal(
               quant, _BundleFixedPointAttributes.pre_quant_mode) then
            return FALSE;
        end;
        ordinal = (ordinal + 1) as integer {0..8};
    end;

    if BundleFPATRReluModeUsesVectorParameter(
           _BundleFixedPointAttributes.relu_mode) then
        let relu = BundleMatrixSourceAt(ordinal);
        if !TileMatrixLocalVectorParameterSchemaLegal(
               relu, n) ||
           !TileMatrixVectorReluContentsLegal(relu) then
            return FALSE;
        end;
    end;
    return TRUE;
end;
