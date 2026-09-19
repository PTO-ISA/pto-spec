// PTO-TEST: {"id":"PTO-AVS-BLOCK-BSTART-TIMG2COL-LOCAL-ASSEMBLE-002","source":"asl/block/model/dispatch/timg2col-execution.asl","requirements":["PTO-INST-BLOCK-BSTART-TIMG2COL","PTO-B-ASSEMBLE-RANGE-001","PTO-BSTART-TIMG2COL-CONTRACT-001","PTO-BSTART-TIMG2COL-DEFINEDNESS-001"],"kind":"fault","summary":"Decoded Local TIMG2COL rejects B.ASSEMBLE because the canonical Local form is one direct B.IOT destination.","pass_condition":"INIT_LAST, malformed-WriterSize, nonzero-offset, cooperative zero-row, and continuation-against-open-generation forms raise TileLegality before GPR/GM, allocation, payload, writer, coverage, finalization, or publication effects; the continuation preserves its complete generation and Tile records while Shared assembly remains accepted.","related_sources":["asl/block/execution/BSTART.TIMG2COL.asl","asl/block/model/dispatch/tile-execution.asl","asl/block/model/operands/shared-generation.asl"]}
pure func TIMG2COLAssembleStart() => bits(64)
begin
    var instruction = Zeros{64} + 0x01c11181;
    instruction[31:27] = Zeros{5} + 27;
    return instruction;
end;

pure func TIMG2COLAssembleDATR() => bits(64)
begin
    var instruction = Zeros{64} + 0x00001023;
    instruction[24:20] = DTYPE_NONE;
    instruction[11:7] = Zeros{5} + 22;
    return instruction;
end;

pure func TIMG2COLAssembleIOR(
    source0: integer, source1: integer, source2: integer) => bits(64)
begin
    var instruction = Zeros{64} + 0x00000013;
    instruction[19:15] = Zeros{5} + source0;
    instruction[24:20] = Zeros{5} + source1;
    instruction[31:27] = Zeros{5} + source2;
    return instruction;
end;

pure func TIMG2COLAssembleDestination(size_code: integer {1..10}) => bits(64)
begin
    var instruction = Zeros{64} + 0x00006013;
    instruction[18:15] = Zeros{4} + size_code;
    instruction[11:9] = '111';
    instruction[19] = '1';
    instruction[8:7] = '10';
    return instruction;
end;

pure func TIMG2COLAssembleModifier(
    writer_size: integer {1..12}, offset: integer {0..2047}) => bits(64)
begin
    var instruction = Zeros{64} + 0x00001053;
    instruction[31] = '1';
    instruction[11] = '1';
    instruction[10:7] = Zeros{4} + writer_size;
    instruction[30:20] = Zeros{11} + offset;
    return instruction;
end;

pure func TIMG2COLAssembleParent() => bits(64)
begin
    var instruction = Zeros{64} + 0x00005013;
    instruction[25:20] = Zeros{6};
    instruction[11:9] = '111';
    instruction[19] = '1';
    return instruction;
end;

pure func TIMG2COLAssembleLast() => bits(64)
begin
    var instruction = TIMG2COLAssembleModifier(3, 4);
    instruction[31] = '0';
    return instruction;
end;

func PrepareTIMG2COLAssembleFixture()
begin
    for element = 0 to 31 do
        Store(Zeros{PTO_XLEN} + 32 + element, 1,
            Zeros{PTO_XLEN} + element + 1);
    end;
    for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        let agent = pe as MemoryAgentId;
        WritePEGPR(agent, 2, Zeros{PTO_XLEN});
        WritePEGPR(agent, 3, Zeros{64} + 1 + (1 << 16) + (64 << 32) +
            (1 << 48) + (1 << 56));
        WritePEGPR(agent, 4, Zeros{64} + (1 << 32) + (1 << 37) +
            (1 << 42) + (1 << 48));
        WritePEGPR(agent, 5, Zeros{PTO_XLEN} + (32 << 32));
    end;
end;

func RunTIMG2COLAssemble(
    writer_size: integer {1..12}, offset: integer {0..2047}) => boolean
begin
    let start = ExecuteCommandInstruction(TIMG2COLAssembleStart(), 32);
    let datr = ExecuteCommandInstruction(TIMG2COLAssembleDATR(), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 32);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 64);
    let gm = ExecuteCommandInstruction(TIMG2COLAssembleIOR(2, 0, 0), 32);
    let parameters = ExecuteCommandInstruction(
        TIMG2COLAssembleIOR(3, 4, 5), 32);
    let destination = ExecuteCommandInstruction(
        TIMG2COLAssembleDestination(3), 32);
    let assemble = ExecuteCommandInstruction(
        TIMG2COLAssembleModifier(writer_size, offset), 32);
    assert start == CommandExecution_Executed &&
           datr == CommandExecution_Executed &&
           gm == CommandExecution_Executed &&
           parameters == CommandExecution_Executed &&
           destination == CommandExecution_Executed &&
           assemble == CommandExecution_Executed;
    return ExecuteBundleTileOperation();
