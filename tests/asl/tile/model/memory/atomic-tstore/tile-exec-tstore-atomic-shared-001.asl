// PTO-TEST: {"id":"PTO-AVS-BLOCK-TSTORE-ATOMIC-SHARED-001","source":"asl/tile/model/memory/atomic-tstore.asl","requirements":["PTO-TSTORE-STRIDED-ATOMIC-RED-001","PTO-B-IOS-SHARED-STATE-001","PTO-B-SUBVIEW-RANGE-001"],"kind":"execution","summary":"Atomic TSTORE uses equivalent Local and Shared source values, gives every selected PE the same Shared view, and honors explicit SUBVIEW","pass_condition":"one Local update matches one Shared PE update; four selected PEs each add the same Shared source to the same GM address; a one-CELL Shared SUBVIEW stores only its eight source words and the published parent remains unchanged","related_sources":["asl/block/model/dispatch/tlsu-atomic-tstore.asl","asl/block/model/operands/shared-generation.asl"]}
pure func AtomicSharedStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00111181;
    instruction[31:27] = TileDataTypeToEncoding(TileDataType_U32);
    return instruction;
end;

pure func AtomicSharedDATR() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001023;
    instruction[31:29] = Zeros{3};
    instruction[25] = '1';
    instruction[24:20] = DTYPE_NONE;
    return instruction;
end;

pure func AtomicSharedTileSource() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[18:15] = Zeros{4};
    instruction[11:9] = '111';
    instruction[19] = '1';
    return instruction;
end;

pure func AtomicSharedIOS(shared_id: bits(6)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001013;
    instruction[25:20] = shared_id;
    instruction[18:15] = Zeros{4};
    instruction[11:9] = '111';
    return instruction;
end;

pure func AtomicSharedSubview(reg_src: integer {0..23},
                               uimm11: integer {0..2047},
                               size_code: integer {1..12}) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000053;
    instruction[30:20] = Zeros{11} + uimm11;
    instruction[19:15] = Zeros{5} + reg_src;
    instruction[10:7] = Zeros{4} + size_code;
    return instruction;
end;

pure func AtomicSharedIOR() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000013;
    instruction[19:15] = Zeros{5} + 2;
    instruction[24:20] = Zeros{5} + 3;
    return instruction;
end;

func AtomicSharedCommandStart()
begin
    let start = ExecuteCommandInstruction(AtomicSharedStart(), 32);
    let attributes = ExecuteCommandInstruction(AtomicSharedDATR(), 32);
    assert start == CommandExecution_Executed &&
           attributes == CommandExecution_Executed;
end;

func AtomicSharedAddress(base: Word, stride: Word)
begin
    WriteGPR(2, base);
    WriteGPR(3, stride);
    let address = ExecuteCommandInstruction(AtomicSharedIOR(), 32);
    assert address == CommandExecution_Executed;
end;

func RunAtomicSharedLocal()
begin
    SelectExecutionContext(0, 0);
    ResetBundleControlState();
    ConfigureTile(0, 128, 1, 1, 1, 1, TileDataType_U32,
        TileLayout_RowMajor);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 5);
    AtomicSharedCommandStart();
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 1);
    let source = ExecuteCommandInstruction(AtomicSharedTileSource(), 32);
    AtomicSharedAddress(Zeros{PTO_XLEN} + 0x200,
        Zeros{PTO_XLEN} + 4);
    let completed = ExecuteBundleTileOperation();
    assert source == CommandExecution_Executed && completed &&
           _LastFault == Fault_None;
end;

func RunAtomicSharedSourcePE(pe: MemoryAgentId, base: Word)
begin
    SelectExecutionContext(0, pe);
    ResetBundleControlState();
    AtomicSharedCommandStart();
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 1);
    let source = ExecuteCommandInstruction(AtomicSharedIOS(Zeros{6} + 42), 32);
    AtomicSharedAddress(base, Zeros{PTO_XLEN} + 4);
    let completed = ExecuteBundleTileOperation();
    assert source == CommandExecution_Executed && completed &&
           _BundleSharedBindings[[0]].pe_mask == '1111' &&
           _BundleSharedBindings[[0]].source_reuse &&
           _LastFault == Fault_None;
end;

func RunAtomicSharedSubview()
begin
    SelectExecutionContext(0, 0);
    ResetBundleControlState();
    AtomicSharedCommandStart();
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 8);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 1);
    let shared = ExecuteCommandInstruction(AtomicSharedIOS(Zeros{6} + 43), 32);
    WriteGPR(4, Zeros{PTO_XLEN} + 1);
    let view = ExecuteCommandInstruction(AtomicSharedSubview(4, 0, 1), 32);
    AtomicSharedAddress(Zeros{PTO_XLEN} + 0x400,
        Zeros{PTO_XLEN} + 4);
    assert shared == CommandExecution_Executed;
    assert view == CommandExecution_Executed;
    assert _BundleSharedBindings[[0]].source0_subview.valid;
    assert _BundleSharedBindings[[0]].valid &&
           _BundleSharedBindings[[0]].size_code == 0 &&
           _BundleSharedBindings[[0]].pe_mask[0] == '1';
    assert _BundleSharedBindings[[0]].source0_subview.reg_src == 4 &&
           _BundleSharedBindings[[0]].source0_subview.size_code == 1 &&
           _BundleSharedBindings[[0]].source0_subview.offset ==
               Zeros{PTO_XLEN} + 1;
    let parent_record = SharedTileRecord((Zeros{6} + 43) as SharedTileID);
    let parent = parent_record.tile;
    assert SharedTilePublished((Zeros{6} + 43) as SharedTileID) &&
           parent.capacity_bytes == 256 && parent.columns == 1 &&
           parent.data_type == TileDataType_U32 &&
           parent.layout == TileLayout_RowMajor;
    assert BundleSharedSubviewOffsetRawForPE(0, 0) ==
               Zeros{PTO_XLEN} + 1 &&
           TileSizeCodeBytes(1) == 128 &&
           TileElementBits(parent.data_type) == 32;
    assert BundleSharedSubviewLegalForPE(0, 0);
    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
