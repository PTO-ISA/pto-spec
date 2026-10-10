// PTO-TEST: {"id":"PTO-AVS-BLOCK-SHARED-TLSU-ASSEMBLE-FAST-SLOW-PE-010","source":"asl/block/model/operands/shared-generation-pe-requests.asl","requirements":["PTO-ARCH-PE-EXECUTION-CONTEXT-001","PTO-B-ASSEMBLE-SHARED-GENERATION-001"],"kind":"execution","summary":"a fast PE retains its next B.ASSEMBLE request while slow peers consume the prior publication","pass_condition":"PE0 reaches the next encoded INIT before PE1/PE2 consume old release tokens, remains parked with its request identity and the prior Shared parent intact, then contributes once after the slow peers consume their original tokens and the next ordinal publishes the new complete parent","related_sources":["asl/block/model/operands/shared-generation.asl","asl/block/model/operands/shared-generation-pe-requests.asl","asl/block/model/dispatch/shared-tlsu.asl"]}
pure func FastSlowSharedStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00011181;
    instruction[24:20] = '00010';
    instruction[31:27] = Zeros{5} + 24;
    return instruction;
end;

pure func FastSlowSharedBinding(shared_id: bits(6), size_code: bits(4))
    => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001013;
    instruction[25:20] = shared_id;
    instruction[18:15] = size_code;
    instruction[11:9] = '111';
    return instruction;
end;

