// PTO-TEST: {"id":"PTO-AVS-BLOCK-SHARED-TLOAD-ASSEMBLE-TAILS-021","source":"asl/block/model/dispatch/shared-tlsu.asl","requirements":["PTO-TLOAD-MEMORY-001","PTO-B-ASSEMBLE-SHARED-GENERATION-001","PTO-ARCH-PE-EXECUTION-CONTEXT-001"],"kind":"state-transition","summary":"four actual PE TLOAD ranges preserve valid rows across physical column tails","pass_condition":"four encoded PE-owned B.ASSEMBLE TLOAD requests read their actual GM row stripes and atomically publish all 16 valid coordinates of a 4x4 rectangle in a 4x16 physical shape; undefined physical tails remain undefined and each arrival contributes once","related_sources":["asl/tile/model/memory/shared-movement.asl","asl/block/model/operands/shared-generation-pe-requests.asl","asl/block/model/operands/shared-generation.asl"]}

pure func TailTLoadStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00011181;
    instruction[24:20] = '00000';
    instruction[31:27] = Zeros{5} + 24;
    return instruction;
end;

pure func TailTLoadBinding(shared_id: bits(6)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001013;
    instruction[25:20] = shared_id;
    instruction[18:15] = '0011';
    instruction[11:9] = '111';
    return instruction;
end;

pure func TailTLoadAssemble(offset: integer) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001053;
    instruction[31] = '1';
    instruction[30:20] = Zeros{11} + offset;
    instruction[11] = '1';
    instruction[10:7] = '0001';
    return instruction;
end;

pure func TailTLoadIOR() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000013;
    instruction[19:15] = Zeros{5} + 2;
    instruction[24:20] = Zeros{5} + 3;
    return instruction;
end;

func WriteTailTLoadWord(address: Word, value: Word)
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

func main() => integer
begin
    ResetProfileState();
    let shared_id = (Zeros{6} + 23) as SharedTileID;
    ConfigureTile(0, 512, 4, 16, 4, 8, TileDataType_U64,
        TileLayout_RowMajor);
    for row = 0 to 3 do
        for column = 0 to 7 do
            WriteTileElement(0, row, column,
                Zeros{PTO_XLEN} + 0x7700 + row * 0x100 + column);
        end;
    end;
    let installed = AtomicUpdateSharedTileWithPublication(
        shared_id, _Tiles[[0]], '1111', TRUE);
    assert installed;
    let old_word = ReadSharedTileWord(shared_id,
        0 as PackedTileElementIndex);
    let base = Zeros{PTO_XLEN} + 0x800;
    for row = 0 to 3 do
        for column = 0 to 7 do
            WriteTailTLoadWord(base + row * 128 + column * 8,
                Zeros{PTO_XLEN} + 0xa000 + row * 0x100 + column);
        end;
    end;
    let launch = LaunchKernelInvocation(0 as PTOModelCoreIdentity,
        Zeros{PTO_XLEN} + 0x100);
    assert launch == KernelLifecycle_Started;
    StartMemoryEventCapture(0 as MemoryAgentId);
    let event_start = _MemoryEventCount;
    var parked_pc: array [[PTO_MODEL_MEMORY_AGENTS]] of Word;
    for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        SelectExecutionContext(0 as PTOModelCoreIdentity,
            pe as MemoryAgentId);
        // Each PE owns one physical row-sized 128-byte source stripe.
        WriteGPR(2, base + pe * 128);
        WriteGPR(3, Zeros{PTO_XLEN});
        let start = ExecuteCommandInstruction(TailTLoadStart(), 32);
        SetBundleDimension(0, Zeros{PTO_XLEN} + 4);
        SetBundleDimension(1, Zeros{PTO_XLEN} + 4);
        SetBundleDimension(2, Zeros{PTO_XLEN} + 16);
        let binding = ExecuteCommandInstruction(
            TailTLoadBinding(Zeros{6} + 23), 32);
        let assemble = ExecuteCommandInstruction(
            TailTLoadAssemble(pe), 32);
        let ior = ExecuteCommandInstruction(TailTLoadIOR(), 32);
        let expected_agent = pe as MemoryAgentId;
        assert start == CommandExecution_Executed &&
               binding == CommandExecution_Executed &&
               assemble == CommandExecution_Executed &&
               ior == CommandExecution_Executed &&
               _BundleSharedBindings[[0]].pe_mask == '1111' &&
               _CurrentMemoryAgent == expected_agent;
        parked_pc[[pe]] = ReadTPC();
        let stop = ExecuteCommandInstruction(Zeros{64}, 16);
        assert stop == CommandExecution_Executed &&
               _LastFault == Fault_None;
        if pe < PTO_MODEL_MEMORY_AGENTS - 1 then
            assert _BundleActive && ReadTPC() == parked_pc[[pe]] &&
                   BundleSharedGenerationRequestWaiting(0) &&
                   !_SharedGenerations[[SharedTileArrayIndex(shared_id)]]
                       .published &&
                   ReadSharedTileWord(shared_id,
                       0 as PackedTileElementIndex) == old_word;
        end;
    end;

    let index = SharedTileArrayIndex(shared_id);
    let generation = _SharedGenerations[[index]];
    assert generation.published && !generation.open;
    assert generation.participant_mask == '1111';
    assert generation.arrived_participants == '1111';
    assert generation.released_participants ==
           SharedGenerationPEBit(3 as MemoryAgentId);
    assert generation.operation_ordinal == 1;
    assert _MemoryEventCount == event_start + 16;
    StopMemoryEventCapture();
    for cell = 0 to generation.parent_cell_count - 1 do
        assert generation.covered_cells[cell] == '1' &&
               generation.ready_cells[cell] == '1';
    end;
    for row = 0 to 3 do
        for column = 0 to 3 do
            let element = TileLogicalLinearIndex(generation.working_tile,
                row as integer {0..65535}, column as integer {0..65535});
            assert TileLogicalElementDefined(generation.working_tile,
                       element) &&
                   TileReadLogicalElement(generation.working_tile, element) ==
                       Zeros{PTO_XLEN} + 0xa000 + row * 0x100 + column;
        end;
        for column = 4 to 15 do
            let element = TileLogicalLinearIndex(generation.working_tile,
                row as integer {0..65535}, column as integer {0..65535});
            assert !TileLogicalElementDefined(generation.working_tile,
                element);
        end;
    end;
    assert SharedTilePublished(shared_id) &&
           ReadSharedTileWord(shared_id,
               0 as PackedTileElementIndex) != old_word;

    for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 2 do
        SelectExecutionContext(0 as PTOModelCoreIdentity,
            pe as MemoryAgentId);
        assert _BundleActive && ReadTPC() == parked_pc[[pe]] &&
               BundleSharedGenerationRequestWaiting(0);
        let release = ExecuteCommandInstruction(Zeros{64}, 16);
        assert release == CommandExecution_Executed &&
               _LastFault == Fault_None && !_BundleActive;
    end;
    assert _SharedGenerations[[index]].released_participants == '1111';
    return 0;
end;
