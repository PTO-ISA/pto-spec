// PTO-TEST: {"id":"PTO-AVS-TILE-TMINS-UNSIGNED-001","source":"asl/tile/tile-scalar-and-immediate/arithmetic/TMINS.asl","requirements":["PTO-INST-TILE-TMINS"],"kind":"execution","summary":"TMINS compares unsigned elements using the selected DataType interpretation","pass_condition":"U8 values two and two hundred fifty against scalar nine produce two and nine","related_sources":["asl/tile/model/execution/elementwise.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(
        0,
        128,
        8,
        2,
        1,
        2,
        TileDataType_U8,
        TileLayout_RowMajor,
        TileLocation_Any);
    ConfigureTile(
        1,
        128,
        8,
        2,
        1,
        2,
        TileDataType_U8,
        TileLayout_RowMajor,
        TileLocation_Any);
    WriteTileElement(
        0,
        0,
        0,
        Zeros{PTO_XLEN} + 2);
    WriteTileElement(
        0,
        0,
        1,
        Zeros{PTO_XLEN} + 250);

    InstructionContractExecute_TMINS(
        1,
        0,
        Zeros{PTO_XLEN} + 9);

    assert ReadTileElement(1, 0, 0) == Zeros{PTO_XLEN} + 2;
    assert ReadTileElement(1, 0, 1) == Zeros{PTO_XLEN} + 9;
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 2;
    return 0;
end;
