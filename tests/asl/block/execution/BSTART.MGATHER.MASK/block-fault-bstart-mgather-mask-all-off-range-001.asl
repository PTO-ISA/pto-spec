// PTO-TEST: {"id":"PTO-AVS-BLOCK-I414-MGATHER-MASK-ALL-OFF-FAULT-001","kind":"fault","pass_condition":"Min=1 and Max=0 raises Fault_TileLegality before destination allocation or any GM event, although every predicate lane is zero.","related_sources":["asl/block/model/dispatch/indexed-tlsu-range-schema.asl","asl/block/model/dispatch/tlsu-mgather-mask.asl","asl/tile/model/memory/addressing.asl","asl/tile/model/memory/gather-scatter.asl"],"requirements":["PTO-B-IOR-BINDING-001","PTO-BSTART-MGATHER-MASK-SCHEMA-001","PTO-INDEXED-TLSU-RANGE-BINDING-001","PTO-INST-BLOCK-BSTART-MGATHER-MASK","PTO-INST-TILE-MGATHER-MASK","PTO-MGATHER-MASK-PREDICATE-001","PTO-MGATHER-MASK-PUBLICATION-001"],"source":"asl/block/execution/BSTART.MGATHER.MASK.asl","summary":"A participating MGATHER.MASK request validates Min and Max even when every execution-mask lane is off."}
pure func MaskGatherStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00611181;
    instruction[31:27] = Zeros{5} + 26;
    return instruction;
end;

pure func MaskGatherBinding(pe_mode: bits(3)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00004013;
    instruction[31:26] = Zeros{6} + 1;
    instruction[19] = '1';
    instruction[18:15] = '0001';
    instruction[11:9] = pe_mode;
    return instruction;
end;

pure func MaskGatherIOR() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000013;
    instruction[19:15] = Zeros{5} + 2;
    instruction[24:20] = Zeros{5} + 3;
    instruction[31:27] = Zeros{5} + 4;
    return instruction;
end;

pure func MaskGatherMaxPad() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001023;
    instruction[28:27] = '01';
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    ConfigureTile(0, 128, 1, 4, 1, 3, TileDataType_S32,
        TileLayout_RowMajor);
    ConfigureTile(1, 128, 1, 4, 1, 3, TileDataType_U8,
        TileLayout_RowMajor);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(0, 0, 1, Zeros{PTO_XLEN} + 0x7fff);
    WriteTileElement(0, 0, 2, Zeros{PTO_XLEN} + 6);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN});
    WriteTileElement(1, 0, 2, Zeros{PTO_XLEN});
    Store(Zeros{PTO_XLEN} + 0x100, 2, Zeros{PTO_XLEN} + 11);
    Store(Zeros{PTO_XLEN} + 0x106, 2, Zeros{PTO_XLEN} + 33);
    WritePEGPR(0, 2, Zeros{PTO_XLEN} + 0x100);
    WritePEGPR(0, 3, Zeros{64} + 1);
    WritePEGPR(0, 4, Zeros{64});
    let started = ExecuteCommandInstruction(MaskGatherStart(), 32);
    assert started == CommandExecution_Executed;
    let padded = ExecuteCommandInstruction(MaskGatherMaxPad(), 32);
    assert padded == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 3);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 4);
    let bound = ExecuteCommandInstruction(MaskGatherBinding('001'), 32);
    assert bound == CommandExecution_Executed;
    let scalar = ExecuteCommandInstruction(MaskGatherIOR(), 32);
    assert scalar == CommandExecution_Executed;
    StartMemoryEventCapture(0);
    let completed = ExecuteBundleTileOperation();
    assert !completed && _LastFault == Fault_TileLegality;
    assert _MemoryEventCount == 0;
    assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;
    StopMemoryEventCapture();
    return 0;
end;
