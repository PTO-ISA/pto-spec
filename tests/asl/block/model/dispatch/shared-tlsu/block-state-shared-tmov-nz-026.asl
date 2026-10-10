// PTO-TEST: {"id":"PTO-AVS-BLOCK-SHARED-TMOV-NZ-026","source":"asl/block/model/dispatch/shared-tlsu.asl","requirements":["PTO-TMOV-CONTRACT-001","PTO-B-ASSEMBLE-SHARED-GENERATION-001"],"kind":"state-transition","summary":"NZ singleton Shared TMOV preserves its logical source rectangle.","pass_condition":"An encoded PE3-only full-parent B.ASSEMBLE TMOV preserves physical layout/shape and the exact declared valid rectangle, copies every defined source coordinate once, publishes and releases once without fault, and does not treat physical padding or storage-index maxima as logical rows.","related_sources":["asl/block/model/state/shared-generation-state.asl","asl/block/model/operands/shared-generation.asl","asl/block/model/operands/shared-generation-pe-requests.asl","asl/tile/model/definedness/elements.asl","asl/tile/model/definedness/packed-boundary.asl"]}
pure func LayoutTMOVStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00011181;
    instruction[24:20] = '00010';
    instruction[31:27] = Zeros{5} + 24;
    return instruction;
end;

pure func LayoutTMOVShared(shared_id: bits(6), size_code: bits(4)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001013;
    instruction[25:20] = shared_id;
    instruction[18:15] = size_code;
    instruction[11:9] = '100';
    return instruction;
end;

pure func LayoutTMOVAssemble(size_code: bits(4)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001053;
    instruction[31] = '1';
    instruction[11] = '1';
    instruction[10:7] = size_code;
    return instruction;
end;

pure func LayoutTMOVTile() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[25:20] = Zeros{6};
    instruction[11:9] = '100';
    instruction[19] = '1';
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    let shared_id = (Zeros{6} + 24) as SharedTileID;
    ConfigureTile(1, 2048, 16, 16, 16, 16,
        TileDataType_U64, TileLayout_NZ);
    for row = 0 to 15 do
        for column = 0 to 15 do
            WriteTileElement(1, row, column,
                Zeros{PTO_XLEN} + 0x7000 + row * 0x100 + column);
        end;
    end;
    InstallSharedTile(shared_id, _Tiles[[1]], '1111');
    let prior_word = ReadSharedTileWord(shared_id,
        0 as PackedTileElementIndex);
    let launch = LaunchKernelInvocation(0 as PTOModelCoreIdentity,
        Zeros{PTO_XLEN} + 0x100);
    assert launch == KernelLifecycle_Started;
    SelectExecutionContext(0 as PTOModelCoreIdentity,
        3 as MemoryAgentId);
    ConfigureTile(0, 2048, 16, 16, 1, 8,
        TileDataType_U64, TileLayout_NZ);
    for row = 0 to 0 do
        for column = 0 to 7 do
            WriteTileElement(0, row, column,
                Zeros{PTO_XLEN} + 0x9000 + row * 0x100 + column);
        end;
    end;
    let start = ExecuteCommandInstruction(LayoutTMOVStart(), 32);
    let shared = ExecuteCommandInstruction(
        LayoutTMOVShared(Zeros{6} + 24, Zeros{4} + 5), 32);
    let assemble = ExecuteCommandInstruction(LayoutTMOVAssemble(Zeros{4} + 5), 32);
    let tile = ExecuteCommandInstruction(LayoutTMOVTile(), 32);
    assert start == CommandExecution_Executed &&
           shared == CommandExecution_Executed &&
           assemble == CommandExecution_Executed &&
           tile == CommandExecution_Executed &&
           _BundleSharedBindings[[0]].pe_mask == '0001' &&
           _CurrentMemoryAgent == 3;
    let event_count = _MemoryEventCount;
    let old_ordinal = _SharedGenerations[[SharedTileArrayIndex(shared_id)]]
        .operation_ordinal;
    let stop = ExecuteCommandInstruction(Zeros{64}, 16);
    assert stop == CommandExecution_Executed && _LastFault == Fault_None &&
           !_BundleActive && _MemoryEventCount == event_count;
    let generation = _SharedGenerations[[SharedTileArrayIndex(shared_id)]];
    assert generation.published && !generation.open &&
           generation.operation_ordinal == old_ordinal + 1 &&
           generation.participant_mask == '0001' &&
           generation.arrived_participants == '0001' &&
           generation.released_participants == '0001' &&
           generation.working_tile.rows == 16 &&
           generation.working_tile.columns == 16 &&
           generation.working_tile.valid_rows == 1 &&
           generation.working_tile.valid_columns == 8 &&
           generation.working_tile.layout == TileLayout_NZ;
    for row = 0 to 0 do
        for column = 0 to 7 do
            let index = TileLogicalLinearIndex(generation.working_tile,
                row as integer {0..65535},
                column as integer {0..65535});
            assert TileLogicalElementDefined(generation.working_tile, index) &&
                   TileReadLogicalElement(generation.working_tile, index) ==
                       Zeros{PTO_XLEN} + 0x9000 + row * 0x100 + column;
        end;
    end;
    for row = 0 to 15 do
        for column = 0 to 15 do
            if row >= 1 || column >= 8 then
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
               0 as PackedTileElementIndex) != prior_word;
    let released_ordinal = generation.operation_ordinal;
    assert _SharedGenerations[[SharedTileArrayIndex(shared_id)]]
        .released_participants == '0001' &&
        _SharedGenerations[[SharedTileArrayIndex(shared_id)]]
            .operation_ordinal == released_ordinal;
    return 0;
end;
