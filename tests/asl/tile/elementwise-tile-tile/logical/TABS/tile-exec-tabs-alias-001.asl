// PTO-TEST: {"id":"PTO-AVS-TILE-TABS-ALIAS-001","source":"asl/tile/elementwise-tile-tile/logical/TABS.asl","requirements":["PTO-TABS-CONTRACT-001","PTO-INST-TILE-TABS"],"kind":"execution","summary":"TABS snapshots the source before an aliased destination write.","pass_condition":"When destination equals source, TABS computes from the original source element.","related_sources":["asl/tile/model/execution/unary.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(0, 128, 1, 1, 1, 1, TileDataType_S8,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0xff);

    assert InstructionContractOperandsLegal_TABS(0, 0);
    InstructionContractExecute_TABS(0, 0);
    assert ReadTileElement(0, 0, 0) ==
        Zeros{PTO_XLEN} + 1;
    return 0;
end;
