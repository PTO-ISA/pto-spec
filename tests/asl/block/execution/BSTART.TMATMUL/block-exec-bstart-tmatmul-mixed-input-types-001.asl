// PTO-TEST: {"id":"PTO-AVS-BLOCK-TMATMUL-EXEC-001","source":"asl/block/execution/BSTART.TMATMUL.asl","requirements":["PTO-BSTART-TMATMUL-CONTRACT-001","PTO-TMATMUL-CONTRACT-001"],"kind":"execution","summary":"TMATMUL uses LB0=M, LB1=N, LB2=K and accepts mixed signed input widths.","pass_condition":"A 2x2 S16 by S8 product allocates one new S32 2x2 destination and commits the expected payload.","related_sources":["asl/block/model/dispatch/cube-tmatmul.asl","asl/tile/model/execution/cube.asl"]}
func main() => integer
begin
    ResetProfileState();
    let a_ready = ConfigureCubeTileForMask(1, 128, 2, 2,
        TileDataType_S16, TileLayout_CUBE_M16,
        TileLocation_Matrix, '1111');
    let b_ready = ConfigureCubeTileForMask(2, 128, 2, 2,
        TileDataType_S8, TileLayout_CUBE_N8,
        TileLocation_Matrix, '1111');
    assert a_ready && b_ready;
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 2);
    WriteTileElement(1, 1, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(1, 1, 1, Zeros{PTO_XLEN} + 4);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 5);
    WriteTileElement(2, 0, 1, Zeros{PTO_XLEN} + 6);
    WriteTileElement(2, 1, 0, Zeros{PTO_XLEN} + 7);
    WriteTileElement(2, 1, 1, Zeros{PTO_XLEN} + 8);
    var start: bits(64) = Zeros{64} + 0x00031181;
    start[31:27] = Zeros{5} + 18;
    let started = ExecuteCommandInstruction(start, 32);
    assert started == CommandExecution_Executed;
    SetBundleFixedPointAttributeState(
        Zeros{6}, Zeros{3}, Zeros{4},
        FALSE, FALSE, FALSE, FALSE);
    SetBundleDataAttributeState(Zeros{5} + 19, Zeros{5}, Zeros{2},
        Zeros{3}, Zeros{3} + 1, TRUE, FALSE);
    _BundleDataAttributesPresent = TRUE;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 2);
    AddBundleTileBinding(TRUE, 0, 1, '1111', TRUE, TRUE, 1, 2, TRUE);
    let completed = ExecuteBundleTileOperation();
    assert completed;
    let destination = _BundleTileBindings[[0]].destination;
    assert _Tiles[[destination]].data_type == TileDataType_S32;
    assert _Tiles[[destination]].valid_rows == 2;
    assert _Tiles[[destination]].valid_columns == 2;
    assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN} + 19;
    assert ReadTileElement(destination, 0, 1) == Zeros{PTO_XLEN} + 22;
    assert ReadTileElement(destination, 1, 0) == Zeros{PTO_XLEN} + 43;
    assert ReadTileElement(destination, 1, 1) == Zeros{PTO_XLEN} + 50;
    return 0;
end;
