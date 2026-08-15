// PTO-TEST: {"id":"PTO-AVS-TILE-TMRGSORT-KERNEL-001","source":"asl/tile/model/execution/sorting.asl","requirements":["PTO-INST-TILE-TMRGSORT"],"kind":"execution","summary":"The TMRGSORT kernel merges two ascending streams with stable left precedence","pass_condition":"the destination contains the complete ordered four-element merge","related_sources":[]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(
        50, 128, 16, 2, 1, 2,
        TileDataType_FP32,
        TileLayout_RowMajor,
        TileLocation_Any);
    ConfigureTile(
        51, 128, 16, 2, 1, 2,
        TileDataType_FP32,
        TileLayout_RowMajor,
        TileLocation_Any);
    ConfigureTile(
        52, 128, 8, 4, 1, 4,
        TileDataType_FP32,
        TileLayout_RowMajor,
        TileLocation_Any);
    WriteTileElement(50, 0, 0, Zeros{PTO_XLEN} + 0x3f800000);
    WriteTileElement(50, 0, 1, Zeros{PTO_XLEN} + 0x40400000);
    WriteTileElement(51, 0, 0, Zeros{PTO_XLEN} + 0x40000000);
    WriteTileElement(51, 0, 1, Zeros{PTO_XLEN} + 0x40800000);

    TMRGSORT(52, 50, 51, FALSE);

    assert ReadTileElement(52, 0, 0) == Zeros{PTO_XLEN} + 0x3f800000;
    assert ReadTileElement(52, 0, 1) == Zeros{PTO_XLEN} + 0x40000000;
    assert ReadTileElement(52, 0, 2) == Zeros{PTO_XLEN} + 0x40400000;
    assert ReadTileElement(52, 0, 3) == Zeros{PTO_XLEN} + 0x40800000;
    return 0;
end;
