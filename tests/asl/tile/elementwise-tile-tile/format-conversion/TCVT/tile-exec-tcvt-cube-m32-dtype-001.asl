// PTO-TEST: {"id":"PTO-AVS-TILE-TCVT-CUBE-M32-DTYPE-001","source":"asl/tile/elementwise-tile-tile/format-conversion/TCVT.asl","requirements":["PTO-TCVT-CONTRACT-001"],"kind":"execution","summary":"TCVT preserves CUBE_M32 logical geometry while changing the element width","pass_condition":"a CUBE_M32 FP16 source converts to a CUBE_M32 FP32 destination with unchanged valid shape and independently derived physical columns","related_sources":["asl/tile/model/shape/cube-cell.asl","asl/tile/model/numeric/formats.asl"]}
func main() => integer
begin
    ResetProfileState();
    let source_ready = ConfigureCubeTile(
        0, 1024, 17, 9, TileDataType_FP16,
        TileLayout_CUBE_M32, TileLocation_Matrix);
    let destination_ready = ConfigureCubeTile(
        1, 2048, 17, 9, TileDataType_FP32,
        TileLayout_CUBE_M32, TileLocation_Matrix);
    assert source_ready && destination_ready;
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 7);
    WriteTileElement(0, 16, 8, Zeros{PTO_XLEN} + 9);
    MarkTileValidRegionDefined(0);

    assert _Tiles[[0]].rows == 32;
    assert _Tiles[[0]].columns == 10;
    assert _Tiles[[1]].rows == 32;
    assert _Tiles[[1]].columns == 9;
    assert _Tiles[[0]].valid_rows == _Tiles[[1]].valid_rows;
    assert _Tiles[[0]].valid_columns == _Tiles[[1]].valid_columns;
    assert TileOperandsLegal_TCVT(
        1, 0, DefaultNumericExecutionControl());

    InstructionContractExecute_TCVT(
        1, 0, DefaultNumericExecutionControl());
    assert _LastFault == Fault_None;
    assert _Tiles[[1]].layout == TileLayout_CUBE_M32;
    assert _Tiles[[1]].location == TileLocation_Matrix;
    assert ReadTileElement(1, 0, 0) ==
        Zeros{PTO_XLEN} + 0x34e00000;
    assert ReadTileElement(1, 16, 8) ==
        Zeros{PTO_XLEN} + 0x35100000;
    assert _Tiles[[1]].contents_defined;
    return 0;
end;
