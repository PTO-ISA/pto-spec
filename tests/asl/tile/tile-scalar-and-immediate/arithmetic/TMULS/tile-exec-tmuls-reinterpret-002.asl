// PTO-TEST: {"id":"PTO-AVS-TILE-TMULS-REINTERPRET-002","source":"asl/tile/tile-scalar-and-immediate/arithmetic/TMULS.asl","requirements":["PTO-TMULS-CONTRACT-001"],"kind":"execution","summary":"TMULS interprets a same-width integer backing carrier under the selected floating operation type","pass_condition":"BF16 TMULS reads U16-backed BF16 encodings, multiplies under BF16 semantics, and publishes a BF16-backed destination","related_sources":["asl/tile/model/legality/dtype-layout.asl","asl/tile/model/legality/operand-schema.asl","asl/tile/model/execution/elementwise.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(
        0, 128, 16, 4, 1, 1, TileDataType_U16,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(
        1, 128, 16, 4, 1, 1, TileDataType_BF16,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN});

    assert TileOperandsLegal_ExecuteTileScalar(
        TileBinary_MUL, 1, 0, Zeros{PTO_XLEN} + 0x3f80);
    InstructionContractExecute_TMULS(
        1, 0, Zeros{PTO_XLEN} + 0x3f80);
    assert ReadTileElement(1, 0, 0) == Zeros{PTO_XLEN};
    assert _Tiles[[1]].data_type == TileDataType_BF16;
    assert _LastFault == Fault_None;
    return 0;
end;
