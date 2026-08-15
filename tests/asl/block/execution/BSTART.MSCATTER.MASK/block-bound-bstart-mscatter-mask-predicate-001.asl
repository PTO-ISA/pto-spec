// PTO-TEST: {"id":"PTO-AVS-BLOCK-MSCATTER-MASK-PRED-001","source":"asl/block/execution/BSTART.MSCATTER.MASK.asl","requirements":["PTO-MSCATTER-MASK-PREDICATE-001"],"kind":"boundary","summary":"MSCATTER.MASK rejects mask values other than exact zero or one.","pass_condition":"Mask value two raises TileLegality before address generation, events, or writes.","related_sources":["asl/tile/model/definedness/elements.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(1, 128, 1, 1, 1, 1, TileDataType_U8,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(2, 128, 1, 1, 1, 1, TileDataType_U16,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(3, 128, 1, 1, 1, 1, TileDataType_U8,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 0x44);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(3, 0, 0, Zeros{PTO_XLEN} + 2);
    var start: bits(64) = Zeros{64} + 0x00711181;
    start[31:27] = Zeros{5} + 27;
    let started = ExecuteCommandInstruction(start, 32);
    assert started == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    AddBundleTileBinding(FALSE, 0, 0, '0001', TRUE, TRUE, 1, 2, FALSE);
    AddBundleTileBinding(FALSE, 0, 0, '0001', TRUE, FALSE, 3, 0, TRUE);
    SetBundleScalarBinding(0, 0, 0, 0, 0, 1);
    StartMemoryEventCapture(0);
    let completed = ExecuteBundleTileOperation();
    assert !completed;
    assert _LastFault == Fault_TileLegality;
    assert _MemoryEventCount == 0;
    StopMemoryEventCapture();
    return 0;
end;
