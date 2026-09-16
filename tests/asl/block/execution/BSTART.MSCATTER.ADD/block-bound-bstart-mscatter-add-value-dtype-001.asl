// PTO-TEST: {"id":"PTO-AVS-BLOCK-MSCATTER-ADD-VALUE-DTYPE-001","source":"asl/block/execution/BSTART.MSCATTER.ADD.asl","requirements":["PTO-ATOM-RED-TYPE-LEGALITY-001","PTO-INST-BLOCK-BSTART-MSCATTER-ADD"],"kind":"boundary","summary":"BSTART.MSCATTER.ADD requires the ValueTile type to equal its encoded operation type.","pass_condition":"An encoded U32 ADD with a U64 ValueTile faults before memory events or writes.","related_sources":["asl/block/model/dispatch/tlsu-gm-atom-red.asl","asl/tile/model/memory/gm-atom-red.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(1, 128, 1, 1, 1, 1, TileDataType_S32,
        TileLayout_RowMajor);
    ConfigureTile(2, 128, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 4);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 5);
    Store(Zeros{PTO_XLEN} + 0x204, 4, Zeros{PTO_XLEN} + 7);
    WritePEGPR(0, 2, Zeros{PTO_XLEN} + 0x200);
    var start: bits(64) = Zeros{64} + 0x01511181;
    start[31:27] = Zeros{5} + 27;
    let started = ExecuteCommandInstruction(start, 32);
    assert started == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 1);
    WritePEGPR(0, 4, Zeros{PTO_XLEN} + 1);
    AddBundleTileBinding(FALSE, 0, 0, '0001', TRUE, TRUE, 1, 2, TRUE);
    SetBundleScalarBinding(0, 0, 2, 0, 0, 2);
    StartMemoryEventCapture(0);
    let completed = ExecuteBundleTileOperation();
    assert !completed;
    assert _LastFault == Fault_TileLegality;
    assert _MemoryEventCount == 0;
    let observed = LoadUnsigned(Zeros{PTO_XLEN} + 0x204, 4);
    assert observed == Zeros{PTO_XLEN} + 7;
    StopMemoryEventCapture();
    return 0;
end;
