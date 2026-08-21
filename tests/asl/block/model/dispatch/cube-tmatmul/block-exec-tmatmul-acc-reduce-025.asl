// PTO-TEST: {"id":"PTO-AVS-BLOCK-TMATMUL-ACC-REDUCE-025","source":"asl/block/model/dispatch/cube-tmatmul.asl","requirements":["PTO-CUBE-ACCUMULATOR-OUTPUT-001"],"kind":"execution","summary":"ACC RowMax and GroupMax observe raw P before destination conversion","pass_condition":"FP16 D contains converted values while both reductions contain the raw FP32 maximum","related_sources":["asl/tile/model/execution/postprocess.asl"]}
func main() => integer
begin
    ResetProfileState();
    let a_ready = ConfigureCubeTileForMask(4, 128, 1, 1,
        TileDataType_FP16, TileLayout_CUBE_M16,
        TileLocation_Matrix, '1111');
    let b_ready = ConfigureCubeTileForMask(5, 128, 1, 8,
        TileDataType_FP16, TileLayout_CUBE_N8,
        TileLocation_Matrix, '1111');
    let c_ready = ConfigureCubeTileForMask(6, 512, 1, 8,
        TileDataType_FP32, TileLayout_CUBE_M16,
        TileLocation_Matrix, '1111');
    assert a_ready && b_ready && c_ready;
    WriteTileElement(4, 0, 0, Zeros{PTO_XLEN});
    for column = 0 to 7 looplimit 8 do
        WriteTileElement(5, 0, column, Zeros{PTO_XLEN});
        WriteTileElement(6, 0, column,
            if column == 7 then Zeros{PTO_XLEN} + 0x40000000
            else Zeros{PTO_XLEN} + 0x3f800000);
    end;

    var start: bits(64) = Zeros{64} + 0x00231181;
    start[31:27] = Zeros{5} + 4;
    let started = ExecuteCommandInstruction(start, 32);
    assert started == CommandExecution_Executed;
    SetBundleFixedPointAttributeState(
        Zeros{6} + 1, Zeros{3}, Zeros{4} + 1,
        TRUE, TRUE, FALSE, FALSE);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 8);
    AddBundleTileBinding(
        TRUE, 0, 2, '1111', TRUE, TRUE, 6, 4, FALSE);
    AddBundleTileBinding(
        TRUE, 1, 1, '1111', TRUE, FALSE, 5, 0, FALSE);
    AddBundleTileBinding(
        TRUE, 2, 1, '1111', FALSE, FALSE, 0, 0, TRUE);

    let completed = ExecuteBundleTileOperation();
    assert completed;
    let destination = BundleMatrixDestinationAt(0);
    let row_max = BundleMatrixDestinationAt(1);
    let group_max = BundleMatrixDestinationAt(2);
    assert _Tiles[[destination]].data_type == TileDataType_FP16;
    assert ReadTileElement(destination, 0, 7) ==
        Zeros{PTO_XLEN} + 0x4000;
    assert ReadTileElement(row_max, 0, 0) ==
        Zeros{PTO_XLEN} + 0x40000000;
    assert ReadTileElement(group_max, 0, 0) ==
        Zeros{PTO_XLEN} + 0x40000000;
    assert ReadTileElement(6, 0, 7) ==
        Zeros{PTO_XLEN} + 0x40000000;
    return 0;
end;
