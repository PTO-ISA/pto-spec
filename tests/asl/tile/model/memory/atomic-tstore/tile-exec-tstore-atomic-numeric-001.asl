// PTO-TEST: {"id":"PTO-AVS-TILE-TSTORE-ATOMIC-NUMERIC-001","source":"asl/tile/model/memory/atomic-tstore.asl","requirements":["PTO-TSTORE-STRIDED-ATOMIC-RED-001","PTO-GM-FLOATING-ADD-NUMERIC-001","PTO-ATOM-RED-ORDERING-001"],"kind":"execution","summary":"Floating Atomic TSTORE agrees with indexed red through actual service for all four formats","pass_condition":"independent FP16/BF16/FP32/FP64 subnormal, NaN, opposite-infinity and negative-zero vectors produce exact literal results through indexed red and TLSU Function 1 Atomic TSTORE, each emits one Atomic event, and numeric status is unchanged","related_sources":["asl/tile/model/memory/gm-atom-red.asl","asl/tile/model/memory/gm-atom-red-execution.asl","asl/block/model/dispatch/tlsu-atomic-tstore.asl"]}

pure func AtomicNumericStart(data_type: TileDataType) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00111181;
    instruction[31:27] = TileDataTypeToEncoding(data_type);
    return instruction;
end;

pure func AtomicNumericDATR() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001023;
    instruction[31:29] = '000';
    instruction[25] = '1';
    instruction[24:20] = DTYPE_NONE;
    return instruction;
end;

pure func AtomicNumericSource() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[25:20] = Zeros{6} + 1;
    instruction[11:9] = '111';
    instruction[19] = '1';
    return instruction;
end;

pure func AtomicNumericIOR() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000013;
    instruction[19:15] = Zeros{5} + 2;
    instruction[24:20] = Zeros{5} + 3;
    return instruction;
end;

func RunAtomicNumericCase(data_type: TileDataType,
                          initial: Word, input: Word, expected: Word,
                          element_bytes: integer {2,4,8})
begin
    ResetProfileState();
    ConfigureTile(0, 128, 1, 1, 1, 1, TileDataType_U32,
        TileLayout_RowMajor);
    ConfigureTile(1, 128, 1, 1, 1, 1, data_type,
        TileLayout_RowMajor);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(1, 0, 0, input);
    MarkTileValidRegionDefined(0);
    MarkTileValidRegionDefined(1);
    let indexed_target = Zeros{PTO_XLEN} + 0x300;
    let tstore_target = Zeros{PTO_XLEN} + 0x400;
    Store(indexed_target, element_bytes, initial);
    Store(tstore_target, element_bytes, initial);
    let flags_before = NumericStatusFlags();

    StartMemoryEventCapture(0);
    GM_RED_VALUE(GMReduction_ADD, indexed_target, 0, 1, TilePad_Null);
    assert _LastFault == Fault_None && _MemoryEventCount == 1;
    let indexed_event = _MemoryEvents[[0 as MemoryEventIndex]];
    assert indexed_event.active && indexed_event.committed &&
           indexed_event.kind == MemoryEvent_Atomic &&
           indexed_event.address == indexed_target &&
           indexed_event.read_value == initial &&
           indexed_event.write_value == expected;
    let indexed_result = LoadUnsigned(indexed_target, element_bytes);
    assert indexed_result == expected;
    StopMemoryEventCapture();

    WriteGPR(2, tstore_target);
    WriteGPR(3, Zeros{PTO_XLEN} + element_bytes);
    let started = ExecuteCommandInstruction(
        AtomicNumericStart(data_type), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 1);
    let attributes = ExecuteCommandInstruction(AtomicNumericDATR(), 32);
    let source = ExecuteCommandInstruction(AtomicNumericSource(), 32);
    let address = ExecuteCommandInstruction(AtomicNumericIOR(), 32);
    assert started == CommandExecution_Executed &&
           attributes == CommandExecution_Executed &&
           source == CommandExecution_Executed &&
           address == CommandExecution_Executed &&
           BundleAtomicTStoreSelected() &&
           _BundleOperation.selector[4:0] == Zeros{5} + 1;
    StartMemoryEventCapture(0);
    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None &&
           _MemoryEventCount == 1;
    let tstore_event = _MemoryEvents[[0 as MemoryEventIndex]];
    assert tstore_event.active && tstore_event.committed &&
           tstore_event.kind == MemoryEvent_Atomic &&
           tstore_event.address == tstore_target &&
           tstore_event.read_value == initial &&
           tstore_event.write_value == expected;
    let tstore_result = LoadUnsigned(tstore_target, element_bytes);
    assert tstore_result == expected &&
           tstore_result == indexed_result &&
           NumericStatusFlags() == flags_before;
    StopMemoryEventCapture();