end;

func main() => integer
begin
    ResetProfileState();
    ConfigureTile(0, 128, 1, 1, 1, 1, TileDataType_U32,
        TileLayout_RowMajor);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 5);
    InstallSharedTile((Zeros{6} + 42) as SharedTileID, _Tiles[[0]], '1111');
    let shared_before = SharedTileRecord((Zeros{6} + 42) as SharedTileID);

    Store(Zeros{PTO_XLEN} + 0x200, 4, Zeros{PTO_XLEN} + 10);
    for row = 0 to 31 do
        Store(Zeros{PTO_XLEN} + 0x400 + row * 4, 4, Zeros{PTO_XLEN});
    end;
    StartMemoryEventCapture(0);

    RunAtomicSharedLocal();
    for pe_number = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        RunAtomicSharedSourcePE(pe_number as MemoryAgentId,
            Zeros{PTO_XLEN} + 0x200);
    end;
    ConfigureTile(0, 256, 64, 1, 64, 1, TileDataType_U32,
        TileLayout_RowMajor);
    for row = 0 to 63 do
        WriteTileElement(0, row, 0, Zeros{PTO_XLEN} + 9 + row);
    end;
    InstallSharedTile((Zeros{6} + 43) as SharedTileID, _Tiles[[0]], '1111');
    let subview_before = SharedTileRecord((Zeros{6} + 43) as SharedTileID);
    StopMemoryEventCapture();
    assert !_MemoryEventCaptureEnabled && _MemoryEventCount == 5;
    RunAtomicSharedSubview();

    assert !_MemoryEventCaptureEnabled;
    let same_base_result = LoadUnsigned(Zeros{PTO_XLEN} + 0x200, 4);
    assert _MemoryEventCount == 5;
    assert same_base_result == Zeros{PTO_XLEN} + 35;
    let local_event = _MemoryEvents[[0]];
    assert local_event.kind == MemoryEvent_Atomic &&
           local_event.address == Zeros{PTO_XLEN} + 0x200 &&
           local_event.read_value == Zeros{PTO_XLEN} + 10 &&
           local_event.write_value == Zeros{PTO_XLEN} + 15;
    for pe_number = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        let pe = pe_number as MemoryAgentId;
        let event = _MemoryEvents[[(pe_number + 1) as MemoryEventIndex]];
        assert event.kind == MemoryEvent_Atomic &&
               event.agent == pe &&
               event.address == Zeros{PTO_XLEN} + 0x200 &&
               event.read_value == Zeros{PTO_XLEN} + 15 + pe_number * 5 &&
               event.write_value == Zeros{PTO_XLEN} + 20 + pe_number * 5;
    end;
    for row = 0 to 31 do
        let actual = LoadUnsigned(Zeros{PTO_XLEN} + 0x400 + row * 4, 4);
        assert actual == Zeros{PTO_XLEN} + 41 + row;
    end;
    let subview_after = SharedTileRecord((Zeros{6} + 43) as SharedTileID);
    let shared_after = SharedTileRecord((Zeros{6} + 42) as SharedTileID);
    assert SharedTilePublished((Zeros{6} + 42) as SharedTileID) &&
           SharedTilePayloadIntact((Zeros{6} + 42) as SharedTileID) &&
           ReadSharedTileWord((Zeros{6} + 42) as SharedTileID, 0) ==
               Zeros{PTO_XLEN} + 5 &&
           shared_after.payload_generation == shared_before.payload_generation &&
           shared_after.tile.payload[[0]] == shared_before.tile.payload[[0]] &&
           SharedTilePublished((Zeros{6} + 43) as SharedTileID) &&
           subview_after.payload_generation == subview_before.payload_generation &&
           subview_after.tile.capacity_bytes == subview_before.tile.capacity_bytes &&
           subview_after.tile.valid_rows == subview_before.tile.valid_rows &&
           subview_after.tile.valid_columns == subview_before.tile.valid_columns;
    assert shared_before.tile.payload[[0]] == Zeros{PTO_XLEN} + 5;
    for row = 0 to 63 do
        let element = TileLogicalLinearIndex(subview_before.tile,
            row as integer {0..65535}, 0);
        assert subview_after.tile.payload[[element]] ==
               subview_before.tile.payload[[element]];
    end;
    return 0;
end;
