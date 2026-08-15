// PTO-TEST: {"id":"PTO-AVS-TILE-TANDS-BITS-001","source":"asl/tile/tile-scalar-and-immediate/logical/TANDS.asl","requirements":["PTO-INST-TILE-TANDS"],"kind":"execution","summary":"TANDS applies raw element-width AND with the scalar","pass_condition":"U8 source patterns AND scalar fifteen preserve only their low nibbles","related_sources":["asl/tile/model/execution/elementwise.asl"]}
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

    InstructionContractExecute_TANDS(
        1,
        0,
        Zeros{PTO_XLEN} + 15);

    assert ReadTileElement(1, 0, 0) == Zeros{PTO_XLEN} + 10;
    assert ReadTileElement(1, 0, 1) == Zeros{PTO_XLEN} + 3;
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 170;
    return 0;
end;
