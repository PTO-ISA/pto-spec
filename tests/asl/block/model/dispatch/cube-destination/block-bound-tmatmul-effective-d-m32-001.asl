// PTO-TEST: {"id":"PTO-AVS-BLOCK-TMATMUL-EFFECTIVE-D-M32-001","source":"asl/block/model/dispatch/cube-destination.asl","requirements":["PTO-B-FPATR-MATRIX-POSTPROCESS-001","PTO-CUBE-AUX-CELLREG-001"],"kind":"boundary","summary":"BF16 effective D and auxiliary descriptors retain M32 CellReg geometry through allocation and reuse","pass_condition":"a 17x2 matrix with GroupN greater than N accepts BF16 RowMaxIn and allocates and reuses three legal M32 BF16 descriptors","related_sources":["asl/block/model/dispatch/cube-tmatmul.asl","asl/block/model/dispatch/destination-shape.asl","asl/tile/model/shape/cube-cell.asl"]}

pure func EffectiveDM32Start() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00031181;
    instruction[31:27] = Zeros{5} + 4;
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    let a_ready = ConfigureCubeTileForMask(1, 128, 17, 1,
        TileDataType_FP16, TileLayout_CUBE_M32, '1111');
    let b_ready = ConfigureCubeTileForMask(2, 128, 1, 2,
        TileDataType_FP16, TileLayout_CUBE_N8, '1111');
    let row_max_in_ready = ConfigureCubeTileForMask(3, 128, 17, 1,
        TileDataType_BF16, TileLayout_CUBE_M32, '1111');
    assert a_ready && b_ready && row_max_in_ready;
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 0x3c00);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 0x3c00);
    WriteTileElement(2, 0, 1, Zeros{PTO_XLEN} + 0x3c00);
    MarkTileValidRegionDefined(3);

    let started = ExecuteCommandInstruction(EffectiveDM32Start(), 32);
    assert started == CommandExecution_Executed;
    SetBundleFixedPointAttributeState(
        '010000', Zeros{3}, '0001', TRUE, TRUE, TRUE, FALSE);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 17);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 1);
    AddBundleTileBinding(
        TRUE, 0, 1, '1111', TRUE, TRUE, 1, 2, FALSE);
    AddBundleTileBinding(
        TRUE, 1, 1, '1111', TRUE, FALSE, 3, 0, FALSE);
    AddBundleTileBinding(
        TRUE, 2, 1, '1111', FALSE, FALSE, 0, 0, TRUE);

    assert BundleMatrixPostProcessSourcesLegal(
        2, 17, 2, TileDataType_FP32, TileLayout_CUBE_M32);
    let resolved = ResolveBundleTMATMULDestination(
        17, 2, TileDataType_FP32, TRUE, TileLayout_CUBE_M32, '1111');
    assert resolved;
    let destination = BundleMatrixDestinationAt(0);
    let row_max = BundleMatrixDestinationAt(1);
    let group_max = BundleMatrixDestinationAt(2);
    assert _Tiles[[destination]].data_type == TileDataType_BF16;
    assert _Tiles[[row_max]].data_type == TileDataType_BF16;
    assert _Tiles[[group_max]].data_type == TileDataType_BF16;
    assert _Tiles[[destination]].layout == TileLayout_CUBE_M32;
    assert _Tiles[[row_max]].layout == TileLayout_CUBE_M32;
    assert _Tiles[[group_max]].layout == TileLayout_CUBE_M32;
    assert _Tiles[[destination]].valid_rows == 17;
    assert _Tiles[[destination]].valid_columns == 2;
    assert _Tiles[[row_max]].valid_rows == 17;
    assert _Tiles[[row_max]].valid_columns == 1;
    assert _Tiles[[group_max]].valid_rows == 17;
    assert _Tiles[[group_max]].valid_columns == 1;
    assert _Tiles[[destination]].rows ==
        TileCubeStorageRows(TileLayout_CUBE_M32, 17,
            TileDataType_BF16);
    assert _Tiles[[destination]].columns ==
        TileCubeStorageColumns(TileLayout_CUBE_M32, 2,
            TileDataType_BF16);
    assert _Tiles[[row_max]].rows ==
        TileCubeStorageRows(TileLayout_CUBE_M32, 17,
            TileDataType_BF16);
    assert _Tiles[[row_max]].columns ==
        TileCubeStorageColumns(TileLayout_CUBE_M32, 1,
            TileDataType_BF16);
    assert _Tiles[[group_max]].rows ==
        TileCubeStorageRows(TileLayout_CUBE_M32, 17,
            TileDataType_BF16);
    assert _Tiles[[group_max]].columns ==
        TileCubeStorageColumns(TileLayout_CUBE_M32, 1,
            TileDataType_BF16);
    assert _Tiles[[destination]].cube_storage_bytes == 128;
    assert _Tiles[[row_max]].cube_storage_bytes == 128;
    assert _Tiles[[group_max]].cube_storage_bytes == 128;
    assert TileCubeDescriptorLegal(_Tiles[[destination]]);
    assert TileCubeDescriptorLegal(_Tiles[[row_max]]);
    assert TileCubeDescriptorLegal(_Tiles[[group_max]]);

    for binding = 0 to 2 looplimit 3 do
        _BundleTileBindings[[binding]].destination_allocated_by_bundle = FALSE;
        _BundleTileBindings[[binding]].destination_reused_by_generation = TRUE;
    end;
    let reused = ResolveBundleTMATMULDestination(
        17, 2, TileDataType_FP32, TRUE, TileLayout_CUBE_M32, '1111');
    assert reused;
    assert _Tiles[[destination]].data_type == TileDataType_BF16;
    assert _Tiles[[row_max]].data_type == TileDataType_BF16;
    assert _Tiles[[group_max]].data_type == TileDataType_BF16;
    return 0;
end;
