// PTO-TEST: {"id":"PTO-AVS-BLOCK-SHARED-TLSU-ASSEMBLE-FOREIGN-RETIREMENT-015","source":"asl/block/model/state/shared-generation-state.asl","requirements":["PTO-ARCH-KERNEL-LIFECYCLE-001","PTO-B-ASSEMBLE-SHARED-GENERATION-001"],"kind":"state-transition","summary":"End and Abort retire only the target Core's actual-PE Shared candidates and release metadata while another Core's handler is selected.","pass_condition":"For both open and published/unconsumed target records, encoded contributions are followed by target-Core End or Abort while a different Core's real handler is selected. The target record is cleared, its published parent and next ordinal are preserved, and caller trap/context plus another Core candidate are unchanged.","related_sources":["asl/arch/state/kernel-lifecycle.asl","asl/block/model/operands/shared-generation.asl","asl/block/model/state/shared-generation-state.asl"]}

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

func TestForeignOpenRetirement(use_abort: boolean)
begin
    ResetProfileState();
    let shared_id = (Zeros{6} + 19) as SharedTileID;
    let launch0 = LaunchKernelInvocation(0, Zeros{PTO_XLEN});
    let launch1 = LaunchKernelInvocation(1, Zeros{PTO_XLEN} + 0x100);
    assert launch0 == KernelLifecycle_Started &&
           launch1 == KernelLifecycle_Started;
    PrepareSharedEndPE(0, 0, 0);
    let old_token = _BundleExecutionDomainToken;
    let first_stop = ExecuteCommandInstruction(Zeros{64}, 16);
    assert first_stop == CommandExecution_Executed && _LastFault == Fault_None;
    let index = SharedTileArrayIndex(shared_id);
    let retired_invocation = _CurrentKernelInvocation;
    assert _SharedGenerations[[index]].open &&
           _SharedGenerations[[index]].arrival_request_tokens[[0]] == old_token;

    SelectExecutionContext(1, 2);
    PrepareSharedEndPE(1, 2, 7);
    let peer_token = _BundleExecutionDomainToken;
    let peer_stop = ExecuteCommandInstruction(Zeros{64}, 16);
    assert peer_stop == CommandExecution_Executed && _LastFault == Fault_None;
    RaiseInterrupt(0 as InterruptID, Zeros{24} + 7);
    let caller_core = _CurrentModelCore;
    let caller_pe = _CurrentMemoryAgent;
    let caller_pc = ReadTPC();
    let caller_bpc = ReadBPC();
    let caller_acr = CurrentACR();
    let caller_origin = _CurrentMemoryOrigin;
    let caller_trap_pc = _TrapContexts[[CurrentACR()]].tpc;
    let caller_trap_domain =
        _TrapContexts[[CurrentACR()]].bundle_execution_domain_token;

    let retired = if use_abort then AbortKernelInvocation(0) else
        EndKernelInvocation(0);
    assert retired == KernelLifecycle_Started &&
           _CurrentModelCore == caller_core &&
           _CurrentMemoryAgent == caller_pe && ReadTPC() == caller_pc &&
           ReadBPC() == caller_bpc && CurrentACR() == caller_acr &&
           _CurrentMemoryOrigin == caller_origin &&
           _TrapContexts[[CurrentACR()]].valid &&
           _TrapContexts[[CurrentACR()]].tpc == caller_trap_pc &&
           _TrapContexts[[CurrentACR()]].bundle_execution_domain_token ==
               caller_trap_domain;
    assert _SharedGenerations[[index]].core_identity != 0 ||
           !_SharedGenerations[[index]].open;

    SelectExecutionContext(0, 0);
    assert !_SharedGenerations[[index]].open &&
           !_SharedGenerations[[index]].published &&
           _SharedGenerations[[index]].operation_ordinal == 0 &&
           _SharedGenerations[[index]].next_operation_ordinal == 1 &&
           _SharedGenerations[[index]].arrival_request_tokens[[0]] == 0;
    let fresh = LaunchKernelInvocation(0, Zeros{PTO_XLEN} + 0x200);
    assert fresh == KernelLifecycle_Started;
    PrepareSharedEndPE(0, 0, 1);
    let fresh_token = _BundleExecutionDomainToken;
    assert fresh_token != old_token;
    let fresh_stop = ExecuteCommandInstruction(Zeros{64}, 16);
    assert fresh_stop == CommandExecution_Executed &&
           _LastFault == Fault_None &&
           _SharedGenerations[[index]].open &&
           _SharedGenerations[[index]].operation_ordinal == 2 &&
           _SharedGenerations[[index]].arrival_request_tokens[[0]] ==
               fresh_token;

    SelectExecutionContext(1, 2);
    assert _SharedGenerations[[index]].open &&
           _SharedGenerations[[index]].core_identity == 1 &&
           _SharedGenerations[[index]].arrival_request_tokens[[2]] ==
               peer_token &&
           _CurrentMemoryOrigin == MemoryEventOrigin_Handler;
end;

