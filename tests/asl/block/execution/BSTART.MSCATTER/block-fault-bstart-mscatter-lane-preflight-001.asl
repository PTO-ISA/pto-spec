// PTO-TEST: {"id":"PTO-AVS-BLOCK-MSCATTER-FAULT-001","source":"asl/block/execution/BSTART.MSCATTER.asl","requirements":["PTO-MSCATTER-BYTE-DISPLACEMENT-001","PTO-INST-TILE-MSCATTER"],"kind":"fault","summary":"MSCATTER preflights all valid lanes before its first write or event.","pass_condition":"A faulting second U16 lane leaves the first address unchanged and records no memory event.","related_sources":["asl/tile/model/memory/gather-scatter.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(1, 128, 1, 2, 1, 2, TileDataType_U16,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(2, 128, 1, 2, 1, 2, TileDataType_U32,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 0x1111);
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 0x2222);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(2, 0, 1, Zeros{PTO_XLEN} + 2);
    Store(Zeros{PTO_XLEN} + 4094, 2, Zeros{PTO_XLEN} + 0xaaaa);
    WritePEGPR(0, 2, Zeros{PTO_XLEN} + 4094);
    var start: bits(64) = Zeros{64} + 0x00511181;
    start[31:27] = Zeros{5} + 26;
    let started = ExecuteCommandInstruction(start, 32);
    assert started == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    WritePEGPR(0, 4, Zeros{PTO_XLEN} + 2);
    AddBundleTileBinding(FALSE, 0, 0, '0001', TRUE, TRUE, 1, 2, TRUE);
    SetBundleScalarBinding(0, 0, 2, 4, 0, 2);
    StartMemoryEventCapture(0);
    let completed = ExecuteBundleTileOperation();
    assert !completed;
    assert _LastFault == Fault_DataPage;
    assert _MemoryEventCount == 0;
    StopMemoryEventCapture();
    let observed = LoadUnsigned(Zeros{PTO_XLEN} + 4094, 2);
    assert observed == Zeros{PTO_XLEN} + 0xaaaa;
    return 0;
end;
