// PTO-TEST: {"id":"PTO-AVS-BLOCK-MGATHER-CAS-PACKED-001","source":"asl/block/execution/BSTART.MGATHER.CAS.asl","requirements":["PTO-BSTART-MGATHER-CAS-SCHEMA-001"],"kind":"boundary","summary":"MGATHER.CAS reserves packed four-bit transfer types.","pass_condition":"A complete U4X2 block is rejected before destination allocation, atomic events, or memory effects because no nibble selector is encoded.","related_sources":["asl/tile/model/legality/memory-schema.asl","asl/tile/model/memory/addressing.asl"]}
pure func PackedCasStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00811181;
    instruction[31:27] = Zeros{5} + 28;
    return instruction;
end;

pure func PackedCasInputs() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00004013;
    instruction[31:26] = Zeros{6} + 1;
    instruction[18:15] = '0000';
    instruction[11:9] = '001';
    return instruction;
end;

pure func PackedCasOutput() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[25:20] = Zeros{6} + 2;
    instruction[19] = '1';
    instruction[18:15] = '0001';
    instruction[11:9] = '001';
    return instruction;
end;

pure func PackedCasIOR() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000013;
    instruction[19:15] = Zeros{5} + 2;
    instruction[24:20] = Zeros{5} + 4;
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    ConfigureTile(0, 128, 1, 2, 1, 2, TileDataType_U16,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(1, 128, 1, 2, 1, 2, TileDataType_U4X2,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(2, 128, 1, 2, 1, 2, TileDataType_U4X2,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(0, 0, 1, Zeros{PTO_XLEN} + 1);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 2);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(2, 0, 1, Zeros{PTO_XLEN} + 4);
    WritePEGPR(0, 2, Zeros{PTO_XLEN} + 0x240);
    let started = ExecuteCommandInstruction(PackedCasStart(), 32);
    assert started == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    WritePEGPR(0, 4, Zeros{PTO_XLEN} + 2);
    let inputs = ExecuteCommandInstruction(PackedCasInputs(), 32);
    assert inputs == CommandExecution_Executed;
    let output = ExecuteCommandInstruction(PackedCasOutput(), 32);
    assert output == CommandExecution_Executed;
    let scalar = ExecuteCommandInstruction(PackedCasIOR(), 32);
    assert scalar == CommandExecution_Executed;
    StartMemoryEventCapture(0);
    let completed = ExecuteBundleTileOperation();
    assert !completed;
    assert _LastFault == Fault_TileLegality;
    assert _MemoryEventCount == 0;
    assert !_BundleTileBindings[[1]].destination_allocated_by_bundle;
    StopMemoryEventCapture();
    return 0;
end;
