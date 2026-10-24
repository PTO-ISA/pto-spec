// PTO-TEST: {"id":"PTO-AVS-TILE-TSTORE-ATOMIC-GRADUAL-001","source":"asl/tile/model/memory/atomic-tstore.asl","requirements":["PTO-TSTORE-STRIDED-ATOMIC-RED-001","PTO-GM-FLOATING-ADD-NUMERIC-001","PTO-ATOM-RED-ORDERING-001"],"kind":"execution","summary":"Function 1 Atomic TSTORE ADD preserves both FP32 gradual-underflow discriminators","pass_condition":"one encoded Function 1 request adds 0x00000001 to 0x00000001 and 0x807fffff to 0x00800000, emits two exact Atomic events, returns no value or destination, and leaves numeric status unchanged","related_sources":["asl/tile/model/memory/gm-atom-red-execution.asl","asl/block/model/dispatch/tlsu-atomic-tstore.asl"]}

pure func AtomicGradualStart() => bits(64)
begin
    var instruction = Zeros{64} + 0x00111181;
    instruction[31:27] = TileDataTypeToEncoding(TileDataType_FP32);
    return instruction;
end;

pure func AtomicGradualDATR() => bits(64)
begin
    var instruction = Zeros{64} + 0x00001023;
    instruction[31:29] = '000';
    instruction[25] = '1';
    instruction[24:20] = DTYPE_NONE;
    instruction[11:7] = Zeros{5};
    return instruction;
end;

pure func AtomicGradualSource() => bits(64)
begin
    var instruction = Zeros{64} + 0x00005013;
    instruction[25:20] = Zeros{6};
    instruction[18:15] = Zeros{4};
    instruction[11:9] = '111';
    instruction[19] = '1';
    return instruction;
end;

pure func AtomicGradualIOR() => bits(64)
begin
    var instruction = Zeros{64} + 0x00000013;
    instruction[19:15] = Zeros{5} + 2;
    instruction[24:20] = Zeros{5} + 3;
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    ConfigureTile(0, 128, 1, 2, 1, 2,
        TileDataType_FP32, TileLayout_RowMajor);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0x00000001);
    WriteTileElement(0, 0, 1, Zeros{PTO_XLEN} + 0x807fffff);
    MarkTileValidRegionDefined(0);
    let base = Zeros{PTO_XLEN} + 0x400;
    Store(base, 4, Zeros{PTO_XLEN} + 0x00000001);
    Store(base + 4, 4, Zeros{PTO_XLEN} + 0x00800000);
    WriteGPR(2, base);
    WriteGPR(3, Zeros{PTO_XLEN} + 8);

    let start = ExecuteCommandInstruction(AtomicGradualStart(), 32);
    let attributes = ExecuteCommandInstruction(AtomicGradualDATR(), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 2);
    let source = ExecuteCommandInstruction(AtomicGradualSource(), 32);
    let address = ExecuteCommandInstruction(AtomicGradualIOR(), 32);
    assert start == CommandExecution_Executed &&
           attributes == CommandExecution_Executed &&
           source == CommandExecution_Executed &&
           address == CommandExecution_Executed &&
           BundleAtomicTStoreSelected() &&
           _BundleOperation.selector[4:0] == Zeros{5} + 1 &&
           _BundleTileBindings[[0]].source0_valid &&
           !_BundleTileBindings[[0]].source1_valid &&
           !_BundleTileBindings[[0]].destination_valid &&
           BundleTileBindingCount() == 1;
    var allocated_local_tiles: integer {0..64} = 0;
    for tile_index = 0 to PTO_TILE_REGISTER_COUNT - 1 do
        if _Tiles[[tile_index as TileIndex]].allocated then
            allocated_local_tiles = (allocated_local_tiles + 1)
                as integer {0..64};
        end;
    end;
    assert allocated_local_tiles == 1;
    let flags_before = NumericStatusFlags();

    StartMemoryEventCapture(0);
    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None &&
           _MemoryEventCount == 2;
    let first = _MemoryEvents[[0 as MemoryEventIndex]];
    let second = _MemoryEvents[[1 as MemoryEventIndex]];
    assert first.active && first.committed &&
           first.kind == MemoryEvent_Atomic &&
           first.address == base &&
           first.read_value == Zeros{PTO_XLEN} + 0x00000001 &&
           first.write_value == Zeros{PTO_XLEN} + 0x00000002 &&
           first.write_performed;
    assert second.active && second.committed &&
           second.kind == MemoryEvent_Atomic &&
           second.address == base + 4 &&
           second.read_value == Zeros{PTO_XLEN} + 0x00800000 &&
           second.write_value == Zeros{PTO_XLEN} + 0x00000001 &&
           second.write_performed;
    StopMemoryEventCapture();

    let first_result = LoadUnsigned(base, 4);
    let second_result = LoadUnsigned(base + 4, 4);
    assert first_result == Zeros{PTO_XLEN} + 0x00000002 &&
           second_result == Zeros{PTO_XLEN} + 0x00000001 &&
           NumericStatusFlags() == flags_before &&
           allocated_local_tiles == 1;
    return 0;
end;
