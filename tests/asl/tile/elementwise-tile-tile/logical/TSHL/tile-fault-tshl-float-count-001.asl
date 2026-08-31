// PTO-TEST: {"id":"PTO-AVS-TILE-TSHL-FLOAT-COUNT-001","source":"asl/tile/elementwise-tile-tile/logical/TSHL.asl","requirements":["PTO-TSHL-CONTRACT-001"],"kind":"fault","summary":"TSHL rejects a floating shift-count carrier even when its element width matches the integer operation type","pass_condition":"a BF16-backed count source is rejected before the U16 TSHL result is published","related_sources":["asl/tile/model/legality/operand-schema.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(0, 128, 16, 1, 1, 1,
        TileDataType_BF16, TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(1, 128, 16, 1, 1, 1,
        TileDataType_BF16, TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(2, 128, 16, 1, 1, 1,
        TileDataType_U16, TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0x3f80);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 2);
    assert !InstructionContractOperandsLegal_TSHL(2, 0, 1);
    return 0;
end;
