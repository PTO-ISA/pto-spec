// PTO-TEST: {"id":"PTO-AVS-BLOCK-I414-MALFORMED-MISSING-FINAL-FLAG-001","source":"asl/block/execution/BSTART.MGATHER.asl","requirements":["PTO-INDEXED-TLSU-RANGE-BINDING-001","PTO-B-IOR-BINDING-001","PTO-BSTART-MGATHER-SCHEMA-001"],"kind":"fault","summary":"missing final ExecMaskPresent","pass_condition":"The combined mask record without ExecMaskPresent faults before destination allocation or memory effects.","related_sources":["asl/block/model/dispatch/commands.asl","asl/block/model/dispatch/indexed-tlsu-range-command-stream.asl","asl/block/model/dispatch/indexed-tlsu-range-schema.asl","asl/block/model/dispatch/scalar-schema.asl"]}
pure func I414MalformedStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00411181;
    instruction[31:27] = TileDataTypeToEncoding(TileDataType_U32);
    return instruction;
end;

pure func I414MalformedInput() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[25:20] = Zeros{6} + 10;
    instruction[19] = '1';
    instruction[18:15] = '0001';
    instruction[11:9] = '001';
    return instruction;
end;

pure func I414MalformedIOR(source0: integer, source1: integer,
    source2: integer, destination: integer, mask_flag: boolean) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000013;
    instruction[19:15] = Zeros{5} + source0;
    instruction[24:20] = Zeros{5} + source1;
    instruction[31:27] = Zeros{5} + source2;
    instruction[11:7] = Zeros{5} + destination;
    instruction[26] = if mask_flag then '1' else '0';
    return instruction;
end;

func SetupI414MalformedGather()
begin
    ResetProfileState();
    let ready = ConfigureCubeTile(10, 128, 1, 2, TileDataType_U32,
        TileLayout_CUBE_M16);
    assert ready;
    WriteTileElement(10, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(10, 0, 1, Zeros{PTO_XLEN} + 4);
    Store(Zeros{PTO_XLEN} + 0x900, 4, Zeros{PTO_XLEN} + 11);
    Store(Zeros{PTO_XLEN} + 0x904, 4, Zeros{PTO_XLEN} + 55);
    WritePEGPR(0, 2, Zeros{64} + 0x900);
    WritePEGPR(0, 3, Zeros{64});
    WritePEGPR(0, 4, Zeros{64} + 4);
    WritePEGPR(0, 5, Zeros{64} + 1);
    let started = ExecuteCommandInstruction(I414MalformedStart(), 32);
    assert started == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 2);
    let input = ExecuteCommandInstruction(I414MalformedInput(), 32);
    assert input == CommandExecution_Executed;
end;

func AssertI414MalformedOperationFault()
begin
    StartMemoryEventCapture(0);
    let completed = ExecuteBundleTileOperation();
    assert !completed && _LastFault == Fault_TileLegality;
    assert _MemoryEventCount == 0;
    assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;
    StopMemoryEventCapture();
    let observed_1 = LoadUnsigned(Zeros{PTO_XLEN} + 0x900, 4);
    assert observed_1 == Zeros{PTO_XLEN} + 11;
    let observed_2 = LoadUnsigned(Zeros{PTO_XLEN} + 0x904, 4);
    assert observed_2 == Zeros{PTO_XLEN} + 55;
end;

func main() => integer
begin
    SetupI414MalformedGather();
    let descriptor = ExecuteCommandInstruction(
        I414MalformedIOR(2, 3, 4, 0, FALSE), 32);
    let mask = ExecuteCommandInstruction(
        I414MalformedIOR(5, 0, 0, 0, FALSE), 32);
    assert descriptor == CommandExecution_Executed &&
           mask == CommandExecution_Executed;
    AssertI414MalformedOperationFault();
    return 0;
end;
