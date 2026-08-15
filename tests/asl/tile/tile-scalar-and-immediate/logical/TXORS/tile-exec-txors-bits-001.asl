// PTO-TEST: {"id":"PTO-AVS-TILE-TXORS-BITS-001","source":"asl/tile/tile-scalar-and-immediate/logical/TXORS.asl","requirements":["PTO-INST-TILE-TXORS"],"kind":"execution","summary":"TXORS applies raw element-width XOR with the scalar","pass_condition":"U8 source patterns XOR scalar fifteen invert their low nibbles","related_sources":["asl/tile/model/execution/elementwise.asl"]}
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
        Zeros{PTO_XLEN} + 170);
    WriteTileElement(
        0,
        0,
        1,
        Zeros{PTO_XLEN} + 243);

    InstructionContractExecute_TXORS(
        1,
        0,
        Zeros{PTO_XLEN} + 15);

    assert ReadTileElement(1, 0, 0) == Zeros{PTO_XLEN} + 165;
    assert ReadTileElement(1, 0, 1) == Zeros{PTO_XLEN} + 252;
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 170;
    return 0;
end;
