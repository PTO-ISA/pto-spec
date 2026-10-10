// PTO-TEST: {"id":"PTO-AVS-BLOCK-SHARED-TLOAD-READINESS-020","source":"asl/block/model/dispatch/shared-tlsu.asl","requirements":["PTO-TLOAD-MEMORY-001","PTO-B-ASSEMBLE-SHARED-GENERATION-001"],"kind":"state-transition","summary":"multi-PE TLOAD B.ASSEMBLE keeps LAST parked when actual source fragments do not fill their covered writer ranges","pass_condition":"two encoded PEs each cover a distinct 256B destination range of a 512B parent but read only their real 128B source stripe; full participant arrival and coverage do not publish the incomplete valid payload or replace the prior parent","related_sources":["asl/tile/model/memory/shared-movement.asl","asl/block/model/operands/shared-generation-pe-requests.asl","asl/block/model/operands/shared-generation.asl"]}

pure func ReadinessTLoadStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00011181;
    instruction[24:20] = '00000';
    instruction[31:27] = Zeros{5} + 24;
    return instruction;
end;

pure func ReadinessTLoadBinding(shared_id: bits(6)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001013;
    instruction[25:20] = shared_id;
    instruction[18:15] = '0011';
    instruction[11:9] = '101';
    return instruction;
end;

pure func ReadinessTLoadAssemble(offset: integer) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001053;
    instruction[31] = '1';
    instruction[30:20] = Zeros{11} + offset;
    instruction[11] = '1';
    instruction[10:7] = '0010';
    return instruction;
end;

pure func ReadinessTLoadIOR() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000013;
    instruction[19:15] = Zeros{5} + 2;
    instruction[24:20] = Zeros{5} + 3;
    return instruction;
end;

func WriteReadinessMemoryWord(address: Word, value: Word)
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

func PrepareReadinessTLoadPE(pe: MemoryAgentId, base: Word,
                             destination_offset: integer)
begin
    SelectExecutionContext(0, pe);
    WriteGPR(2, base);
    WriteGPR(3, Zeros{PTO_XLEN});
    let start = ExecuteCommandInstruction(ReadinessTLoadStart(), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 16);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 4);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 16);
    let binding = ExecuteCommandInstruction(
        ReadinessTLoadBinding(Zeros{6} + 23), 32);
    let assemble = ExecuteCommandInstruction(
        ReadinessTLoadAssemble(destination_offset), 32);
    let ior = ExecuteCommandInstruction(ReadinessTLoadIOR(), 32);
    assert start == CommandExecution_Executed &&
           binding == CommandExecution_Executed &&
           assemble == CommandExecution_Executed &&
           ior == CommandExecution_Executed &&
           _BundleSharedBindings[[0]].pe_mask == '1100';
end;

func main() => integer
begin
    ResetProfileState();
    let shared_id = (Zeros{6} + 23) as SharedTileID;
    ConfigureTile(0, 512, 4, 16, 4, 16, TileDataType_U64,
        TileLayout_RowMajor);
    for element = 0 to 63 do
        WriteTileElement(0, element DIVRM 16, element MOD 16,
            Zeros{PTO_XLEN} + 0x7700 + element);
    end;
    let old_published = AtomicUpdateSharedTileWithPublication(
        shared_id, _Tiles[[0]], '1111', TRUE);
    assert old_published && SharedTilePublished(shared_id);
    let prior_word = ReadSharedTileWord(shared_id,
        0 as PackedTileElementIndex);
    let first_base = Zeros{PTO_XLEN} + 0x400;
    let second_base = Zeros{PTO_XLEN} + 0x600;
    for column = 0 to 15 do
        WriteReadinessMemoryWord(first_base + column * 8,
            Zeros{PTO_XLEN} + 0xa000 + column);
        WriteReadinessMemoryWord(second_base + column * 8,
            Zeros{PTO_XLEN} + 0xb000 + column);
    end;
    let launch = LaunchKernelInvocation(0, Zeros{PTO_XLEN} + 0x100);
    assert launch == KernelLifecycle_Started;

    PrepareReadinessTLoadPE(0 as MemoryAgentId, first_base, 0);
    let first_parked_pc = ReadTPC();
    let first_stop = ExecuteCommandInstruction(Zeros{64}, 16);
    assert first_stop == CommandExecution_Executed &&
           _LastFault == Fault_None && _BundleActive &&
           ReadTPC() == first_parked_pc &&
           BundleSharedGenerationRequestWaiting(0) &&
           !_SharedGenerations[[SharedTileArrayIndex(shared_id)]].published;

    PrepareReadinessTLoadPE(1 as MemoryAgentId, second_base, 2);
    let second_parked_pc = ReadTPC();
    let second_stop = ExecuteCommandInstruction(Zeros{64}, 16);
    assert second_stop == CommandExecution_Executed &&
           _LastFault == Fault_None && _BundleActive &&
           ReadTPC() == second_parked_pc &&
           BundleSharedGenerationRequestWaiting(0);

    let generation = _SharedGenerations[[SharedTileArrayIndex(shared_id)]];
    assert generation.open && !generation.published &&
           generation.last_seen && generation.operation_ordinal == 1 &&
           generation.participant_mask == '1100' &&
           generation.arrived_participants == '1100' &&
           generation.released_participants == Zeros{4};
    for cell = 0 to generation.parent_cell_count - 1 do
        assert generation.covered_cells[cell] == '1';
        if cell < 4 || (cell >= 8 && cell < 12) then
            assert generation.ready_cells[cell] == '1';
        else
            assert generation.ready_cells[cell] == '0';
        end;
    end;
    for element = 0 to 15 do
        assert TileLogicalElementDefined(generation.working_tile,
                   element as PackedTileElementIndex) &&
               TileReadLogicalElement(generation.working_tile,
                   element as PackedTileElementIndex) ==
                   Zeros{PTO_XLEN} + 0xa000 + element;
        assert !TileLogicalElementDefined(generation.working_tile,
            (16 + element) as PackedTileElementIndex);
        assert TileLogicalElementDefined(generation.working_tile,
                   (32 + element) as PackedTileElementIndex) &&
               TileReadLogicalElement(generation.working_tile,
                   (32 + element) as PackedTileElementIndex) ==
                   Zeros{PTO_XLEN} + 0xb000 + element;
        assert !TileLogicalElementDefined(generation.working_tile,
            (48 + element) as PackedTileElementIndex);
    end;
    assert SharedTilePublished(shared_id) &&
           ReadSharedTileWord(shared_id,
               0 as PackedTileElementIndex) == prior_word;
    return 0;
end;
