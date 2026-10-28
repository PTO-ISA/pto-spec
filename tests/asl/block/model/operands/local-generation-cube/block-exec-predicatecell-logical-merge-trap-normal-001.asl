// PTO-TEST: {"id":"PTO-AVS-BLOCK-PREDICATECELL-LOGICAL-MERGE-TRAP-NORMAL-001","source":"asl/block/model/operands/local-generation-cube.asl","requirements":["PTO-B-ASSEMBLE-CUBE-PARENT-GEOMETRY-001","PTO-B-ASSEMBLE-CONSUMER-READINESS-001","PTO-TAND-CONTRACT-001"],"kind":"execution","summary":"PredicateCell MERGE wait pins its implicit Q across normal trap recovery","pass_condition":"after a waiting consumer is saved and handler header/mask work clears the live binding, recovery resumes with the same Q; an abort/recreate at the same tile, slot and static INIT identity with a new dynamic domain cannot substitute","related_sources":["asl/arch/data-types/trap-context.asl","asl/arch/state/trap-context.asl","asl/block/model/dispatch/execution-mask-schema.asl","asl/block/model/dispatch/tile-execution.asl"]}
pure func LogicalAssemblyStart() => bits(64)
begin
    var instruction = Zeros{64} + 0x00019181;
    instruction[24:20] = Zeros{5} + 6;
    instruction[31:27] = TileDataTypeToEncoding(TileDataType_U8);
    return instruction;
end;
pure func LogicalAssemblyInputs(init: boolean) => bits(64)
begin
    var instruction = Zeros{64} + 0x00004013;
    instruction[25:20] = if init then Zeros{6} + 1 else Zeros{6} + 3;
    instruction[31:26] = if init then Zeros{6} + 2 else Zeros{6} + 4;
    instruction[19] = if init then '1' else '0';
    instruction[18:15] = if init then Zeros{4} + 2 else Zeros{4};
    instruction[11:9] = '111'; instruction[8:7] = if init then '01' else '00';
    return instruction;
end;
pure func LogicalAssemblyModifier(init: boolean, last: boolean,
    offset: integer {0,1}) => bits(64)
begin
    var instruction = Zeros{64} + 0x00001053;
    instruction[31] = if init then '1' else '0';
    instruction[11] = if last then '1' else '0';
    instruction[10:7] = '0001';
    instruction[30:20] = Zeros{11} + offset;
    return instruction;
end;
func LogicalAssemblyWriter(init: boolean, last: boolean,
    offset: integer {0,1}, columns: integer {1..8}, complete_ready: boolean,
    expect_wait: boolean)
begin
    let started = ExecuteCommandInstruction(LogicalAssemblyStart(), 32);
    let attributes = ExecuteCommandInstruction(Zeros{64} + 0x01f01fa3, 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + columns);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 8);
    var mask = CommandExecution_Executed;
    if !init then
        var ior = Zeros{64} + 0x00000013;
        ior[19:15] = Zeros{5} + 2;
        ior[26] = '1';
        mask = ExecuteCommandInstruction(ior, 32);
    end;
    let bound = ExecuteCommandInstruction(LogicalAssemblyInputs(init), 32);
    var parent = CommandExecution_Executed;
    if !init then
        parent = ExecuteCommandInstruction(Zeros{64} + 0x01185e13, 32);
    end;
    let assembled = ExecuteCommandInstruction(LogicalAssemblyModifier(init,last,offset), 32);
    assert started == CommandExecution_Executed;
    assert attributes == CommandExecution_Executed;
    assert mask == CommandExecution_Executed;
    assert bound == CommandExecution_Executed;
    assert parent == CommandExecution_Executed;
    assert assembled == CommandExecution_Executed;
    let completed = CompleteBundleAt(Zeros{PTO_XLEN} + 0x100 + offset * 16);
    if expect_wait then
        assert !completed && _BundleExecutionMask.merge_base_waiting &&
               _LastFault == Fault_None;
        return;
    end;
    assert completed;
    if complete_ready then
        let slot = BundleLocalGenerationSlot(1, '1111');
        let ready = CompleteBundleLocalGenerationWriterEvent(
            slot, _BundleExecutionDomainToken, offset, 1);
        assert ready;
    end;
end;
func InstallPendingPredicateCellGeneration(
    slot: integer {0..63}, destination: TileIndex,
    execution_domain_token: integer)
