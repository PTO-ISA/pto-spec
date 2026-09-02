// PTO-TEST: {"id":"PTO-AVS-BLOCK-MGATHER-FAULT-001","source":"asl/block/execution/BSTART.MGATHER.asl","requirements":["PTO-MGATHER-BYTE-DISPLACEMENT-001","PTO-INST-TILE-MGATHER"],"kind":"fault","summary":"MGATHER preflights every row-indexed lane before events or destination publication.","pass_condition":"A fault on the second U16 column rolls back destination allocation and leaves the event log empty.","related_sources":["asl/tile/model/memory/gather-scatter.asl"]}
pure func FaultGatherStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00411181;
    instruction[31:27] = Zeros{5} + 26;
    return instruction;
end;

pure func FaultGatherBinding() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[19] = '1';
    instruction[18:15] = '0001';
    instruction[11:9] = '001';
    return instruction;
end;

pure func FaultGatherIOR() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000013;
    instruction[19:15] = Zeros{5} + 2;
    instruction[24:20] = Zeros{5} + 4;
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    ConfigureTile(0, 128, 1, 1, 1, 1, TileDataType_U32,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN});
    WritePEGPR(0, 2, Zeros{PTO_XLEN} + 4094);
    let started = ExecuteCommandInstruction(FaultGatherStart(), 32);
    assert started == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    WritePEGPR(0, 4, Zeros{PTO_XLEN} + 2);
    let tiles = ExecuteCommandInstruction(FaultGatherBinding(), 32);
    assert tiles == CommandExecution_Executed;
    let scalar = ExecuteCommandInstruction(FaultGatherIOR(), 32);
    assert scalar == CommandExecution_Executed;
    StartMemoryEventCapture(0);
    let completed = ExecuteBundleTileOperation();
    assert !completed;
    assert _LastFault == Fault_DataPage;
    assert _MemoryEventCount == 0;
    assert CoreTileCapacityInUse() == 128;
    assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;
    StopMemoryEventCapture();
    return 0;
end;