pure func FastSlowTileBinding(source: bits(6)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[25:20] = source;
    instruction[11:9] = '111';
    instruction[19] = '1';
    return instruction;
end;

pure func FastSlowAssemble(offset: integer) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001053;
    instruction[31] = '1';
    instruction[30:20] = Zeros{11} + offset;
    instruction[11] = '1';
    instruction[10:7] = Zeros{4} + 1;
    return instruction;
end;

func PrepareFastSlowPE(pe: MemoryAgentId, epoch: integer)
begin
    SelectExecutionContext(0 as PTOModelCoreIdentity, pe);
    ConfigureTile(0, 512, 4, 16, 1, 16, TileDataType_U64,
        TileLayout_RowMajor);
    for column = 0 to 15 do
        WriteTileElement(0, 0, column,
            Zeros{PTO_XLEN} + 0x1000 + epoch * 0x10000 +
                (pe as integer {0..3}) * 0x100 + column);
    end;
    let start = ExecuteCommandInstruction(FastSlowSharedStart(), 32);
    let shared = ExecuteCommandInstruction(FastSlowSharedBinding(
        Zeros{6} + 19, '0011'), 32);
    let assemble = ExecuteCommandInstruction(
        FastSlowAssemble(pe as integer {0..3}), 32);
    let tile = ExecuteCommandInstruction(FastSlowTileBinding(Zeros{6}), 32);
    assert start == CommandExecution_Executed &&
           shared == CommandExecution_Executed &&
           assemble == CommandExecution_Executed &&
           tile == CommandExecution_Executed;
    assert _BundleActive && _BundleSharedBindings[[0]].valid &&
           _BundleSharedBindings[[0]].destination_assemble.valid &&
           _BundleSharedBindings[[0]].pe_mask == '1111';
end;

func main() => integer
begin
    ResetProfileState();
    let launched = LaunchKernelInvocation(0 as PTOModelCoreIdentity,
        Zeros{PTO_XLEN});
    assert launched == KernelLifecycle_Started;
    var old_tokens : array [[PTO_MODEL_MEMORY_AGENTS]] of integer;
    var next_tokens : array [[PTO_MODEL_MEMORY_AGENTS]] of integer;
    for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        let agent = pe as MemoryAgentId;
        PrepareFastSlowPE(agent, 0);
        old_tokens[[pe]] = _BundleExecutionDomainToken;
        let stopped = ExecuteCommandInstruction(Zeros{64}, 16);
        assert stopped == CommandExecution_Executed &&
               _LastFault == Fault_None;
        if pe < PTO_MODEL_MEMORY_AGENTS - 1 then
            assert _BundleActive && BundleSharedGenerationRequestWaiting(0);
        end;
    end;
    let shared_id = (Zeros{6} + 19) as SharedTileID;
    assert SharedTilePublished(shared_id);
    let old_ordinal = _SharedGenerations[[
        SharedTileArrayIndex(shared_id)]].operation_ordinal;
    assert old_ordinal == 1;
    for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        assert _SharedGenerations[[SharedTileArrayIndex(shared_id)]]
            .arrival_request_tokens[[pe]] == old_tokens[[pe]];
    end;
    let old_parent = SharedTileRecord(shared_id);

    // PE3 closed and consumed its request; PE0 consumes its prior completion
    // and immediately reaches the next dynamic INIT while PE1 and PE2 still
    // hold the first operation's published STOP/release.
    SelectExecutionContext(0 as PTOModelCoreIdentity, 0 as MemoryAgentId);
    assert _BundleExecutionDomainToken == old_tokens[[0]] &&
           BundleSharedGenerationRequestWaiting(0);
    let old_stop = ExecuteCommandInstruction(Zeros{64}, 16);
    assert old_stop == CommandExecution_Executed && _LastFault == Fault_None &&
           !_BundleActive;
    assert _SharedGenerations[[SharedTileArrayIndex(shared_id)]]
        .released_participants == '1001';

    PrepareFastSlowPE(0 as MemoryAgentId, 1);
    next_tokens[[0]] = _BundleExecutionDomainToken;
    assert next_tokens[[0]] != old_tokens[[0]];
    let fast_tpc = ReadTPC();
    let fast_stop = ExecuteCommandInstruction(Zeros{64}, 16);
    assert fast_stop == CommandExecution_Executed &&
           _LastFault == Fault_None && ReadTPC() == fast_tpc;
    assert _BundleActive && BundleSharedGenerationRequestWaiting(0) &&
           _BundleExecutionDomainToken == next_tokens[[0]];
    let still_old = _SharedGenerations[[SharedTileArrayIndex(shared_id)]];
    assert still_old.published && !still_old.open &&
           still_old.operation_ordinal == old_ordinal &&
           still_old.released_participants == '1001';
    assert still_old.arrival_request_tokens[[1]] == old_tokens[[1]] &&
           still_old.arrival_request_tokens[[2]] == old_tokens[[2]];
    for cell = 0 to 63 do
        let row = cell DIVRM 16;
        let column = cell MOD 16;
        assert ReadSharedTileWord(shared_id,
            cell as PackedTileElementIndex) ==
            Zeros{PTO_XLEN} + 0x1000 + row * 0x100 + column;
    end;

    for pe = 1 to 2 do
        let agent = pe as MemoryAgentId;
        SelectExecutionContext(0 as PTOModelCoreIdentity, agent);
        assert _BundleExecutionDomainToken == old_tokens[[pe]] &&
               BundleSharedGenerationRequestWaiting(0);
        let slow_stop = ExecuteCommandInstruction(Zeros{64}, 16);
        assert slow_stop == CommandExecution_Executed &&
               _LastFault == Fault_None && !_BundleActive;
        assert _SharedGenerations[[SharedTileArrayIndex(shared_id)]]
            .arrival_request_tokens[[pe]] == old_tokens[[pe]];
    end;
    assert _SharedGenerations[[SharedTileArrayIndex(shared_id)]]
        .released_participants == '1111';

    // Retry the exact retained PE0 request after both slow peers consume their
    // old release. It opens ordinal two and contributes its saved epoch-one
    // snapshot once; PE1..3 contribute their actual private snapshots next.
    SelectExecutionContext(0 as PTOModelCoreIdentity, 0 as MemoryAgentId);
    assert _BundleExecutionDomainToken == next_tokens[[0]] &&
           BundleSharedGenerationRequestWaiting(0);
    let resumed = ExecuteCommandInstruction(Zeros{64}, 16);
    assert resumed == CommandExecution_Executed && _LastFault == Fault_None;
    let next_ordinal = old_ordinal + 1;
    assert _BundleActive && BundleSharedGenerationRequestWaiting(0) &&
           _SharedGenerations[[SharedTileArrayIndex(shared_id)]]
               .operation_ordinal == next_ordinal &&
           _SharedGenerations[[SharedTileArrayIndex(shared_id)]]
               .arrived_participants == SharedGenerationPEBit(0) &&
           _SharedGenerations[[SharedTileArrayIndex(shared_id)]]
               .arrival_request_tokens[[0]] == next_tokens[[0]];
    for pe = 1 to PTO_MODEL_MEMORY_AGENTS - 1 do
        let agent = pe as MemoryAgentId;
        PrepareFastSlowPE(agent, 1);
        next_tokens[[pe]] = _BundleExecutionDomainToken;
        SelectExecutionContext(0 as PTOModelCoreIdentity, agent);
        let stopped = ExecuteCommandInstruction(Zeros{64}, 16);
        assert stopped == CommandExecution_Executed &&
               _LastFault == Fault_None;
        if pe < PTO_MODEL_MEMORY_AGENTS - 1 then
            assert _BundleActive && BundleSharedGenerationRequestWaiting(0);
        end;
    end;
    assert SharedTilePublished(shared_id) &&
           _SharedGenerations[[SharedTileArrayIndex(shared_id)]]
               .operation_ordinal == next_ordinal;
    let replacement = SharedTileRecord(shared_id);
    for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        for column = 0 to 15 do
            let index = TileLogicalLinearIndex(replacement.tile,
                pe as integer {0..3}, column as integer {0..15});
            assert TileReadLogicalElement(replacement.tile, index) ==
                Zeros{PTO_XLEN} + 0x11000 + pe * 0x100 + column;
        end;
    end;
    for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 2 do
        let agent = pe as MemoryAgentId;
        SelectExecutionContext(0 as PTOModelCoreIdentity, agent);
        assert _BundleActive && BundleSharedGenerationRequestWaiting(0) &&
               _BundleExecutionDomainToken == next_tokens[[pe]];
        let released = ExecuteCommandInstruction(Zeros{64}, 16);
        assert released == CommandExecution_Executed &&
               _LastFault == Fault_None && !_BundleActive;
    end;
    assert _SharedGenerations[[SharedTileArrayIndex(shared_id)]]
        .released_participants == '1111';
    assert old_parent.tile.capacity_bytes == 512;
    return 0;
end;
