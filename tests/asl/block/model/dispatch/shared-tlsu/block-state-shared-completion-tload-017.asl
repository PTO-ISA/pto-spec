// PTO-TEST: {"id":"PTO-AVS-BLOCK-SHARED-COMPLETION-TLOAD-017","source":"asl/block/model/dispatch/shared-tlsu.asl","requirements":["PTO-TLOAD-MEMORY-001","PTO-B-ASSEMBLE-SHARED-GENERATION-001","PTO-ARCH-MEMORY-MODEL-TRAP-RESTORE-001"],"kind":"state-transition","summary":"actual-PE Shared TLOADs read only their own range and exact published completion does not re-probe the private source","pass_condition":"four encoded full-mask B.ASSEMBLE TLOAD requests each read and contribute only their executing PE range; after PE0 handler changes its private base to an inaccessible address, its exact stop retires without source revalidation; a sparse nonparticipant with an inaccessible base retires without effects, while an invalid new request preserves the published parent and pending peer releases","related_sources":["asl/tile/memory-and-data-movement/regular/TLOAD.asl","asl/tile/model/memory/shared-movement.asl","asl/block/model/operands/shared-generation-pe-requests.asl"]}

pure func SharedTLoadStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00011181;
    instruction[24:20] = '00000';
    instruction[31:27] = Zeros{5} + 24;
    return instruction;
end;

pure func SharedTLoadBinding(shared_id: bits(6), pe_mode: bits(3))
    => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001013;
    instruction[25:20] = shared_id;
    instruction[18:15] = '0011';
    instruction[11:9] = pe_mode;
    return instruction;
end;

pure func SharedTLoadAssemble(offset: integer) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001053;
    instruction[31] = '1';
    instruction[30:20] = Zeros{11} + offset;
    instruction[11] = '1';
    instruction[10:7] = '0001';
    return instruction;
end;

pure func SharedTLoadIOR() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000013;
    instruction[19:15] = Zeros{5} + 2;
    instruction[24:20] = Zeros{5} + 3;
    return instruction;
end;

func WriteMemoryWordBytes(address: Word, value: Word)
begin
    WriteMemoryByte(address + 0, value[7:0]);
    WriteMemoryByte(address + 1, value[15:8]);
    WriteMemoryByte(address + 2, value[23:16]);
    WriteMemoryByte(address + 3, value[31:24]);
    WriteMemoryByte(address + 4, value[39:32]);
    WriteMemoryByte(address + 5, value[47:40]);
    WriteMemoryByte(address + 6, value[55:48]);
    WriteMemoryByte(address + 7, value[63:56]);
end;

func PrepareSharedTLoadPE(pe: MemoryAgentId, base: Word,
                          pe_mode: bits(3), writer_offset: integer)
begin
    SelectExecutionContext(0, pe);
    WriteGPR(2, base);
    WriteGPR(3, Zeros{PTO_XLEN});
    let start = ExecuteCommandInstruction(SharedTLoadStart(), 32);
    assert _LastFault == Fault_None;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 16);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 4);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 16);
    let shared = ExecuteCommandInstruction(
        SharedTLoadBinding(Zeros{6} + 19, pe_mode), 32);
    assert _LastFault == Fault_None;
    let assemble = ExecuteCommandInstruction(
        SharedTLoadAssemble(writer_offset), 32);
    assert _LastFault == Fault_None;
    let ior = ExecuteCommandInstruction(SharedTLoadIOR(), 32);
    assert _LastFault == Fault_None;
    assert start == CommandExecution_Executed &&
           shared == CommandExecution_Executed &&
           assemble == CommandExecution_Executed &&
           ior == CommandExecution_Executed &&
           _BundleSharedBindings[[0]].pe_mask ==
               if pe_mode == '111' then '1111' else '1000';
end;

