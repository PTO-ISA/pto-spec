// PTO-TEST: {"id":"PTO-AVS-BLOCK-MGATHER-STRIDE-002","source":"asl/block/execution/BSTART.MGATHER.asl","requirements":["PTO-BSTART-MGATHER-SCHEMA-001","PTO-INDEXED-TLSU-STRIDE-001","PTO-INST-TILE-MGATHER"],"kind":"boundary","summary":"MGATHER rejects a GM row stride smaller than ValidCol before effects.","pass_condition":"ValidCol two with stride one raises TileLegality without destination allocation or memory events.","related_sources":["asl/block/model/dispatch/tlsu-mgather.asl","asl/tile/model/legality/memory-schema.asl"]}
pure func UndersizedStrideGatherStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00411181;
    instruction[31:27] = Zeros{5} + 27;
    return instruction;
end;

pure func UndersizedStrideGatherBinding() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[19] = '1';
    instruction[18:15] = '0001';
    instruction[11:9] = '001';
    return instruction;
end;

pure func UndersizedStrideGatherIOR() => bits(64)
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
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(0, 0, 1, Zeros{PTO_XLEN} + 1);
    WritePEGPR(0, 2, Zeros{PTO_XLEN} + 0x200);
    WritePEGPR(0, 4, Zeros{PTO_XLEN} + 1);

    let started = ExecuteCommandInstruction(
        UndersizedStrideGatherStart(), 32);
    assert started == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    let bound = ExecuteCommandInstruction(
        UndersizedStrideGatherBinding(), 32);
    assert bound == CommandExecution_Executed;
    let scalar = ExecuteCommandInstruction(
        UndersizedStrideGatherIOR(), 32);
    assert scalar == CommandExecution_Executed;

    StartMemoryEventCapture(0);
    let completed = ExecuteBundleTileOperation();
    assert !completed;
    assert _LastFault == Fault_TileLegality;
    assert _MemoryEventCount == 0;
    assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;
    StopMemoryEventCapture();
    return 0;
end;
