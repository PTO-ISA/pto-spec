// PTO-TEST: {"id":"PTO-AVS-BLOCK-SHARED-TLSU-ASSEMBLE-END-012","source":"asl/block/model/operands/shared-generation-pe-requests.asl","requirements":["PTO-ARCH-KERNEL-LIFECYCLE-001","PTO-B-ASSEMBLE-SHARED-GENERATION-001"],"kind":"execution","summary":"Successful kernel end retires published Shared release metadata without erasing the parent or another Core's candidate.","pass_condition":"A real four-PE encoded B.ASSEMBLE publishes once with three unconsumed releases; successful End clears only its invocation-owned generation metadata while preserving the committed Shared payload and ordinal. A following invocation uses the next ordinal, and ending another Core leaves a live candidate intact until its owner ends.","related_sources":["asl/arch/state/kernel-lifecycle.asl","asl/block/model/operands/shared-generation.asl","asl/block/model/state/shared-generation-state.asl"]}
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
    ConfigureTile(1, 512, 4, 16, 1, 16, TileDataType_U64,
        TileLayout_RowMajor);
    for column = 0 to 15 do
        WriteTileElement(1, 0, column, Zeros{PTO_XLEN} + 0x7777 + column);
    end;
    InstallSharedTile(shared_id, _Tiles[[1]], '1111');

    let launch0 = LaunchKernelInvocation(0 as PTOModelCoreIdentity,
        Zeros{PTO_XLEN});
    assert launch0 == KernelLifecycle_Started;
    var old_tokens: array [[PTO_MODEL_MEMORY_AGENTS]] of integer;
    for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        let agent = pe as MemoryAgentId;
        PrepareSharedEndPE(0 as PTOModelCoreIdentity, agent, 0);
        old_tokens[[pe]] = _BundleExecutionDomainToken;
        let stop = ExecuteCommandInstruction(Zeros{64}, 16);
        assert stop == CommandExecution_Executed && _LastFault == Fault_None;
        if pe < PTO_MODEL_MEMORY_AGENTS - 1 then
            assert _BundleActive && BundleSharedGenerationRequestWaiting(0);
        end;
    end;
    let index = SharedTileArrayIndex(shared_id);
    let ordinal = _SharedGenerations[[index]].operation_ordinal;
    assert ordinal == 1 && SharedTilePublished(shared_id) &&
           _SharedGenerations[[index]].released_participants ==
               SharedGenerationPEBit(3 as MemoryAgentId);
    for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        assert _SharedGenerations[[index]].arrival_request_tokens[[pe]] ==
               old_tokens[[pe]];
    end;
    let committed_parent = SharedTileRecord(shared_id);
    let ended = EndKernelInvocation(0 as PTOModelCoreIdentity);
    assert ended == KernelLifecycle_Started;
    let retired = _SharedGenerations[[index]];
    assert !retired.open && !retired.published &&
           retired.arrived_participants == Zeros{4} &&
           retired.released_participants == Zeros{4} &&
           retired.operation_ordinal == 0 &&
           retired.next_operation_ordinal == ordinal &&
           retired.arrival_request_tokens[[0]] == 0 &&
           retired.arrival_request_tokens[[1]] == 0 &&
           retired.arrival_request_tokens[[2]] == 0 &&
           retired.arrival_request_tokens[[3]] == 0;
    assert SharedTilePublished(shared_id) &&
           SharedTileRecord(shared_id).tile.capacity_bytes ==
               committed_parent.tile.capacity_bytes &&
           SharedTileRecord(shared_id).tile.rows ==
               committed_parent.tile.rows &&
           SharedTileRecord(shared_id).tile.columns ==
               committed_parent.tile.columns &&
           ReadSharedTileWord(shared_id, 0 as PackedTileElementIndex) ==
               Zeros{PTO_XLEN} + 0x2000;

    let launch0_next = LaunchKernelInvocation(0 as PTOModelCoreIdentity,
        Zeros{PTO_XLEN} + 0x100);
    assert launch0_next == KernelLifecycle_Started;
    PrepareSharedEndPE(0 as PTOModelCoreIdentity, 0 as MemoryAgentId, 1);
    let next_token = _BundleExecutionDomainToken;
    assert next_token != old_tokens[[0]];
    let next_stop = ExecuteCommandInstruction(Zeros{64}, 16);
    assert next_stop == CommandExecution_Executed && _LastFault == Fault_None &&
           BundleSharedGenerationRequestWaiting(0);
    assert _SharedGenerations[[index]].open &&
           _SharedGenerations[[index]].operation_ordinal == ordinal + 1 &&
           _SharedGenerations[[index]].arrival_request_tokens[[0]] ==
               next_token;
    let abort0 = AbortKernelInvocation(0 as PTOModelCoreIdentity);
    assert abort0 == KernelLifecycle_Started;

    let launch1 = LaunchKernelInvocation(1 as PTOModelCoreIdentity,
        Zeros{PTO_XLEN} + 0x200);
    assert launch1 == KernelLifecycle_Started;
    PrepareSharedEndPE(1 as PTOModelCoreIdentity, 2 as MemoryAgentId, 2);
    let core1_stop = ExecuteCommandInstruction(Zeros{64}, 16);
    assert core1_stop ==
           CommandExecution_Executed && _LastFault == Fault_None;
    let core1_invocation = _CurrentKernelInvocation;
    assert _SharedGenerations[[index]].open &&
           _SharedGenerations[[index]].core_identity == 1 &&
           _SharedGenerations[[index]].invocation_identity ==
               core1_invocation;
    let core1_ordinal = _SharedGenerations[[index]].operation_ordinal;
    let launch0_other = LaunchKernelInvocation(0 as PTOModelCoreIdentity,
        Zeros{PTO_XLEN} + 0x300);
    assert launch0_other == KernelLifecycle_Started;
    let end0_other = EndKernelInvocation(0 as PTOModelCoreIdentity);
    assert end0_other == KernelLifecycle_Started;
    SelectExecutionContext(1 as PTOModelCoreIdentity, 2 as MemoryAgentId);
    assert _SharedGenerations[[index]].open &&
           _SharedGenerations[[index]].core_identity == 1 &&
           _SharedGenerations[[index]].invocation_identity ==
               core1_invocation;
    let end1 = EndKernelInvocation(1 as PTOModelCoreIdentity);
    assert end1 == KernelLifecycle_Started;
    assert !BundleSharedGenerationOpen(shared_id) &&
           !_SharedGenerations[[index]].published &&
           _SharedGenerations[[index]].next_operation_ordinal ==
               core1_ordinal;
    return 0;
end;
