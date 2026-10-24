// PTO-TEST: {"id":"PTO-AVS-BLOCK-SHARED-TMOV-CUBE-TO-ND-TAIL-PUBLICATION-008","source":"asl/block/model/dispatch/shared-tmov-cube-to-nd.asl","requirements":["PTO-ARCH-PE-EXECUTION-CONTEXT-001","PTO-B-ASSEMBLE-SHARED-GENERATION-001","PTO-BSTART-TMOV-SHARED-001","PTO-TMOV-CUBE-TO-SHARED-ND-001"],"kind":"state-transition","summary":"M32 Shared CUBE-to-ND publishes a highest-address valid tail but waits on an internal undefined row tail","pass_condition":"Four actual PEs publish valid rows 0..119 when PE3 owns a 24-row valid tail in a 32-row writer; moving that same undefined tail to PE0 leaves rows 24..31 undefined inside the parent valid extent and parks the request while retaining the prior published Shared parent; nonzero undefined source padding is not published","related_sources":["asl/block/model/dispatch/shared-tlsu.asl","asl/block/model/operands/shared-generation.asl","asl/block/model/operands/shared-generation-pe-requests.asl","asl/tile/model/memory/shared-cube-to-nd.asl"]}

pure func TailNDGolden(pe: integer {0..3}, row: integer {0..31},
    column: integer {0..127}) => Word
begin
    return Zeros{PTO_XLEN} +
        (((31 + pe * 43 + row * 17 + column * 5 +
            ((row * column) MOD 89)) MOD 255) + 1);
end;

pure func TailNDStart() => bits(64)
begin
    return Zeros{64} + 0x38211181;
end;

pure func TailNDDATR() => bits(64)
begin
    return Zeros{64} + 0x01f01c23;
end;

