// PTO-TEST: {"id":"PTO-AVS-BLOCK-MGATHER-CAS-SCHEMA-001","source":"asl/block/execution/BSTART.MGATHER.CAS.asl","requirements":["PTO-BSTART-MGATHER-CAS-SCHEMA-001"],"kind":"fault","summary":"MGATHER.CAS rejects an incomplete scalar-binding schema before effects.","pass_condition":"A block with both required B.IOT commands and LB0 but no B.IOR raises TileLegality without destination allocation, atomic events, or memory writes.","related_sources":["asl/block/model/dispatch/tlsu-mgather-cas.asl"]}
pure func SchemaCasStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00811181;
    instruction[31:27] = Zeros{5} + 27;
    return instruction;
end;

pure func SchemaCasInputs() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00004013;
    instruction[31:26] = Zeros{6} + 1;
    instruction[18:15] = '0000';
    instruction[11:9] = '001';
    return instruction;
end;

pure func SchemaCasOutput() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[25:20] = Zeros{6} + 2;
    instruction[19] = '1';
    instruction[18:15] = '0001';
    instruction[11:9] = '001';
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    ConfigureTile(0, 128, 1, 1, 1, 1, TileDataType_U16,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(1, 128, 1, 1, 1, 1, TileDataType_U8,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(2, 128, 1, 1, 1, 1, TileDataType_U8,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 2);
    Store(Zeros{PTO_XLEN} + 0x200, 1, Zeros{PTO_XLEN} + 1);
    let started = ExecuteCommandInstruction(SchemaCasStart(), 32);
    assert started == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    let inputs = ExecuteCommandInstruction(SchemaCasInputs(), 32);
    assert inputs == CommandExecution_Executed;
    let output = ExecuteCommandInstruction(SchemaCasOutput(), 32);
    assert output == CommandExecution_Executed;
    StartMemoryEventCapture(0);
    let completed = ExecuteBundleTileOperation();
    assert !completed;
    assert _LastFault == Fault_TileLegality;
    assert _MemoryEventCount == 0;
    assert !_BundleTileBindings[[1]].destination_allocated_by_bundle;
    StopMemoryEventCapture();
    let memory = LoadUnsigned(Zeros{PTO_XLEN} + 0x200, 1);
    assert memory == Zeros{PTO_XLEN} + 1;
    return 0;
end;