func TestForeignPublishedRetirement(use_abort: boolean)
begin
    ResetProfileState();
    let shared_id = (Zeros{6} + 19) as SharedTileID;
    ConfigureTile(1, 512, 4, 16, 1, 16, TileDataType_U64,
        TileLayout_RowMajor);
    for column = 0 to 15 do
        WriteTileElement(1, 0, column, Zeros{PTO_XLEN} + 0x7700 + column);
    end;
    InstallSharedTile(shared_id, _Tiles[[1]], '1111');
    let launch0 = LaunchKernelInvocation(0, Zeros{PTO_XLEN});
    let launch1 = LaunchKernelInvocation(1, Zeros{PTO_XLEN} + 0x100);
    assert launch0 == KernelLifecycle_Started &&
           launch1 == KernelLifecycle_Started;
    var tokens: array [[PTO_MODEL_MEMORY_AGENTS]] of integer;
    for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        PrepareSharedEndPE(0, pe as MemoryAgentId, 3);
        tokens[[pe]] = _BundleExecutionDomainToken;
        let stop = ExecuteCommandInstruction(Zeros{64}, 16);
        assert stop == CommandExecution_Executed && _LastFault == Fault_None;
    end;
    let index = SharedTileArrayIndex(shared_id);
    let ordinal = _SharedGenerations[[index]].operation_ordinal;
    let parent = SharedTileRecord(shared_id);
    assert ordinal == 1 && _SharedGenerations[[index]].published &&
           _SharedGenerations[[index]].released_participants ==
               SharedGenerationPEBit(3 as MemoryAgentId);

    SelectExecutionContext(1, 2);
    PrepareSharedEndPE(1, 2, 9);
    let peer_token = _BundleExecutionDomainToken;
    let peer_stop = ExecuteCommandInstruction(Zeros{64}, 16);
    assert peer_stop == CommandExecution_Executed && _LastFault == Fault_None;
    RaiseInterrupt(0 as InterruptID, Zeros{24} + 8);
    let caller_pc = ReadTPC();
    let caller_bpc = ReadBPC();
    let caller_acr = CurrentACR();
    let caller_origin = _CurrentMemoryOrigin;
    let caller_trap_pc = _TrapContexts[[CurrentACR()]].tpc;
    let caller_trap_domain =
        _TrapContexts[[CurrentACR()]].bundle_execution_domain_token;
    let retired = if use_abort then AbortKernelInvocation(0) else
        EndKernelInvocation(0);
    assert retired == KernelLifecycle_Started && _CurrentModelCore == 1 &&
           _CurrentMemoryAgent == 2 && ReadTPC() == caller_pc &&
           ReadBPC() == caller_bpc && CurrentACR() == caller_acr &&
           _CurrentMemoryOrigin == caller_origin &&
           _TrapContexts[[CurrentACR()]].valid &&
           _TrapContexts[[CurrentACR()]].tpc == caller_trap_pc &&
           _TrapContexts[[CurrentACR()]].bundle_execution_domain_token ==
               caller_trap_domain;
    SelectExecutionContext(0, 0);
    assert !_SharedGenerations[[index]].open &&
           !_SharedGenerations[[index]].published &&
           _SharedGenerations[[index]].operation_ordinal == 0 &&
           _SharedGenerations[[index]].next_operation_ordinal == ordinal &&
           _SharedGenerations[[index]].released_participants == Zeros{4} &&
           _SharedGenerations[[index]].arrival_request_tokens[[0]] == 0 &&
           _SharedGenerations[[index]].arrival_request_tokens[[1]] == 0 &&
           _SharedGenerations[[index]].arrival_request_tokens[[2]] == 0 &&
           _SharedGenerations[[index]].arrival_request_tokens[[3]] == 0;
    assert SharedTilePublished(shared_id) &&
           SharedTileRecord(shared_id).tile.capacity_bytes ==
               parent.tile.capacity_bytes &&
           SharedTileRecord(shared_id).tile.rows == parent.tile.rows &&
           SharedTileRecord(shared_id).tile.columns == parent.tile.columns &&
           ReadSharedTileWord(shared_id,
               0 as PackedTileElementIndex) ==
               Zeros{PTO_XLEN} + 0x32000;

    SelectExecutionContext(1, 2);
    assert _SharedGenerations[[index]].open &&
           _SharedGenerations[[index]].core_identity == 1 &&
           _SharedGenerations[[index]].arrival_request_tokens[[2]] ==
               peer_token;
    SelectExecutionContext(0, 0);
    let launch_next = LaunchKernelInvocation(0,
        Zeros{PTO_XLEN} + 0x200);
    assert launch_next == KernelLifecycle_Started;
    PrepareSharedEndPE(0, 0, 4);
    let next_token = _BundleExecutionDomainToken;
    let next_stop = ExecuteCommandInstruction(Zeros{64}, 16);
    assert next_stop == CommandExecution_Executed && _LastFault == Fault_None &&
           _SharedGenerations[[index]].open &&
           _SharedGenerations[[index]].operation_ordinal == ordinal + 1 &&
           _SharedGenerations[[index]].arrival_request_tokens[[0]] ==
               next_token && next_token != tokens[[0]];
end;

func main() => integer
begin
    TestForeignOpenRetirement(TRUE);
    TestForeignOpenRetirement(FALSE);
    TestForeignPublishedRetirement(TRUE);
    TestForeignPublishedRetirement(FALSE);
    return 0;
end;
