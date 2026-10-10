// PTO-TEST: {"id":"PTO-AVS-BLOCK-SHARED-TLOAD-PARTIAL-VALID-ROW-022","source":"asl/block/model/dispatch/shared-tlsu.asl","requirements":["PTO-TLOAD-MEMORY-001","PTO-B-ASSEMBLE-SHARED-GENERATION-001"],"kind":"state-transition","summary":"full-mask TLOAD participants without valid source stripes do not expand the parent rectangle","pass_condition":"four encoded full-mask PE arrivals assemble a one-row, four-element valid parent from PE0's actual GM reads; PEs with no valid source elements still arrive without fabricated data, and physical row and column tails remain undefined","related_sources":["asl/tile/model/memory/shared-movement.asl","asl/block/model/operands/shared-generation-pe-requests.asl","asl/block/model/operands/shared-generation.asl"]}

pure func PartialRowTLoadStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00011181;
    instruction[24:20] = '00000';
    instruction[31:27] = Zeros{5} + 24;
    return instruction;
end;

pure func PartialRowTLoadBinding(shared_id: bits(6)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001013;
    instruction[25:20] = shared_id;
    instruction[18:15] = '0011';
    instruction[11:9] = '111';
    return instruction;
end;

pure func PartialRowTLoadAssemble(offset: integer) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001053;
    instruction[31] = '1';
    instruction[30:20] = Zeros{11} + offset;
    instruction[11] = '1';
    instruction[10:7] = '0001';
    return instruction;
end;

pure func PartialRowTLoadIOR() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000013;
    instruction[19:15] = Zeros{5} + 2;
    instruction[24:20] = Zeros{5} + 3;
    return instruction;
end;

func WritePartialRowMemoryWord(address: Word, value: Word)
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
    let shared_id = (Zeros{6} + 25) as SharedTileID;
    ConfigureTile(0, 512, 4, 16, 4, 16, TileDataType_U64,
        TileLayout_RowMajor);
    for row = 0 to 3 do
        for column = 0 to 15 do
            WriteTileElement(0, row, column,
                Zeros{PTO_XLEN} + 0x7700 + row * 0x100 + column);
        end;
    end;
    InstallSharedTile(shared_id, _Tiles[[0]], '1111');
    let old_word = ReadSharedTileWord(shared_id,
        0 as PackedTileElementIndex);
    let base = Zeros{PTO_XLEN} + 0xa00;
    for column = 0 to 3 do
        WritePartialRowMemoryWord(base + column * 8,
            Zeros{PTO_XLEN} + 0xb000 + column);
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
        WriteGPR(2, base);
        WriteGPR(3, Zeros{PTO_XLEN});
        let start = ExecuteCommandInstruction(PartialRowTLoadStart(), 32);
        SetBundleDimension(0, Zeros{PTO_XLEN} + 4);
        SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
        SetBundleDimension(2, Zeros{PTO_XLEN} + 16);
        let binding = ExecuteCommandInstruction(
            PartialRowTLoadBinding(Zeros{6} + 25), 32);
        let assemble = ExecuteCommandInstruction(
            PartialRowTLoadAssemble(pe), 32);
        let ior = ExecuteCommandInstruction(PartialRowTLoadIOR(), 32);
        assert start == CommandExecution_Executed &&
               binding == CommandExecution_Executed &&
               assemble == CommandExecution_Executed &&
               ior == CommandExecution_Executed &&
               _BundleSharedBindings[[0]].pe_mask == '1111' &&
               _CurrentMemoryAgent == (pe as MemoryAgentId);
        parked_pc[[pe]] = ReadTPC();
        let stop = ExecuteCommandInstruction(Zeros{64}, 16);
        assert stop == CommandExecution_Executed && _LastFault == Fault_None;
        if pe < PTO_MODEL_MEMORY_AGENTS - 1 then
            assert _BundleActive && ReadTPC() == parked_pc[[pe]] &&
                   BundleSharedGenerationRequestWaiting(0) &&
                   !_SharedGenerations[[SharedTileArrayIndex(shared_id)]]
                       .published &&
                   ReadSharedTileWord(shared_id,
                       0 as PackedTileElementIndex) == old_word;
        end;
    end;
    StopMemoryEventCapture();
    let generation = _SharedGenerations[[SharedTileArrayIndex(shared_id)]];
    assert generation.published && !generation.open;
    assert generation.arrived_participants == '1111';
    assert generation.released_participants ==
           SharedGenerationPEBit(3 as MemoryAgentId);
    assert generation.working_tile.rows == 4;
    assert generation.working_tile.columns == 16;
    assert generation.working_tile.valid_rows == 1;
    assert generation.working_tile.valid_columns == 4;
    assert _MemoryEventCount == event_start + 4;
    for column = 0 to 3 do
        let index = TileLogicalLinearIndex(generation.working_tile,
            0 as integer {0..65535}, column as integer {0..65535});
        assert TileLogicalElementDefined(generation.working_tile, index) &&
               TileReadLogicalElement(generation.working_tile, index) ==
                   Zeros{PTO_XLEN} + 0xb000 + column;
    end;
    for row = 0 to 3 do
        for column = 0 to 15 do
            if row != 0 || column >= 4 then
                let index = TileLogicalLinearIndex(generation.working_tile,
                    row as integer {0..65535},
                    column as integer {0..65535});
                assert !TileLogicalElementDefined(generation.working_tile,
                    index);
            end;
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
    assert _SharedGenerations[[SharedTileArrayIndex(shared_id)]]
        .released_participants == '1111';
    return 0;
end;
