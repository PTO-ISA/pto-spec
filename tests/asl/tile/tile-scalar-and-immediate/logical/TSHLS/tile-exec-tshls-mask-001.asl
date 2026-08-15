// PTO-TEST: {"id":"PTO-AVS-TILE-TSHLS-MASK-001","source":"asl/tile/tile-scalar-and-immediate/logical/TSHLS.asl","requirements":["PTO-INST-TILE-TSHLS"],"kind":"execution","summary":"TSHLS masks the scalar shift count by the selected element width","pass_condition":"U8 scalar nine behaves as shift one and results remain eight bits wide","related_sources":["asl/tile/model/execution/elementwise.asl"]}
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
        Zeros{PTO_XLEN} + 129);
    WriteTileElement(
        0,
        0,
        1,
        Zeros{PTO_XLEN} + 3);

    InstructionContractExecute_TSHLS(
        1,
        0,
        Zeros{PTO_XLEN} + 9);

    assert ReadTileElement(1, 0, 0) == Zeros{PTO_XLEN} + 2;
    assert ReadTileElement(1, 0, 1) == Zeros{PTO_XLEN} + 6;
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 129;
    return 0;
end;
