// PTO-TEST: {"id":"PTO-AVS-TILE-TREMS-SIGNED-001","source":"asl/tile/tile-scalar-and-immediate/arithmetic/TREMS.asl","requirements":["PTO-INST-TILE-TREMS"],"kind":"execution","summary":"TREMS uses divisor-signed modulo for signed integer elements","pass_condition":"S8 minus five modulo positive three produces positive one and positive five modulo three produces two","related_sources":["asl/tile/model/execution/elementwise.asl"]}
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
        TileDataType_S8,
        TileLayout_RowMajor,
        TileLocation_Any);
    ConfigureTile(
        1,
        128,
        8,
        2,
        1,
        2,
        TileDataType_S8,
        TileLayout_RowMajor,
        TileLocation_Any);
    WriteTileElement(
        0,
        0,
        0,
        Zeros{PTO_XLEN} + 251);
    WriteTileElement(
        0,
        0,
        1,
        Zeros{PTO_XLEN} + 5);

    InstructionContractExecute_TREMS(
        1,
        0,
        Zeros{PTO_XLEN} + 3);

    assert ReadTileElement(1, 0, 0) == Zeros{PTO_XLEN} + 1;
    assert ReadTileElement(1, 0, 1) == Zeros{PTO_XLEN} + 2;
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 251;
    return 0;
end;
