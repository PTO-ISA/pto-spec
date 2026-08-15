// PTO-TEST: {"id":"PTO-AVS-TILE-TMAX-ALIAS-001","source":"asl/tile/elementwise-tile-tile/arithmetic/TMAX.asl","requirements":["PTO-TMAX-CONTRACT-001"],"kind":"execution","summary":"TMAX snapshots aliased sources before writing the destination.","pass_condition":"When destination aliases the left source, the comparison uses the original left value.","related_sources":["asl/tile/model/execution/elementwise.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(0, 128, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(1, 128, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 5);

    assert InstructionContractOperandsLegal_TMAX(0, 0, 1);
    InstructionContractExecute_TMAX(0, 0, 1);
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 5;
    return 0;
end;
