// PTO-TEST: {"id":"PTO-AVS-TILE-TSTORE-ATOMIC-LIFETIME-LOCAL-001","source":"asl/tile/model/memory/atomic-tstore.asl","requirements":["PTO-TSTORE-STRIDED-ATOMIC-RED-001","PTO-B-SOURCE-LIFETIME-PE-COMPLETION-001"],"kind":"state-transition","summary":"Local Atomic TSTORE reuse preserves its source and last-use consumes it only after the update","pass_condition":"actual TLSU Function 1 Atomic TSTORE emits one committed Atomic event in both cases; B.IOT reuse leaves the Local payload live and unchanged, while B.IOT last-use clears only payload liveness after the committed update and retains its descriptor","related_sources":["asl/block/model/dispatch/tlsu-atomic-tstore.asl","asl/block/model/operands/tile-bindings.asl","asl/tile/model/memory/atomic-tstore.asl"]}

pure func LocalLifetimeStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00111181;
    instruction[31:27] = Zeros{5} + 25;
    return instruction;
end;

pure func LocalLifetimeDATR() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001023;
    instruction[31:29] = '000';
    instruction[25] = '1';
    instruction[24:20] = DTYPE_NONE;
    return instruction;
end;

pure func LocalLifetimeSource(last_use: boolean) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[18:15] = Zeros{4};
    instruction[11:9] = '111';
    instruction[19] = '1';
    instruction[26] = if last_use then '1' else '0';
    return instruction;
end;

pure func LocalLifetimeIOR() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000013;
    instruction[19:15] = Zeros{5} + 2;
    instruction[24:20] = Zeros{5} + 3;
    return instruction;
end;

func TestLocalAtomicLifetime(last_use: boolean)
begin
    ResetProfileState();
    ConfigureTile(0, 128, 1, 1, 1, 1, TileDataType_U32,
        TileLayout_RowMajor);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 2);
    MarkTileValidRegionDefined(0);
    let live_before = _TilePayloadLiveMasks[[0]];
    assert live_before != Zeros{4};
    WriteMemoryByte(Zeros{PTO_XLEN} + 0x200, Zeros{8} + 5);
    WriteMemoryByte(Zeros{PTO_XLEN} + 0x201, Zeros{8});
    WriteMemoryByte(Zeros{PTO_XLEN} + 0x202, Zeros{8});
    WriteMemoryByte(Zeros{PTO_XLEN} + 0x203, Zeros{8});
    WriteGPR(2, Zeros{PTO_XLEN} + 0x200);
    WriteGPR(3, Zeros{PTO_XLEN} + 4);

    let start = ExecuteCommandInstruction(LocalLifetimeStart(), 32);
    let attributes = ExecuteCommandInstruction(LocalLifetimeDATR(), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 1);
    let source = ExecuteCommandInstruction(LocalLifetimeSource(last_use), 32);
    let address = ExecuteCommandInstruction(LocalLifetimeIOR(), 32);
    assert start == CommandExecution_Executed &&
           attributes == CommandExecution_Executed &&
           source == CommandExecution_Executed &&
           address == CommandExecution_Executed &&
           BundleAtomicTStoreSelected() && BundleTileBindingCount() == 1 &&
           _BundleTileBindings[[0]].source0_reuse == !last_use;

    StartMemoryEventCapture(0);
    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None && _MemoryEventCount == 1;
    let event = _MemoryEvents[[0 as MemoryEventIndex]];
    assert event.active && event.kind == MemoryEvent_Atomic &&
           event.address == Zeros{PTO_XLEN} + 0x200 && event.committed &&
           event.read_value == Zeros{PTO_XLEN} + 5 &&
           event.write_value == Zeros{PTO_XLEN} + 7;
    StopMemoryEventCapture();
    let actual_gm = LoadUnsigned(Zeros{PTO_XLEN} + 0x200, 4);
    assert actual_gm == Zeros{PTO_XLEN} + 7;
    assert _Tiles[[0]].allocated && ReadTileElement(0, 0, 0) ==
           Zeros{PTO_XLEN} + 2;
    if last_use then
        assert _TilePayloadLiveMasks[[0]] == Zeros{4};
    else
        assert _TilePayloadLiveMasks[[0]] == live_before;
    end;
end;

func main() => integer
begin
    TestLocalAtomicLifetime(FALSE);
    TestLocalAtomicLifetime(TRUE);
    return 0;
end;
