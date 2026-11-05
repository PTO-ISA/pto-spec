// PTO-TEST: {"id":"PTO-AVS-BLOCK-I414-PE-LOCAL-FAULT-PROGRESS-001","source":"asl/block/execution/BSTART.MSCATTER.asl","requirements":["PTO-ARCH-PE-EXECUTION-CONTEXT-001","PTO-INDEXED-TLSU-RANGE-BINDING-001","PTO-MSCATTER-BYTE-DISPLACEMENT-001","PTO-BSTART-MSCATTER-SCHEMA-001","PTO-MSCATTER-DUPLICATE-ORDER-001","PTO-INST-TILE-MSCATTER","PTO-INST-BLOCK-BSTART-MSCATTER"],"kind":"execution","summary":"A later PE-local Min>Max fault preserves a prior PE's committed scatter and events.","pass_condition":"PE0 stores one byte with Min=Max=0; PE1 later reads its changed private Min=1/Max=0, faults before its own effects, and PE0's store/event remains committed.","related_sources":["asl/arch/state/pe-execution-context.asl","asl/block/model/dispatch/indexed-tlsu-range-schema.asl","asl/block/model/dispatch/tlsu-mscatter.asl","asl/tile/model/memory/gather-scatter.asl"]}
pure func PELocalScatterStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00511181;
    instruction[31:27] = TileDataTypeToEncoding(TileDataType_U8);
    return instruction;
end;

pure func PELocalScatterBinding() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00004013;
    instruction[31:26] = Zeros{6} + 2;
    instruction[25:20] = Zeros{6} + 1;
    instruction[19] = '1';
    instruction[11:9] = '101';
    return instruction;
end;

pure func PELocalScatterIOR() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000013;
    instruction[19:15] = Zeros{5} + 2;
    instruction[24:20] = Zeros{5} + 3;
    instruction[31:27] = Zeros{5} + 4;
    return instruction;
end;

func BindPELocalScatter(pe: MemoryAgentId, base: Word,
    payload: Word)
begin
    SelectExecutionContext(0 as PTOModelCoreIdentity, pe);
    ConfigureTile(1, 128, 1, 1, 1, 1, TileDataType_U8,
        TileLayout_RowMajor);
    ConfigureTile(2, 128, 1, 1, 1, 1, TileDataType_S32,
        TileLayout_RowMajor);
    WriteTileElement(1, 0, 0, payload);
    WriteTileElement(2, 0, 0, Zeros{64});
    WritePEGPR(pe as integer {0..3}, 2, base);
    WritePEGPR(pe as integer {0..3}, 3, Zeros{64});
    WritePEGPR(pe as integer {0..3}, 4, Zeros{64});
    let started = ExecuteCommandInstruction(PELocalScatterStart(), 32);
    assert started == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 1);
    let binding = ExecuteCommandInstruction(PELocalScatterBinding(), 32);
    let scalar = ExecuteCommandInstruction(PELocalScatterIOR(), 32);
    assert binding == CommandExecution_Executed &&
           scalar == CommandExecution_Executed;
end;

func main() => integer
begin
    ResetProfileState();
    Store(Zeros{PTO_XLEN} + 0x700, 1, Zeros{PTO_XLEN} + 0x22);
    Store(Zeros{PTO_XLEN} + 0x800, 1, Zeros{PTO_XLEN} + 0x33);
    BindPELocalScatter(0 as MemoryAgentId,
        Zeros{PTO_XLEN} + 0x700, Zeros{PTO_XLEN} + 0x11);
    StartMemoryEventCapture(0);
    let pe0_completed = ExecuteBundleTileOperation();
    assert pe0_completed && _LastFault == Fault_None;
    assert _MemoryEventCount == 1;
    assert _MemoryEvents[[0]].address == Zeros{PTO_XLEN} + 0x700;

    BindPELocalScatter(1 as MemoryAgentId,
        Zeros{PTO_XLEN} + 0x800, Zeros{PTO_XLEN} + 0x44);
    // The future request's own GPRs change before PE1 reaches its request.
    WritePEGPR(1, 3, Zeros{64} + 1);
    WritePEGPR(1, 4, Zeros{64});
    let pe1_completed = ExecuteBundleTileOperation();
    assert !pe1_completed && _LastFault == Fault_TileLegality;
    assert _MemoryEventCount == 1;
    assert _MemoryEvents[[0]].address == Zeros{PTO_XLEN} + 0x700;
    StopMemoryEventCapture();

    SelectExecutionContext(0 as PTOModelCoreIdentity, 0 as MemoryAgentId);
    assert _LastFault == Fault_None;
    assert _MemoryEventCount == 1;
    assert _MemoryEvents[[0]].address == Zeros{PTO_XLEN} + 0x700;
    let observed_1 = LoadUnsigned(Zeros{PTO_XLEN} + 0x700, 1);
    let observed_2 = LoadUnsigned(Zeros{PTO_XLEN} + 0x800, 1);
    assert observed_1 == Zeros{PTO_XLEN} + 0x11;
    assert observed_2 == Zeros{PTO_XLEN} + 0x33;
    SelectExecutionContext(0 as PTOModelCoreIdentity, 1 as MemoryAgentId);
    assert _LastFault == Fault_TileLegality;
    let observed_3 = LoadUnsigned(Zeros{PTO_XLEN} + 0x700, 1);
    assert observed_3 == Zeros{PTO_XLEN} + 0x11;
    return 0;
end;
