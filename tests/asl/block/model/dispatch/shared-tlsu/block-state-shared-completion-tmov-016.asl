// PTO-TEST: {"id":"PTO-AVS-BLOCK-SHARED-COMPLETION-TMOV-016","source":"asl/block/model/dispatch/shared-tlsu.asl","requirements":["PTO-B-ASSEMBLE-SHARED-GENERATION-001","PTO-ARCH-MEMORY-MODEL-TRAP-RESTORE-001"],"kind":"state-transition","summary":"an exact published TMOV request consumes completion before probing a handler-reconfigured Local source","pass_condition":"four encoded contributions publish once; PE0 is parked through a real interrupt while its Local source is reconfigured undefined; its original stop then retires once without a source fault, contribution replay, event, ordinal change, or loss of peer releases; an invalid next request also preserves those published releases","related_sources":["asl/block/model/operands/shared-generation-pe-requests.asl","asl/block/model/operands/subview-descriptor.asl","asl/block/model/dispatch/gm-obligation-dispatch.asl"]}

pure func SharedEndStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00011181;
    instruction[24:20] = '00010';
    instruction[31:27] = Zeros{5} + 24;
    return instruction;
end;

pure func SharedEndBinding(shared_id: bits(6)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001013;
    instruction[25:20] = shared_id;
    instruction[18:15] = '0011';
    instruction[11:9] = '111';
    return instruction;
end;

pure func SharedEndAssemble(offset: integer) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001053;
    instruction[31] = '1';
    instruction[30:20] = Zeros{11} + offset;
    instruction[11] = '1';
    instruction[10:7] = '0001';
    return instruction;
end;

pure func SharedEndTileBinding() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[25:20] = Zeros{6};
    instruction[11:9] = '111';
    instruction[19] = '1';
    return instruction;
end;

func PrepareSharedEndPE(core: PTOModelCoreIdentity,
                        pe: MemoryAgentId, epoch: integer)
begin
    SelectExecutionContext(core, pe);
    ConfigureTile(0, 512, 4, 16, 1, 16, TileDataType_U64,
        TileLayout_RowMajor);
    for column = 0 to 15 do
        WriteTileElement(0, 0, column,
            Zeros{PTO_XLEN} + 0x2000 + epoch * 0x10000 +
                (pe as integer {0..3}) * 0x100 + column);
    end;
    let start = ExecuteCommandInstruction(SharedEndStart(), 32);
    let shared = ExecuteCommandInstruction(
        SharedEndBinding(Zeros{6} + 19), 32);
    let assemble = ExecuteCommandInstruction(
        SharedEndAssemble(pe as integer {0..3}), 32);
    let tile = ExecuteCommandInstruction(SharedEndTileBinding(), 32);
    assert start == CommandExecution_Executed &&
           shared == CommandExecution_Executed &&
           assemble == CommandExecution_Executed &&
           tile == CommandExecution_Executed &&
           _BundleSharedBindings[[0]].pe_mask == '1111';
end;

func main() => integer
begin
    ResetProfileState();
    let shared_id = (Zeros{6} + 19) as SharedTileID;
    let launch = LaunchKernelInvocation(0, Zeros{PTO_XLEN} + 0x100);
    assert launch == KernelLifecycle_Started;
    for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        PrepareSharedEndPE(0, pe as MemoryAgentId, 0);
        let stop = ExecuteCommandInstruction(Zeros{64}, 16);
        assert stop == CommandExecution_Executed && _LastFault == Fault_None;
    end;
    assert SharedTilePublished(shared_id);
    let index = SharedTileArrayIndex(shared_id);
    let ordinal = _SharedGenerations[[index]].operation_ordinal;
    let arrivals = _SharedGenerations[[index]].arrived_participants;
    let release_before = _SharedGenerations[[index]].released_participants;
    let parent_before = SharedTileRecord(shared_id);
    let parent_word_before = ReadSharedTileWord(shared_id,
        0 as PackedTileElementIndex);
    let event_count_before = _MemoryEventCount;
    SelectExecutionContext(0, 0);
    assert BundleSharedGenerationRequestWaiting(0);
    let parked_pc = ReadTPC();
    let parked_token = _BundleExecutionDomainToken;
    RaiseInterrupt(0 as InterruptID, Zeros{24} + 9);
    assert _CurrentMemoryOrigin == MemoryEventOrigin_Handler;
    ConfigureTile(0, 512, 4, 16, 1, 16, TileDataType_U64,
        TileLayout_RowMajor);
    assert !TileSourceContentsDefined(0);
    let recovered = RecoverTrapContext(0);
    assert recovered && ReadTPC() == parked_pc &&
           _BundleExecutionDomainToken == parked_token;
    let released = ExecuteCommandInstruction(Zeros{64}, 16);
    assert released == CommandExecution_Executed && _LastFault == Fault_None &&
           !_BundleActive && ReadTPC() != parked_pc;
    assert _SharedGenerations[[index]].published &&
           _SharedGenerations[[index]].operation_ordinal == ordinal &&
           _SharedGenerations[[index]].arrived_participants == arrivals &&
           _SharedGenerations[[index]].released_participants ==
               (release_before OR
                SharedGenerationPEBit(0 as MemoryAgentId)) &&
           _SharedGenerations[[index]].arrival_request_tokens[[0]] ==
               parked_token && SharedTilePublished(shared_id) &&
           ReadSharedTileWord(shared_id,
               0 as PackedTileElementIndex) == parent_word_before &&
           _MemoryEventCount == event_count_before &&
           SharedTileRecord(shared_id).tile.capacity_bytes ==
               parent_before.tile.capacity_bytes;

    // The consumed request is gone. A distinct malformed INIT with an
    // out-of-range offset faults, while the older published operation's
    // pending peer releases remain irrevocable.
    let invalid_start = ExecuteCommandInstruction(SharedEndStart(), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 1);
    let invalid_shared = ExecuteCommandInstruction(
        SharedEndBinding(Zeros{6} + 19), 32);
    let invalid_assemble = ExecuteCommandInstruction(
        SharedEndAssemble(0), 32);
    ConfigureTile(0, 256, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor);
    let invalid_tile = ExecuteCommandInstruction(SharedEndTileBinding(), 32);
    let invalid_stop = ExecuteCommandInstruction(Zeros{64}, 16);
    assert invalid_start == CommandExecution_Executed &&
           invalid_shared == CommandExecution_Executed &&
           invalid_assemble == CommandExecution_Executed &&
           invalid_tile == CommandExecution_Executed &&
           invalid_stop == CommandExecution_Rejected &&
           _LastFault == Fault_TileLegality;
    assert _SharedGenerations[[index]].published &&
           _SharedGenerations[[index]].operation_ordinal == ordinal &&
           _SharedGenerations[[index]].released_participants ==
               (release_before OR
                SharedGenerationPEBit(0 as MemoryAgentId)) &&
           SharedTilePublished(shared_id);
    return 0;
end;
