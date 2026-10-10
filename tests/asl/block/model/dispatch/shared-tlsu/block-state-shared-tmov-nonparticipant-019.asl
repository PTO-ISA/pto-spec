// PTO-TEST: {"id":"PTO-AVS-BLOCK-SHARED-TMOV-INACTIVE-019","source":"asl/block/model/dispatch/shared-tlsu.asl","requirements":["PTO-B-ASSEMBLE-SHARED-GENERATION-001","PTO-B-ASSEMBLE-SHARED-STANDALONE-001"],"kind":"state-transition","summary":"a legal nonparticipant B.ASSEMBLE TMOV retires without inspecting its private payload or changing the published generation","pass_condition":"each of four encoded sparse singleton INIT_LAST TMOVs publishes immediately from its selected PE; all three nonselected streams have allocated undefined private sources yet retire with no fault, arrival, ordinal, or parent/release change; malformed nonparticipant range structure still faults and preserves the published state","related_sources":["asl/block/model/operands/shared-generation-pe-requests.asl","asl/block/model/operands/range-modifiers.asl"]}

pure func InactiveTMOVStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00011181;
    instruction[24:20] = '00010';
    instruction[31:27] = Zeros{5} + 24;
    return instruction;
end;

pure func InactiveTMOVMode(pe: MemoryAgentId) => bits(3)
begin
    if pe == (0 as MemoryAgentId) then return '001'; end;
    if pe == (1 as MemoryAgentId) then return '010'; end;
    if pe == (2 as MemoryAgentId) then return '011'; end;
    return '100';
end;

pure func InactiveTMOVShared(shared_id: bits(6),
                             participant_pe: MemoryAgentId) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001013;
    instruction[25:20] = shared_id;
    instruction[18:15] = '0001';
    instruction[11:9] = InactiveTMOVMode(participant_pe);
    return instruction;
end;

pure func InactiveTMOVAssemble(offset: integer) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001053;
    instruction[31] = '1';
    instruction[30:20] = Zeros{11} + offset;
    instruction[11] = '1';
    instruction[10:7] = '0001';
    return instruction;
end;

pure func InactiveTMOVTile(pe: MemoryAgentId) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[25:20] = Zeros{6};
    instruction[11:9] = InactiveTMOVMode(pe);
    instruction[19] = '1';
    return instruction;
end;

func PrepareInactiveTMOV(pe: MemoryAgentId, offset: integer,
                         participant_pe: MemoryAgentId)
begin
    SelectExecutionContext(0, pe);
    let start = ExecuteCommandInstruction(InactiveTMOVStart(), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 16);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 16);
    let shared = ExecuteCommandInstruction(
        InactiveTMOVShared(Zeros{6} + 22, participant_pe), 32);
    let assemble = ExecuteCommandInstruction(
        InactiveTMOVAssemble(offset), 32);
    let tile = ExecuteCommandInstruction(InactiveTMOVTile(participant_pe), 32);
    assert start == CommandExecution_Executed &&
           shared == CommandExecution_Executed &&
           assemble == CommandExecution_Executed &&
           tile == CommandExecution_Executed &&
           _BundleSharedBindings[[0]].pe_mask ==
               SharedGenerationPEBit(participant_pe);
end;

func main() => integer
begin
    for selected_pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        ResetProfileState();
        let shared_id = (Zeros{6} + 22) as SharedTileID;
        let participant_pe = selected_pe as MemoryAgentId;
        let launch = LaunchKernelInvocation(0, Zeros{PTO_XLEN} + 0x100);
        assert launch == KernelLifecycle_Started;

        SelectExecutionContext(0, participant_pe);
        ConfigureTile(0, 128, 1, 16, 1, 16, TileDataType_U64,
            TileLayout_RowMajor);
        for column = 0 to 15 do
            WriteTileElement(0, 0, column,
                Zeros{PTO_XLEN} + 0xa000 + selected_pe * 0x100 + column);
        end;
        PrepareInactiveTMOV(participant_pe, 0, participant_pe);
        let eligible_stop = ExecuteCommandInstruction(Zeros{64}, 16);
        let index = SharedTileArrayIndex(shared_id);
        let ordinal = _SharedGenerations[[index]].operation_ordinal;
        let arrivals = _SharedGenerations[[index]].arrived_participants;
        let releases = _SharedGenerations[[index]].released_participants;
        let expected_word = ReadSharedTileWord(shared_id,
            0 as PackedTileElementIndex);
        let participant = SharedGenerationPEBit(participant_pe);
        assert eligible_stop == CommandExecution_Executed;
        assert _LastFault == Fault_None;
        assert !_BundleActive;
        assert SharedTilePublished(shared_id) && ordinal == 1 &&
               arrivals == participant && releases == participant;
        assert expected_word == Zeros{PTO_XLEN} +
                   0xa000 + selected_pe * 0x100;

        // Every nonselected PE has an allocated private source descriptor,
        // but its undefined contents are not part of this singleton request.
        for nonparticipant_pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
            if nonparticipant_pe != selected_pe then
                let agent = nonparticipant_pe as MemoryAgentId;
                SelectExecutionContext(0, agent);
                ConfigureTile(0, 128, 1, 16, 1, 16,
                    TileDataType_U64, TileLayout_RowMajor);
                assert !TileSourceContentsDefined(0);
                PrepareInactiveTMOV(agent, 0, participant_pe);
                let nonparticipant_stop =
                    ExecuteCommandInstruction(Zeros{64}, 16);
                assert nonparticipant_stop == CommandExecution_Executed &&
                       _LastFault == Fault_None && !_BundleActive &&
                       _SharedGenerations[[index]].published &&
                       _SharedGenerations[[index]].operation_ordinal ==
                           ordinal &&
                       _SharedGenerations[[index]].arrived_participants ==
                           arrivals &&
                       _SharedGenerations[[index]].released_participants ==
                           releases &&
                       ReadSharedTileWord(shared_id,
                           0 as PackedTileElementIndex) == expected_word;
            end;
        end;

        // Wire/range structure remains enforced for a nonparticipant.
        let malformed_pe = ((selected_pe + 1) MOD
            PTO_MODEL_MEMORY_AGENTS) as MemoryAgentId;
        SelectExecutionContext(0, malformed_pe);
        PrepareInactiveTMOV(malformed_pe, 1, participant_pe);
        let malformed_stop = ExecuteCommandInstruction(Zeros{64}, 16);
        assert malformed_stop == CommandExecution_Rejected &&
               _LastFault == Fault_TileLegality &&
               _SharedGenerations[[index]].published &&
               _SharedGenerations[[index]].operation_ordinal == ordinal &&
               _SharedGenerations[[index]].arrived_participants == arrivals &&
               _SharedGenerations[[index]].released_participants == releases &&
               ReadSharedTileWord(shared_id,
                   0 as PackedTileElementIndex) == expected_word;
    end;
    return 0;
end;
