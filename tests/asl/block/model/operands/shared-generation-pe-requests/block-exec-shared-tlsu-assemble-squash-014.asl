// PTO-TEST: {"id":"PTO-AVS-BLOCK-SHARED-TLSU-ASSEMBLE-SQUASH-014","source":"asl/block/model/operands/shared-generation-pe-requests.asl","requirements":["PTO-ARCH-PE-EXECUTION-CONTEXT-001","PTO-ARCH-KERNEL-LIFECYCLE-001","PTO-B-ASSEMBLE-SHARED-GENERATION-001","PTO-B-ASSEMBLE-SPECULATION-001"],"kind":"execution","summary":"A real Shared PE contribution is discarded by its execution-domain squash without false publication, trap restoration cannot revive its request, and fresh requests remain isolated from unrelated Core candidates.","pass_condition":"An encoded PE0 contribution opens an actual-PE Core candidate; squash by matching Core/invocation/token discards only that incomplete candidate and marks saved trap and live request identities. The old stop remains parked and creates no event/publication. Trap control-register recovery redirects to an inactive restart; a real encoded BSTART allocates a new token, and four encoded contributions publish only their own payload at the next ordinal. A concurrent Core1 candidate survives and completes independently. A squash after full publication preserves the result and every outstanding release token.","related_sources":["asl/block/model/operands/shared-generation-pe-requests.asl","asl/block/model/state/shared-generation-state.asl","asl/arch/state/pe-execution-context.asl","asl/block/model/operands/local-generation-squash.asl"]}
pure func SquashAssembleStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00011181;
    instruction[24:20] = '00010';
    instruction[31:27] = Zeros{5} + 24;
    return instruction;
end;

pure func SquashAssembleBinding() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001013;
    instruction[25:20] = Zeros{6} + 19;
    instruction[18:15] = '0011';
    instruction[11:9] = '111';
    return instruction;
end;

pure func SquashAssembleModifier(offset: integer) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001053;
    instruction[31] = '1';
    instruction[30:20] = Zeros{11} + offset;
    instruction[11] = '1';
    instruction[10:7] = '0001';
    return instruction;
end;

pure func SquashAssembleTileBinding() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[25:20] = Zeros{6};
    instruction[11:9] = '111';
    instruction[19] = '1';
    return instruction;
end;

func PrepareSquashAssemblePE(core: PTOModelCoreIdentity,
                             pe: MemoryAgentId, epoch: integer)
begin
    SelectExecutionContext(core, pe);
    ConfigureTile(0, 512, 4, 16, 1, 16, TileDataType_U64,
        TileLayout_RowMajor);
    for column = 0 to 15 do
        WriteTileElement(0, 0, column,
            Zeros{PTO_XLEN} + 0x1000 + epoch * 0x10000 +
                (pe as integer {0..3}) * 0x100 + column);
    end;
    let start = ExecuteCommandInstruction(SquashAssembleStart(), 32);
    let shared = ExecuteCommandInstruction(SquashAssembleBinding(), 32);
    let assemble = ExecuteCommandInstruction(SquashAssembleModifier(
        pe as integer {0..3}), 32);
    let tile = ExecuteCommandInstruction(SquashAssembleTileBinding(), 32);
    assert start == CommandExecution_Executed &&
           shared == CommandExecution_Executed &&
           assemble == CommandExecution_Executed &&
           tile == CommandExecution_Executed &&
           _BundleSharedBindings[[0]].pe_mask == '1111';
end;

func SubmitSquashAssemblePE(core: PTOModelCoreIdentity,
                            pe: MemoryAgentId, epoch: integer) => integer
begin
    PrepareSquashAssemblePE(core, pe, epoch);
    let domain = _BundleExecutionDomainToken;
    let stopped = ExecuteCommandInstruction(Zeros{64}, 16);
    assert stopped == CommandExecution_Executed && _LastFault == Fault_None;
    return domain;
end;

