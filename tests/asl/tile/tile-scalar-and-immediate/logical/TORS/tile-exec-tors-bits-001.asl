// PTO-TEST: {"id":"PTO-AVS-TILE-TORS-BITS-001","source":"asl/tile/tile-scalar-and-immediate/logical/TORS.asl","requirements":["PTO-INST-TILE-TORS"],"kind":"execution","summary":"TORS applies raw element-width OR with the scalar","pass_condition":"U8 source patterns OR scalar fifteen set their low nibbles","related_sources":["asl/tile/model/execution/elementwise.asl"]}
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
        Zeros{PTO_XLEN} + 160);
    WriteTileElement(
        0,
        0,
        1,
        Zeros{PTO_XLEN} + 240);

    InstructionContractExecute_TORS(
        1,
        0,
        Zeros{PTO_XLEN} + 15);

    assert ReadTileElement(1, 0, 0) == Zeros{PTO_XLEN} + 175;
    assert ReadTileElement(1, 0, 1) == Zeros{PTO_XLEN} + 255;
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 160;
    return 0;
end;
