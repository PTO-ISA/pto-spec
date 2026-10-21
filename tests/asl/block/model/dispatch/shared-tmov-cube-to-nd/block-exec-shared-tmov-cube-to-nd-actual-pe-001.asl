// PTO-TEST: {"id":"PTO-AVS-BLOCK-SHARED-TMOV-CUBE-TO-ND-ACTUAL-PE-001","source":"asl/block/model/dispatch/shared-tmov-cube-to-nd.asl","requirements":["PTO-ARCH-PE-EXECUTION-CONTEXT-001","PTO-B-ASSEMBLE-SHARED-GENERATION-001","PTO-BSTART-TMOV-SHARED-001","PTO-TMOV-CUBE-TO-SHARED-ND-001"],"kind":"execution","summary":"four actual PEs atomically publish nonzero CUBE_M32/M16 raw payloads as Shared ND","pass_condition":"M32 and M16 E4M3 sources use exact per-writer CUBE capacities, identical encoded BSTART/DATR/B.IOS/B.ASSEMBLE/B.IOT streams, independent explicit GPR offsets, and publish exact RowMajor parent goldens without GM events; parked actual PE requests consume completion once","related_sources":["asl/block/model/dispatch/shared-tlsu.asl","asl/block/model/operands/shared-generation.asl","asl/block/model/operands/shared-generation-pe-requests.asl","asl/tile/model/memory/shared-cube-to-nd.asl"]}
pure func CubeToSharedNDGolden(pe: integer {0..3}, row: integer {0..31},
    column: integer {0..127}) => Word
begin
    return Zeros{PTO_XLEN} +
        (((17 + pe * 47 + row * 13 + column * 3 +
            ((row * column) MOD 101)) MOD 255) + 1);
end;

