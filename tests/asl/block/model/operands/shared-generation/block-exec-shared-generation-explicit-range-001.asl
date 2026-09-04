// PTO-TEST: {"id":"PTO-AVS-BLOCK-SHARED-EXPLICIT-RANGE-001","source":"asl/block/model/operands/shared-generation.asl","requirements":["PTO-B-ASSEMBLE-SHARED-GENERATION-001"],"kind":"execution","summary":"Explicit Shared ranges admit zero-payload participants and publish only after physical coverage, stable producer inputs, and collective arrival are complete.","pass_condition":"A changed producer snapshot rejects, two zero-payload participants add no definedness, INIT and LAST cover the complete eight-unit parent, and publication copies only two 32-byte payload units after all four participants arrive.","related_sources":["asl/block/model/state/shared-generation-state.asl"]}
pure func ExplicitSharedStart() => bits(64)
begin
    var instruction = Zeros{64} + 0x00011181;
    instruction[31:27] = Zeros{5} + 27;
    return instruction;
end;

pure func ExplicitSharedBIOS() => bits(64)
begin
    var instruction = Zeros{64} + 0x00001013;
    instruction[25:20] = Zeros{6} + 8;
    instruction[18:15] = '0001';
    instruction[11:9] = '111';
    return instruction;
end;

pure func ExplicitSharedAssemble(init: boolean, last: boolean,
                                 parent_size: integer) => bits(64)
begin
    var instruction = Zeros{64} + 0x00001053;
    instruction[31] = if init then '1' else '0';
    instruction[11] = if last then '1' else '0';
    instruction[10:7] = Zeros{4} + parent_size;
    return instruction;
end;

func PrepareExplicitSharedWriter(init: boolean, last: boolean,
                                 parent_size: integer)
begin
    let started = ExecuteCommandInstruction(ExplicitSharedStart(), 32);
    assert started == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 128);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 128);
    let binder = ExecuteCommandInstruction(ExplicitSharedBIOS(), 32);
    assert binder == CommandExecution_Executed;
    let modifier = ExecuteCommandInstruction(
        ExplicitSharedAssemble(init, last, parent_size), 32);
    assert modifier == CommandExecution_Executed;
end;

func ExplicitSharedCandidate(tile: TileInfo, arrival: bits(4))
    => SharedTileInfo
begin
    return SharedTileInfo {
        descriptor_valid = TRUE,
        allocation_mask = '1111',
        initialized_mask = arrival,
        whole_parent_ready = FALSE,
        published = FALSE,
        tile = tile
    };
end;