begin
    ClearBundleLocalGenerationState(slot);
    _LocalGenerations[[slot]].open = FALSE;
    _LocalGenerations[[slot]].closed = TRUE;
    _LocalGenerations[[slot]].published = FALSE;
    _LocalGenerations[[slot]].generation_identity_valid = TRUE;
    _LocalGenerations[[slot]].descriptor_finalized = TRUE;
    _LocalGenerations[[slot]].destination_hand =
        RelativeTileHandIndex(destination);
    _LocalGenerations[[slot]].participant_mask = '1111';
    _LocalGenerations[[slot]].generation_instance =
        Zeros{PTO_XLEN} + 0x5a0;
    _LocalGenerations[[slot]].parent_size_code = 1;
    _LocalGenerations[[slot]].parent_cell_count = 1;
    _LocalGenerations[[slot]].working_destination = destination;
    _LocalGenerations[[slot]].last_seen = TRUE;
    _LocalGenerations[[slot]].writer_count = 1;
    _LocalGenerations[[slot]].parent_descriptor.valid = TRUE;
    _LocalGenerations[[slot]].parent_descriptor.object_name = destination;
    _LocalGenerations[[slot]].parent_descriptor.object_kind =
        TileStorage_PredicateCell;
    _LocalGenerations[[slot]].parent_descriptor.participant_mask = '1111';
    _LocalGenerations[[slot]].parent_descriptor.capacity_bytes =
        _Tiles[[destination]].capacity_bytes;
    _LocalGenerations[[slot]].parent_descriptor.rows = _Tiles[[destination]].rows;
    _LocalGenerations[[slot]].parent_descriptor.columns = _Tiles[[destination]].columns;
    _LocalGenerations[[slot]].parent_descriptor.valid_rows = _Tiles[[destination]].valid_rows;
    _LocalGenerations[[slot]].parent_descriptor.valid_columns = _Tiles[[destination]].valid_columns;
    _LocalGenerations[[slot]].parent_descriptor.data_type = _Tiles[[destination]].data_type;
    _LocalGenerations[[slot]].parent_descriptor.predicate_basis_type =
        _Tiles[[destination]].predicate_basis_type;
    _LocalGenerations[[slot]].parent_descriptor.layout =
        _Tiles[[destination]].layout;
    _LocalGenerations[[slot]].parent_descriptor.cube_k_repeat = _Tiles[[destination]].cube_k_repeat;
    _LocalGenerations[[slot]].parent_descriptor.cube_n_repeat = _Tiles[[destination]].cube_n_repeat;
    _LocalGenerations[[slot]].parent_descriptor.cube_cell_count =
        _Tiles[[destination]].cube_cell_count;
    _LocalGenerations[[slot]].parent_descriptor.cube_storage_bytes =
        _Tiles[[destination]].cube_storage_bytes;
    _LocalGenerations[[slot]].writers[[0]].valid = TRUE;
    _LocalGenerations[[slot]].writers[[0]].offset_cells = 0;
    _LocalGenerations[[slot]].writers[[0]].cell_count = 1;
    _LocalGenerations[[slot]].writers[[0]].destination = destination;
    _LocalGenerations[[slot]].writers[[0]].pe_mask = '1111';
    _LocalGenerations[[slot]].writers[[0]].ready = FALSE;
    _LocalGenerations[[slot]].writers[[0]].physical_rows = 16;
    _LocalGenerations[[slot]].writers[[0]].physical_columns = 8;
    _LocalGenerations[[slot]].writers[[0]].valid_rows =
        _Tiles[[destination]].valid_rows;
    _LocalGenerations[[slot]].writers[[0]].valid_columns =
        _Tiles[[destination]].valid_columns;
    _LocalGenerations[[slot]].writers[[0]].data_type =
        _Tiles[[destination]].data_type;
    _LocalGenerations[[slot]].writers[[0]].predicate_basis_type =
        _Tiles[[destination]].predicate_basis_type;
    _LocalGenerations[[slot]].writers[[0]].layout =
        _Tiles[[destination]].layout;
    _LocalGenerations[[slot]].writers[[0]].identity.instruction_instance =
        Zeros{PTO_XLEN} + 0x5a0;
    _LocalGenerations[[slot]].writers[[0]].identity.execution_domain_token =
        execution_domain_token;
    _LocalGenerations[[slot]].covered_cells[0] = '1';
    for pe = 0 to 3 do
        var covered = Zeros{2048};
        covered[0] = '1';
        _LocalGenerations[[slot]].per_pe_covered_cells[[pe]] = covered;
        _LocalGenerations[[slot]].per_pe_closed[[pe]] = TRUE;
        _LocalGenerations[[slot]].per_pe_working_destination[[pe]] =
            destination;
    end;
