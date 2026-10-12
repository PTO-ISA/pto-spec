// PTO-TEST: {"id":"PTO-AVS-BLOCK-TMATMUL-SHARED-PACKED-TRANSPOSED-N-UPPER-055","source":"asl/block/model/dispatch/cube-tmatmul.asl","requirements":["PTO-TMATMUL-CONTRACT-001","PTO-CUBE-SHARED-TRANSPOSE-001"],"kind":"boundary","summary":"Packed TransB with N=65535 rejects because no even 16-bit source pitch can represent it.","pass_condition":"Dimensions M=1,N=65535,K=2 remain legal and a generic-legal Shared B physical 2x65535 descriptor is rejected only when selected as packed transposed B due its odd original pitch.","related_sources":["asl/block/model/dispatch/shared-cube-matrix.asl","asl/tile/model/legality/matrix-shape.asl"]}

func main() => integer
begin
    ResetProfileState();
    ConfigureTileForMask(10, 128, 64, 2, 1, 2,
        TileDataType_E2M1X2, TileLayout_RowMajor, '1111');
    ConfigureTileForMask(11, 65536, 2, 65535, 2, 65535,
        TileDataType_E2M1X2, TileLayout_RowMajor, '1111');
    MarkTileValidRegionDefined(10);
    MarkTileValidRegionDefined(11);
    InstallSharedTile((Zeros{6} + 40) as SharedTileID,
        _Tiles[[10]], '1111');
    InstallSharedTile((Zeros{6} + 41) as SharedTileID,
        _Tiles[[11]], '1111');
    assert TileInfoDescriptorLegal(_Tiles[[11]]);
    assert SharedTileDescriptorLegal((Zeros{6} + 41) as SharedTileID);

    var start: bits(64) = Zeros{64} + 0x00031181;
    start[31:27] = TileDataTypeToEncoding(TileDataType_E2M1X2);
    let started = ExecuteCommandInstruction(start, 32);
    assert started == CommandExecution_Executed;
    SetBundleFixedPointAttributeState(
        Zeros{6}, Zeros{3}, Zeros{4}, FALSE, FALSE, FALSE, FALSE,
        FALSE, TRUE);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 65535);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 2);
    BindBundleSharedIO((Zeros{6} + 40) as SharedTileID, 0, '1111');
    BindBundleSharedIO((Zeros{6} + 41) as SharedTileID, 0, '1111');
    assert BundleTMATMULDimensionsLegal(2);
    assert !BundleMatrixSharedSchemasLegal(
        11, TileDataType_E2M1X2, TileDataType_E2M1X2,
        1, 65535, 2, 2);
    assert BundleMatrixSharedBPrimarySchemaLegal(
        1, 2, 65535, TileDataType_E2M1X2, TRUE) == FALSE;
    assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;
    assert !_BundleSharedBindings[[0]].consumed;
    assert !_BundleSharedBindings[[1]].consumed;
    return 0;
end;
