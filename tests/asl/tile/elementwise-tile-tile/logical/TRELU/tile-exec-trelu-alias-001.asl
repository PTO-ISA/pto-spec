// PTO-TEST: {"id":"PTO-AVS-TILE-TRELU-ALIAS-001","source":"asl/tile/elementwise-tile-tile/logical/TRELU.asl","requirements":["PTO-TRELU-CONTRACT-001","PTO-INST-TILE-TRELU"],"kind":"execution","summary":"TRELU snapshots the source before an aliased destination write.","pass_condition":"When destination equals source, TRELU computes from the original source element.","related_sources":["asl/tile/model/execution/unary.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(0, 128, 1, 1, 1, 1, TileDataType_S8,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0xff);

    assert InstructionContractOperandsLegal_TRELU(0, 0);
    InstructionContractExecute_TRELU(0, 0);
    assert ReadTileElement(0, 0, 0) ==
        Zeros{PTO_XLEN} + 0;
    return 0;
end;
