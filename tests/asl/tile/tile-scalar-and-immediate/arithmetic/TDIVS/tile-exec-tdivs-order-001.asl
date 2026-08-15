// PTO-TEST: {"id":"PTO-AVS-TILE-TDIVS-ORDER-001","source":"asl/tile/tile-scalar-and-immediate/arithmetic/TDIVS.asl","requirements":["PTO-INST-TILE-TDIVS"],"kind":"execution","summary":"TDIVS divides the Tile element by the scalar in source-first order","pass_condition":"U8 values nine and two hundred fifty-five divided by scalar two produce four and one hundred twenty-seven","related_sources":["asl/tile/model/execution/elementwise.asl"]}
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
        Zeros{PTO_XLEN} + 9);
    WriteTileElement(
        0,
        0,
        1,
        Zeros{PTO_XLEN} + 255);

    InstructionContractExecute_TDIVS(
        1,
        0,
        Zeros{PTO_XLEN} + 2);

    assert ReadTileElement(1, 0, 0) == Zeros{PTO_XLEN} + 4;
    assert ReadTileElement(1, 0, 1) == Zeros{PTO_XLEN} + 127;
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 9;
    return 0;
end;
