// PTO-TEST: {"id":"PTO-AVS-TILE-TSTORE-ATOMIC-UNEQUAL-LIMITS-001","source":"asl/tile/model/memory/atomic-tstore.asl","requirements":["PTO-TSTORE-STRIDED-ATOMIC-RED-001","PTO-ATOM-RED-INC-DEC-SEMANTICS-001","PTO-ARCH-MEMORY-MODEL-ATOMIC-CROSS-AGENT-001"],"kind":"execution","summary":"duplicate Atomic TSTORE INC and DEC targets honor unequal per-element limits without assuming traversal order","pass_condition":"two source coordinates target one aligned U32 word with unequal limits; all exact Atomic events commit once and the final value is one of the independently derived outcomes for either legal serialization order","related_sources":["asl/tile/model/memory/gm-atom-red.asl","asl/block/model/dispatch/tlsu-atomic-tstore.asl","asl/arch/memory-model/atomicity.asl"]}

pure func LimitStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00111181;
    instruction[31:27] = Zeros{5} + 25;
    return instruction;
end;

pure func LimitDATR(mode: bits(3)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001023;
    instruction[31:29] = mode;
    instruction[25] = '1';
    instruction[24:20] = DTYPE_NONE;
    return instruction;
end;

pure func LimitSource() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[18:15] = Zeros{4};
    instruction[11:9] = '111';
    instruction[19] = '1';
    return instruction;
end;

pure func LimitIOR() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000013;
    instruction[19:15] = Zeros{5} + 2;
    instruction[24:20] = Zeros{5} + 3;
    return instruction;
end;

func RunDuplicateLimits(mode: integer {6,7}, initial: integer,
                        limit0: integer, limit1: integer,
                        result_a: integer, result_b: integer)
begin
    ResetProfileState();
    ConfigureTile(0, 128, 2, 1, 2, 1, TileDataType_U32,
        TileLayout_RowMajor);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + limit0);
    WriteTileElement(0, 1, 0, Zeros{PTO_XLEN} + limit1);
    MarkTileValidRegionDefined(0);
    WriteMemoryByte(Zeros{PTO_XLEN} + 0x200, Zeros{8} + initial);
    WriteMemoryByte(Zeros{PTO_XLEN} + 0x201, Zeros{8});
    WriteMemoryByte(Zeros{PTO_XLEN} + 0x202, Zeros{8});
    WriteMemoryByte(Zeros{PTO_XLEN} + 0x203, Zeros{8});
    WriteGPR(2, Zeros{PTO_XLEN} + 0x200);
    WriteGPR(3, Zeros{PTO_XLEN});

    let start = ExecuteCommandInstruction(LimitStart(), 32);
    let attributes = ExecuteCommandInstruction(
        LimitDATR((Zeros{3} + mode) as bits(3)), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 1);
    let source = ExecuteCommandInstruction(LimitSource(), 32);
    let address = ExecuteCommandInstruction(LimitIOR(), 32);
    assert start == CommandExecution_Executed &&
           attributes == CommandExecution_Executed &&
           source == CommandExecution_Executed &&
           address == CommandExecution_Executed &&
           BundleAtomicTStoreSelected() && BundleTileBindingCount() == 1 &&
           _BundleOperation.selector[4:0] == Zeros{5} + 1;

    StartMemoryEventCapture(0);
    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None && _MemoryEventCount == 2;
    for index = 0 to 1 do
        let event = _MemoryEvents[[index as MemoryEventIndex]];
        assert event.active;
        assert event.kind == MemoryEvent_Atomic;
        assert event.address == Zeros{PTO_XLEN} + 0x200;
        assert event.committed;
    end;
    StopMemoryEventCapture();
    let actual = LoadUnsigned(Zeros{PTO_XLEN} + 0x200, 4);
    assert actual == Zeros{PTO_XLEN} + result_a ||
           actual == Zeros{PTO_XLEN} + result_b;
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + limit0 &&
           ReadTileElement(0, 1, 0) == Zeros{PTO_XLEN} + limit1;
end;

func main() => integer
begin
    // INC old=0 with limits 1 and 3: limit order 1,3 yields 2; 3,1 yields 0.
    RunDuplicateLimits(6, 0, 1, 3, 0, 2);
    // DEC old=4 with limits 2 and 5: limit order 2,5 yields 1; 5,2 yields 2.
    RunDuplicateLimits(7, 4, 2, 5, 1, 2);
    return 0;
end;
