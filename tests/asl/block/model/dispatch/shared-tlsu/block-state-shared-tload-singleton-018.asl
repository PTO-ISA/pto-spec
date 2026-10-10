// PTO-TEST: {"id":"PTO-AVS-BLOCK-SHARED-TLOAD-SINGLETON-018","source":"asl/block/model/dispatch/shared-tlsu.asl","requirements":["PTO-TLOAD-MEMORY-001","PTO-B-ASSEMBLE-SHARED-GENERATION-001"],"kind":"state-transition","summary":"a singleton Shared TLOAD preserves a one-row valid rectangle in a larger physical parent","pass_condition":"an encoded PE3-only full-parent B.ASSEMBLE TLOAD reads and publishes the 1x8 valid rectangle in a 4x16 physical shape; undefined row and column tails remain undefined and only eight valid elements are read","related_sources":["asl/tile/model/memory/shared-movement.asl","asl/block/model/operands/shared-generation-pe-requests.asl","asl/block/model/operands/shared-generation.asl"]}

pure func FragmentTLoadStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00011181;
    instruction[24:20] = '00000';
    instruction[31:27] = Zeros{5} + 24;
    return instruction;
end;

pure func FragmentTLoadBinding(shared_id: bits(6)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001013;
    instruction[25:20] = shared_id;
    instruction[18:15] = '0011';
    instruction[11:9] = '100';
    return instruction;
end;

pure func FragmentTLoadAssembleFullParent() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001053;
    instruction[31] = '1';
    instruction[11] = '1';
    instruction[10:7] = '0011';
    return instruction;
end;

pure func FragmentTLoadIOR() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000013;
    instruction[19:15] = Zeros{5} + 2;
    instruction[24:20] = Zeros{5} + 3;
    return instruction;
end;

func WriteFragmentMemoryWord(address: Word, value: Word)
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
    let shared_id = (Zeros{6} + 21) as SharedTileID;
    ConfigureTile(0, 512, 4, 16, 4, 16, TileDataType_U64,
        TileLayout_RowMajor);
    for element = 0 to 63 do
        let row = element DIVRM 16;
        let column = element MOD 16;
        WriteTileElement(0, row, column,
            Zeros{PTO_XLEN} + 0x7700 + element);
    end;
    InstallSharedTile(shared_id, _Tiles[[0]], '0001');
    let prior_word = ReadSharedTileWord(shared_id,
        0 as PackedTileElementIndex);
    let base = Zeros{PTO_XLEN} + 0x400;
    for row = 0 to 3 do
        for column = 0 to 7 do
            WriteFragmentMemoryWord(base + row * 128 + column * 8,
                Zeros{PTO_XLEN} + 0x9000 + row * 0x100 + column);
        end;
    end;

    let launch = LaunchKernelInvocation(0, Zeros{PTO_XLEN} + 0x100);
    assert launch == KernelLifecycle_Started;
    SelectExecutionContext(0, 3);
    WriteGPR(2, base);
    WriteGPR(3, Zeros{PTO_XLEN} + 128);
    let start = ExecuteCommandInstruction(FragmentTLoadStart(), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 8);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 16);
    let binding = ExecuteCommandInstruction(
        FragmentTLoadBinding(Zeros{6} + 21), 32);
    let assemble = ExecuteCommandInstruction(
        FragmentTLoadAssembleFullParent(), 32);
    let ior = ExecuteCommandInstruction(FragmentTLoadIOR(), 32);
    assert start == CommandExecution_Executed &&
           binding == CommandExecution_Executed &&
           assemble == CommandExecution_Executed &&
           ior == CommandExecution_Executed &&
           _BundleSharedBindings[[0]].pe_mask == '0001' &&
           _CurrentMemoryAgent == 3;
    let parked_pc = ReadTPC();
    StartMemoryEventCapture(3 as MemoryAgentId);
    let event_start = _MemoryEventCount;
    let stop = ExecuteCommandInstruction(Zeros{64}, 16);
    assert stop == CommandExecution_Executed && _LastFault == Fault_None &&
           !_BundleActive && ReadTPC() != parked_pc;
    assert _MemoryEventCount == event_start + 8;
    StopMemoryEventCapture();

    let index = SharedTileArrayIndex(shared_id);
    let generation = _SharedGenerations[[index]];
    assert !generation.open && generation.published &&
           generation.operation_ordinal == 1 &&
           generation.participant_mask == '0001' &&
           generation.arrived_participants ==
               SharedGenerationPEBit(3 as MemoryAgentId) &&
           generation.released_participants ==
               SharedGenerationPEBit(3 as MemoryAgentId);
    for cell = 0 to generation.parent_cell_count - 1 do
        assert generation.covered_cells[cell] == '1';
        assert generation.ready_cells[cell] == '1';
    end;
    assert generation.working_tile.rows == 4 &&
           generation.working_tile.valid_rows == 1 &&
           generation.working_tile.valid_columns == 8;
    for column = 0 to 7 do
            let element = TileLogicalLinearIndex(generation.working_tile,
                0 as integer {0..65535}, column as integer {0..65535});
            assert TileLogicalElementDefined(generation.working_tile,
                       element) &&
                   TileReadLogicalElement(generation.working_tile, element) ==
                       Zeros{PTO_XLEN} + 0x9000 + column;
    end;
    for row = 0 to 3 do
        for column = 0 to 15 do
            if row != 0 || column >= 8 then
            let element = TileLogicalLinearIndex(generation.working_tile,
                row as integer {0..65535}, column as integer {0..65535});
            assert !TileLogicalElementDefined(generation.working_tile,
                element);
            end;
        end;
    end;
    assert SharedTilePublished(shared_id) &&
           ReadSharedTileWord(shared_id,
               0 as PackedTileElementIndex) != prior_word &&
           ReadSharedTileWord(shared_id,
               0 as PackedTileElementIndex) ==
                   Zeros{PTO_XLEN} + 0x9000;
    return 0;
end;
