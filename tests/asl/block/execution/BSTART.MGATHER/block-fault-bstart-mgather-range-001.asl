// PTO-TEST: {"id":"PTO-AVS-BLOCK-I414-MGATHER-RANGE-FAULT-001","source":"asl/block/execution/BSTART.MGATHER.asl","requirements":["PTO-INDEXED-TLSU-RANGE-BINDING-001","PTO-MGATHER-BYTE-DISPLACEMENT-001","PTO-BSTART-MGATHER-SCHEMA-001","PTO-INST-TILE-MGATHER","PTO-INST-BLOCK-BSTART-MGATHER"],"kind":"fault","summary":"An invalid signed MGATHER range faults before allocation or memory effects.","pass_condition":"Encoded Min=1 and Max=0 raise Fault_TileLegality before any event, destination allocation, or byte change.","related_sources":["asl/block/model/dispatch/indexed-tlsu-range-schema.asl","asl/block/model/dispatch/tlsu-mgather.asl","asl/tile/model/memory/addressing.asl","asl/tile/model/memory/gather-scatter.asl"]}
pure func RangeGatherStart(data_type: bits(5)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00411181;
    instruction[31:27] = data_type;
    return instruction;
end;

pure func RangeGatherBinding() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[25:20] = Zeros{6};
    instruction[19] = '1';
    instruction[18:15] = '0001';
    instruction[11:9] = '001';
    instruction[8:7] = '00';
    return instruction;
end;

pure func RangeGatherIOR(base: bits(5), minimum: bits(5),
                         maximum: bits(5)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000013;
    instruction[19:15] = base;
    instruction[24:20] = minimum;
    instruction[31:27] = maximum;
    return instruction;
end;

pure func RangeGatherMaxPad() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001023;
    instruction[28:27] = '01';
    instruction[24:20] = DTYPE_NONE;
    return instruction;
end;

func RunRangeGather(descriptor_present: boolean)
begin
    ResetProfileState();
    ConfigureTile(0, 128, 1, 4, 1, 3, TileDataType_S32,
        TileLayout_RowMajor);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} - 4);
    WriteTileElement(0, 0, 1, Zeros{PTO_XLEN});
    WriteTileElement(0, 0, 2, Zeros{PTO_XLEN} + 3);
    Store(Zeros{PTO_XLEN} + 0xfc, 1, Zeros{PTO_XLEN} + 0x11);
    Store(Zeros{PTO_XLEN} + 0x100, 1, Zeros{PTO_XLEN} + 0x27);
    Store(Zeros{PTO_XLEN} + 0x103, 1, Zeros{PTO_XLEN} + 0x44);
    WritePEGPR(0, 2, Zeros{PTO_XLEN} + 0x100);
    WritePEGPR(0, 3, if descriptor_present then Zeros{64} + 1
        else Zeros{64} + 99);
    WritePEGPR(0, 4, if descriptor_present then Zeros{64}
        else Zeros{64} - 99);
    let started = ExecuteCommandInstruction(
        RangeGatherStart(TileDataTypeToEncoding(TileDataType_U8)), 32);
    let padded = ExecuteCommandInstruction(RangeGatherMaxPad(), 32);
    assert started == CommandExecution_Executed;
    assert padded == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 3);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 4);
    WritePEGPR(0, 5, Zeros{PTO_XLEN} + 4);
    let bound = ExecuteCommandInstruction(RangeGatherBinding(), 32);
    assert bound == CommandExecution_Executed;
    let range_ior = ExecuteCommandInstruction(
        RangeGatherIOR(Zeros{5} + 2,
            if descriptor_present then Zeros{5} + 3 else Zeros{5},
            if descriptor_present then Zeros{5} + 4 else Zeros{5}), 32);
    assert range_ior == CommandExecution_Executed;
    StartMemoryEventCapture(0);
    let completed = ExecuteBundleTileOperation();
    assert !completed && _LastFault == Fault_TileLegality;
    assert _MemoryEventCount == 0;
    assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;
    let observed_1 = LoadUnsigned(Zeros{PTO_XLEN} + 0xfc, 1);
    assert observed_1 == Zeros{PTO_XLEN} + 0x11;
    let observed_2 = LoadUnsigned(Zeros{PTO_XLEN} + 0x100, 1);
    assert observed_2 == Zeros{PTO_XLEN} + 0x27;
    let observed_3 = LoadUnsigned(Zeros{PTO_XLEN} + 0x103, 1);
    assert observed_3 == Zeros{PTO_XLEN} + 0x44;
    StopMemoryEventCapture();
end;

func main() => integer
begin
    RunRangeGather(TRUE);
    return 0;
end;
