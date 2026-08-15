// PTO-TEST: {"id":"PTO-AVS-BLOCK-B-IOT-SOURCE-PERSIST-001","source":"asl/block/operands/B.IOT.asl","requirements":["PTO-INST-BLOCK-B-IOT"],"kind":"state-transition","summary":"L does not end a Local source descriptor lifetime.","pass_condition":"Successful block finalization leaves every B.IOT Local source allocated and unchanged.","related_sources":["asl/block/model/operands/tile-bindings.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(7, 128, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(7, 0, 0, Zeros{PTO_XLEN} + 0x55);
    AddBundleTileBinding(FALSE, 0, 0, '0001', TRUE, FALSE, 7, 0, TRUE);
    FinalizeBundleTileAttempt(TileExecution_Executed);
    assert _Tiles[[7]].allocated;
    assert ReadTileElement(7, 0, 0) == Zeros{PTO_XLEN} + 0x55;
    return 0;
end;
