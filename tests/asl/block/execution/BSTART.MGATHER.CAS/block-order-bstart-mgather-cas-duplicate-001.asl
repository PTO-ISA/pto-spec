// PTO-TEST: {"id":"PTO-AVS-BLOCK-MGATHER-CAS-DUP-001","source":"asl/block/execution/BSTART.MGATHER.CAS.asl","requirements":["PTO-MGATHER-CAS-ATOMIC-001"],"kind":"ordering","summary":"Duplicate MGATHER.CAS addresses serialize atomically without a fixed lane order.","pass_condition":"Two lanes targeting one byte produce exactly one successful CAS and one of the two complete serialization outcomes.","related_sources":["asl/tile/model/memory/atomics.asl"]}
pure func DuplicateCasStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00811181;
    instruction[31:27] = Zeros{5} + 27;
    return instruction;
end;

pure func DuplicateCasInputs() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00004013;
    instruction[31:26] = Zeros{6} + 1;
    instruction[18:15] = '0000';
    instruction[11:9] = '001';
    return instruction;
end;

pure func DuplicateCasOutput() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[25:20] = Zeros{6} + 2;
    instruction[19] = '1';
    instruction[18:15] = '0001';
    instruction[11:9] = '001';
    return instruction;
end;

pure func DuplicateCasIOR() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000013;
    instruction[19:15] = Zeros{5} + 2;
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    ConfigureTile(0, 128, 1, 2, 1, 2, TileDataType_U32,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(1, 128, 1, 2, 1, 2, TileDataType_U8,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(2, 128, 1, 2, 1, 2, TileDataType_U8,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(0, 0, 1, Zeros{PTO_XLEN});
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 10);
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 10);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 20);
    WriteTileElement(2, 0, 1, Zeros{PTO_XLEN} + 30);
    Store(Zeros{PTO_XLEN} + 0x180, 1, Zeros{PTO_XLEN} + 10);
    WritePEGPR(0, 2, Zeros{PTO_XLEN} + 0x180);
    let started = ExecuteCommandInstruction(DuplicateCasStart(), 32);
    assert started == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    let inputs = ExecuteCommandInstruction(DuplicateCasInputs(), 32);
    assert inputs == CommandExecution_Executed;
    let output = ExecuteCommandInstruction(DuplicateCasOutput(), 32);
    assert output == CommandExecution_Executed;
    let scalar = ExecuteCommandInstruction(DuplicateCasIOR(), 32);
    assert scalar == CommandExecution_Executed;
    StartMemoryEventCapture(0);
    let completed = ExecuteBundleTileOperation();
    assert completed;
    let destination = _BundleTileBindings[[1]].destination;
    let observed0 = ReadTileElement(destination, 0, 0);
    let observed1 = ReadTileElement(destination, 0, 1);
    assert _MemoryEventCount == 2;
    var writes: integer {0..2} = 0;
    for event = 0 to 1 do
        assert _MemoryEvents[[event]].kind == MemoryEvent_Atomic;
        if _MemoryEvents[[event]].write_performed then
            writes = (writes + 1) as integer {0..2};
        end;
    end;
    assert writes == 1;
    StopMemoryEventCapture();
    let memory = LoadUnsigned(Zeros{PTO_XLEN} + 0x180, 1);
    assert (memory == Zeros{PTO_XLEN} + 20 &&
            observed0 == Zeros{PTO_XLEN} + 10 &&
            observed1 == Zeros{PTO_XLEN} + 20) ||
           (memory == Zeros{PTO_XLEN} + 30 &&
            observed0 == Zeros{PTO_XLEN} + 30 &&
            observed1 == Zeros{PTO_XLEN} + 10);
    return 0;
end;