end;
func RunSavedMergeTrapScenario(portable: boolean,
    replacement: boolean) => boolean
begin
    ResetProfileState();
    let configured1 = ConfigurePredicateCellForMask(1,128,2,8,
        TileDataType_U32,TileLayout_CUBE_M16,'1111');
    let configured2 = ConfigurePredicateCellForMask(2,128,2,8,
        TileDataType_FP32,TileLayout_CUBE_M16,'1111');
    let configured3 = ConfigurePredicateCellForMask(3,128,2,3,
        TileDataType_U32,TileLayout_CUBE_M16,'1111');
    let configured4 = ConfigurePredicateCellForMask(4,128,2,3,
        TileDataType_FP32,TileLayout_CUBE_M16,'1111');
    let configuredq = ConfigurePredicateCellForMask(17,128,2,3,
        TileDataType_U32,TileLayout_CUBE_M16,'1111');
    if !configured1 || !configured2 || !configured3 || !configured4 ||
       !configuredq then return FALSE; end;
    for index = 1 to 4 do
        for row = 0 to 1 do
            for column = 0 to _Tiles[[index]].valid_columns - 1
                looplimit 8 do
                WriteTileElement(index as TileIndex,
                    row as integer {0..65535},
                    column as integer {0..65535},
                    if column MOD 2 == 0 then Zeros{PTO_XLEN} + 1
                    else Zeros{PTO_XLEN});
            end;
        end;
        MarkTileValidRegionDefined(index as TileIndex);
        InstallRelativeTileFixture(index as TileIndex, index as TileIndex);
    end;
    for row = 0 to 1 do
        for column = 0 to 2 do
            WriteTileElement(17, row as integer {0..65535},
                column as integer {0..65535}, Zeros{PTO_XLEN} + 1);
        end;
    end;
    MarkTileValidRegionDefined(17);

    LogicalAssemblyWriter(TRUE,FALSE,0,8,TRUE,FALSE);
    let parent_slot = BundleLocalGenerationSlot(1, '1111');
    let parent = _LocalGenerations[[parent_slot]].working_destination;
    let q_slot: integer {0..63} = 60;
    InstallPendingPredicateCellGeneration(q_slot,17,77);
    assert TilePredicateCellValuesLegal(17) &&
           TilePayloadIntactForMask(17,'1111') &&
           BundleLocalGenerationSlotForDestination(17) == q_slot;
    InstallRelativeTileFixture(17,parent);
    InstallRelativeTileFixture(16,17);
    for pe = 0 to 3 do
        WritePEGPR(pe as MemoryAgentId,2,Zeros{PTO_XLEN} + 1);
    end;

    LogicalAssemblyWriter(FALSE,TRUE,1,3,FALSE,TRUE);
    if !_BundleExecutionMask.merge_base_generation_valid ||
       _BundleExecutionMask.merge_base != 17 ||
       _BundleExecutionMask.merge_base_generation_slot != q_slot ||
       _BundleExecutionMask.merge_base_writer_execution_domain_token != 77 ||
       !_BundleExecutionMask.merge_base_waiting then return FALSE; end;
    let saved_generation =
        _BundleExecutionMask.merge_base_generation_instance;
    let saved_writer =
        _BundleExecutionMask.merge_base_writer_instruction_instance;
    let saved_domain =
        _BundleExecutionMask.merge_base_writer_execution_domain_token;
    if portable then
        SavePortableTrapContext(1,CurrentACR());
    else
        SaveTrapContext(1,CurrentACR());
    end;
    if !_TrapContexts[[1]].merge_base_generation_valid ||
       _TrapContexts[[1]].merge_base != 17 || _TrapContexts[[1]].merge_base_generation_slot != q_slot ||
       _TrapContexts[[1]].merge_base_generation_instance != saved_generation ||
       _TrapContexts[[1]].merge_base_writer_instruction_instance != saved_writer ||
       _TrapContexts[[1]].merge_base_writer_execution_domain_token != saved_domain then return FALSE; end;
    SetCurrentACR(1);
    ClearBundleHeaderState();
    _BundleExecutionMask.valid = TRUE;
    _BundleExecutionMask.carrier = BundleExecutionMask_GPR;
    _BundleExecutionMask.word_count = 1;
    _BundleExecutionMask.low_word = Zeros{PTO_XLEN} + 0xdead;

    if replacement then
        AbortBundleLocalGeneration(q_slot);
        let configured_replacement = ConfigurePredicateCellForMask(17,128,2,3,
            TileDataType_U32,TileLayout_CUBE_M16,'1111');
        if !configured_replacement then return FALSE; end;
        for row = 0 to 1 do
            for column = 0 to 2 do
                WriteTileElement(17, row as integer {0..65535},
                    column as integer {0..65535}, Zeros{PTO_XLEN});
            end;
        end;
        MarkTileValidRegionDefined(17);
        InstallPendingPredicateCellGeneration(q_slot,17,78);
        assert _LocalGenerations[[q_slot]].generation_instance ==
                   Zeros{PTO_XLEN} + 0x5a0 &&
               _LocalGenerations[[q_slot]].writers[[0]]
                   .identity.instruction_instance ==
                   Zeros{PTO_XLEN} + 0x5a0 &&
               _LocalGenerations[[q_slot]].writers[[0]]
                   .identity.execution_domain_token == 78 &&
               ReadTileElement(17,0,0) == Zeros{PTO_XLEN};
        let replacement_ready = CompleteBundleLocalGenerationWriterEvent(
            q_slot,78,0,1);
        assert replacement_ready && _LocalGenerations[[q_slot]].published;
    end;

    let recovered = if portable then RecoverPortableTrapContext(1)
        else RecoverTrapContext(1);
    if !recovered || CurrentACR() != 0 then return FALSE; end;
    if _BundleExecutionMask.carrier != BundleExecutionMask_GPR ||
       _BundleExecutionMask.low_word != Zeros{PTO_XLEN} + 0xdead then
        return FALSE;
    end;
    if !_BundleExecutionMask.merge_base_generation_valid ||
       _BundleExecutionMask.merge_base != 17 || _BundleExecutionMask.merge_base_generation_slot != q_slot ||
       _BundleExecutionMask.merge_base_generation_instance != saved_generation ||
       _BundleExecutionMask.merge_base_writer_instruction_instance != saved_writer ||
       _BundleExecutionMask.merge_base_writer_execution_domain_token != saved_domain ||
       _BundleExecutionMask.merge_base_waiting then return FALSE; end;
    if replacement then
        let retried = CompleteBundleAt(Zeros{PTO_XLEN} + 0x110);
        assert !retried;
        assert _LocalGenerations[[q_slot]].consumer_count == 0;
        assert _LastFault == Fault_TileLegality;
        assert !_BundleExecutionMask.merge_base_waiting;
        assert _LocalGenerations[[q_slot]].published;
        assert _LocalGenerations[[q_slot]].writers[[0]]
                   .identity.execution_domain_token == 78;
        return TRUE;
    end;

    let q_writer = _LocalGenerations[[q_slot]].writers[[0]];
    let q_ready = CompleteBundleLocalGenerationWriterEvent(q_slot,
        q_writer.identity.execution_domain_token,
        q_writer.offset_cells,
        q_writer.cell_count as integer {1..2048});
    assert q_ready && _LocalGenerations[[q_slot]].published;
    let resumed = CompleteBundleAt(Zeros{PTO_XLEN} + 0x110);
    assert resumed && _LastFault == Fault_None;
    let p_ready = CompleteBundleLocalGenerationWriterEvent(parent_slot,
        _BundleExecutionDomainToken,1,1);
    assert p_ready && _LocalGenerations[[parent_slot]].published;
    assert _Tiles[[parent]].valid_columns == 11;
    assert ReadTileElement(parent,0,8) == Zeros{PTO_XLEN} + 1;
    assert ReadTileElement(parent,0,9) == Zeros{PTO_XLEN} + 1;
    return TRUE;
end;
func main() => integer
begin
    let replacement = RunSavedMergeTrapScenario(FALSE,TRUE);
    assert replacement;
    let resumed = RunSavedMergeTrapScenario(FALSE,FALSE);
    assert resumed;
    return 0;
end;
