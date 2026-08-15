// PTO-TEST: {"id":"PTO-AVS-TILE-TSHRS-SIGNED-001","source":"asl/tile/tile-scalar-and-immediate/logical/TSHRS.asl","requirements":["PTO-INST-TILE-TSHRS"],"kind":"execution","summary":"TSHRS masks the scalar count and selects arithmetic shift for signed elements","pass_condition":"S8 scalar nine behaves as shift one and preserves the sign bit of negative one hundred twenty-eight","related_sources":["asl/tile/model/execution/elementwise.asl"]}
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
        Zeros{PTO_XLEN} + 128);
    WriteTileElement(
        0,
        0,
        1,
        Zeros{PTO_XLEN} + 126);

    InstructionContractExecute_TSHRS(
        1,
        0,
        Zeros{PTO_XLEN} + 9);

    assert ReadTileElement(1, 0, 0) == Zeros{PTO_XLEN} + 192;
    assert ReadTileElement(1, 0, 1) == Zeros{PTO_XLEN} + 63;
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 128;
    return 0;
end;
