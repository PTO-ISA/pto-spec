// PTO-TEST: {"id":"PTO-AVS-BLOCK-I414-MGATHER-CAS-RANGE-FAULT-001","source":"asl/block/execution/BSTART.MGATHER.CAS.asl","requirements":["PTO-INDEXED-TLSU-RANGE-BINDING-001","PTO-B-IOR-BINDING-001","PTO-BSTART-MGATHER-CAS-SCHEMA-001","PTO-MGATHER-CAS-ATOMIC-001","PTO-MGATHER-CAS-PUBLICATION-001","PTO-INST-BLOCK-BSTART-MGATHER-CAS","PTO-INST-TILE-MGATHER-CAS"],"kind":"fault","summary":"An invalid current-PE MGATHER.CAS range faults before allocation, publication, or atomic effects.","pass_condition":"Encoded Min=7 and Max=6 produce Fault_TileLegality, no CAS event or bundle destination allocation, no return-old publication, and unchanged GM bytes.","related_sources":["asl/block/model/dispatch/indexed-tlsu-range-schema.asl","asl/block/model/dispatch/tlsu-mgather-cas.asl","asl/tile/model/memory/addressing.asl","asl/tile/model/memory/atomics.asl"]}
pure func CasStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00811181;
    instruction[31:27] = Zeros{5} + 26;
    return instruction;
end;

pure func CasInputs() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00004013;
    instruction[31:26] = Zeros{6} + 1;
    instruction[11:9] = '001';
    instruction[11:9] = '001';
    return instruction;
end;

pure func CasOutput() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[25:20] = Zeros{6} + 2;
    instruction[19] = '1';
    instruction[18:15] = '0001';
    instruction[11:9] = '001';
    return instruction;
end;

pure func CasIOR() => bits(64)
begin
    var instruction = Zeros{64} + 0x00000013;
    instruction[19:15] = Zeros{5} + 2;
    instruction[24:20] = Zeros{5} + 3;
    instruction[31:27] = Zeros{5} + 4;
    return instruction;
end;

pure func CasMaxPad() => bits(64)
begin
    var instruction = Zeros{64} + 0x00001023;
    instruction[28:27] = '01';
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    ConfigureTile(0, 128, 2, 2, 2, 2, TileDataType_S32,
        TileLayout_RowMajor);
    ConfigureTile(1, 128, 2, 4, 2, 2, TileDataType_U16,
        TileLayout_RowMajor);
    ConfigureTile(2, 128, 2, 4, 2, 2, TileDataType_U16,
        TileLayout_RowMajor);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(0, 0, 1, Zeros{PTO_XLEN} + 2);
    WriteTileElement(0, 1, 0, Zeros{PTO_XLEN} + 4);
    WriteTileElement(0, 1, 1, Zeros{PTO_XLEN} + 6);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 10);
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 99);
    WriteTileElement(1, 1, 0, Zeros{PTO_XLEN} + 30);
    WriteTileElement(1, 1, 1, Zeros{PTO_XLEN} + 98);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 100);
    WriteTileElement(2, 0, 1, Zeros{PTO_XLEN} + 101);
    WriteTileElement(2, 1, 0, Zeros{PTO_XLEN} + 102);
    WriteTileElement(2, 1, 1, Zeros{PTO_XLEN} + 103);
    Store(Zeros{PTO_XLEN} + 0x100, 2, Zeros{PTO_XLEN} + 10);
    Store(Zeros{PTO_XLEN} + 0x102, 2, Zeros{PTO_XLEN} + 20);
    Store(Zeros{PTO_XLEN} + 0x104, 2, Zeros{PTO_XLEN} + 30);
    Store(Zeros{PTO_XLEN} + 0x106, 2, Zeros{PTO_XLEN} + 40);
    WritePEGPR(0, 2, Zeros{PTO_XLEN} + 0x100);
    WritePEGPR(0, 3, Zeros{64} + 7);
    WritePEGPR(0, 4, Zeros{64} + 6);
    let started = ExecuteCommandInstruction(CasStart(), 32);
    let padded = ExecuteCommandInstruction(CasMaxPad(), 32);
    assert started == CommandExecution_Executed;
    assert padded == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    WritePEGPR(0, 4, Zeros{64} + 2);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 2);
    let inputs = ExecuteCommandInstruction(CasInputs(), 32);
    let output = ExecuteCommandInstruction(CasOutput(), 32);
    let scalar = ExecuteCommandInstruction(CasIOR(), 32);
    assert inputs == CommandExecution_Executed;
    assert output == CommandExecution_Executed;
    assert scalar == CommandExecution_Executed;
    // Change the full-width Max operand after binding to exercise request-time
    // PE-local values; Min=7 remains greater than Max=2.
    WritePEGPR(0, 4, Zeros{64} + 2);
    StartMemoryEventCapture(0);
    let completed = ExecuteBundleTileOperation();
    assert !completed && _LastFault == Fault_TileLegality;
    assert _MemoryEventCount == 0;
    assert !_BundleTileBindings[[1]].destination_allocated_by_bundle;
    StopMemoryEventCapture();
    let observed_0 = LoadUnsigned(Zeros{PTO_XLEN} + 0x100, 2);
    let observed_1 = LoadUnsigned(Zeros{PTO_XLEN} + 0x102, 2);
    let observed_2 = LoadUnsigned(Zeros{PTO_XLEN} + 0x104, 2);
    let observed_3 = LoadUnsigned(Zeros{PTO_XLEN} + 0x106, 2);
    assert observed_0 == Zeros{PTO_XLEN} + 10;
    assert observed_1 == Zeros{PTO_XLEN} + 20;
    assert observed_2 == Zeros{PTO_XLEN} + 30;
    assert observed_3 == Zeros{PTO_XLEN} + 40;
    return 0;
end;
