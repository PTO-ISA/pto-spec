// PTO-TEST: {"id":"PTO-AVS-BLOCK-TLOAD-WEIGHT-COOPERATIVE-001","source":"asl/block/model/dispatch/weight-to-shared-execution.asl","requirements":["PTO-BSTART-TLOAD-WEIGHT-COOPERATIVE-001","PTO-BSTART-TLOAD-WEIGHT-NK-CONTRACT-001","PTO-BSTART-TLOAD-WEIGHT-SOURCE-001"],"kind":"state-transition","summary":"Four participating PEs publish one complete Shared NK generation through ordinary B.ASSEMBLE phases.","pass_condition":"Mask 1111 assigns complete contiguous N-row spans whose encoded writer SizeCodes match exactly, preflights the complete selected-PE GM footprint before the first load, preserves the prior publication while a generation is open, aborts that generation on participant-value mismatch, then cleanly reissues and atomically publishes the gap-free row-major NK tile at LAST.","related_sources":["asl/block/model/dispatch/weight-to-shared-schema.asl","asl/block/model/operands/shared-generation.asl"]}
func WeightCoopStart() => bits(64)
begin
    var instruction = Zeros{64} + 0x00011181;
    instruction[31:27] = Zeros{5} + 4;
    return instruction;
end;

func WeightCoopAttributes() => bits(64)
begin
    var instruction = Zeros{64} + 0x00001023;
    instruction[24:20] = DTYPE_NONE;
    instruction[11:7] = Zeros{5} + 10;
    return instruction;
end;

func WeightCoopIOR() => bits(64)
begin
    var instruction = Zeros{64} + 0x00000013;
    instruction[19:15] = Zeros{5} + 2;
    instruction[24:20] = Zeros{5} + 3;
    instruction[31:27] = Zeros{5} + 4;
    return instruction;
end;

func WeightCoopShared(init: boolean) => bits(64)
begin
    var instruction = Zeros{64} + 0x00001013;
    instruction[25:20] = Zeros{6} + 8;
    instruction[18:15] = if init then '0011' else '0000';
    instruction[11:9] = '111';
    return instruction;
end;

func WeightCoopAssemble(init: boolean, last: boolean,
                        writer_size: integer {1..2}) => bits(64)
begin
    var instruction = Zeros{64} + 0x00001053;
    instruction[31] = if init then '1' else '0';
    instruction[11] = if last then '1' else '0';
    instruction[10:7] = Zeros{4} + writer_size;
    return instruction;
end;

func WeightCoopPhase(pe: integer, init: boolean, last: boolean,
                     gm_base: integer, writer_size: integer {1..2},
                     mismatch_shape: boolean) => boolean
begin
    _CurrentMemoryAgent = pe as MemoryAgentId;
    let shape = Zeros{64} + 3 + (16 << 16) + (1 << 32) + (1 << 40);
    for participant = 0 to PTO_MODEL_MEMORY_AGENTS - 1 looplimit 4 do
        let agent = participant as MemoryAgentId;
        WritePEGPR(agent, 2, Zeros{PTO_XLEN} + gm_base);
        WritePEGPR(agent, 3, shape);
        WritePEGPR(agent, 4, Zeros{PTO_XLEN});
    end;
    if mismatch_shape then
        WritePEGPR(3 as MemoryAgentId, 3, shape + 1);
    end;
    let start_status = ExecuteCommandInstruction(WeightCoopStart(), 32);
    let datr_status = ExecuteCommandInstruction(WeightCoopAttributes(), 32);
    assert start_status == CommandExecution_Executed;
    assert datr_status == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 16);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 16);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 16);
    let ior_status = ExecuteCommandInstruction(WeightCoopIOR(), 32);
    let shared_status = ExecuteCommandInstruction(
        WeightCoopShared(init), 32);
    let assemble_status = ExecuteCommandInstruction(
        WeightCoopAssemble(init, last, writer_size), 32);
    assert ior_status == CommandExecution_Executed;
    assert shared_status == CommandExecution_Executed;
    assert assemble_status == CommandExecution_Executed;
    return ExecuteBundleTileOperation();
end;

func InstallPriorCoopShared()
begin
    ConfigureTile(0, 128, 128, 1, 1, 1, TileDataType_U8,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0x55);
    InstallSharedTile((Zeros{6} + 8) as SharedTileID, _Tiles[[0]], '1111');
end;

func StoreCoopWeights(base: integer)
begin
    for oc = 0 to 15 looplimit 16 do
        for ci = 0 to 2 looplimit 3 do
            Store(Zeros{PTO_XLEN} + base + (oc * 3 + ci) * 2, 2,
                Zeros{PTO_XLEN} + 1000 * oc + ci + 1);
        end;
    end;