end;

func main() => integer
begin
    // Exact IEEE encodings: smallest-subnormal 1+1 remains 2; a signaling
    // NaN is canonicalized; opposite infinities produce canonical NaN;
    // -0+-0 preserves negative zero. Each is checked through both services.
    RunAtomicNumericCase(TileDataType_FP16,
        Zeros{PTO_XLEN} + 0x0001, Zeros{PTO_XLEN} + 0x0001,
        Zeros{PTO_XLEN} + 0x0002, 2);
    RunAtomicNumericCase(TileDataType_FP16,
        Zeros{PTO_XLEN} + 0x7c01, Zeros{PTO_XLEN} + 0x3c00,
        Zeros{PTO_XLEN} + 0x7e00, 2);
    RunAtomicNumericCase(TileDataType_FP16,
        Zeros{PTO_XLEN} + 0x7c00, Zeros{PTO_XLEN} + 0xfc00,
        Zeros{PTO_XLEN} + 0x7e00, 2);
    RunAtomicNumericCase(TileDataType_FP16,
        Zeros{PTO_XLEN} + 0x8000, Zeros{PTO_XLEN} + 0x8000,
        Zeros{PTO_XLEN} + 0x8000, 2);

    RunAtomicNumericCase(TileDataType_BF16,
        Zeros{PTO_XLEN} + 0x0001, Zeros{PTO_XLEN} + 0x0001,
        Zeros{PTO_XLEN} + 0x0002, 2);
    RunAtomicNumericCase(TileDataType_BF16,
        Zeros{PTO_XLEN} + 0x7f81, Zeros{PTO_XLEN} + 0x3f80,
        Zeros{PTO_XLEN} + 0x7fc0, 2);
    RunAtomicNumericCase(TileDataType_BF16,
        Zeros{PTO_XLEN} + 0x7f80, Zeros{PTO_XLEN} + 0xff80,
        Zeros{PTO_XLEN} + 0x7fc0, 2);
    RunAtomicNumericCase(TileDataType_BF16,
        Zeros{PTO_XLEN} + 0x8000, Zeros{PTO_XLEN} + 0x8000,
        Zeros{PTO_XLEN} + 0x8000, 2);

    RunAtomicNumericCase(TileDataType_FP32,
        Zeros{PTO_XLEN} + 0x00000001, Zeros{PTO_XLEN} + 0x00000001,
        Zeros{PTO_XLEN} + 0x00000002, 4);
    RunAtomicNumericCase(TileDataType_FP32,
        Zeros{PTO_XLEN} + 0x7f800001, Zeros{PTO_XLEN} + 0x3f800000,
        Zeros{PTO_XLEN} + 0x7fc00000, 4);
    RunAtomicNumericCase(TileDataType_FP32,
        Zeros{PTO_XLEN} + 0x7f800000, Zeros{PTO_XLEN} + 0xff800000,
        Zeros{PTO_XLEN} + 0x7fc00000, 4);
    RunAtomicNumericCase(TileDataType_FP32,
        Zeros{PTO_XLEN} + 0x80000000, Zeros{PTO_XLEN} + 0x80000000,
        Zeros{PTO_XLEN} + 0x80000000, 4);

    RunAtomicNumericCase(TileDataType_FP64,
        Zeros{PTO_XLEN} + 0x00000000_00000001,
        Zeros{PTO_XLEN} + 0x00000000_00000001,
        Zeros{PTO_XLEN} + 0x00000000_00000002, 8);
    RunAtomicNumericCase(TileDataType_FP64,
        Zeros{PTO_XLEN} + 0x7ff00000_00000001,
        Zeros{PTO_XLEN} + 0x3ff00000_00000000,
        Zeros{PTO_XLEN} + 0x7ff80000_00000000, 8);
    RunAtomicNumericCase(TileDataType_FP64,
        Zeros{PTO_XLEN} + 0x7ff00000_00000000,
        Zeros{PTO_XLEN} + 0xfff00000_00000000,
        Zeros{PTO_XLEN} + 0x7ff80000_00000000, 8);
    RunAtomicNumericCase(TileDataType_FP64,
        Zeros{PTO_XLEN} + 0x80000000_00000000,
        Zeros{PTO_XLEN} + 0x80000000_00000000,
        Zeros{PTO_XLEN} + 0x80000000_00000000, 8);
    return 0;
end;
