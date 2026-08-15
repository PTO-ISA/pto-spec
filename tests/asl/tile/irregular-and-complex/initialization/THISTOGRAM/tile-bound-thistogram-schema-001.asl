// PTO-TEST: {"id":"PTO-AVS-TILE-THISTOGRAM-SCHEMA-001","source":"asl/tile/irregular-and-complex/initialization/THISTOGRAM.asl","requirements":["PTO-INST-TILE-THISTOGRAM"],"kind":"boundary","summary":"THISTOGRAM requires exact U32 output geometry and a U8 prefix filter","pass_condition":"the exact descriptor set is legal while 257 output columns and an S8 filter are rejected","related_sources":["asl/tile/model/legality/indexed-layout.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(
        0,
        1024,
        1,
        256,
        1,
        256,
        TileDataType_U32,
        TileLayout_RowMajor,
        TileLocation_Any);
    ConfigureTile(
        1,
        128,
        16,
        4,
        1,
        4,
        TileDataType_U16,
        TileLayout_RowMajor,
        TileLocation_Any);
    ConfigureTile(
        2,
        128,
        128,
        1,
        1,
        1,
        TileDataType_U8,
        TileLayout_RowMajor,
        TileLocation_Any);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN});
    WriteTileElement(1, 0, 2, Zeros{PTO_XLEN});
    WriteTileElement(1, 0, 3, Zeros{PTO_XLEN});
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN});
    assert TileOperandsLegal_THISTOGRAM(0, 1, 2, 0);
    assert TileHistogramSelectedByteSupported(TileDataType_U16, 0);
    assert TileHistogramSelectedByteSupported(TileDataType_U16, 1);
    assert !TileHistogramSelectedByteSupported(TileDataType_U16, 2);
    assert !TileOperandsLegal_THISTOGRAM(0, 1, 2, 2);
    assert TileHistogramSelectedByteSupported(TileDataType_U32, 3);

    ConfigureTile(
        3,
        2048,
        1,
        512,
        1,
        257,
        TileDataType_U32,
        TileLayout_RowMajor,
        TileLocation_Any);
    assert !TileOperandsLegal_THISTOGRAM(3, 1, 2, 0);

    ConfigureTile(
        4,
        128,
        128,
        1,
        1,
        1,
        TileDataType_S8,
        TileLayout_RowMajor,
        TileLocation_Any);
    WriteTileElement(4, 0, 0, Zeros{PTO_XLEN});
    assert !TileOperandsLegal_THISTOGRAM(0, 1, 4, 0);
    return 0;
end;
