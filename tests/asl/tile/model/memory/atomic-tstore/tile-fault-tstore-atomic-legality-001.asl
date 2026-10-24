// PTO-TEST: {"id":"PTO-AVS-TILE-TSTORE-ATOMIC-LEGALITY-001","source":"asl/tile/model/memory/atomic-tstore.asl","requirements":["PTO-TSTORE-STRIDED-ATOMIC-RED-001","PTO-CUBE-CELL-TRANSPORT-001"],"kind":"fault","summary":"Atomic TSTORE clips valid coordinates and rejects unsupported CUBE layouts, backing, LB2 and binding shapes before effects","pass_condition":"CUBE_N8, explicit CUBE LB2, undefined active Local data, nonnumeric source backing, and an unexpected second Local source all reject with zero Atomic effects while preserving GM; M32/M16 valid-region behavior is covered by the separate stride witness","related_sources":["asl/block/model/dispatch/tlsu-atomic-tstore.asl","asl/tile/model/legality/dtype-layout.asl"]}
pure func AtomicLegalityStart(data_type: TileDataType) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00111181;
    instruction[31:27] = TileDataTypeToEncoding(data_type);
    return instruction;
end;

pure func AtomicLegalityDATR(layout: integer {0..31}) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001023;
    instruction[25] = '1';
    instruction[24:20] = DTYPE_NONE;
    instruction[11:7] = Zeros{5} + layout;
    return instruction;
end;

pure func AtomicLegalitySource(tile: integer {0..31}) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[25:20] = Zeros{6} + tile;
    instruction[19] = '1';
    instruction[11:9] = '111';
    return instruction;
end;

pure func AtomicLegalityTwoSources() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00004013;
    instruction[31:26] = Zeros{6} + 1;
    instruction[25:20] = Zeros{6};
    instruction[19] = '1';
    instruction[11:9] = '111';
    return instruction;
end;

pure func AtomicLegalityShared() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001013;
    instruction[25:20] = Zeros{6} + 42;
    instruction[11:9] = '111';
    return instruction;
end;

pure func AtomicLegalityAddress() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000013;
    instruction[19:15] = Zeros{5} + 2;
    instruction[24:20] = Zeros{5} + 3;
    return instruction;
end;

func RunAtomicLegalityReject(data_type: TileDataType,
    tile_layout: TileLayout, layout_code: integer {0..31},
    define_source: boolean, predicate_backing: boolean,
    explicit_lb2: boolean, mixed_shared: boolean,
    unexpected_source1: boolean, strict_tile_fault: boolean) => boolean
begin
    ResetProfileState();
    var configured = FALSE;
    if predicate_backing then
        configured = ConfigurePredicateCell(0, 128, 1, 1,
            TileDataType_U32, tile_layout);
        if configured then InstallRelativeTileFixture(0, 0); end;
    else
        configured = ConfigureCubeTile(0, 256, 1, 1,
            data_type, tile_layout);
    end;
    assert configured;
    if define_source then WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 1); end;
    if unexpected_source1 then
        let second_ready = ConfigureCubeTile(1, 256, 1, 1,
            data_type, tile_layout);
        assert second_ready;
        WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 2);
    end;
    Store(Zeros{PTO_XLEN} + 0x200, 8,
        Zeros{PTO_XLEN} + 0x1122334455667788);
    WriteGPR(2, Zeros{PTO_XLEN} + 0x200);
    WriteGPR(3, Zeros{PTO_XLEN} + 8);
    let start = ExecuteCommandInstruction(AtomicLegalityStart(data_type), 32);
    let attributes = ExecuteCommandInstruction(
        AtomicLegalityDATR(layout_code), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    if explicit_lb2 then SetBundleDimension(2, Zeros{PTO_XLEN} + 1); end;
    var binding = CommandExecution_Rejected;
    if unexpected_source1 then
        binding = ExecuteCommandInstruction(AtomicLegalityTwoSources(), 32);
    else
        binding = ExecuteCommandInstruction(AtomicLegalitySource(0), 32);
    end;
    var shared_status = CommandExecution_Executed;
    if mixed_shared then
        shared_status = ExecuteCommandInstruction(AtomicLegalityShared(), 32);
    end;
    let address = ExecuteCommandInstruction(AtomicLegalityAddress(), 32);
    assert start == CommandExecution_Executed &&
           attributes == CommandExecution_Executed &&
           binding == CommandExecution_Executed &&
           shared_status == CommandExecution_Executed &&
           address == CommandExecution_Executed;
    StartMemoryEventCapture(0);
    let completed = ExecuteBundleTileOperation();
    let rejected = !completed && _LastFault != Fault_None &&
        _MemoryEventCount == 0;
    let exact_fault = if unexpected_source1 then
        _LastFault == Fault_BundleControl
        else if strict_tile_fault then
            _LastFault == Fault_TileLegality
        else _LastFault == Fault_TileLegality ||
             _LastFault == Fault_BundleControl;
    StopMemoryEventCapture();
    assert !_MemoryEventCaptureEnabled;
    let unchanged = LoadUnsigned(Zeros{PTO_XLEN} + 0x200, 8) ==
        Zeros{PTO_XLEN} + 0x1122334455667788;
    if unexpected_source1 then
        assert rejected;
        assert exact_fault;
        assert unchanged;
    end;
    return rejected && exact_fault && unchanged;
end;

func main() => integer
begin
    let cube_n8 = RunAtomicLegalityReject(TileDataType_FP16,
        TileLayout_CUBE_N8, 26, TRUE, FALSE, FALSE, FALSE, FALSE, TRUE);
    assert cube_n8;
    let wrong_lb2 = RunAtomicLegalityReject(TileDataType_U32,
        TileLayout_CUBE_M16, 25, TRUE, FALSE, TRUE, FALSE, FALSE, TRUE);
    assert wrong_lb2;
    let undefined_active = RunAtomicLegalityReject(TileDataType_U32,
        TileLayout_CUBE_M16, 25, FALSE, FALSE, FALSE, FALSE, FALSE, TRUE);
    assert undefined_active;
    let unsupported_backing = RunAtomicLegalityReject(TileDataType_U32,
        TileLayout_CUBE_M16, 25, TRUE, TRUE, FALSE, FALSE, FALSE, TRUE);
    assert unsupported_backing;
    let mixed_local_shared = RunAtomicLegalityReject(TileDataType_U32,
        TileLayout_CUBE_M16, 25, TRUE, FALSE, FALSE, TRUE, FALSE, FALSE);
    assert mixed_local_shared;
    let extra_local_source = RunAtomicLegalityReject(TileDataType_U32,
        TileLayout_CUBE_M16, 25, TRUE, FALSE, FALSE, FALSE, TRUE, TRUE);
    assert extra_local_source;
    return 0;
end;
