// PTO-TEST: {"id":"PTO-AVS-TILE-TSUBS-ORDER-001","source":"asl/tile/tile-scalar-and-immediate/arithmetic/TSUBS.asl","requirements":["PTO-INST-TILE-TSUBS"],"kind":"execution","summary":"TSUBS preserves operand order and wraps at the selected element width","pass_condition":"U8 values three and nine minus scalar five produce 254 and four while the source persists","related_sources":["asl/tile/model/execution/elementwise.asl"]}
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
        Zeros{PTO_XLEN} + 3);
    WriteTileElement(
        0,
        0,
        1,
        Zeros{PTO_XLEN} + 9);

    InstructionContractExecute_TSUBS(
        1,
        0,
        Zeros{PTO_XLEN} + 5);

    assert ReadTileElement(1, 0, 0) == Zeros{PTO_XLEN} + 254;
    assert ReadTileElement(1, 0, 1) == Zeros{PTO_XLEN} + 4;
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 3;
    return 0;
end;
