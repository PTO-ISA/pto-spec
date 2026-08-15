// PTO-TEST: {"id":"PTO-AVS-TILE-TMULS-WIDTH-001","source":"asl/tile/tile-scalar-and-immediate/arithmetic/TMULS.asl","requirements":["PTO-INST-TILE-TMULS"],"kind":"execution","summary":"TMULS multiplies each element by the normalized scalar and wraps at element width","pass_condition":"U8 values seven and eighty-six times scalar three produce twenty-one and two","related_sources":["asl/tile/model/execution/elementwise.asl"]}
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
        Zeros{PTO_XLEN} + 7);
    WriteTileElement(
        0,
        0,
        1,
        Zeros{PTO_XLEN} + 86);

    InstructionContractExecute_TMULS(
        1,
        0,
        Zeros{PTO_XLEN} + 3);

    assert ReadTileElement(1, 0, 0) == Zeros{PTO_XLEN} + 21;
    assert ReadTileElement(1, 0, 1) == Zeros{PTO_XLEN} + 2;
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 7;
    return 0;
end;
