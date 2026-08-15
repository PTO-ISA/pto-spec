// PTO-TEST: {"id":"PTO-AVS-BLOCK-TMATMUL-MX-SHARED-RIGHT-001","source":"asl/block/model/dispatch/cube-tmatmul.asl","requirements":["PTO-TMATMUL-MX-CONTRACT-001"],"kind":"execution","summary":"TMATMULMX accepts a complete Shared right matrix and scale group","pass_condition":"Local left operands and Shared right operands produce one FP32 destination","related_sources":["asl/tile/model/legality/matrix-functions.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(0, 512, 1, 32, 1, 32, TileDataType_E4M3,
        TileLayout_RowMajor, TileLocation_Matrix);
    ConfigureTile(1, 128, 1, 1, 1, 1, TileDataType_E8M0,
        TileLayout_RowMajor, TileLocation_Matrix);
    ConfigureTile(10, 512, 32, 1, 32, 1, TileDataType_E5M2,
        TileLayout_RowMajor, TileLocation_Matrix);
    ConfigureTile(11, 128, 1, 1, 1, 1, TileDataType_E8M0,
        TileLayout_RowMajor, TileLocation_Matrix);
    for inner = 0 to 31 looplimit 32 do
        WriteTileElement(0, 0, inner, Zeros{PTO_XLEN} + 2);
        WriteTileElement(10, inner, 0, Zeros{PTO_XLEN} + 3);
    end;
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(11, 0, 0, Zeros{PTO_XLEN} + 1);
    InstallSharedTile(Zeros{8} + 42, _Tiles[[10]], '1111');
    InstallSharedTile(Zeros{8} + 43, _Tiles[[11]], '1111');
    var start: bits(64) = Zeros{64} + 0x00431181;
    start[31:27] = Zeros{5} + 7;
    let start_result = ExecuteCommandInstruction(start, 32);
    assert start_result == CommandExecution_Executed;
    SetBundleDataAttributeState(
        Zeros{5} + 8, Zeros{5}, Zeros{2}, Zeros{3}, Zeros{3},
        FALSE, FALSE);
    _BundleDataAttributesPresent = TRUE;
    SetBundleFixedPointAttributeState(
        Zeros{6}, Zeros{3}, Zeros{4}, FALSE, FALSE, FALSE, FALSE);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 32);
    BindBundleSharedIO(Zeros{8} + 42, 0, '1111');
    BindBundleSharedIO(Zeros{8} + 43, 0, '1111');
    AddBundleTileBinding(
        TRUE, 0, 1, '1111', TRUE, TRUE, 0, 1, TRUE);

    let completed = ExecuteBundleTileOperation();
    assert completed;
    let destination = BundleMatrixDestinationAt(0);
    assert _Tiles[[destination]].data_type == TileDataType_FP32;
    assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN} + 192;
    return 0;
end;
