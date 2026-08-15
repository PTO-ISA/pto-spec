// PTO-TEST: {"id":"PTO-AVS-BLOCK-TPREFETCH-FOOTPRINT-001","source":"asl/block/execution/BSTART.TPREFETCH.asl","requirements":["PTO-BSTART-TPREFETCH-MEMORY-001","PTO-TPREFETCH-FOOTPRINT-001","PTO-INST-TILE-TPREFETCH","PTO-INST-BLOCK-BSTART-TPREFETCH"],"kind":"execution","summary":"TPREFETCH reads four PE-private base and stride pairs and records TLOAD-equivalent typed events.","pass_condition":"The combined U16 2x2 footprints produce sixteen correctly addressed acquire events grouped by PE and no Tile allocation.","related_sources":["asl/tile/model/memory/gather-scatter.asl","asl/arch/programming-model/scalar-registers.asl"]}
pure func PrefetchFootprintStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00311181;
    instruction[31:27] = Zeros{5} + 26;
    return instruction;
end;

pure func PrefetchFootprintIOR() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000013;
    instruction[19:15] = Zeros{5} + 2;
    instruction[24:20] = Zeros{5} + 3;
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    WritePEGPR(0, 2, Zeros{PTO_XLEN} + 0x100);
    WritePEGPR(1, 2, Zeros{PTO_XLEN} + 0x200);
    WritePEGPR(2, 2, Zeros{PTO_XLEN} + 0x300);
    WritePEGPR(3, 2, Zeros{PTO_XLEN} + 0x400);
    WritePEGPR(0, 3, Zeros{PTO_XLEN} + 4);
    WritePEGPR(1, 3, Zeros{PTO_XLEN} + 5);
    WritePEGPR(2, 3, Zeros{PTO_XLEN} + 6);
    WritePEGPR(3, 3, Zeros{PTO_XLEN} + 7);
    let started = ExecuteCommandInstruction(PrefetchFootprintStart(), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 4);
    let bound = ExecuteCommandInstruction(PrefetchFootprintIOR(), 32);
    assert started == CommandExecution_Executed;
    assert bound == CommandExecution_Executed;
    _BundleControlAttributes.acquire = TRUE;
    StartMemoryEventCapture(0);
    let completed = ExecuteBundleTileOperation();
    assert completed;
    assert _MemoryEventCount == 16;
    assert _MemoryEvents[[0]].agent == 0;
    assert _MemoryEvents[[0]].address == Zeros{PTO_XLEN} + 0x100;
    assert _MemoryEvents[[1]].address == Zeros{PTO_XLEN} + 0x102;
    assert _MemoryEvents[[2]].address == Zeros{PTO_XLEN} + 0x108;
    assert _MemoryEvents[[3]].address == Zeros{PTO_XLEN} + 0x10a;
    assert _MemoryEvents[[4]].agent == 1;
    assert _MemoryEvents[[6]].address == Zeros{PTO_XLEN} + 0x20a;
    assert _MemoryEvents[[8]].agent == 2;
    assert _MemoryEvents[[10]].address == Zeros{PTO_XLEN} + 0x30c;
    assert _MemoryEvents[[12]].agent == 3;
    assert _MemoryEvents[[14]].address == Zeros{PTO_XLEN} + 0x40e;
    for event = 0 to 15 do
        assert _MemoryEvents[[event]].kind == MemoryEvent_Load;
        assert _MemoryEvents[[event]].size_bytes == 2;
        assert _MemoryEvents[[event]].order == MemoryOrder_Acquire;
    end;
    assert CoreTileCapacityInUse() == 0;
    StopMemoryEventCapture();
    return 0;
end;
