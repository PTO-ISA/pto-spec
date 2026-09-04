// PTO-TEST: {"id":"PTO-AVS-BLOCK-BSTART-TIMG2COL-SHARED-001","source":"asl/block/execution/BSTART.TIMG2COL.asl","requirements":["PTO-INST-BLOCK-BSTART-TIMG2COL","PTO-BSTART-TIMG2COL-CONTRACT-001","PTO-B-ASSEMBLE-SHARED-GENERATION-001","PTO-BSTART-TIMG2COL-DEFINEDNESS-001"],"kind":"execution","summary":"Four TIMG2COL PE phases build one Shared generation with a zero-row participant and publish only at LAST.","pass_condition":"PE0 INIT maps source RowStart one to destination row zero, PE3 LAST covers the undefined parent tail, and a replacement generation with changed ValidRow aborts while preserving the published parent.","related_sources":["asl/block/model/dispatch/timg2col-execution.asl","asl/block/model/operands/shared-generation.asl"]}
pure func Timg2COLStart() => bits(64)
begin
    var instruction = Zeros{64} + 0x01c11181;
    instruction[31:27] = Zeros{5} + 27;
    return instruction;
end;

pure func Timg2COLIOR(source0: integer, source1: integer, source2: integer)
    => bits(64)
begin
    var instruction = Zeros{64} + 0x00000013;
    instruction[19:15] = Zeros{5} + source0;
    instruction[24:20] = Zeros{5} + source1;
    instruction[31:27] = Zeros{5} + source2;
    return instruction;
end;

pure func Timg2COLSharedIO() => bits(64)
begin
    var instruction = Zeros{64} + 0x00001013;
    instruction[25:20] = Zeros{6} + 8;
    instruction[18:15] = Zeros{4} + 1;
    instruction[11:9] = '111';
    return instruction;
end;

pure func Timg2COLAssemble(init: boolean, last: boolean,
                      parent_size: integer) => bits(64)
begin
    var instruction = Zeros{64} + 0x00001053;
    instruction[31] = if init then '1' else '0';
    instruction[11] = if last then '1' else '0';
    instruction[10:7] = Zeros{4} + parent_size;
    return instruction;
end;

func Timg2COLPhase(
    pe: integer, init: boolean, last: boolean, gm_base: integer,
    valid_row: integer) => boolean
begin
    _CurrentMemoryAgent = pe as MemoryAgentId;
    for participant = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        let agent = participant as MemoryAgentId;
        WritePEGPR(agent, 2, Zeros{PTO_XLEN} + gm_base);
        WritePEGPR(agent, 3, Zeros{64} + 4 + (1 << 16) + (1 << 32) +
            (1 << 48) + (1 << 56));
        WritePEGPR(agent, 4, Zeros{64} + (1 << 32) + (1 << 37) +
            (1 << 42) + (1 << 48));
        WritePEGPR(agent, 5, Zeros{PTO_XLEN} + 1);
    end;
    let started = ExecuteCommandInstruction(Timg2COLStart(), 32);
    assert started == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 32);
    SetBundleDimension(1, Zeros{PTO_XLEN} + valid_row);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 64);
    let gm_binding = ExecuteCommandInstruction(Timg2COLIOR(2, 0, 0), 32);
    assert gm_binding == CommandExecution_Executed;
    let parameter_binding = ExecuteCommandInstruction(Timg2COLIOR(3, 4, 5), 32);
    assert parameter_binding == CommandExecution_Executed;
    let shared_binding = ExecuteCommandInstruction(Timg2COLSharedIO(), 32);
    assert shared_binding == CommandExecution_Executed;
    let assemble_parent_size = if init then 1 else 0;
    let assemble_status = ExecuteCommandInstruction(
        Timg2COLAssemble(init, last, assemble_parent_size), 32);
    assert assemble_status == CommandExecution_Executed;
    let completed = CompleteBundleAt(Zeros{PTO_XLEN} + 0x100);
    return completed;
end;

func main() => integer
begin
    ResetProfileState();
    _Memory[[1]] = Zeros{8} + 0x5a;
    let phase_0 = Timg2COLPhase(0, TRUE, FALSE, 0, 1);
    assert phase_0;
    let shared_tile_id = (Zeros{6} + 8) as SharedTileID;
    assert BundleSharedGenerationOpen(shared_tile_id);
    assert !SharedTilePublished(shared_tile_id);
    ClearBundleHeaderState();
    let phase_1 = Timg2COLPhase(1, FALSE, FALSE, 0, 1);
    assert phase_1;
    ClearBundleHeaderState();
    let phase_2 = Timg2COLPhase(2, FALSE, FALSE, 0, 1);
    assert phase_2;
    ClearBundleHeaderState();
    let phase_3 = Timg2COLPhase(3, FALSE, TRUE, 0, 1);
    assert phase_3;
    assert SharedTilePublished(shared_tile_id);
    let shared = SharedTileRecord(shared_tile_id);
    assert shared.tile.columns == 64 && shared.tile.valid_columns == 32;
    assert TileLogicalElementDefined(shared.tile,
        TileLogicalLinearIndex(shared.tile, 0, 0));
    assert TileReadLogicalElement(shared.tile,
        TileLogicalLinearIndex(shared.tile, 0, 0)) ==
        Zeros{PTO_XLEN} + 0x5a;
    assert !TileLogicalElementDefined(shared.tile,
        TileLogicalLinearIndex(shared.tile, 0, 32));
    assert !TileLogicalElementDefined(shared.tile,
        TileLogicalLinearIndex(shared.tile, 1, 0));
    ClearBundleHeaderState();
    let replacement_init = Timg2COLPhase(0, TRUE, FALSE, 0, 1);
    assert replacement_init && SharedTilePublished(shared_tile_id);
    ClearBundleHeaderState();
    let mismatched_middle = Timg2COLPhase(1, FALSE, FALSE, 0, 2);
    assert !mismatched_middle && _LastFault == Fault_TileLegality;
    assert !BundleSharedGenerationOpen(shared_tile_id);
    assert SharedTilePublished(shared_tile_id);
    assert TileReadLogicalElement(SharedTileRecord(shared_tile_id).tile,
        TileLogicalLinearIndex(shared.tile, 0, 0)) ==
        Zeros{PTO_XLEN} + 0x5a;
    return 0;
end;
