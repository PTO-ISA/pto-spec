// PTO-TEST: {"id":"PTO-AVS-BLOCK-TSTORE-ATOMIC-SHARED-FAULT-001","source":"asl/block/model/dispatch/tlsu-atomic-tstore.asl","requirements":["PTO-TSTORE-STRIDED-ATOMIC-RED-001","PTO-B-IOS-SHARED-STATE-001"],"kind":"execution","summary":"Unpublished Shared Atomic TSTORE waits without effects, then selected PEs fault or succeed independently after publication","pass_condition":"the same PE request waits on an unpublished whole parent without fault/event/consumption; after publishing, PE0 faults at address 4096 while PE1 completes one real Atomic event at its private base, and the shared source remains unchanged","related_sources":["asl/block/model/operands/shared-generation.asl","asl/tile/model/memory/atomic-tstore.asl","asl/block/model/dispatch/tlsu-atomic-tstore.asl"]}
pure func SharedAtomicFaultStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00111181;
    instruction[31:27] = TileDataTypeToEncoding(TileDataType_U32);
    return instruction;
end;

pure func SharedAtomicFaultDATR() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001023;
    instruction[25] = '1';
    instruction[24:20] = DTYPE_NONE;
    return instruction;
end;

pure func SharedAtomicFaultBinding(shared_id: bits(6)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001013;
    instruction[25:20] = shared_id;
    instruction[18:15] = Zeros{4};
    instruction[11:9] = '111';
    return instruction;
end;

pure func SharedAtomicFaultAddress() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000013;
    instruction[19:15] = Zeros{5} + 2;
    instruction[24:20] = Zeros{5} + 3;
    return instruction;
end;

func PrepareSharedAtomicFaultPE(pe: MemoryAgentId, base: Word)
begin
    SelectExecutionContext(0, pe);
    ResetBundleControlState();
    let start = ExecuteCommandInstruction(SharedAtomicFaultStart(), 32);
    let attributes = ExecuteCommandInstruction(SharedAtomicFaultDATR(), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 1);
    let source = ExecuteCommandInstruction(SharedAtomicFaultBinding(
        Zeros{6} + 42), 32);
    WriteGPR(2, base);
    WriteGPR(3, Zeros{PTO_XLEN} + 4);
    let address = ExecuteCommandInstruction(SharedAtomicFaultAddress(), 32);
    assert start == CommandExecution_Executed;
    assert attributes == CommandExecution_Executed;
    assert source == CommandExecution_Executed;
    assert address == CommandExecution_Executed;
    assert _BundleSharedBindings[[0]].valid &&
           _BundleSharedBindings[[0]].pe_mask == '1111' &&
           !_BundleSharedBindings[[0]].consumed;
end;

func main() => integer
begin
    ResetProfileState();
    ConfigureTile(0, 128, 1, 1, 1, 1, TileDataType_U32,
        TileLayout_RowMajor);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 5);
    MarkTileValidRegionDefined(0);
    let shared_id = (Zeros{6} + 42) as SharedTileID;
    let unpublished = AtomicUpdateSharedTileWithPublication(shared_id,
        _Tiles[[0]], '1111', FALSE);
    assert unpublished;
    assert !SharedTilePublished(shared_id) &&
           !SharedTileRecord(shared_id).whole_parent_ready &&
           SharedTileRecord(shared_id).descriptor_valid;

    Store(Zeros{PTO_XLEN} + 0x200, 4, Zeros{PTO_XLEN} + 10);
    StartMemoryEventCapture(0);
    PrepareSharedAtomicFaultPE(0, Zeros{PTO_XLEN} + 4096);
    let waiting = ExecuteBundleTileOperation();
    assert !waiting && _LastFault == Fault_None &&
           _MemoryEventCount == 0 && !_BundleSharedBindings[[0]].consumed;
    assert !_BundleSharedBindings[[0]].source0_subview.valid;
    assert !SharedTilePublished(shared_id) &&
           !SharedTileRecord(shared_id).whole_parent_ready;
    let waiting_binding = _BundleSharedBindings[[0]];
    let waiting_operation = _BundleOperation;
    assert BundleAtomicTStoreSelected() &&
           waiting_binding.valid && waiting_operation.valid;

    let published = AtomicUpdateSharedTileWithPublication(shared_id,
        _Tiles[[0]], '1111', TRUE);
    assert published;
    assert SharedTilePublished(shared_id) &&
           SharedTileRecord(shared_id).whole_parent_ready;
    let shared_generation = SharedTileRecord(shared_id).payload_generation;
    let shared_word = ReadSharedTileWord(shared_id, 0);
    assert shared_word == Zeros{PTO_XLEN} + 5;

    let faulted = ExecuteBundleTileOperation();
    assert !faulted && _LastFault == Fault_DataPage &&
           _FaultAddress == Zeros{PTO_XLEN} + 4096 &&
           _MemoryEventCount == 0 && !_BundleSharedBindings[[0]].consumed;
    assert SharedTileRecord(shared_id).payload_generation == shared_generation &&
           ReadSharedTileWord(shared_id, 0) == shared_word;

    PrepareSharedAtomicFaultPE(1, Zeros{PTO_XLEN} + 0x200);
    let completed = ExecuteBundleTileOperation();
    assert completed;
    assert _LastFault == Fault_None;
    assert _MemoryEventCount == 1;
    let event = _MemoryEvents[[0]];
    assert event.active && event.kind == MemoryEvent_Atomic &&
           event.agent == 1 && event.address == Zeros{PTO_XLEN} + 0x200 &&
           event.read_value == Zeros{PTO_XLEN} + 10 &&
           event.write_value == Zeros{PTO_XLEN} + 15 && event.committed;
    assert _MemoryEventCount == 1;
    StopMemoryEventCapture();
    let result = LoadUnsigned(Zeros{PTO_XLEN} + 0x200, 4);
    assert result == Zeros{PTO_XLEN} + 15 && _MemoryEventCount == 1;
    assert ReadSharedTileWord(shared_id, 0) == shared_word &&
           SharedTileRecord(shared_id).payload_generation == shared_generation;
    return 0;
end;