func main() => integer
begin
    ResetProfileState();
    ConfigureTile(0, 128, 128, 1, 1, 1, TileDataType_U8,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0x11);
    PrepareExplicitSharedWriter(TRUE, FALSE, 2);
    assert ValidateBundleSharedGenerationRange(0, 0, 1, '0001', TRUE,
        Zeros{PTO_XLEN} + 0x10, Zeros{PTO_XLEN} + 0x11,
        Zeros{PTO_XLEN} + 0x12, Zeros{PTO_XLEN} + 0x13,
        Zeros{PTO_XLEN} + 0x20);
    let candidate_0 = ExplicitSharedCandidate(_Tiles[[0]], '0001');
    let committed_0 = CommitBundleSharedGenerationCandidateRange(0,
        candidate_0, 0, 1, 1, '0001', TRUE,
        Zeros{PTO_XLEN} + 0x10, Zeros{PTO_XLEN} + 0x11,
        Zeros{PTO_XLEN} + 0x12, Zeros{PTO_XLEN} + 0x13,
        Zeros{PTO_XLEN} + 0x20);
    assert committed_0;
    let generation_index = SharedTileArrayIndex((Zeros{6} + 8) as SharedTileID);
    assert _SharedGenerations[[generation_index]].parent_cell_count == 8;
    assert _SharedGenerations[[generation_index]].participant_mask == '1111';
    assert _SharedGenerations[[generation_index]].arrived_participants == '0001';
    assert _SharedGenerations[[generation_index]].covered_cells[0] == '1';

    ClearBundleHeaderState();
    PrepareExplicitSharedWriter(FALSE, TRUE, 0);
    assert !ValidateBundleSharedGenerationRange(0, 1, 1, '1000', TRUE,
        Zeros{PTO_XLEN} + 0x10, Zeros{PTO_XLEN} + 0x11,
        Zeros{PTO_XLEN} + 0x12, Zeros{PTO_XLEN} + 0x13,
        Zeros{PTO_XLEN} + 0x20);
    assert !ValidateBundleSharedGenerationRange(0, 1, 0, '0010', TRUE,
        Zeros{PTO_XLEN} + 0x20, Zeros{PTO_XLEN} + 0x11,
        Zeros{PTO_XLEN} + 0x12, Zeros{PTO_XLEN} + 0x13,
        Zeros{PTO_XLEN} + 0x20);
    assert !ValidateBundleSharedGenerationRange(0, 1, 0, '0010', TRUE,
        Zeros{PTO_XLEN} + 0x10, Zeros{PTO_XLEN} + 0x11,
        Zeros{PTO_XLEN} + 0x12, Zeros{PTO_XLEN} + 0x13,
        Zeros{PTO_XLEN} + 0x21);

    ClearBundleHeaderState();
    PrepareExplicitSharedWriter(FALSE, FALSE, 0);
    var empty = _Tiles[[0]];
    empty.valid_rows = 0;
    empty.defined_elements = Zeros{PTO_MODEL_TILE_ELEMENTS};
    empty.packed_defined_elements = ZeroPackedTileDefinedElements();
    empty.defined_valid_elements = 0;
    assert ValidateBundleSharedGenerationRange(0, 1, 0, '0010', TRUE,
        Zeros{PTO_XLEN} + 0x10, Zeros{PTO_XLEN} + 0x11,
        Zeros{PTO_XLEN} + 0x12, Zeros{PTO_XLEN} + 0x13,
        Zeros{PTO_XLEN} + 0x20);
    let candidate_1 = ExplicitSharedCandidate(empty, '0010');
    let committed_1 = CommitBundleSharedGenerationCandidateRange(0,
        candidate_1, 1, 0, 0, '0010', TRUE,
        Zeros{PTO_XLEN} + 0x10, Zeros{PTO_XLEN} + 0x11,
        Zeros{PTO_XLEN} + 0x12, Zeros{PTO_XLEN} + 0x13,
        Zeros{PTO_XLEN} + 0x20);
    assert committed_1;
    assert _SharedGenerations[[generation_index]].arrived_participants == '0011';

    ClearBundleHeaderState();
    PrepareExplicitSharedWriter(FALSE, FALSE, 0);
    assert ValidateBundleSharedGenerationRange(0, 1, 0, '0100', TRUE,
        Zeros{PTO_XLEN} + 0x10, Zeros{PTO_XLEN} + 0x11,
        Zeros{PTO_XLEN} + 0x12, Zeros{PTO_XLEN} + 0x13,
        Zeros{PTO_XLEN} + 0x20);
    let candidate_2 = ExplicitSharedCandidate(empty, '0100');
    let committed_2 = CommitBundleSharedGenerationCandidateRange(0,
        candidate_2, 1, 0, 0, '0100', TRUE,
        Zeros{PTO_XLEN} + 0x10, Zeros{PTO_XLEN} + 0x11,
        Zeros{PTO_XLEN} + 0x12, Zeros{PTO_XLEN} + 0x13,
        Zeros{PTO_XLEN} + 0x20);
    assert committed_2;
    assert _SharedGenerations[[generation_index]].arrived_participants == '0111';

    ClearBundleHeaderState();
    ConfigureTile(1, 128, 128, 1, 1, 1, TileDataType_U8,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 0x22);
    PrepareExplicitSharedWriter(FALSE, TRUE, 0);
    assert ValidateBundleSharedGenerationRange(0, 1, 7, '1000', TRUE,
        Zeros{PTO_XLEN} + 0x10, Zeros{PTO_XLEN} + 0x11,
        Zeros{PTO_XLEN} + 0x12, Zeros{PTO_XLEN} + 0x13,
        Zeros{PTO_XLEN} + 0x20);
    let candidate_3 = ExplicitSharedCandidate(_Tiles[[1]], '1000');
    let committed_3 = CommitBundleSharedGenerationCandidateRange(0,
        candidate_3, 1, 7, 1, '1000', TRUE,
        Zeros{PTO_XLEN} + 0x10, Zeros{PTO_XLEN} + 0x11,
        Zeros{PTO_XLEN} + 0x12, Zeros{PTO_XLEN} + 0x13,
        Zeros{PTO_XLEN} + 0x20);
    assert committed_3;

    let shared_tile_id = (Zeros{6} + 8) as SharedTileID;
    assert SharedTilePublished(shared_tile_id);
    let shared = SharedTileRecord(shared_tile_id);
    assert TileReadLogicalElement(shared.tile, 0) ==
        Zeros{PTO_XLEN} + 0x11;
    assert !TileLogicalElementDefined(shared.tile, 1);
    assert TileReadLogicalElement(shared.tile, 32) ==
        Zeros{PTO_XLEN} + 0x22;
    assert !TileLogicalElementDefined(shared.tile, 33);
    return 0;
end;
