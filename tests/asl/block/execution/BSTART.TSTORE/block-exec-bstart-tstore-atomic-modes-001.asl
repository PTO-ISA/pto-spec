// PTO-TEST: {"id":"PTO-AVS-BLOCK-TSTORE-ATOMIC-MODES-001","source":"asl/block/execution/BSTART.TSTORE.asl","requirements":["PTO-TSTORE-STRIDED-ATOMIC-RED-001","PTO-ATOM-RED-ORDERING-001"],"kind":"execution","summary":"TLSU Function 1 TSTORE applies every CMode reduction as one intrinsic Atomic effect","pass_condition":"all eight CMode values update one U32 GM word with the selected ADD/MIN/MAX/AND/OR/XOR/INC/DEC operation, emit exactly one Atomic event, and use only the existing TSTORE source binding","related_sources":["asl/tile/model/memory/load-store.asl","asl/tile/model/memory/gm-atom-red.asl"]}
pure func AtomicModeStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00111181;
    instruction[31:27] = Zeros{5} + 25;
    return instruction;
end;

pure func AtomicModeDATR(mode: bits(3)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001023;
    instruction[31:29] = mode;
    instruction[25] = '1';
    instruction[24:20] = DTYPE_NONE;
    return instruction;
end;

pure func AtomicModeSource() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[18:15] = Zeros{4};
    instruction[11:9] = '111';
    instruction[19] = '1';
    return instruction;
end;

pure func AtomicModeIOR() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000013;
    instruction[19:15] = Zeros{5} + 2;
    instruction[24:20] = Zeros{5} + 3;
    return instruction;
end;

func RunAtomicMode(mode: integer {0..7}, initial: integer,
                   input: integer, expected: integer)
begin
    ResetProfileState();
    ConfigureTile(0, 128, 1, 1, 1, 1, TileDataType_U32,
        TileLayout_RowMajor);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + input);
    WriteMemoryByte(Zeros{PTO_XLEN} + 0x200,
        (Zeros{8} + initial) as Byte);
    WriteMemoryByte(Zeros{PTO_XLEN} + 0x201, Zeros{8});
    WriteMemoryByte(Zeros{PTO_XLEN} + 0x202, Zeros{8});
    WriteMemoryByte(Zeros{PTO_XLEN} + 0x203, Zeros{8});
    WriteGPR(2, Zeros{PTO_XLEN} + 0x200);
    WriteGPR(3, Zeros{PTO_XLEN} + 4);

    let started = ExecuteCommandInstruction(AtomicModeStart(), 32);
    let attributes = ExecuteCommandInstruction(AtomicModeDATR(
        (Zeros{3} + mode) as bits(3)), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 1);
    let source = ExecuteCommandInstruction(AtomicModeSource(), 32);
    let address = ExecuteCommandInstruction(AtomicModeIOR(), 32);
    StartMemoryEventCapture(0);
    assert started == CommandExecution_Executed;
    assert attributes == CommandExecution_Executed;
    assert source == CommandExecution_Executed;
    assert address == CommandExecution_Executed;
    assert BundleTileBindingCount() == 1;
    assert _BundleOperation.selector[4:0] == Zeros{5} + 1;
    assert !_KernelInvocationActiveByCore[[_CurrentModelCore]];
    assert _CurrentKernelInvocation == 0;
    assert _MemoryEventCaptureEnabled;

    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
    assert _MemoryEventCaptureEnabled;
    assert _MemoryEventCount == 1;
    let event = _MemoryEvents[[0 as MemoryEventIndex]];
    assert event.active && event.kind == MemoryEvent_Atomic &&
           event.address == Zeros{PTO_XLEN} + 0x200 && event.committed;
    StopMemoryEventCapture();
    let actual = LoadUnsigned(Zeros{PTO_XLEN} + 0x200, 4);
    assert actual == Zeros{PTO_XLEN} + expected;
end;

func main() => integer
begin
    RunAtomicMode(0, 5, 2, 7);  // ADD
    RunAtomicMode(1, 5, 2, 2);  // MIN
    RunAtomicMode(2, 5, 2, 5);  // MAX
    RunAtomicMode(3, 5, 3, 1);  // AND
    RunAtomicMode(4, 5, 2, 7);  // OR
    RunAtomicMode(5, 5, 3, 6);  // XOR
    RunAtomicMode(6, 4, 7, 5);  // INC to limit
    RunAtomicMode(7, 4, 7, 3);  // DEC to limit
    return 0;
end;
