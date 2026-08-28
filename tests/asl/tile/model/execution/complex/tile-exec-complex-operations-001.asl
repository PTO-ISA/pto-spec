// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-TILE-TESTTILECOMPLEX-EXECUTION-001","source":"asl/tile/model/execution/complex.asl","requirements":[],"kind":"execution","summary":"The complex execution unit retains current ordering and histogram behavior.","pass_condition":"Current sorting and histogram helpers complete without retired TPART aliases","related_sources":["asl/tile/irregular-and-complex/sorting/TSORT.asl","asl/tile/irregular-and-complex/sorting/TMRGSORT.asl","asl/tile/irregular-and-complex/initialization/THISTOGRAM.asl"]}
func TestTileComplex()
begin
    ConfigureTile(32, 256, 1, 4, 1, 4, TileDataType_FP32,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(33, 256, 1, 4, 1, 4, TileDataType_FP32,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(38, 256, 1, 4, 1, 4, TileDataType_U32,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(32, 0, 0, Zeros{PTO_XLEN} + 4);
    WriteTileElement(32, 0, 1, Zeros{PTO_XLEN} + 1);
    WriteTileElement(32, 0, 2, Zeros{PTO_XLEN} + 3);
    WriteTileElement(32, 0, 3, Zeros{PTO_XLEN} + 2);
    TSORT(33, 38, 32, 32, FALSE);
    assert ReadTileElement(33, 0, 0) == Zeros{PTO_XLEN} + 1;
    assert ReadTileElement(33, 0, 3) == Zeros{PTO_XLEN} + 4;
    assert ReadTileElement(38, 0, 0) == Zeros{PTO_XLEN} + 1;
    assert ReadTileElement(38, 0, 3) == Zeros{PTO_XLEN};

    ConfigureTile(34, 256, 1, 2, 1, 2, TileDataType_FP32,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(35, 256, 1, 2, 1, 2, TileDataType_FP32,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(36, 256, 1, 4, 1, 4, TileDataType_FP32,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(34, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(34, 0, 1, Zeros{PTO_XLEN} + 4);
    WriteTileElement(35, 0, 0, Zeros{PTO_XLEN} + 2);
    WriteTileElement(35, 0, 1, Zeros{PTO_XLEN} + 3);
    TMRGSORT(36, 34, 35, FALSE);
    assert ReadTileElement(36, 0, 0) == Zeros{PTO_XLEN} + 1;
    assert ReadTileElement(36, 0, 3) == Zeros{PTO_XLEN} + 4;

    ConfigureTile(37, 2048, 1, 256, 1, 256, TileDataType_U32,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(49, 256, 3, 1, 3, 1, TileDataType_U8,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(50, 256, 1, 4, 1, 4, TileDataType_U32,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(49, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(49, 1, 0, Zeros{PTO_XLEN});
    WriteTileElement(49, 2, 0, Zeros{PTO_XLEN});
    WriteTileElement(50, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(50, 0, 1, Zeros{PTO_XLEN} + 1);
    WriteTileElement(50, 0, 2, Zeros{PTO_XLEN} + 1);
    WriteTileElement(50, 0, 3, Zeros{PTO_XLEN} + 3);
    THISTOGRAM(37, 50, 49, 0);
    assert ReadTileElement(37, 0, 0) == Zeros{PTO_XLEN} + 1;
    assert ReadTileElement(37, 0, 1) == Zeros{PTO_XLEN} + 3;
    assert ReadTileElement(37, 0, 2) == Zeros{PTO_XLEN} + 3;
    assert ReadTileElement(37, 0, 3) == Zeros{PTO_XLEN} + 4;
end;
func main() => integer
begin
    ResetProfileState();
    TestTileComplex();
    return 0;
end;
