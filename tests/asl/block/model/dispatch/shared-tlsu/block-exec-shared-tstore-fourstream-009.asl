// PTO-TEST: {"id":"PTO-AVS-BLOCK-SHARED-TSTORE-FOURSTREAM-009","source":"asl/block/model/dispatch/shared-tlsu.asl","requirements":["PTO-ARCH-PE-EXECUTION-CONTEXT-001","PTO-INST-TILE-TSTORE","PTO-ARCH-MEMORY-MODEL-REPLAY-001"],"kind":"execution","summary":"four encoded Shared-source TSTORE streams emit only their eligible PE's GM effects","pass_condition":"a sparse PE0-only TSTORE emits one PE0 event, a full-mask four-stream TSTORE emits one event per actual PE, and zero-mask streams emit no event or effect; each write uses the executing PE's private base GPR and the shared source is unchanged","related_sources":["asl/block/model/dispatch/shared-tlsu.asl","asl/tile/model/memory/shared-movement.asl","asl/arch/state/pe-execution-context.asl"]}
pure func FourStreamSharedTSTOREStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00011181;
    instruction[24:20] = '00001';
    instruction[31:27] = Zeros{5} + 24;
    return instruction;
end;

pure func FourStreamSharedBinding(shared_id: bits(6),
                                   pe_mode: bits(3)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001013;
    instruction[25:20] = shared_id;
    instruction[18:15] = Zeros{4};
    instruction[11:9] = pe_mode;
    return instruction;
end;

pure func FourStreamSharedAddress() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000013;
    instruction[19:15] = Zeros{5} + 2;
    instruction[24:20] = Zeros{5} + 3;
    return instruction;
end;

func ExecuteFourStreamTSTORE(pe: MemoryAgentId, base: Word,
                             pe_mode: bits(3))
begin
    SelectExecutionContext(0 as PTOModelCoreIdentity, pe);
    assert _CurrentPEContextValid && _CurrentMemoryAgent == pe;
    WriteGPR(2, base);
    WriteGPR(3, Zeros{PTO_XLEN} + 8);
    let start = ExecuteCommandInstruction(FourStreamSharedTSTOREStart(), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 1);
    let shared = ExecuteCommandInstruction(FourStreamSharedBinding(
        Zeros{6} + 42, pe_mode), 32);
    let address = ExecuteCommandInstruction(FourStreamSharedAddress(), 32);
    assert start == CommandExecution_Executed;
    assert shared == CommandExecution_Executed;
    assert address == CommandExecution_Executed;
    if pe_mode == '111' then
        assert _BundleSharedBindings[[0]].pe_mask == '1111';
    elsif pe_mode == '001' then
        assert _BundleSharedBindings[[0]].pe_mask == '1000';
    else
        assert _BundleSharedBindings[[0]].pe_mask == Zeros{4};
    end;
    let event_count_before_stop = _MemoryEventCount;
    let stop = ExecuteCommandInstruction(Zeros{64}, 16);
    assert stop == CommandExecution_Executed;
    assert _LastFault == Fault_None;
    assert !_BundleActive;
    if pe_mode == '111' || (pe_mode == '001' && pe == 0) then
        assert _MemoryEventCount == event_count_before_stop + 1;
    else
        assert _MemoryEventCount == event_count_before_stop;
    end;
end;

func main() => integer
begin
    ResetProfileState();
    let launched = LaunchKernelInvocation(0 as PTOModelCoreIdentity,
        Zeros{PTO_XLEN} + 0x200);
    assert launched == KernelLifecycle_Started;
    SelectExecutionContext(0 as PTOModelCoreIdentity, 0 as MemoryAgentId);
    ConfigureTile(0, 128, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0x5a);
    InstallSharedTile((Zeros{6} + 42) as SharedTileID,
        _Tiles[[0]], '1111');
    StartMemoryEventCapture(0);

    // A complete logical mask still gives each independently executed stream
    // only its own address and one real store event.
    for pe_number = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        let pe = pe_number as MemoryAgentId;
        ExecuteFourStreamTSTORE(pe,
            Zeros{PTO_XLEN} + 0x800 + pe_number * 8, '111');
    end;
    assert _MemoryEventCount == PTO_MODEL_MEMORY_AGENTS;
    for pe_number = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        let pe = pe_number as MemoryAgentId;
        let address = Zeros{PTO_XLEN} + 0x800 + pe_number * 8;
        let byte_index = UInt(address) as integer
            {0..PTO_MODEL_MEMORY_BYTES-1};
        assert _Memory[[byte_index]] ==
            Zeros{8} + 0x5a;
        let event = _MemoryEvents[[pe_number as MemoryEventIndex]];
        assert event.active && event.kind == MemoryEvent_Store &&
               event.core_identity == 0 && event.agent == pe &&
               event.address == address &&
               event.write_value == Zeros{PTO_XLEN} + 0x5a &&
               event.committed;
    end;

    // A sparse mask assigns the one effect to PE0 even though all four
    // independent streams decode and retire the same block.
    for pe_number = 1 to PTO_MODEL_MEMORY_AGENTS - 1 do
        ExecuteFourStreamTSTORE(pe_number as MemoryAgentId,
            Zeros{PTO_XLEN} + 0xa00 + pe_number * 8, '001');
        assert _MemoryEventCount == PTO_MODEL_MEMORY_AGENTS;
    end;
    ExecuteFourStreamTSTORE(0 as MemoryAgentId,
        Zeros{PTO_XLEN} + 0xa00, '001');
    assert _MemoryEventCount == PTO_MODEL_MEMORY_AGENTS + 1;
    assert _Memory[[0xa00]] == Zeros{8} + 0x5a;
    for pe_number = 1 to PTO_MODEL_MEMORY_AGENTS - 1 do
        let byte_index = 0xa00 + pe_number * 8;
        assert _Memory[[byte_index]] ==
            Zeros{8};
    end;
    let sparse_event = _MemoryEvents[[PTO_MODEL_MEMORY_AGENTS as
        MemoryEventIndex]];
    assert sparse_event.agent == 0 && sparse_event.address ==
        Zeros{PTO_XLEN} + 0xa00;

    // The zero mask completes each stream as an effect-free operation.
    for pe_number = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        ExecuteFourStreamTSTORE(pe_number as MemoryAgentId,
            Zeros{PTO_XLEN} + 0xb00 + pe_number * 8, Zeros{3});
    end;
    assert _MemoryEventCount == PTO_MODEL_MEMORY_AGENTS + 1;
    for pe_number = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        let byte_index = 0xb00 + pe_number * 8;
        assert _Memory[[byte_index]] ==
            Zeros{8};
    end;
    assert SharedTilePublished((Zeros{6} + 42) as SharedTileID);
    assert ReadSharedTileWord((Zeros{6} + 42) as SharedTileID, 0) ==
        Zeros{PTO_XLEN} + 0x5a;
    StopMemoryEventCapture();
    return 0;
end;