end;

func RunTIMG2COLAssembleContinuation() => boolean
begin
    let start = ExecuteCommandInstruction(TIMG2COLAssembleStart(), 32);
    let datr = ExecuteCommandInstruction(TIMG2COLAssembleDATR(), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 32);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 64);
    let gm = ExecuteCommandInstruction(TIMG2COLAssembleIOR(2, 0, 0), 32);
    let parameters = ExecuteCommandInstruction(
        TIMG2COLAssembleIOR(3, 4, 5), 32);
    let parent = ExecuteCommandInstruction(TIMG2COLAssembleParent(), 32);
    let assemble = ExecuteCommandInstruction(TIMG2COLAssembleLast(), 32);
    assert start == CommandExecution_Executed &&
           datr == CommandExecution_Executed &&
           gm == CommandExecution_Executed &&
           parameters == CommandExecution_Executed &&
           parent == CommandExecution_Executed &&
           assemble == CommandExecution_Executed;
    return ExecuteBundleTileOperation();
end;

func AssertNoTIMG2COLLocalGenerationEffects()
begin
    assert _MemoryEventCount == 0;
    for tile = 0 to PTO_TILE_REGISTER_COUNT - 1 do
        assert !_Tiles[[tile]].allocated;
    end;
    for slot = 0 to 63 do
        assert !_LocalGenerations[[slot]].generation_identity_valid &&
               !_LocalGenerations[[slot]].open &&
               !_LocalGenerations[[slot]].descriptor_finalized &&
               !_LocalGenerations[[slot]].published &&
               _LocalGenerations[[slot]].writer_count == 0;
    end;
end;

readonly func TIMG2COLGenerationUnchanged(
    slot: integer {0..63}, before: LocalGenerationState) => boolean
begin
    let after = _LocalGenerations[[slot]];
    if after.open != before.open || after.closed != before.closed ||
       after.published != before.published ||
       after.generation_identity_valid != before.generation_identity_valid ||
       after.descriptor_finalized != before.descriptor_finalized ||
       after.destination_hand != before.destination_hand ||
       after.participant_mask != before.participant_mask ||
       after.generation_instance != before.generation_instance ||
       after.init_tpc != before.init_tpc ||
       after.init_tpc_valid != before.init_tpc_valid ||
       after.parent_size_code != before.parent_size_code ||
       after.parent_cell_count != before.parent_cell_count ||
       after.covered_cells != before.covered_cells ||
       after.ready_cells != before.ready_cells ||
       after.writer_count != before.writer_count ||
       after.last_seen != before.last_seen ||
       after.consumer_count != before.consumer_count ||
       after.working_destination != before.working_destination ||
       after.published_destination != before.published_destination ||
       after.committed_destination != before.committed_destination ||
       after.committed_valid != before.committed_valid then return FALSE; end;
    let ap = after.parent_descriptor; let bp = before.parent_descriptor;
    if ap.valid != bp.valid || ap.object_name != bp.object_name ||
       ap.object_kind != bp.object_kind || ap.participant_mask != bp.participant_mask ||
       ap.capacity_bytes != bp.capacity_bytes || ap.rows != bp.rows ||
       ap.columns != bp.columns || ap.valid_rows != bp.valid_rows ||
       ap.valid_columns != bp.valid_columns || ap.data_type != bp.data_type ||
       ap.predicate_basis_type != bp.predicate_basis_type || ap.layout != bp.layout ||
       ap.cube_k_repeat != bp.cube_k_repeat || ap.cube_n_repeat != bp.cube_n_repeat ||
       ap.cube_cell_count != bp.cube_cell_count ||
       ap.cube_storage_bytes != bp.cube_storage_bytes then return FALSE; end;
    for pe = 0 to 3 do
        if after.per_pe_covered_cells[[pe]] != before.per_pe_covered_cells[[pe]] ||
           after.per_pe_ready_cells[[pe]] != before.per_pe_ready_cells[[pe]] ||
           after.per_pe_closed[[pe]] != before.per_pe_closed[[pe]] ||
           after.per_pe_published[[pe]] != before.per_pe_published[[pe]] ||
           after.per_pe_working_destination[[pe]] !=
               before.per_pe_working_destination[[pe]] then return FALSE; end;
    end;
    for writer = 0 to 15 do
        let aw = after.writers[[writer]]; let bw = before.writers[[writer]];
        if aw.valid != bw.valid || aw.offset_cells != bw.offset_cells ||
           aw.cell_count != bw.cell_count || aw.destination != bw.destination ||
           aw.pe_mask != bw.pe_mask || aw.ready != bw.ready ||
           aw.physical_rows != bw.physical_rows ||
           aw.physical_columns != bw.physical_columns ||
           aw.valid_rows != bw.valid_rows || aw.valid_columns != bw.valid_columns ||
           aw.data_type != bw.data_type ||
           aw.predicate_basis_type != bw.predicate_basis_type ||
           aw.layout != bw.layout ||
           aw.identity.instruction_instance != bw.identity.instruction_instance ||
           aw.identity.execution_domain_token !=
               bw.identity.execution_domain_token then return FALSE; end;
    end;
    for consumer = 0 to 15 do
        let ac = after.consumers[[consumer]]; let bc = before.consumers[[consumer]];
        if ac.valid != bc.valid || ac.source != bc.source ||
           ac.participant_mask != bc.participant_mask ||
           ac.generation_instance != bc.generation_instance ||
           ac.execution_domain_token != bc.execution_domain_token ||
           ac.mode != bc.mode || ac.required_cells != bc.required_cells ||
           ac.required_cell_count != bc.required_cell_count ||
           ac.after_last != bc.after_last || ac.state != bc.state ||
           ac.consumer_instruction_instance !=
               bc.consumer_instruction_instance then return FALSE; end;
    end;
    return TRUE;
