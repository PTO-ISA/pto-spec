// PTO-TEST: {"id":"PTO-AVS-TILE-TFILLPAD-SCALAR-001","source":"asl/tile/layout-and-rearrangement/initialization/TFILLPAD.asl","requirements":["PTO-TFILLPAD-CONTRACT-001","PTO-INST-TILE-TFILLPAD"],"kind":"execution","summary":"TFILLPAD copies the source valid rectangle and fills the remaining physical destination.","pass_condition":"Copied values persist and every other physical element equals the low-width scalar value and is defined.","related_sources":["asl/tile/model/execution/generation.asl","asl/tile/model/legality/operand-schema.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(
        1, 128, 32, 4, 1, 2, TileDataType_U8,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(
        2, 128, 32, 4, 2, 3, TileDataType_U8,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 2);
    TFILLPAD(2, 1, Zeros{PTO_XLEN} + 0x1aa);
    assert ReadTileElement(2, 0, 0) == Zeros{PTO_XLEN} + 1;
    assert ReadTileElement(2, 0, 2) == Zeros{PTO_XLEN} + 0xaa;
    assert ReadTileElement(2, 1, 1) == Zeros{PTO_XLEN} + 0xaa;
    assert TileElementDefined(2, 31, 3);
    return 0;
end;
