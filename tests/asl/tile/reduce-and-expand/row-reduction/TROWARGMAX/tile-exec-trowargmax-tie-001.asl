// PTO-TEST: {"id":"PTO-AVS-TILE-TROWARGMAX-TIE-001","source":"asl/tile/reduce-and-expand/row-reduction/TROWARGMAX.asl","requirements":["PTO-INST-TILE-TROWARGMAX"],"kind":"execution","summary":"TROWARGMAX returns the lowest column index among equal maxima.","pass_condition":"The first of two equal maxima produces U32 index one.","related_sources":["asl/tile/model/execution/reduction.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(
        0, 128, 1, 4, 1, 3,
        TileDataType_U8,
        TileLayout_RowMajor,
        TileLocation_Any);
    ConfigureTile(
        1, 128, 1, 1, 1, 1,
        TileDataType_U32,
        TileLayout_RowMajor,
        TileLocation_Any);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(0, 0, 1, Zeros{PTO_XLEN} + 9);
    WriteTileElement(0, 0, 2, Zeros{PTO_XLEN} + 9);

    ExecuteTileReduction(
        TileReduction_ARGMAX,
        TileAxis_Row,
        1,
        0);

    assert ReadTileElement(1, 0, 0) == Zeros{PTO_XLEN} + 1;
    return 0;
end;
