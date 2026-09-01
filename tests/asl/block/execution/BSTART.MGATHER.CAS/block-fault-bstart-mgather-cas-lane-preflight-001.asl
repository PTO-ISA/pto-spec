// PTO-TEST: {"id":"PTO-AVS-BLOCK-MGATHER-CAS-FAULT-001","source":"asl/block/execution/BSTART.MGATHER.CAS.asl","requirements":["PTO-MGATHER-CAS-PUBLICATION-001","PTO-INST-TILE-ATOM-CAS"],"kind":"fault","summary":"MGATHER.CAS preflights every read and write lane before atomic effects.","pass_condition":"A page fault on the second U16 lane rolls back destination allocation and leaves the first lane, memory, and atomic-event log unchanged.","related_sources":["asl/tile/model/memory/atomics.asl","asl/arch/memory-model/fault-precision.asl"]}
pure func FaultCasStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00811181;
    instruction[31:27] = Zeros{5} + 26;
    return instruction;
end;

pure func FaultCasInputs() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00004013;
    instruction[31:26] = Zeros{6} + 1;
    instruction[18:15] = '0000';
    instruction[11:9] = '001';
    return instruction;
end;

pure func FaultCasOutput() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[25:20] = Zeros{6} + 2;
    instruction[19] = '1';
    instruction[18:15] = '0001';
    instruction[11:9] = '001';
    return instruction;
end;

pure func FaultCasIOR() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000013;
    instruction[19:15] = Zeros{5} + 2;
    instruction[24:20] = Zeros{5} + 4;
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    ConfigureTile(0, 128, 1, 2, 1, 2, TileDataType_U32,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(1, 128, 1, 2, 1, 2, TileDataType_U16,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(2, 128, 1, 2, 1, 2, TileDataType_U16,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(0, 0, 1, Zeros{PTO_XLEN} + 2);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 11);
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 22);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 111);
    WriteTileElement(2, 0, 1, Zeros{PTO_XLEN} + 222);
    Store(Zeros{PTO_XLEN} + 4094, 2, Zeros{PTO_XLEN} + 11);
    WritePEGPR(0, 2, Zeros{PTO_XLEN} + 4094);
    let started = ExecuteCommandInstruction(FaultCasStart(), 32);
    assert started == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    WritePEGPR(0, 4, Zeros{PTO_XLEN} + 2);
    let inputs = ExecuteCommandInstruction(FaultCasInputs(), 32);
    assert inputs == CommandExecution_Executed;
    let output = ExecuteCommandInstruction(FaultCasOutput(), 32);
    assert output == CommandExecution_Executed;
    let scalar = ExecuteCommandInstruction(FaultCasIOR(), 32);
    assert scalar == CommandExecution_Executed;
    StartMemoryEventCapture(0);
    let completed = ExecuteBundleTileOperation();
    assert !completed;
    assert _LastFault == Fault_DataPage;
    assert _MemoryEventCount == 0;
    assert !_BundleTileBindings[[1]].destination_allocated_by_bundle;
    StopMemoryEventCapture();
    let first = LoadUnsigned(Zeros{PTO_XLEN} + 4094, 2);
    assert first == Zeros{PTO_XLEN} + 11;
    return 0;
end;
