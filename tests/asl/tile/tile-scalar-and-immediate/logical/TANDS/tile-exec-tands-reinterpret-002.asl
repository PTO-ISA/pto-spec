// PTO-TEST: {"id":"PTO-AVS-TILE-TANDS-REINTERPRET-002","source":"asl/tile/tile-scalar-and-immediate/logical/TANDS.asl","requirements":["PTO-TANDS-CONTRACT-001"],"kind":"execution","summary":"TANDS consumes a same-width floating backing carrier under the selected integer operation type","pass_condition":"U16 TANDS reads BF16-backed raw bits, publishes a U16-backed result, preserves the source, and rejects an eight-bit destination interpretation","related_sources":["asl/tile/model/legality/dtype-layout.asl","asl/tile/model/legality/operand-schema.asl","asl/tile/model/execution/elementwise.asl"]}
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
        2, 128, 32, 4, 1, 1, TileDataType_U8,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0x3f8f);

    assert TileOperandsLegal_ExecuteTileScalar(
        TileBinary_AND, 1, 0, Zeros{PTO_XLEN} + 0x00ff);
    InstructionContractExecute_TANDS(
        1, 0, Zeros{PTO_XLEN} + 0x00ff);
    assert ReadTileElement(1, 0, 0) == Zeros{PTO_XLEN} + 0x008f;
    assert _Tiles[[1]].data_type == TileDataType_U16;
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 0x3f8f;
    assert !TileOperandsLegal_ExecuteTileScalar(
        TileBinary_AND, 2, 0, Zeros{PTO_XLEN} + 0xff);
    return 0;
end;