end;

func main() => integer
begin
    // PE0 owns only the first four rows. A fault beginning at PE1's first row
    // must nevertheless be found before PE0 records any architectural load.
    ResetProfileState();
    StartMemoryEventCapture(0);
    let preflight_rejected = WeightCoopPhase(0, TRUE, FALSE, 4072, 1, FALSE);
    assert !preflight_rejected && _LastFault == Fault_DataPage;
    assert _MemoryEventCount == 0;
    assert !_SharedGenerations[[SharedTileArrayIndex(
        (Zeros{6} + 8) as SharedTileID)]].open;

    // Four rows x 16 FP16 elements is exactly 128 bytes (SizeCode 1).
    // SizeCode 2 must reject before opening a generation.
    ResetProfileState();
    StartMemoryEventCapture(0);
    let writer_size_rejected = WeightCoopPhase(0, TRUE, FALSE, 0, 2, FALSE);
    assert !writer_size_rejected && _LastFault == Fault_TileLegality;
    assert _MemoryEventCount == 0;
    assert !_SharedGenerations[[SharedTileArrayIndex(
        (Zeros{6} + 8) as SharedTileID)]].open;

    ResetProfileState();
    StoreCoopWeights(0);
    InstallPriorCoopShared();
    let shared_tile_id = (Zeros{6} + 8) as SharedTileID;
    let phase_0 = WeightCoopPhase(0, TRUE, FALSE, 0, 1, FALSE);
    assert phase_0;
    assert SharedTilePublished(shared_tile_id);
    assert BundleSharedGenerationOpen(shared_tile_id);
    assert ReadSharedTileWord(shared_tile_id, 0) == Zeros{PTO_XLEN} + 0x55;
    ClearBundleHeaderState();
    StartMemoryEventCapture(0);
    let mismatch = WeightCoopPhase(1, FALSE, FALSE, 0, 1, TRUE);
    assert !mismatch && _LastFault == Fault_TileLegality;
    assert _MemoryEventCount == 0;
    assert !BundleSharedGenerationOpen(shared_tile_id);
    assert SharedTilePublished(shared_tile_id);
    assert ReadSharedTileWord(shared_tile_id, 0) == Zeros{PTO_XLEN} + 0x55;
    StopMemoryEventCapture();

    ClearFault();
    ClearBundleHeaderState();
    let retry_0 = WeightCoopPhase(0, TRUE, FALSE, 0, 1, FALSE);
    assert retry_0;
    assert BundleSharedGenerationOpen(shared_tile_id);
    assert ReadSharedTileWord(shared_tile_id, 0) == Zeros{PTO_XLEN} + 0x55;
    ClearBundleHeaderState();
    let phase_1 = WeightCoopPhase(1, FALSE, FALSE, 0, 1, FALSE);
    assert phase_1;
    assert BundleSharedGenerationOpen(shared_tile_id);
    assert SharedTilePublished(shared_tile_id);
    assert ReadSharedTileWord(shared_tile_id, 0) == Zeros{PTO_XLEN} + 0x55;
    ClearBundleHeaderState();
    let phase_2 = WeightCoopPhase(2, FALSE, FALSE, 0, 1, FALSE);
    assert phase_2;
    assert BundleSharedGenerationOpen(shared_tile_id);
    assert SharedTilePublished(shared_tile_id);
    assert ReadSharedTileWord(shared_tile_id, 0) == Zeros{PTO_XLEN} + 0x55;
    ClearBundleHeaderState();
    let phase_3 = WeightCoopPhase(3, FALSE, TRUE, 0, 1, FALSE);
    assert phase_3;
    assert SharedTilePublished(shared_tile_id);
    let shared = SharedTileRecord(shared_tile_id).tile;
    assert shared.layout == TileLayout_RowMajor;
    assert shared.columns == 16 && shared.valid_rows == 16 &&
        shared.valid_columns == 16;
    for row = 0 to 15 looplimit 16 do
        for col = 0 to 15 looplimit 16 do
            let element = TileLogicalLinearIndex(shared, row, col);
            assert TileLogicalElementDefined(shared, element);
            if col < 3 then
                assert TileReadLogicalElement(shared, element) ==
                    Zeros{PTO_XLEN} + 1000 * row + col + 1;
            else
                assert TileReadLogicalElement(shared, element) ==
                    Zeros{PTO_XLEN};
            end;
        end;
    end;
    return 0;
end;
