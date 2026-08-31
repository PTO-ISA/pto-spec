// PTO-TEST: {"id":"PTO-AVS-TILE-TSHL-REINTERPRET-002","source":"asl/tile/elementwise-tile-tile/logical/TSHL.asl","requirements":["PTO-TSHL-CONTRACT-001"],"kind":"execution","summary":"TSHL accepts a floating value backing carrier with an integer shift-count carrier of the selected width","pass_condition":"U16 TSHL reads BF16-backed value bits, uses the U16-backed count, and publishes a U16-backed shifted result","related_sources":["asl/tile/model/legality/dtype-layout.asl","asl/tile/model/legality/operand-schema.asl","asl/tile/model/execution/elementwise.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(
        0, 128, 16, 4, 1, 1, TileDataType_BF16,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(
        1, 128, 16, 4, 1, 1, TileDataType_U16,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(
        2, 128, 16, 4, 1, 1, TileDataType_U16,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0x3f80);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 1);

    assert InstructionContractOperandsLegal_TSHL(2, 0, 1);
    InstructionContractExecute_TSHL(2, 0, 1);
    assert ReadTileElement(2, 0, 0) == Zeros{PTO_XLEN} + 0x7f00;
    assert _Tiles[[2]].data_type == TileDataType_U16;
    return 0;
end;
