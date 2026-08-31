// PTO-TEST: {"id":"PTO-AVS-TILE-TANDS-E8M0-CARRIER-003","source":"asl/tile/tile-scalar-and-immediate/logical/TANDS.asl","requirements":["PTO-TANDS-CONTRACT-001"],"kind":"execution","summary":"E8M0 backing storage is available to raw eight-bit carrier operations","pass_condition":"U8 TANDS consumes E8M0-backed bits without numeric reinterpretation checks and publishes a U8-backed raw result","related_sources":["asl/tile/model/legality/dtype-layout.asl","asl/tile/model/legality/operand-schema.asl","asl/tile/model/execution/elementwise.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(
        0, 128, 32, 4, 1, 1, TileDataType_E8M0,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(
        1, 128, 32, 4, 1, 1, TileDataType_U8,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0xaa);

    assert TileOperandsLegal_ExecuteTileScalar(
        TileBinary_AND, 1, 0, Zeros{PTO_XLEN} + 0x0f);
    InstructionContractExecute_TANDS(
        1, 0, Zeros{PTO_XLEN} + 0x0f);
    assert ReadTileElement(1, 0, 0) == Zeros{PTO_XLEN} + 0x0a;
    assert _Tiles[[1]].data_type == TileDataType_U8;
    return 0;
end;
