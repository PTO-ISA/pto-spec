// PTO-TEST: {"id":"PTO-AVS-TILE-TNEG-ALIAS-001","source":"asl/tile/elementwise-tile-tile/logical/TNEG.asl","requirements":["PTO-TNEG-CONTRACT-001","PTO-INST-TILE-TNEG"],"kind":"execution","summary":"TNEG snapshots the source before an aliased destination write.","pass_condition":"When destination equals source, TNEG computes from the original source element.","related_sources":["asl/tile/model/execution/unary.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(0, 128, 1, 1, 1, 1, TileDataType_S8,
        TileLayout_RowMajor);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 1);

    assert TNEGOperandsLegal(0, 0);
    ExecuteTNEG(0, 0);
    assert ReadTileElement(0, 0, 0) ==
        Zeros{PTO_XLEN} + 0xff;
    return 0;
end;