pure func CubeToSharedNDSharedBinding(shared_id: bits(6),
    parent_size: bits(4)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001013;
    instruction[25:20] = shared_id;
    instruction[18:15] = parent_size;
    instruction[11:9] = '111';
    return instruction;
end;

pure func CubeToSharedNDAssemble(writer_size: bits(4)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001053;
    instruction[31] = '1';
    instruction[19:15] = Zeros{5} + 1;
    instruction[11] = '1';
    instruction[10:7] = writer_size;
    return instruction;
end;

pure func CubeToSharedNDTileBinding() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[25:20] = Zeros{6};
    instruction[11:9] = '111';
    instruction[19] = '1';
    return instruction;
end;

pure func CubeToSharedNDLastUseTileBinding() => bits(64)
begin
    var instruction = CubeToSharedNDTileBinding();
    instruction[26] = '1';
    return instruction;
end;

func ConfigureCubeToSharedNDSource(pe: integer {0..3},
    capacity_bytes: integer {128..262144}, rows: integer {16,32},
    columns: integer {1..65535}, layout: TileLayout)
begin
    let configured = ConfigureCubeTileForMask(0, capacity_bytes, rows,
        columns, TileDataType_E4M3, layout, '1111');
    assert configured;
    InstallRelativeTileFixture(0, 0);
    var tile = _Tiles[[0]];
    for row = 0 to rows - 1 looplimit 65536 do
        for column = 0 to columns - 1 looplimit 65536 do
            let element = TileStorageIndex(tile,
                row as integer {0..65535}, column as integer {0..65535});
            tile.payload[[element]] = CubeToSharedNDGolden(pe,
                row as integer {0..31}, column as integer {0..127});
            tile.defined_elements[element] = '1';
        end;
    end;
    tile.defined_valid_elements = (rows * columns)
        as integer {0..524288};
    tile.contents_defined = TRUE;
    _Tiles[[0]] = tile;
end;

func RunActualCubeToSharedND(layout: TileLayout,
    source_rows: integer {16,32}, writer_size: integer {5,6},
    parent_size: integer {7,8}, offset_stride: integer {16,32},
    datr_word: bits(32), shared_id: SharedTileID,
    source_last_use: boolean)
begin
    let source_capacity = TileSizeCodeBytes(writer_size);
    let source_columns = 128;
    let parent_rows = TileSizeCodeBytes(parent_size) DIVRM source_columns;
    let launched = LaunchKernelInvocation(0 as PTOModelCoreIdentity,
        Zeros{PTO_XLEN});
    assert launched == KernelLifecycle_Started;
    var parked_tpcs: array [[PTO_MODEL_MEMORY_AGENTS]] of Word;
    StartMemoryEventCapture(0);
    for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        let agent = pe as MemoryAgentId;
        let pe_index = pe as integer {0..3};
        SelectExecutionContext(0 as PTOModelCoreIdentity, agent);
        if ReadTPC() == Zeros{PTO_XLEN} then
            WriteTPC(Zeros{PTO_XLEN} + 0x100);
        end;
        ConfigureCubeToSharedNDSource(pe, source_capacity, source_rows,
            source_columns, layout);
        WriteGPR(1, Zeros{PTO_XLEN} + pe * offset_stride);
        let start_status = ExecuteCommandInstruction(
            Zeros{64} + 0x38211181, 32);
        assert start_status == CommandExecution_Executed;
        let datr_status = ExecuteCommandInstruction(
            Zeros{PTO_XLEN} + UInt(datr_word), 32);
        assert datr_status == CommandExecution_Executed;
        let shared_status = ExecuteCommandInstruction(
            CubeToSharedNDSharedBinding(shared_id as bits(6),
                (Zeros{4} + parent_size) as bits(4)), 32);
        assert shared_status == CommandExecution_Executed;
        let assemble_status = ExecuteCommandInstruction(
            CubeToSharedNDAssemble((Zeros{4} + writer_size) as bits(4)), 32);
        assert assemble_status == CommandExecution_Executed;
        let binding_status = ExecuteCommandInstruction(
            if source_last_use then CubeToSharedNDLastUseTileBinding()
            else CubeToSharedNDTileBinding(), 32);
        assert binding_status == CommandExecution_Executed;
        parked_tpcs[[agent]] = ReadTPC();
        let stopped = ExecuteCommandInstruction(Zeros{64}, 16);
        assert stopped == CommandExecution_Executed && _LastFault == Fault_None;
        let source_pe_bit = SharedGenerationPEBit(agent);
        if source_last_use && pe < PTO_MODEL_MEMORY_AGENTS - 1 then
            assert TilePayloadIntactForMask(0, source_pe_bit);
        elsif source_last_use then
            assert !TilePayloadIntactForMask(0, source_pe_bit);
        else
            assert TilePayloadIntactForMask(0, source_pe_bit);
        end;
        if pe < PTO_MODEL_MEMORY_AGENTS - 1 then
            let generation_index = SharedTileArrayIndex(shared_id);
            let ordinal_before_replay =
                _SharedGenerations[[generation_index]].operation_ordinal;
            let arrived_before_replay =
                _SharedGenerations[[generation_index]].arrived_participants;
            let covered_before_replay =
                _SharedGenerations[[generation_index]].covered_cells;
            let ready_before_replay =
                _SharedGenerations[[generation_index]].ready_cells;
            let token_before_replay =
                _SharedGenerations[[generation_index]].arrival_request_tokens[[pe_index]];
            let replay_status = ExecuteCommandInstruction(Zeros{64}, 16);
            assert replay_status == CommandExecution_Executed &&
                   _LastFault == Fault_None &&
                   _SharedGenerations[[generation_index]].operation_ordinal ==
                       ordinal_before_replay &&
                   _SharedGenerations[[generation_index]].arrived_participants ==
                       arrived_before_replay &&
                   _SharedGenerations[[generation_index]].covered_cells ==
                       covered_before_replay &&
                   _SharedGenerations[[generation_index]].ready_cells ==
                       ready_before_replay &&
                   _SharedGenerations[[generation_index]].arrival_request_tokens[[pe_index]] ==
                       token_before_replay;
            assert !SharedTilePublished(shared_id) &&
                   BundleSharedGenerationOpen(shared_id) &&
                   ReadTPC() == parked_tpcs[[agent]] &&
                   BundleSharedGenerationRequestWaiting(0);
        end;
    end;
    StopMemoryEventCapture();
    assert _MemoryEventCount == 0 && SharedTilePublished(shared_id);
    let published = SharedTileRecord(shared_id);
    assert published.tile.layout == TileLayout_RowMajor &&
           published.tile.data_type == TileDataType_E4M3 &&
           published.tile.capacity_bytes == TileSizeCodeBytes(parent_size) &&
           published.tile.rows == parent_rows &&
           published.tile.columns == source_columns &&
           published.tile.valid_rows == parent_rows &&
           published.tile.valid_columns == source_columns;
    for row = 0 to parent_rows - 1 looplimit 65536 do
        let source_pe = (row DIVRM source_rows) as integer {0..3};
        let source_row = (row MOD source_rows) as integer {0..31};
        for column = 0 to source_columns - 1 looplimit 65536 do
            let element = TileLogicalLinearIndex(published.tile,
                row as integer {0..65535}, column as integer {0..65535});
            assert TileLogicalElementDefined(published.tile, element) &&
                TileReadLogicalElement(published.tile, element) ==
                    CubeToSharedNDGolden(source_pe, source_row, column);
        end;
    end;
    for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 2 do
        let agent = pe as MemoryAgentId;
        let pe_index = pe as integer {0..3};
        SelectExecutionContext(0 as PTOModelCoreIdentity, agent);
        assert ReadTPC() == parked_tpcs[[agent]] && _BundleActive &&
               BundleSharedGenerationRequestWaiting(0);
        let generation_index = SharedTileArrayIndex(shared_id);
        let ordinal_before_release =
            _SharedGenerations[[generation_index]].operation_ordinal;
        let arrived_before_release =
            _SharedGenerations[[generation_index]].arrived_participants;
        let covered_before_release =
            _SharedGenerations[[generation_index]].covered_cells;
        let ready_before_release =
            _SharedGenerations[[generation_index]].ready_cells;
        let token_before_release =
            _SharedGenerations[[generation_index]].arrival_request_tokens[[pe_index]];
        let drain_status = ExecuteCommandInstruction(Zeros{64}, 16);
        assert drain_status == CommandExecution_Executed;
        assert _LastFault == Fault_None && !_BundleActive &&
               !BundleSharedGenerationRequestWaiting(0);
        assert _SharedGenerations[[generation_index]].operation_ordinal ==
                   ordinal_before_release &&
               _SharedGenerations[[generation_index]].arrived_participants ==
                   arrived_before_release &&
               _SharedGenerations[[generation_index]].covered_cells ==
                   covered_before_release &&
               _SharedGenerations[[generation_index]].ready_cells ==
                   ready_before_release &&
               _SharedGenerations[[generation_index]].arrival_request_tokens[[pe_index]] ==
                   token_before_release;
        if source_last_use then
            assert !TilePayloadIntactForMask(0, SharedGenerationPEBit(agent));
        end;
    end;
    assert _MemoryEventCount == 0;
end;

func main() => integer
begin
    ResetProfileState();
    RunActualCubeToSharedND(TileLayout_CUBE_M32, 32, 6, 8, 32,
        Zeros{32} + 0x01f01c23, (Zeros{6} + 19) as SharedTileID, FALSE);
    ResetProfileState();
    RunActualCubeToSharedND(TileLayout_CUBE_M16, 16, 5, 7, 16,
        Zeros{32} + 0x01f01ca3, (Zeros{6} + 20) as SharedTileID, TRUE);
    return 0;
end;