func main() => integer
begin
    ResetProfileState();
    let shared_id = (Zeros{6} + 19) as SharedTileID;

    SelectExecutionContext(0 as PTOModelCoreIdentity, 0 as MemoryAgentId);
    ConfigureTile(1, 512, 4, 16, 1, 16, TileDataType_U64,
        TileLayout_RowMajor);
    for column = 0 to 15 do
        WriteTileElement(1, 0, column, Zeros{PTO_XLEN} + 0x5555 + column);
    end;
    InstallSharedTile(shared_id, _Tiles[[1]], '1111');

    let launch0 = LaunchKernelInvocation(0 as PTOModelCoreIdentity,
        Zeros{PTO_XLEN} + 0x100);
    assert launch0 == KernelLifecycle_Started;
    PrepareSquashAssemblePE(0 as PTOModelCoreIdentity,
        0 as MemoryAgentId, 0);
    let old_domain = _BundleExecutionDomainToken;
    let old_tpc = ReadTPC();
    let old_stop = ExecuteCommandInstruction(Zeros{64}, 16);
    let index = SharedTileArrayIndex(shared_id);
    let old_ordinal = _SharedGenerations[[index]].operation_ordinal;
    assert old_stop == CommandExecution_Executed && _LastFault == Fault_None &&
           old_ordinal == 1 && _SharedGenerations[[index]].open &&
           _SharedGenerations[[index]].actual_pe_owned &&
           _SharedGenerations[[index]].core_identity == 0 &&
           _SharedGenerations[[index]].invocation_identity ==
               _CurrentKernelInvocation &&
           _SharedGenerations[[index]].arrival_request_tokens[[0]] ==
               old_domain && BundleSharedGenerationRequestWaiting(0);
    assert ReadSharedTileWord(shared_id, 0 as PackedTileElementIndex) ==
        Zeros{PTO_XLEN} + 0x5555;

    // A genuine trap saves the old Block request before the squash. The
    // cancellation must be copied into both that saved image and live PE state.
    RaiseInterrupt(0 as InterruptID, Zeros{24} + 9);
    assert _CurrentMemoryOrigin == MemoryEventOrigin_Handler &&
           _TrapContexts[[CurrentACR()]].valid &&
           _TrapContexts[[CurrentACR()]].bundle_execution_domain_token ==
               old_domain &&
           !_TrapContexts[[CurrentACR()]].bundle_shared_bindings[[0]]
               .destination_assemble.shared_request_squashed;

    // Keep another Core's real candidate live across the matching squash.
    let launch1 = LaunchKernelInvocation(1 as PTOModelCoreIdentity,
        Zeros{PTO_XLEN} + 0x200);
    assert launch1 == KernelLifecycle_Started;
    SelectExecutionContext(1 as PTOModelCoreIdentity, 0 as MemoryAgentId);
    ConfigureTile(1, 512, 4, 16, 1, 16, TileDataType_U64,
        TileLayout_RowMajor);
    for column = 0 to 15 do
        WriteTileElement(1, 0, column, Zeros{PTO_XLEN} + 0x7777 + column);
    end;
    InstallSharedTile(shared_id, _Tiles[[1]], '1111');
    var core1_domains: array [[PTO_MODEL_MEMORY_AGENTS]] of integer;
    core1_domains[[2]] = SubmitSquashAssemblePE(1 as PTOModelCoreIdentity,
        2 as MemoryAgentId, 9);
    let core1_ordinal = _SharedGenerations[[index]].operation_ordinal;
    assert _SharedGenerations[[index]].open &&
           _SharedGenerations[[index]].core_identity == 1 &&
           _SharedGenerations[[index]].arrival_request_tokens[[2]] ==
               core1_domains[[2]];
    SelectExecutionContext(0 as PTOModelCoreIdentity, 0 as MemoryAgentId);
    assert _CurrentModelCore == 0 && _CurrentKernelInvocation != 0 &&
           _CurrentMemoryOrigin == MemoryEventOrigin_Handler;

    EnterBundleExecutionDomainSquashEvent(old_domain);
    assert !_SharedGenerations[[index]].open &&
           !_SharedGenerations[[index]].published &&
           _SharedGenerations[[index]].next_operation_ordinal == old_ordinal &&
           _SharedGenerations[[index]].operation_ordinal == 0 &&
           ReadSharedTileWord(shared_id, 0 as PackedTileElementIndex) ==
               Zeros{PTO_XLEN} + 0x5555 &&
           _PEExecutionContexts[[0]][[0]].bundle_shared_bindings[[0]]
               .destination_assemble.shared_request_squashed &&
           _TrapContexts[[CurrentACR()]].bundle_shared_bindings[[0]]
               .destination_assemble.shared_request_squashed;
    SelectExecutionContext(1 as PTOModelCoreIdentity, 2 as MemoryAgentId);
    assert _SharedGenerations[[index]].open &&
           _SharedGenerations[[index]].core_identity == 1 &&
           _SharedGenerations[[index]].invocation_identity ==
               _KernelInvocationByCore[[1]] &&
           _SharedGenerations[[index]].arrival_request_tokens[[2]] ==
               core1_domains[[2]];
    SelectExecutionContext(0 as PTOModelCoreIdentity, 0 as MemoryAgentId);
    assert _CurrentMemoryOrigin == MemoryEventOrigin_Handler;
    let recovered = RecoverTrapContext(CurrentACR());
    assert recovered && _CurrentMemoryOrigin == MemoryEventOrigin_Kernel &&
           _BundleExecutionDomainToken == old_domain &&
           _BundleSharedBindings[[0]].destination_assemble
               .shared_request_squashed;
    let stale_stop = ExecuteCommandInstruction(Zeros{64}, 16);
    assert stale_stop == CommandExecution_Executed &&
           _LastFault == Fault_None && ReadTPC() == old_tpc &&
           BundleSharedGenerationRequestWaiting(0) &&
           !_SharedGenerations[[index]].open &&
           ReadSharedTileWord(shared_id, 0 as PackedTileElementIndex) ==
               Zeros{PTO_XLEN} + 0x5555;

    // A real trap handler redirects the saved architectural Block control to
    // an inactive restart PC. Recovery restores the squashed frame's canceled
    // marker; only the actual encoded BSTART below allocates the new token.
    RaiseInterrupt(0 as InterruptID, Zeros{24} + 10);
    assert _CurrentMemoryOrigin == MemoryEventOrigin_Handler &&
           _TrapContexts[[CurrentACR()]].bundle_shared_bindings[[0]]
               .destination_assemble.shared_request_squashed;
    let replay_ring = CurrentACR();
    var saved_control = ReadContextRegister(replay_ring, 0x0f40);
    saved_control[5] = '0';
    saved_control[6] = '0';
    WriteContextRegister(replay_ring, 0x0f40, saved_control);
    WriteContextRegister(replay_ring, 0x0f41, Zeros{PTO_XLEN} + 0x100);
    WriteContextRegister(replay_ring, 0x0f43, Zeros{PTO_XLEN} + 0x100);
    let replayed = RecoverTrapContext(replay_ring);
    assert replayed && !_BundleActive && _CurrentMemoryOrigin ==
           MemoryEventOrigin_Kernel &&
           _BundleSharedBindings[[0]].destination_assemble
               .shared_request_squashed;

    var core0_domains: array [[PTO_MODEL_MEMORY_AGENTS]] of integer;
    PrepareSquashAssemblePE(0 as PTOModelCoreIdentity,
        0 as MemoryAgentId, 1);
    core0_domains[[0]] = _BundleExecutionDomainToken;
    assert core0_domains[[0]] != old_domain &&
           !_BundleSharedBindings[[0]].destination_assemble
               .shared_request_squashed;
    let replay_stop = ExecuteCommandInstruction(Zeros{64}, 16);
    assert replay_stop == CommandExecution_Executed &&
           _LastFault == Fault_None && _SharedGenerations[[index]].open &&
           _SharedGenerations[[index]].operation_ordinal == old_ordinal + 1 &&
           _SharedGenerations[[index]].arrival_request_tokens[[0]] ==
               core0_domains[[0]] &&
           SharedTilePublished(shared_id) &&
           ReadSharedTileWord(shared_id, 0 as PackedTileElementIndex) ==
               Zeros{PTO_XLEN} + 0x5555;
    for pe_number = 1 to PTO_MODEL_MEMORY_AGENTS - 1 do
        core0_domains[[pe_number]] = SubmitSquashAssemblePE(
            0 as PTOModelCoreIdentity, pe_number as MemoryAgentId, 1);
        SelectExecutionContext(0 as PTOModelCoreIdentity,
            pe_number as MemoryAgentId);
        assert _BundleExecutionDomainToken != old_domain &&
               !_BundleSharedBindings[[0]].destination_assemble
                   .shared_request_squashed;
        if pe_number < PTO_MODEL_MEMORY_AGENTS - 1 then
            assert _SharedGenerations[[index]].open &&
                   !_SharedGenerations[[index]].published &&
                   _SharedGenerations[[index]].operation_ordinal ==
                       old_ordinal + 1 &&
                   _SharedGenerations[[index]].arrival_request_tokens[[pe_number]] ==
                       core0_domains[[pe_number]] &&
                   SharedTilePublished(shared_id) &&
                   ReadSharedTileWord(shared_id,
                       0 as PackedTileElementIndex) ==
                       Zeros{PTO_XLEN} + 0x5555;
        end;
    end;
    assert _SharedGenerations[[index]].published &&
           _SharedGenerations[[index]].operation_ordinal == old_ordinal + 1;
    let core0_parent = SharedTileRecord(shared_id);
    for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        for column = 0 to 15 do
            let element = TileLogicalLinearIndex(core0_parent.tile,
                pe as integer {0..3}, column as integer {0..15});
            assert TileReadLogicalElement(core0_parent.tile, element) ==
                Zeros{PTO_XLEN} + 0x11000 + pe * 0x100 + column;
        end;
    end;

    // The old PE2 request on Core1 remains independent and contributes its
    // captured payload when the other three real participants arrive.
    assert _SharedGenerations[[index]].core_identity == 0;
    for pe_number = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        if pe_number != 2 then
            core1_domains[[pe_number]] = SubmitSquashAssemblePE(
                1 as PTOModelCoreIdentity, pe_number as MemoryAgentId, 9);
        end;
    end;
    SelectExecutionContext(1 as PTOModelCoreIdentity, 3 as MemoryAgentId);
    assert _SharedGenerations[[index]].published &&
           _SharedGenerations[[index]].core_identity == 1 &&
           _SharedGenerations[[index]].operation_ordinal == core1_ordinal;
    let core1_parent = SharedTileRecord(shared_id);
    for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        for column = 0 to 15 do
            let element = TileLogicalLinearIndex(core1_parent.tile,
                pe as integer {0..3}, column as integer {0..15});
            assert TileReadLogicalElement(core1_parent.tile, element) ==
                Zeros{PTO_XLEN} + 0x91000 + pe * 0x100 + column;
        end;
    end;

    // A squash after irrevocable publication cannot discard any retained
    // completion token: the exact original stop still consumes its release.
    SelectExecutionContext(0 as PTOModelCoreIdentity, 0 as MemoryAgentId);
    assert _BundleSharedBindings[[0]].destination_assemble
               .shared_request_execution_domain == core0_domains[[0]] &&
           _BundleSharedBindings[[0]].destination_assemble.shared_request_waiting;
    let released_before = _SharedGenerations[[index]].released_participants;
    EnterBundleExecutionDomainSquashEvent(core0_domains[[0]]);
    assert _SharedGenerations[[index]].published &&
           _SharedGenerations[[index]].released_participants == released_before &&
           !_BundleSharedBindings[[0]].destination_assemble
               .shared_request_squashed;
    let first_release = ExecuteCommandInstruction(Zeros{64}, 16);
    assert first_release == CommandExecution_Executed && _LastFault == Fault_None &&
           !_BundleSharedBindings[[0]].destination_assemble.shared_request_waiting;
    for pe_number = 1 to PTO_MODEL_MEMORY_AGENTS - 2 do
        SelectExecutionContext(0 as PTOModelCoreIdentity,
            pe_number as MemoryAgentId);
        let released = ExecuteCommandInstruction(Zeros{64}, 16);
        assert released == CommandExecution_Executed && _LastFault == Fault_None;
    end;
    assert _SharedGenerations[[index]].released_participants == '1111';
    return 0;
end;
