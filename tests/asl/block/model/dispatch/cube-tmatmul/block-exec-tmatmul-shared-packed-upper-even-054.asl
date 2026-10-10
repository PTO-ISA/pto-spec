// PTO-TEST: {"id":"PTO-AVS-BLOCK-TMATMUL-SHARED-PACKED-UPPER-EVEN-054","source":"asl/block/model/dispatch/cube-tmatmul.asl","requirements":["PTO-TMATMUL-CONTRACT-001","PTO-CUBE-SHARED-TRANSPOSE-001"],"kind":"execution","summary":"Upper even K=65534 remains representable for Shared packed Matrix primaries.","pass_condition":"Decoded all-Shared E2M1X2 TMATMUL at M=N=1,K=65534 accepts each 2x65534 source in 65536 bytes, reads the final source nibble at its original coordinate, and publishes a defined 128-byte Local result.","related_sources":["asl/block/model/dispatch/shared-cube-matrix.asl","asl/tile/model/definedness/packed-boundary.asl"]}

func main() => integer
begin
    ResetProfileState();
    ConfigureTileForMask(10, 65536, 2, 65534, 1, 65534,
        TileDataType_E2M1X2, TileLayout_RowMajor, '1111');
    ConfigureTileForMask(11, 65536, 2, 65534, 1, 65534,
        TileDataType_E2M1X2, TileLayout_RowMajor, '1111');
    MarkTileValidRegionDefined(10);
    MarkTileValidRegionDefined(11);
    for tile = 10 to 11 looplimit 2 do
        WriteTileElement(tile as TileIndex, 0, 65532,
            Zeros{PTO_XLEN} + 3);
        WriteTileElement(tile as TileIndex, 0, 65533,
            Zeros{PTO_XLEN} + 12);
    end;
    InstallSharedTile((Zeros{6} + 40) as SharedTileID,
        _Tiles[[10]], '1111');
    InstallSharedTile((Zeros{6} + 41) as SharedTileID,
        _Tiles[[11]], '1111');
    let last_source_element = TileLogicalLinearIndex(_Tiles[[11]], 0, 65533);
    assert last_source_element == 65533;
    assert TilePackedCarrierIndex(TileDataType_E2M1X2,
        last_source_element) == 4095;
    assert TilePackedLaneIndex(TileDataType_E2M1X2,
        last_source_element) == 13;
    assert TileReadLogicalElement(_Tiles[[11]], last_source_element) ==
        Zeros{PTO_XLEN} + 12;

    var start: bits(64) = Zeros{64} + 0x00031181;
    start[31:27] = TileDataTypeToEncoding(TileDataType_E2M1X2);
    let started = ExecuteCommandInstruction(start, 32);
    assert started == CommandExecution_Executed;
    SetBundleFixedPointAttributeState(
        Zeros{6}, Zeros{3}, Zeros{4}, FALSE, FALSE, FALSE, FALSE);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 65534);
    BindBundleSharedIO((Zeros{6} + 40) as SharedTileID, 0, '1111');
    BindBundleSharedIO((Zeros{6} + 41) as SharedTileID, 0, '1111');
    AddBundleTileBinding(
        TRUE, 0, 1, '1111', FALSE, FALSE, 0, 0, TRUE);
    assert BundleTMATMULDimensionsLegal(2);
    assert BundleMatrixSharedSchemasLegal(
        11, TileDataType_E2M1X2, TileDataType_E2M1X2,
        1, 1, 65534, 2);

    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
    let destination = BundleMatrixDestinationAt(0);
    assert _Tiles[[destination]].contents_defined;
    assert _Tiles[[destination]].data_type == TileDataType_FP32;
    assert _Tiles[[destination]].capacity_bytes == 128;
    assert _Tiles[[destination]].valid_rows == 1;
    assert _Tiles[[destination]].valid_columns == 1;
    assert _BundleSharedBindings[[0]].consumed;
    assert _BundleSharedBindings[[1]].consumed;
    return 0;
end;
