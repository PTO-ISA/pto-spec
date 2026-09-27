// PTO-TEST: {"id":"PTO-AVS-BLOCK-EXECUTION-MASK-CELLWORD-COORDINATE-001","source":"asl/block/model/dispatch/execution-mask-schema.asl","requirements":["PTO-B-IOR-BINDING-001","PTO-TILE-MODEL-EXECUTION-MASK-APPLICABILITY-001","PTO-TILE-MODEL-EXECUTION-MASK-REARRANGEMENT-001"],"kind":"boundary","summary":"TPACK and TUNPACK masks use source CELL-word coordinates for both carriers","pass_condition":"M16 source rows by four words fit one GPR word and accept matching PredicateCell shape; M32 source rows by four words require two GPR words, accept their final coordinate, and reject a wrong predicate shape","related_sources":["asl/block/model/dispatch/scalar-schema.asl","asl/tile/model/legality/layout-rearrangement.asl"]}
func SelectCellWordBundle(layout_code: bits(5), data_type: TileDataType)
begin
    _BundleOperation.valid = TRUE;
    _BundleOperation.operation_class = BundleOperation_TileElement;
    _BundleOperation.data_type_valid = TRUE;
    _BundleOperation.data_type = TileDataTypeToEncoding(data_type);
    _BundleDataAttributes.data_layout = layout_code;
end;

func BindTilePackSources(left: TileIndex, right: TileIndex)
begin
    _BundleTileBindings[[0]].valid = TRUE;
    _BundleTileBindings[[0]].source0_valid = TRUE;
    _BundleTileBindings[[0]].source0 = left;
    _BundleTileBindings[[0]].source1_valid = TRUE;
    _BundleTileBindings[[0]].source1 = right;
end;

func main() => integer
begin
    ResetProfileState();
    let source0_ready = ConfigureCubeTile(
        0, 4096, 1, 4, TileDataType_U32, TileLayout_CUBE_M16);
    let source1_ready = ConfigureCubeTile(
        1, 4096, 1, 4, TileDataType_U32, TileLayout_CUBE_M16);
    let predicate_ready = ConfigurePredicateCell(
        2, 256, 1, 4, TileDataType_U16, TileLayout_CUBE_M16);
    let wrong_predicate_ready = ConfigurePredicateCell(
        3, 256, 1, 1, TileDataType_U16, TileLayout_CUBE_M16);
    assert source0_ready && source1_ready && predicate_ready &&
           wrong_predicate_ready;
    MarkTileValidRegionDefined(2);
    MarkTileValidRegionDefined(3);
    SelectCellWordBundle(Zeros{5} + 31, TileDataType_U32);
    BindTilePackSources(0, 1);
    let pack = DecodeTileOperation(
        TileDecode_TEPL, Zeros{12} + 0x077)
        as integer {0..PTO_TILE_OPERATION_COUNT-1};
    assert BundleExecutionMaskCoordinateValidRows(pack) == 1;
    assert BundleExecutionMaskCoordinateValidColumns(pack) == 4;
    assert BundleExecutionMaskGPRWordCount(pack) == 1;
    assert BundleExecutionMaskGPRCarrierShapeLegal(pack);
    _BundleTileBindings[[1]].valid = TRUE;
    _BundleTileBindings[[1]].source0_valid = TRUE;
    _BundleTileBindings[[1]].source0 = 2;
    assert BundleExecutionMaskTileCarrierPresent(pack);
    assert BundleExecutionMaskTileCarrierSchemaLegal(pack);
    _BundleTileBindings[[1]].source0 = 3;
    assert !BundleExecutionMaskTileCarrierSchemaLegal(pack);

    ResetProfileState();
    let unpack_source_ready = ConfigureCubeTile(
        0, 4096, 32, 4, TileDataType_U32, TileLayout_CUBE_M32);
    assert unpack_source_ready;
    SelectCellWordBundle(Zeros{5} + 29, TileDataType_U32);
    _BundleTileBindings[[0]].valid = TRUE;
    _BundleTileBindings[[0]].source0_valid = TRUE;
    _BundleTileBindings[[0]].source0 = 0;
    let unpack = DecodeTileOperation(
        TileDecode_TEPL, Zeros{12} + 0x078)
        as integer {0..PTO_TILE_OPERATION_COUNT-1};
    assert BundleExecutionMaskCoordinateValidRows(unpack) == 32;
    assert BundleExecutionMaskCoordinateValidColumns(unpack) == 4;
    assert BundleExecutionMaskGPRWordCount(unpack) == 2;
    assert BundleExecutionMaskGPRCarrierShapeLegal(unpack);
    SetBundleScalarBindingWithExecutionMask(
        0, 0, 0, 5, 0, 3, TRUE);
    assert BundleExecutionMaskGPRBindingSchemaLegal(unpack);

    ResetProfileState();
    let parent_ready = ConfigureCubeTile(
        0, 4096, 32, 2, TileDataType_U32, TileLayout_CUBE_M32);
    let right_ready = ConfigureCubeTile(
        1, 4096, 32, 4, TileDataType_U32, TileLayout_CUBE_M32);
    let view_ready = ConfigureCubeTile(
        2, 4096, 32, 4, TileDataType_U32, TileLayout_CUBE_M32);
    assert parent_ready && right_ready && view_ready;
    SelectCellWordBundle(Zeros{5} + 29, TileDataType_U32);
    _BundleTileBindings[[0]].valid = TRUE;
    _BundleTileBindings[[0]].source0_valid = TRUE;
    _BundleTileBindings[[0]].source0 = 0;
    _BundleTileBindings[[0]].source0_subview.materialized = TRUE;
    _BundleTileBindings[[0]].source0_subview.materialized_index = 2;
    _BundleTileBindings[[0]].source1_valid = TRUE;
    _BundleTileBindings[[0]].source1 = 1;
    let subview_pack = DecodeTileOperation(
        TileDecode_TEPL, Zeros{12} + 0x077)
        as integer {0..PTO_TILE_OPERATION_COUNT-1};
    assert BundleExecutionMaskGPRWordCount(subview_pack) == 2;
    assert BundleExecutionMaskCoordinateValidRows(subview_pack) == 32;
    assert BundleExecutionMaskCoordinateValidColumns(subview_pack) == 4;
    assert BundleExecutionMaskGPRCarrierShapeLegal(subview_pack);
    return 0;
end;
