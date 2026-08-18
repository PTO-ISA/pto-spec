// PTO-TEST: {"id":"PTO-AVS-TILE-STAGE4-COPY-001","source":"asl/tile/model/execution/expansion.asl","requirements":[],"kind":"execution","summary":"Stage 4 expansion and scalar initialization copy raw invalid carrier patterns","pass_condition":"BW32-NP COPY and TEXPANDS retain concrete dtype and low physical-width payloads","related_sources":["asl/tile/model/legality/reduction-and-expansion.asl","asl/tile/model/execution/generation.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(0, 128, 2, 1, 2, 1, TileDataType_E3M2,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(1, 128, 2, 2, 2, 2, TileDataType_E3M2,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0xf1);
    WriteTileElement(0, 1, 0, Zeros{PTO_XLEN} + 0x82);
    assert !TileNumericEncodingValid(
        TileDataType_E3M2, Zeros{PTO_XLEN} + 0xf1);
    assert TileOperandsLegal_ExecuteTileExpand(
        TileExpand_COPY, TileAxis_Row, 1, 0, 0);
    ExecuteTileExpand(TileExpand_COPY, TileAxis_Row, 1, 0, 0);
    assert _Tiles[[1]].data_type == TileDataType_E3M2;
    assert ReadTileElement(1, 0, 0) == Zeros{PTO_XLEN} + 0xf1;
    assert ReadTileElement(1, 1, 0) == Zeros{PTO_XLEN} + 0x82;
    assert ReadTileElement(1, 0, 1) == Zeros{PTO_XLEN} + 0xf1;
    assert ReadTileElement(1, 1, 1) == Zeros{PTO_XLEN} + 0x82;

    ConfigureTile(2, 128, 1, 1, 1, 1, TileDataType_E2M3,
        TileLayout_RowMajor, TileLocation_Any);
    assert TileOperandsLegal_ExecuteTileFillScalar(
        2, Zeros{PTO_XLEN} + 0xff);
    ExecuteTileFillScalar(2, Zeros{PTO_XLEN} + 0x1ff);
    assert _Tiles[[2]].data_type == TileDataType_E2M3;
    assert ReadTileElement(2, 0, 0) == Zeros{PTO_XLEN} + 0xff;
    return 0;
end;