func main() => integer
begin
    ResetProfileState();
    let shared_id = (Zeros{6} + 19) as SharedTileID;
    for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        let base = Zeros{PTO_XLEN} + 0x100 + pe * 0x100;
        for column = 0 to 15 do
            let value = Zeros{PTO_XLEN} + 0x1000 + pe * 0x100 + column;
            WriteMemoryWordBytes(base + column * 8, value);
        end;
        WritePEGPR(pe as MemoryAgentId, 2,
            Zeros{PTO_XLEN} + 0x1000);
    end;
    let launch = LaunchKernelInvocation(0, Zeros{PTO_XLEN} + 0x100);
    assert launch == KernelLifecycle_Started;
    let index = SharedTileArrayIndex(shared_id);
    for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        let agent = pe as MemoryAgentId;
        let base = Zeros{PTO_XLEN} + 0x100 + pe * 0x100;
        let writer_offset = (pe + 1) MOD 4;
        if pe == 1 then
            assert _SharedGenerations[[index]].open &&
                   _SharedGenerations[[index]].actual_pe_owned;
        end;
        PrepareSharedTLoadPE(agent, base, '111', writer_offset);
        if pe == 1 then
            assert _SharedGenerations[[index]].open &&
                   _SharedGenerations[[index]].actual_pe_owned;
        end;
        assert _CurrentPEContextValid &&
               _CurrentMemoryAgent == agent && _CurrentModelCore == 0;
        let stopped = ExecuteCommandInstruction(Zeros{64}, 16);
        assert _CurrentPEContextValid &&
               _CurrentMemoryAgent == agent && _CurrentModelCore == 0;
        assert stopped == CommandExecution_Executed &&
               _LastFault == Fault_None;
        if pe < PTO_MODEL_MEMORY_AGENTS - 1 then
            assert BundleSharedGenerationRequestWaiting(0) &&
                   !_SharedGenerations[[SharedTileArrayIndex(shared_id)]]
                       .published;
        end;
    end;
    let generation = _SharedGenerations[[index]];
    let parent = SharedTileRecord(shared_id);
    let parent_word_before = TileReadLogicalElement(parent.tile, 0);
    assert generation.published && generation.operation_ordinal == 1 &&
           generation.arrived_participants == '1111' &&
           generation.released_participants ==
               SharedGenerationPEBit(3 as MemoryAgentId) &&
           parent.tile.capacity_bytes == 512 && parent.tile.rows == 4 &&
           parent.tile.columns == 16;
    for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        for column = 0 to 15 do
            let element = TileLogicalLinearIndex(parent.tile,
                pe as integer {0..3}, column as integer {0..15});
            let source_pe = (pe + 3) MOD 4;
            assert TileReadLogicalElement(parent.tile, element) ==
                Zeros{PTO_XLEN} + 0x1000 + source_pe * 0x100 + column;
        end;
    end;

    SelectExecutionContext(0, 0);
    assert BundleSharedGenerationRequestWaiting(0);
    let parked_pc = ReadTPC();
    let parked_token = _BundleExecutionDomainToken;
    RaiseInterrupt(0 as InterruptID, Zeros{24} + 9);
    assert _CurrentMemoryOrigin == MemoryEventOrigin_Handler;
    WriteGPR(2, Zeros{PTO_XLEN} + 0x1000);
    let recovered = RecoverTrapContext(0);
    assert recovered && _CurrentMemoryOrigin == MemoryEventOrigin_Kernel &&
           _BundleExecutionDomainToken == parked_token;
    let denied_source = ProbeTileMemoryAccess(
        Zeros{PTO_XLEN} + 0x1000, TileDataType_U64, FALSE);
    assert denied_source.fault == Fault_DataPage;
    let released = ExecuteCommandInstruction(Zeros{64}, 16);
    assert released == CommandExecution_Executed &&
           _LastFault == Fault_None && !_BundleActive &&
           ReadTPC() != parked_pc;
    assert _SharedGenerations[[index]].published &&
           _SharedGenerations[[index]].operation_ordinal == 1 &&
           _SharedGenerations[[index]].arrived_participants == '1111' &&
           _SharedGenerations[[index]].released_participants ==
               (SharedGenerationPEBit(3 as MemoryAgentId) OR
                SharedGenerationPEBit(0 as MemoryAgentId)) &&
           _SharedGenerations[[index]].arrival_request_tokens[[0]] ==
               parked_token && SharedTilePublished(shared_id);
    let parent_after_retry = SharedTileRecord(shared_id);
    assert parent_after_retry.tile.capacity_bytes == parent.tile.capacity_bytes &&
           parent_word_before == TileReadLogicalElement(parent.tile, 0);
    assert ReadSharedTileWord(shared_id,
               0 as PackedTileElementIndex) == parent_word_before;

    // PE2 consumes its own original completion, then executes a structurally
    // valid sparse-mask assembly request as a nonparticipant. Its private
    // source address is outside modeled memory and must remain unobserved.
    SelectExecutionContext(0, 2);
    assert _CurrentPEContextValid && _CurrentMemoryAgent == 2 &&
           _BundleActive &&
           _BundleSharedBindings[[0]].destination_assemble
               .shared_request_identity_valid;
    let peer_release = ExecuteCommandInstruction(Zeros{64}, 16);
    assert peer_release == CommandExecution_Executed &&
           _LastFault == Fault_None && !_BundleActive;
    let release_before_nonparticipant =
        _SharedGenerations[[index]].released_participants;
    let arrival_before_nonparticipant =
        _SharedGenerations[[index]].arrived_participants;
    let ordinal_before_nonparticipant =
        _SharedGenerations[[index]].operation_ordinal;
    PrepareSharedTLoadPE(2 as MemoryAgentId,
        Zeros{PTO_XLEN} + 0x1000, '001', 0);
    assert _CurrentPEContextValid && _CurrentMemoryAgent == 2 &&
           _BundleSharedBindings[[0]].pe_mask == '1000';
    let nonparticipant_stop = ExecuteCommandInstruction(Zeros{64}, 16);
    assert nonparticipant_stop == CommandExecution_Executed &&
           _LastFault == Fault_None && !_BundleActive &&
           _SharedGenerations[[index]].published &&
           _SharedGenerations[[index]].operation_ordinal ==
               ordinal_before_nonparticipant &&
           _SharedGenerations[[index]].arrived_participants ==
               arrival_before_nonparticipant &&
           _SharedGenerations[[index]].released_participants ==
               release_before_nonparticipant &&
           ReadSharedTileWord(shared_id,
               0 as PackedTileElementIndex) == parent_word_before;

    // A structurally invalid new nonparticipant request still faults, but
    // cannot erase the previous publication's pending peer releases.
    SelectExecutionContext(0, 2);
    let bad_start = ExecuteCommandInstruction(SharedTLoadStart(), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 17);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 4);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 16);
    let bad_shared = ExecuteCommandInstruction(
        SharedTLoadBinding(Zeros{6} + 19, '001'), 32);
    let bad_assemble = ExecuteCommandInstruction(
        SharedTLoadAssemble(0), 32);
    let bad_ior = ExecuteCommandInstruction(SharedTLoadIOR(), 32);
    let bad_stop = ExecuteCommandInstruction(Zeros{64}, 16);
    assert bad_start == CommandExecution_Executed &&
           bad_shared == CommandExecution_Executed &&
           bad_assemble == CommandExecution_Executed &&
           bad_ior == CommandExecution_Executed &&
           bad_stop == CommandExecution_Rejected &&
           _LastFault == Fault_TileLegality;
    assert _SharedGenerations[[index]].published &&
           _SharedGenerations[[index]].operation_ordinal == 1 &&
           _SharedGenerations[[index]].released_participants ==
               release_before_nonparticipant &&
           SharedTilePublished(shared_id) &&
           ReadSharedTileWord(shared_id,
               0 as PackedTileElementIndex) == parent_word_before;
    return 0;
end;
