// PTO-TEST: {"id":"PTO-AVS-BLOCK-MGATHER-CAS-EXEC-001","source":"asl/block/execution/BSTART.MGATHER.CAS.asl","requirements":["PTO-BSTART-MGATHER-CAS-SCHEMA-001","PTO-MGATHER-CAS-ATOMIC-001","PTO-MGATHER-CAS-PUBLICATION-001","PTO-INST-TILE-MGATHER-CAS","PTO-INST-BLOCK-BSTART-MGATHER-CAS"],"kind":"atomicity","summary":"MGATHER.CAS performs typed byte-displacement CAS operations and publishes observed old values.","pass_condition":"Four unique U8 lanes produce two successful writes, two failed writes, the complete old-value destination, and Max padding outside the valid region.","related_sources":["asl/block/model/dispatch/tlsu-mgather-cas.asl","asl/tile/model/memory/atomics.asl"]}
pure func CasStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00811181;
    instruction[31:27] = Zeros{5} + 27;
    return instruction;
end;

pure func CasInputs(mask: bits(4)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00004013;
    instruction[25:20] = Zeros{6};
    instruction[31:26] = Zeros{6} + 1;
    instruction[18:15] = mask;
    return instruction;
end;

pure func CasOutput(mask: bits(4)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[25:20] = Zeros{6} + 2;
    instruction[19] = '1';
    instruction[18:15] = mask;
    instruction[11:9] = '001';
    instruction[8:7] = '00';
    return instruction;
end;

pure func CasIOR() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000013;
    instruction[19:15] = Zeros{5} + 2;
    return instruction;
end;

pure func CasMaxPad() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001023;
    instruction[28:27] = '01';
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    ConfigureTile(0, 128, 2, 2, 2, 2, TileDataType_S16,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(1, 128, 2, 4, 2, 2, TileDataType_U8,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(2, 128, 2, 4, 2, 2, TileDataType_U8,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(0, 0, 0, Ones{PTO_XLEN} - 7);
    WriteTileElement(0, 0, 1, Ones{PTO_XLEN} - 4);
    WriteTileElement(0, 1, 0, Ones{PTO_XLEN} - 2);
    WriteTileElement(0, 1, 1, Ones{PTO_XLEN});
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 10);
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 99);
    WriteTileElement(1, 1, 0, Zeros{PTO_XLEN} + 30);
    WriteTileElement(1, 1, 1, Zeros{PTO_XLEN} + 98);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 100);
    WriteTileElement(2, 0, 1, Zeros{PTO_XLEN} + 101);
    WriteTileElement(2, 1, 0, Zeros{PTO_XLEN} + 102);
    WriteTileElement(2, 1, 1, Zeros{PTO_XLEN} + 103);
    Store(Zeros{PTO_XLEN} + 0x100, 1, Zeros{PTO_XLEN} + 10);
    Store(Zeros{PTO_XLEN} + 0x103, 1, Zeros{PTO_XLEN} + 20);
    Store(Zeros{PTO_XLEN} + 0x105, 1, Zeros{PTO_XLEN} + 30);
    Store(Zeros{PTO_XLEN} + 0x107, 1, Zeros{PTO_XLEN} + 40);
    WritePEGPR(0, 2, Zeros{PTO_XLEN} + 0x108);
    let started = ExecuteCommandInstruction(CasStart(), 32);
    assert started == CommandExecution_Executed;
    let padded = ExecuteCommandInstruction(CasMaxPad(), 32);
    assert padded == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 2);
    let inputs = ExecuteCommandInstruction(CasInputs('0001'), 32);
    assert inputs == CommandExecution_Executed;
    let output = ExecuteCommandInstruction(CasOutput('0001'), 32);
    assert output == CommandExecution_Executed;
    let scalar = ExecuteCommandInstruction(CasIOR(), 32);
    assert scalar == CommandExecution_Executed;
    StartMemoryEventCapture(0);
    let completed = ExecuteBundleTileOperation();
    assert completed;
    let destination = _BundleTileBindings[[1]].destination;
    assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN} + 10;
    assert ReadTileElement(destination, 0, 1) == Zeros{PTO_XLEN} + 20;
    assert ReadTileElement(destination, 1, 0) == Zeros{PTO_XLEN} + 30;
    assert ReadTileElement(destination, 1, 1) == Zeros{PTO_XLEN} + 40;
    assert ReadTileElement(destination, 2, 0) == Zeros{PTO_XLEN} + 0xff;
    assert _MemoryEventCount == 4;
    var writes: integer {0..4} = 0;
    for event = 0 to 3 do
        assert _MemoryEvents[[event]].kind == MemoryEvent_Atomic;
        if _MemoryEvents[[event]].write_performed then
            writes = (writes + 1) as integer {0..4};
        end;
    end;
    assert writes == 2;
    StopMemoryEventCapture();
    let memory0 = LoadUnsigned(Zeros{PTO_XLEN} + 0x100, 1);
    let memory1 = LoadUnsigned(Zeros{PTO_XLEN} + 0x103, 1);
    let memory2 = LoadUnsigned(Zeros{PTO_XLEN} + 0x105, 1);
    let memory3 = LoadUnsigned(Zeros{PTO_XLEN} + 0x107, 1);
    assert memory0 == Zeros{PTO_XLEN} + 100;
    assert memory1 == Zeros{PTO_XLEN} + 20;
    assert memory2 == Zeros{PTO_XLEN} + 102;
    assert memory3 == Zeros{PTO_XLEN} + 40;
    return 0;
end;
