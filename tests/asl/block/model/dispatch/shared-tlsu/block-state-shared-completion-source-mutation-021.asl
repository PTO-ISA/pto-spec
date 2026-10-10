// PTO-TEST: {"id":"PTO-AVS-BLOCK-SHARED-COMPLETION-SOURCE-MUTATION-021","source":"asl/block/model/dispatch/shared-tlsu.asl","requirements":["PTO-B-ASSEMBLE-SHARED-GENERATION-001","PTO-ARCH-MEMORY-MODEL-TRAP-RESTORE-001"],"kind":"state-transition","summary":"an exact published TMOV completion survives legal handler changes to its live source allocation","pass_condition":"three encoded operations publish once; while PE0 is parked, a real handler shrinks, releases, or changes the type/shape of its source tile; each original stop then consumes its completion once without fault, event, ordinal change, or loss of peer releases","related_sources":["asl/block/model/operands/shared-generation-pe-requests.asl","asl/block/model/dispatch/gm-obligation-dispatch.asl","asl/tile/model/state/allocation.asl"]}

pure func CompletionMutationStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00011181;
    instruction[24:20] = '00010';
    instruction[31:27] = Zeros{5} + 24;
    return instruction;
end;

pure func CompletionMutationBinding(shared_id: bits(6)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001013;
    instruction[25:20] = shared_id;
    instruction[18:15] = '0011';
    instruction[11:9] = '111';
    return instruction;
end;

pure func CompletionMutationAssemble(offset: integer) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001053;
    instruction[31] = '1';
    instruction[30:20] = Zeros{11} + offset;
    instruction[11] = '1';
    instruction[10:7] = '0001';
    return instruction;
end;

pure func CompletionMutationTileBinding() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[25:20] = Zeros{6};
    instruction[11:9] = '111';
    instruction[19] = '1';
    return instruction;
end;

func PrepareCompletionMutationPE(pe: MemoryAgentId,
                                 shared_id: SharedTileID,
                                 epoch: integer)
begin
    SelectExecutionContext(0 as PTOModelCoreIdentity, pe);
    ConfigureTile(0, 512, 4, 16, 1, 16, TileDataType_U64,
        TileLayout_RowMajor);
    for column = 0 to 15 do
        WriteTileElement(0, 0, column,
            Zeros{PTO_XLEN} + 0x2000 + epoch * 0x10000 +
                (pe as integer {0..3}) * 0x100 + column);
    end;
    let start = ExecuteCommandInstruction(CompletionMutationStart(), 32);
    let shared = ExecuteCommandInstruction(
        CompletionMutationBinding(shared_id), 32);
    let assemble = ExecuteCommandInstruction(
        CompletionMutationAssemble(pe as integer {0..3}), 32);
    let tile = ExecuteCommandInstruction(CompletionMutationTileBinding(), 32);
    assert start == CommandExecution_Executed &&
           shared == CommandExecution_Executed &&
           assemble == CommandExecution_Executed &&
           tile == CommandExecution_Executed &&
           _BundleSharedBindings[[0]].pe_mask == '1111';
end;

func RunCompletionMutation(shared_id: SharedTileID,
                           mutation: integer {0..2})
begin
    for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        let agent = pe as MemoryAgentId;
        PrepareCompletionMutationPE(agent, shared_id, mutation);
        SelectExecutionContext(0 as PTOModelCoreIdentity, agent);
        let stop = ExecuteCommandInstruction(Zeros{64}, 16);
        assert stop == CommandExecution_Executed &&
               _LastFault == Fault_None;
        if pe < PTO_MODEL_MEMORY_AGENTS - 1 then
            assert BundleSharedGenerationRequestWaiting(0);
        end;
    end;

    let index = SharedTileArrayIndex(shared_id);
    assert _SharedGenerations[[index]].published &&
           _SharedGenerations[[index]].released_participants ==
               SharedGenerationPEBit(3 as MemoryAgentId);
    let operation_ordinal = _SharedGenerations[[index]].operation_ordinal;
    let parent_word = ReadSharedTileWord(shared_id,
        0 as PackedTileElementIndex);
    let event_count = _MemoryEventCount;
    SelectExecutionContext(0 as PTOModelCoreIdentity, 0 as MemoryAgentId);
    let parked_pc = ReadTPC();
    let request_token = _BundleExecutionDomainToken;
    RaiseInterrupt(0 as InterruptID, Zeros{24} + 9);
    assert _CurrentMemoryOrigin == MemoryEventOrigin_Handler;
    if mutation == 0 then
        ConfigureTile(0, 256, 4, 8, 1, 8, TileDataType_U64,
            TileLayout_RowMajor);
    elsif mutation == 1 then
        ReleaseTile(0);
        assert !_Tiles[[0]].allocated;
    else
        ConfigureTile(0, 512, 8, 16, 1, 8, TileDataType_U32,
            TileLayout_RowMajor);
    end;
    let recovered = RecoverTrapContext(0);
    assert recovered && ReadTPC() == parked_pc &&
           _BundleExecutionDomainToken == request_token;
    let released = ExecuteCommandInstruction(Zeros{64}, 16);
    assert released == CommandExecution_Executed &&
           _LastFault == Fault_None && !_BundleActive &&
           ReadTPC() != parked_pc && _MemoryEventCount == event_count;
    assert _SharedGenerations[[index]].published &&
           _SharedGenerations[[index]].operation_ordinal ==
               operation_ordinal &&
           _SharedGenerations[[index]].arrival_request_tokens[[0]] ==
               request_token &&
           _SharedGenerations[[index]].released_participants == '1001' &&
           SharedTilePublished(shared_id) &&
           ReadSharedTileWord(shared_id,
               0 as PackedTileElementIndex) == parent_word;

    for pe = 1 to PTO_MODEL_MEMORY_AGENTS - 2 do
        SelectExecutionContext(0 as PTOModelCoreIdentity,
            pe as MemoryAgentId);
        let peer_release = ExecuteCommandInstruction(Zeros{64}, 16);
        assert peer_release == CommandExecution_Executed &&
               _LastFault == Fault_None && !_BundleActive;
    end;
    assert _SharedGenerations[[index]].released_participants == '1111';
end;

func main() => integer
begin
    ResetProfileState();
    let launch = LaunchKernelInvocation(0 as PTOModelCoreIdentity,
        Zeros{PTO_XLEN} + 0x100);
    assert launch == KernelLifecycle_Started;
    RunCompletionMutation((Zeros{6} + 19) as SharedTileID, 0);
    RunCompletionMutation((Zeros{6} + 20) as SharedTileID, 1);
    RunCompletionMutation((Zeros{6} + 21) as SharedTileID, 2);
    return 0;
end;
