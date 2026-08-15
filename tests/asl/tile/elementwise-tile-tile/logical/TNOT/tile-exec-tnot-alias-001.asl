// PTO-TEST: {"id":"PTO-AVS-TILE-TNOT-ALIAS-001","source":"asl/tile/elementwise-tile-tile/logical/TNOT.asl","requirements":["PTO-TNOT-CONTRACT-001","PTO-INST-TILE-TNOT"],"kind":"execution","summary":"TNOT snapshots the source before an aliased destination write.","pass_condition":"When destination equals source, TNOT computes from the original source element.","related_sources":["asl/tile/model/execution/unary.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(0, 128, 1, 1, 1, 1, TileDataType_U8,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0x0f);

    assert InstructionContractOperandsLegal_TNOT(0, 0);
    InstructionContractExecute_TNOT(0, 0);
    assert ReadTileElement(0, 0, 0) ==
        Zeros{PTO_XLEN} + 0xf0;
    return 0;
end;
