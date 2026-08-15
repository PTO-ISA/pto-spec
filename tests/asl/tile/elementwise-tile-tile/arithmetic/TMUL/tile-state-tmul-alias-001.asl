// PTO-TEST: {"id":"PTO-AVS-TILE-TMUL-ALIAS-001","source":"asl/tile/elementwise-tile-tile/arithmetic/TMUL.asl","requirements":["PTO-INST-TILE-TMUL"],"kind":"state-transition","summary":"TMUL snapshots both sources before a destination aliases the left source","pass_condition":"every aliased destination element uses the complete pre-operation left payload","related_sources":["asl/tile/model/execution/elementwise.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(0, 128, 4, 4, 1, 2, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(1, 128, 4, 4, 1, 2, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(0, 0, 1, Zeros{PTO_XLEN} + 5);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 7);
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 11);

    assert InstructionContractOperandsLegal_TMUL(0, 0, 1);
    InstructionContractExecute_TMUL(0, 0, 1);
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 21;
    assert ReadTileElement(0, 0, 1) == Zeros{PTO_XLEN} + 55;
    return 0;
end;
