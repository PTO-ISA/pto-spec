// PTO-TEST: {"id":"PTO-AVS-BLOCK-SHARED-TMOV-SINGLETON-ROW-TAIL-022","source":"asl/block/model/dispatch/shared-tlsu.asl","requirements":["PTO-TMOV-CONTRACT-001","PTO-B-ASSEMBLE-SHARED-GENERATION-001"],"kind":"state-transition","summary":"a singleton Shared TMOV keeps physical row tails outside the valid parent","pass_condition":"an encoded PE3-only full-parent B.ASSEMBLE TMOV places its 1x8 valid source rectangle in a 4x16 physical parent without expanding valid rows from the 512-byte writer extent","related_sources":["asl/block/model/operands/shared-generation-pe-requests.asl","asl/block/model/operands/shared-generation.asl"]}

pure func SingletonTMOVStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00011181;
    instruction[24:20] = '00010';
    instruction[31:27] = Zeros{5} + 24;
    return instruction;
end;

pure func SingletonTMOVShared(shared_id: bits(6)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001013;
    instruction[25:20] = shared_id;
    instruction[18:15] = '0011';
    instruction[11:9] = '100';
    return instruction;
end;

pure func SingletonTMOVAssemble() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001053;
    instruction[31] = '1';
    instruction[11] = '1';
    instruction[10:7] = '0011';
    return instruction;
end;

pure func SingletonTMOVTile() => bits(64)
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
    ConfigureTile(1, 512, 4, 16, 4, 16, TileDataType_U64,
        TileLayout_RowMajor);
    for row = 0 to 3 do
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
    ConfigureTile(0, 512, 4, 16, 1, 8, TileDataType_U64,
        TileLayout_RowMajor);
    for column = 0 to 7 do
        WriteTileElement(0, 0, column,
            Zeros{PTO_XLEN} + 0x9000 + column);
    end;
    let start = ExecuteCommandInstruction(SingletonTMOVStart(), 32);
    let shared = ExecuteCommandInstruction(
        SingletonTMOVShared(Zeros{6} + 24), 32);
    let assemble = ExecuteCommandInstruction(SingletonTMOVAssemble(), 32);
    let tile = ExecuteCommandInstruction(SingletonTMOVTile(), 32);
    assert start == CommandExecution_Executed &&
           shared == CommandExecution_Executed &&
           assemble == CommandExecution_Executed &&
           tile == CommandExecution_Executed &&
           _BundleSharedBindings[[0]].pe_mask == '0001' &&
           _CurrentMemoryAgent == 3;
    let old_ordinal = _SharedGenerations[[SharedTileArrayIndex(shared_id)]]
        .operation_ordinal;
    let stop = ExecuteCommandInstruction(Zeros{64}, 16);
    assert stop == CommandExecution_Executed && _LastFault == Fault_None &&
           !_BundleActive;
    let generation = _SharedGenerations[[SharedTileArrayIndex(shared_id)]];
    assert generation.published && !generation.open &&
           generation.operation_ordinal == old_ordinal + 1 &&
           generation.participant_mask == '0001' &&
           generation.arrived_participants == '0001' &&
           generation.released_participants == '0001' &&
           generation.working_tile.rows == 4 &&
           generation.working_tile.columns == 16 &&
           generation.working_tile.valid_rows == 1 &&
           generation.working_tile.valid_columns == 8;
    for column = 0 to 7 do
        let index = TileLogicalLinearIndex(generation.working_tile,
            0 as integer {0..65535}, column as integer {0..65535});
        assert TileLogicalElementDefined(generation.working_tile, index) &&
               TileReadLogicalElement(generation.working_tile, index) ==
                   Zeros{PTO_XLEN} + 0x9000 + column;
    end;
    for row = 0 to 3 do
        for column = 0 to 15 do
            if row != 0 || column >= 8 then
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
    return 0;
end;
