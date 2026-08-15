// PTO-TEST: {"id":"PTO-AVS-BLOCK-MSCATTER-PACKED-001","source":"asl/block/execution/BSTART.MSCATTER.asl","requirements":["PTO-MSCATTER-BYTE-DISPLACEMENT-001"],"kind":"boundary","summary":"MSCATTER rejects packed four-bit transfer types without a nibble selector.","pass_condition":"A U4X2 source and transfer DataType reject before memory events or writes.","related_sources":["asl/tile/model/legality/memory-schema.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(1, 128, 1, 2, 1, 2, TileDataType_U4X2,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(2, 128, 1, 2, 1, 2, TileDataType_U16,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 2);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(2, 0, 1, Zeros{PTO_XLEN} + 1);
    var start: bits(64) = Zeros{64} + 0x00511181;
    start[31:27] = Zeros{5} + 28;
    let started = ExecuteCommandInstruction(start, 32);
    assert started == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    AddBundleTileBinding(FALSE, 0, 0, '0001', TRUE, TRUE, 1, 2, TRUE);
    SetBundleScalarBinding(0, 0, 0, 0, 0, 1);
    StartMemoryEventCapture(0);
    let completed = ExecuteBundleTileOperation();
    assert !completed;
    assert _LastFault == Fault_TileLegality;
    assert _MemoryEventCount == 0;
    StopMemoryEventCapture();
    return 0;
end;