pure func TailNDSharedBinding(shared_id: bits(6),
    parent_size: bits(4), pemode: bits(3)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001013;
    instruction[25:20] = shared_id;
    instruction[18:15] = parent_size;
    instruction[11:9] = pemode;
    return instruction;
end;

pure func TailNDAssemble(writer_size: bits(4)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001053;
    instruction[31] = '1';
    instruction[19:15] = Zeros{5} + 1;
    instruction[11] = '1';
    instruction[10:7] = writer_size;
    return instruction;
end;

pure func TailNDSrcBinding(pemode: bits(3)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[25:20] = Zeros{6};
    instruction[11:9] = pemode;
    instruction[19] = '1';
    return instruction;
end;

func ConfigureTailNDSource(pe: integer {0..3}, valid_rows: integer {24,32})
begin
    let configured = ConfigureCubeTileForMask(0, 4096, 32, 128,
        TileDataType_E4M3, TileLayout_CUBE_M32, '1111');
    assert configured;
    InstallRelativeTileFixture(0, 0);
    var tile = _Tiles[[0]];
    tile.valid_rows = valid_rows;
    tile.valid_columns = 128;
    for row = 0 to 31 looplimit 65536 do
        for column = 0 to 127 looplimit 65536 do
            let element = TileStorageIndex(tile,
                row as integer {0..65535}, column as integer {0..65535});
            if row < valid_rows then
                tile.payload[[element]] = TailNDGolden(pe,
                    row as integer {0..31}, column as integer {0..127});
                tile.defined_elements[element] = '1';
            else
                // Deliberately nonzero invalid physical padding. The converter
                // must not publish it or treat it as ready data.
                tile.payload[[element]] = Zeros{PTO_XLEN} + 0xA5;
                tile.defined_elements[element] = '0';
            end;
        end;
    end;
    tile.defined_valid_elements = valid_rows * 128;
    tile.contents_defined = TRUE;
    _Tiles[[0]] = tile;
    assert TileCubeDescriptorLegal(_Tiles[[0]]) &&
           TileLogicalElementDefined(_Tiles[[0]],
               TileLogicalLinearIndex(_Tiles[[0]], 0, 0));
    if valid_rows == 24 then
        assert _Tiles[[0]].payload[[TileStorageIndex(_Tiles[[0]], 24, 0)]] ==
                   Zeros{PTO_XLEN} + 0xA5 &&
               !TileLogicalElementDefined(_Tiles[[0]],
                   TileLogicalLinearIndex(_Tiles[[0]], 24, 0));
    end;
end;

func InstallTailPrior(shared_id: SharedTileID)
begin
    ConfigureTileForMask(10, 128, 1, 1, 1, 1, TileDataType_U8,
        TileLayout_RowMajor, '1111');
    WriteTileElement(10, 0, 0, Zeros{PTO_XLEN} + 0x5a);
    InstallSharedTile(shared_id, _Tiles[[10]], '1111');
    assert SharedTilePublished(shared_id) &&
           TileReadLogicalElement(SharedTileRecord(shared_id).tile, 0) ==
               Zeros{PTO_XLEN} + 0x5a;
end;

func SubmitTailNDPE(pe: integer {0..3}, valid_rows: integer {24,32},
    offset: integer {0..96}, shared_id: SharedTileID,
    pemode: bits(3))
begin
    let agent = pe as MemoryAgentId;
    SelectExecutionContext(0 as PTOModelCoreIdentity, agent);
    if ReadTPC() == Zeros{PTO_XLEN} then WriteTPC(Zeros{PTO_XLEN} + 0x100); end;
    ConfigureTailNDSource(pe, valid_rows);
    WriteGPR(1, Zeros{PTO_XLEN} + offset);
    let start_status = ExecuteCommandInstruction(TailNDStart(), 32);
    let datr_status = ExecuteCommandInstruction(TailNDDATR(), 32);
    let shared_status = ExecuteCommandInstruction(TailNDSharedBinding(
        shared_id as bits(6), Zeros{4} + 8, pemode), 32);
    let assemble_status = ExecuteCommandInstruction(TailNDAssemble(
        Zeros{4} + 6), 32);
    let source_status = ExecuteCommandInstruction(TailNDSrcBinding(pemode), 32);
    assert start_status == CommandExecution_Executed &&
           datr_status == CommandExecution_Executed &&
           shared_status == CommandExecution_Executed &&
           assemble_status == CommandExecution_Executed &&
           source_status == CommandExecution_Executed;
    let stopped = ExecuteCommandInstruction(Zeros{64}, 16);
    assert stopped == CommandExecution_Executed && _LastFault == Fault_None;
end;

func RunTerminalTailPublishes()
begin
    ResetProfileState();
    let shared_id = (Zeros{6} + 56) as SharedTileID;
    InstallTailPrior(shared_id);
    let launched = LaunchKernelInvocation(0 as PTOModelCoreIdentity,
        Zeros{PTO_XLEN});
    assert launched == KernelLifecycle_Started;
    StartMemoryEventCapture(0);
    for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        let valid_rows = if pe == PTO_MODEL_MEMORY_AGENTS - 1 then 24 else 32;
        SubmitTailNDPE(pe as integer {0..3}, valid_rows,
            pe * 32 as integer {0..96}, shared_id, '111');
        if pe < PTO_MODEL_MEMORY_AGENTS - 1 then
            assert SharedTilePublished(shared_id) &&
                   TileReadLogicalElement(SharedTileRecord(shared_id).tile, 0) ==
                       Zeros{PTO_XLEN} + 0x5a &&
                   BundleSharedGenerationOpen(shared_id);
        end;
    end;
    assert SharedTilePublished(shared_id) &&
           _MemoryEventCount == 0;
    let published = SharedTileRecord(shared_id).tile;
    assert published.layout == TileLayout_RowMajor &&
           published.data_type == TileDataType_E4M3 &&
           published.capacity_bytes == 16384 &&
           published.rows == 128 && published.columns == 128 &&
           published.valid_rows == 120 && published.valid_columns == 128;
    for row = 0 to 119 looplimit 65536 do
        let source_pe = (row DIVRM 32) as integer {0..3};
        let source_row = (row MOD 32) as integer {0..31};
        for column = 0 to 127 looplimit 65536 do
            let element = TileLogicalLinearIndex(published,
                row as integer {0..65535}, column as integer {0..65535});
            assert TileLogicalElementDefined(published, element) &&
                   TileReadLogicalElement(published, element) ==
                       TailNDGolden(source_pe, source_row,
                           column as integer {0..127});
        end;
    end;
    for column = 0 to 127 looplimit 65536 do
        assert !TileLogicalElementDefined(published,
            TileLogicalLinearIndex(published, 120, column));
    end;
    for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 2 do
        let agent = pe as MemoryAgentId;
        SelectExecutionContext(0 as PTOModelCoreIdentity, agent);
        let drain_status = ExecuteCommandInstruction(Zeros{64}, 16);
        assert drain_status == CommandExecution_Executed &&
               _LastFault == Fault_None && !_BundleActive &&
               !BundleSharedGenerationRequestWaiting(0);
    end;
    assert _SharedGenerations[[SharedTileArrayIndex(shared_id)]]
               .released_participants == '1111';
    StopMemoryEventCapture();
end;

func RunInternalTailWaitsAndPreservesPrior()
begin
    ResetProfileState();
    let shared_id = (Zeros{6} + 57) as SharedTileID;
    InstallTailPrior(shared_id);
    let launched = LaunchKernelInvocation(0 as PTOModelCoreIdentity,
        Zeros{PTO_XLEN});
    assert launched == KernelLifecycle_Started;
    StartMemoryEventCapture(0);
    for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        let valid_rows = if pe == 0 then 24 else 32;
        SubmitTailNDPE(pe as integer {0..3}, valid_rows,
            pe * 32 as integer {0..96}, shared_id, '111');
        assert SharedTilePublished(shared_id) &&
               TileReadLogicalElement(SharedTileRecord(shared_id).tile, 0) ==
                   Zeros{PTO_XLEN} + 0x5a &&
               BundleSharedGenerationOpen(shared_id);
    end;
    let generation = _SharedGenerations[[SharedTileArrayIndex(shared_id)]];
    assert !generation.closed && !generation.published &&
           generation.arrived_participants == '1111' &&
           generation.last_seen &&
           generation.working_tile.valid_rows == 128 &&
           BundleSharedGenerationRequestWaiting(0) &&
           _LastFault == Fault_None && _MemoryEventCount == 0;
    StopMemoryEventCapture();
end;

func main() => integer
begin
    RunTerminalTailPublishes();
    RunInternalTailWaitsAndPreservesPrior();
    return 0;
end;
