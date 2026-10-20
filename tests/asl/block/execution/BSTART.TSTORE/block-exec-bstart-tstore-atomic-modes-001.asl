// PTO-TEST: {"id":"PTO-AVS-BLOCK-TSTORE-ATOMIC-MODES-001","source":"asl/block/execution/BSTART.TSTORE.asl","requirements":["PTO-TSTORE-STRIDED-ATOMIC-RED-001","PTO-ATOM-RED-ORDERING-001"],"kind":"execution","summary":"TLSU Function 1 TSTORE applies every CMode reduction as one intrinsic Atomic effect with element-width integer normalization","pass_condition":"all eight CMode values update one U32 GM word with the selected ADD/MIN/MAX/AND/OR/XOR/INC/DEC operation, emit exactly one Atomic event, and S32 MIN/MAX plus U32 INC/DEC ignore carrier bits outside their selected 32-bit element","related_sources":["asl/tile/model/memory/load-store.asl","asl/tile/model/memory/gm-atom-red.asl"]}
pure func AtomicModeStart(data_type: TileDataType) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00111181;
    instruction[31:27] = TileDataTypeToEncoding(data_type);
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

    let started = ExecuteCommandInstruction(
        AtomicModeStart(TileDataType_U32), 32);
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

func RunAtomicModeCarrier(data_type: TileDataType, mode: bits(3),
                          initial: Word, input: Word, expected: Word)
begin
    ResetProfileState();
    ConfigureTile(0, 128, 1, 1, 1, 1, data_type,
        TileLayout_RowMajor);
    WriteTileElement(0, 0, 0, input);
    MarkTileValidRegionDefined(0);
    let target = Zeros{PTO_XLEN} + 0x240;
    Store(target, 4, initial);
    WriteGPR(2, target);
    WriteGPR(3, Zeros{PTO_XLEN} + 4);

    let started = ExecuteCommandInstruction(AtomicModeStart(data_type), 32);
    let attributes = ExecuteCommandInstruction(
        AtomicModeDATR(mode), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 1);
    let source = ExecuteCommandInstruction(AtomicModeSource(), 32);
    let address = ExecuteCommandInstruction(AtomicModeIOR(), 32);
    StartMemoryEventCapture(0);
    assert started == CommandExecution_Executed &&
           attributes == CommandExecution_Executed &&
           source == CommandExecution_Executed &&
           address == CommandExecution_Executed;
    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None && _MemoryEventCount == 1;
    let event = _MemoryEvents[[0 as MemoryEventIndex]];
    assert event.active && event.committed &&
           event.kind == MemoryEvent_Atomic && event.address == target;
    assert event.read_value == NormalizeMemoryAccessValue(initial, 4);
    assert event.write_value == NormalizeMemoryAccessValue(expected, 4);
    StopMemoryEventCapture();
    let actual = LoadUnsigned(target, 4);
    assert actual == NormalizeMemoryAccessValue(expected, 4);
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
    // The source and old value are XLEN carriers; selected U32/S32
    // semantics use only their low 32 bits for ordering and INC/DEC limits.
    RunAtomicModeCarrier(TileDataType_S32, '001',
        Zeros{PTO_XLEN} + 0x00000000_00000010,
        Zeros{PTO_XLEN} + 0x00000001_ffffffff,
        Zeros{PTO_XLEN} + 0x00000000_ffffffff); // signed MIN: -16 vs -1
    RunAtomicModeCarrier(TileDataType_S32, '010',
        Zeros{PTO_XLEN} + 0x00000001_ffffffff,
        Zeros{PTO_XLEN} + 0x00000000_00000010,
        Zeros{PTO_XLEN} + 0x00000000_00000010); // signed MAX: -1 vs 16
    RunAtomicModeCarrier(TileDataType_U32, '110',
        Zeros{PTO_XLEN} + 5,
        Zeros{PTO_XLEN} + 0x00000001_00000001,
        Zeros{PTO_XLEN}); // INC limit is low32=1, so 5 wraps to 0
    RunAtomicModeCarrier(TileDataType_U32, '111',
        Zeros{PTO_XLEN} + 6,
        Zeros{PTO_XLEN} + 0x00000001_00000001,
        Zeros{PTO_XLEN} + 1); // DEC limit is low32=1
    return 0;
end;