end;

func main() => integer
begin
    ResetProfileState();
    PrepareTIMG2COLAssembleFixture();
    let rejected = RunTIMG2COLAssemble(3, 0);
    assert !rejected && _LastFault == Fault_TileLegality;
    AssertNoTIMG2COLLocalGenerationEffects();

    ResetProfileState();
    PrepareTIMG2COLAssembleFixture();
    let bad_size = RunTIMG2COLAssemble(2, 0);
    assert !bad_size && _LastFault == Fault_TileLegality;
    AssertNoTIMG2COLLocalGenerationEffects();

    ResetProfileState();
    PrepareTIMG2COLAssembleFixture();
    let bad_init_last = RunTIMG2COLAssemble(3, 1);
    assert !bad_init_last && _LastFault == Fault_TileLegality;
    AssertNoTIMG2COLLocalGenerationEffects();

    ResetProfileState();
    PrepareTIMG2COLAssembleFixture();
    _CurrentMemoryAgent = 1;
    let zero_row = RunTIMG2COLAssemble(3, 0);
    assert !zero_row && _LastFault == Fault_TileLegality;
    AssertNoTIMG2COLLocalGenerationEffects();

    ResetProfileState();
    PrepareTIMG2COLAssembleFixture();
    let open_slot: integer {0..63} = 5;
    ClearBundleLocalGenerationState(open_slot);
    let configured = ConfigureCubeTileForMask(1, 1024, 1, 32,
        TileDataType_U8, TileLayout_CUBE_M16, '1000');
    assert configured;
    InstallRelativeTileFixture(0, 1);
    _LocalGenerations[[open_slot]].generation_identity_valid = TRUE;
    _LocalGenerations[[open_slot]].open = TRUE;
    _LocalGenerations[[open_slot]].participant_mask = '1000';
    _LocalGenerations[[open_slot]].generation_instance =
        Zeros{PTO_XLEN} + 0x331;
    _LocalGenerations[[open_slot]].parent_size_code = 4;
    _LocalGenerations[[open_slot]].parent_cell_count = 8;
    _LocalGenerations[[open_slot]].working_destination = 1;
    _LocalGenerations[[open_slot]].parent_descriptor.valid = TRUE;
    _LocalGenerations[[open_slot]].parent_descriptor.object_name = 1;
    _LocalGenerations[[open_slot]].parent_descriptor.object_kind =
        TileStorage_Numeric;
    _LocalGenerations[[open_slot]].parent_descriptor.participant_mask = '1000';
    _LocalGenerations[[open_slot]].parent_descriptor.capacity_bytes = 1024;
    _LocalGenerations[[open_slot]].parent_descriptor.layout =
        TileLayout_CUBE_M16;
    _LocalGenerations[[open_slot]].writer_count = 1;
    _LocalGenerations[[open_slot]].writers[[0]].valid = TRUE;
    _LocalGenerations[[open_slot]].writers[[0]].offset_cells = 0;
    _LocalGenerations[[open_slot]].writers[[0]].cell_count = 4;
    _LocalGenerations[[open_slot]].writers[[0]].destination = 1;
    _LocalGenerations[[open_slot]].writers[[0]].pe_mask = '1000';
    for cell = 0 to 3 do
        _LocalGenerations[[open_slot]].covered_cells[cell] = '1';
        _LocalGenerations[[open_slot]].per_pe_covered_cells[[0]][cell] = '1';
    end;
    let before_generation = _LocalGenerations[[open_slot]];
    let before_rows = _Tiles[[1]].rows;
    let before_columns = _Tiles[[1]].columns;
    let before_value = TileReadLogicalElement(_Tiles[[1]], 0);
    let continuation = RunTIMG2COLAssembleContinuation();
    assert !continuation && _LastFault == Fault_TileLegality &&
           _MemoryEventCount == 0;
    assert TIMG2COLGenerationUnchanged(open_slot, before_generation);
    assert _Tiles[[1]].allocated && _Tiles[[1]].rows == before_rows &&
           _Tiles[[1]].columns == before_columns &&
           TileReadLogicalElement(_Tiles[[1]], 0) == before_value;
    return 0;
end;
