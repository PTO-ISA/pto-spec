// PTO-TEST: {"id":"PTO-AVS-BLOCK-TMATMUL-SHARED-PACKED-TIGHT-ODD-N-047","source":"asl/block/model/dispatch/cube-tmatmul.asl","requirements":["PTO-TMATMUL-CONTRACT-001","PTO-CUBE-SHARED-TRANSPOSE-001"],"kind":"execution","summary":"Tight-capacity Shared packed B with odd N=5 remains representable at K=194.","pass_condition":"Decoded all-Shared TMATMUL at M=17,N=5,K=194 accepts A [17,194]/2048 B and B [5,194]/512; the original B pitch addresses the independent final nibble and the private canonical [194,5] view stays within its unpadded 512-byte span.","related_sources":["asl/block/model/dispatch/shared-cube-matrix.asl","asl/tile/model/definedness/packed-boundary.asl"]}

func main() => integer
begin
    ResetProfileState();
    let a_rows = DerivedTileRows(2048, 194, TileDataType_E2M1X2);
    ConfigureTileForMask(10, 2048, a_rows, 194, 17, 194,
        TileDataType_E2M1X2, TileLayout_RowMajor, '1111');
    ConfigureTileForMask(11, 512, 5, 194, 5, 194,
        TileDataType_E2M1X2, TileLayout_RowMajor, '1111');
    MarkTileValidRegionDefined(10);
    MarkTileValidRegionDefined(11);
    WriteTileElement(11, 4, 192, Zeros{PTO_XLEN} + 3);
    WriteTileElement(11, 4, 193, Zeros{PTO_XLEN} + 12);
    InstallSharedTile((Zeros{6} + 40) as SharedTileID,
        _Tiles[[10]], '1111');
    InstallSharedTile((Zeros{6} + 41) as SharedTileID,
        _Tiles[[11]], '1111');

    var start: bits(64) = Zeros{64} + 0x00031181;
    start[31:27] = Zeros{5} + 11;
    let started = ExecuteCommandInstruction(start, 32);
    assert started == CommandExecution_Executed;
    SetBundleFixedPointAttributeState(
        Zeros{6}, Zeros{3}, Zeros{4}, FALSE, FALSE, FALSE, FALSE);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 17);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 5);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 194);
    BindBundleSharedIO((Zeros{6} + 40) as SharedTileID, 0, '1111');
    BindBundleSharedIO((Zeros{6} + 41) as SharedTileID, 0, '1111');
    AddBundleTileBinding(
        TRUE, 0, 3, '1111', FALSE, FALSE, 0, 0, TRUE);

    // Physical source row 4, column 193 has an even 194-element pitch.
    let source_element = TileLogicalLinearIndex(_Tiles[[11]], 4, 193);
    assert source_element == 969;
    assert TilePackedCarrierIndex(TileDataType_E2M1X2, source_element) == 60;
    assert TilePackedLaneIndex(TileDataType_E2M1X2, source_element) == 9;
    assert TileReadLogicalElement(_Tiles[[11]], source_element) ==
        Zeros{PTO_XLEN} + 12;

    let private_view = MaterializeBundleSharedMatrixPrimary(
        1, 194, 5, TileDataType_E2M1X2, FALSE, _CurrentMemoryAgent);
    assert private_view.layout == TileLayout_ColumnMajor;
    assert BundleMatrixPrivateSharedViewLegal(
        private_view, 194, 5, TileDataType_E2M1X2, TRUE);
    let private_element = TileLogicalLinearIndex(private_view, 193, 4);
    assert private_element == 969;
    assert private_element < PackedTileLogicalCapacity(
        private_view.capacity_bytes, private_view.data_type);
    assert TileReadLogicalElement(private_view, private_element) ==
        Zeros{PTO_XLEN} + 12;

    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
    let destination = BundleMatrixDestinationAt(0);
    assert _Tiles[[destination]].contents_defined;
    assert _Tiles[[destination]].data_type == TileDataType_FP32;
    assert _Tiles[[destination]].valid_rows == 16;
    assert _Tiles[[destination]].valid_columns == 5;
    assert _BundleSharedBindings[[0]].consumed;
    assert _BundleSharedBindings[[1]].consumed;
    return 0;
end;
