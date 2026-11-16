// PTO-TEST: {"id":"PTO-AVS-BLOCK-PREDICATECELL-LOGICAL-MERGE-WAIT-001","source":"asl/block/model/operands/local-generation-cube.asl","requirements":["PTO-B-ASSEMBLE-CUBE-PARENT-GEOMETRY-001","PTO-B-ASSEMBLE-CONSUMER-READINESS-001","PTO-TAND-CONTRACT-001"],"kind":"execution","summary":"Decoded assembly MERGE waits on the exact implicit newest-hand Local generation, resumes after publication, and rejects aborted or mismatched identities","pass_condition":"an unready newest-hand Q creates a non-faulting no-effect dependency, publication resumes the same decoded consumer and commits its result, aborting a pinned Q prevents fallback, and a mismatched normalized destination is rejected before effects","related_sources":["asl/block/model/dispatch/destination-operation.asl","asl/block/model/dispatch/execution-mask-schema.asl","asl/block/model/operands/local-generation.asl","asl/tile/model/legality/destination-value.asl"]}
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
readonly func LogicalAssemblyAllocatedTileCount() => integer {0..64}
begin
    var count: integer {0..64} = 0;
    for index = 0 to 63 do
        if _Tiles[[index]].allocated then
            count = (count + 1) as integer {0..64};
        end;
    end;
    return count;
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
    slot: integer {0..63}, destination: TileIndex)
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
    _LocalGenerations[[slot]].writers[[0]].identity.execution_domain_token = 77;
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
func RunPredicateMergeDependencyScenario(scenario: integer {0..2}) => boolean
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
    InstallPendingPredicateCellGeneration(q_slot, 17);
    assert TilePredicateCellValuesLegal(17) &&
           TilePayloadIntactForMask(17,'1111') &&
           BundleLocalGenerationSlotForDestination(17) == q_slot;
    InstallRelativeTileFixture(17,parent);
    InstallRelativeTileFixture(16,17);
    WritePEGPR(0,2,Zeros{PTO_XLEN} + 1);
    WritePEGPR(1,2,Zeros{PTO_XLEN} + 1);
    WritePEGPR(2,2,Zeros{PTO_XLEN} + 1);
    WritePEGPR(3,2,Zeros{PTO_XLEN} + 1);
    let allocated_before = LogicalAssemblyAllocatedTileCount();
    LogicalAssemblyWriter(FALSE,TRUE,1,3,FALSE,TRUE);
    if LogicalAssemblyAllocatedTileCount() != allocated_before ||
       !_LocalGenerations[[q_slot]].generation_identity_valid ||
       _LocalGenerations[[q_slot]].published ||
       !_LocalGenerations[[parent_slot]].open ||
       _LocalGenerations[[parent_slot]].published ||
       _LocalGenerations[[parent_slot]].writer_count != 1 ||
       _LocalGenerations[[q_slot]].consumer_count == 0 ||
       _LocalGenerations[[q_slot]].consumers[[0]].state !=
           BundleConsumerDependency_Waiting then return FALSE; end;
    if !_BundleExecutionMask.merge_base_generation_valid ||
       _BundleExecutionMask.merge_base != 17 ||
       _BundleExecutionMask.merge_base_generation_slot != q_slot then
        return FALSE;
    end;
    let q_generation = _LocalGenerations[[q_slot]].generation_instance;
    if scenario == 1 then
        AbortBundleLocalGeneration(q_slot);
        if _LocalGenerations[[q_slot]].generation_identity_valid ||
           _Tiles[[17]].allocated then return FALSE; end;
        let retried = CompleteBundleAt(Zeros{PTO_XLEN} + 0x110);
        return !retried && _LastFault == Fault_TileLegality &&
               !_LocalGenerations[[parent_slot]].generation_identity_valid &&
               !_LocalGenerations[[parent_slot]].committed_valid &&
               !_LocalGenerations[[parent_slot]].published &&
               !_Tiles[[parent]].allocated;
    elsif scenario == 2 then
        assert parent != 17;
        _BundleTileBindings[[0]].destination = 17;
        let stale_destination = CompleteBundleAt(Zeros{PTO_XLEN} + 0x110);
        return !stale_destination && _LastFault == Fault_BundleControl &&
               !_LocalGenerations[[parent_slot]].generation_identity_valid &&
               !_LocalGenerations[[parent_slot]].committed_valid &&
               !_Tiles[[parent]].allocated &&
               !_LocalGenerations[[q_slot]].published &&
               _LocalGenerations[[q_slot]].consumers[[0]].state ==
                   BundleConsumerDependency_Waiting;
    end;
    let q_writer = _LocalGenerations[[q_slot]].writers[[0]];
    let q_ready = CompleteBundleLocalGenerationWriterEvent(q_slot,
        q_writer.identity.execution_domain_token,
        q_writer.offset_cells,
        q_writer.cell_count as integer {1..2048});
    assert q_ready;
    assert _LocalGenerations[[q_slot]].published &&
           _LocalGenerations[[q_slot]].committed_valid &&
           _LocalGenerations[[q_slot]].generation_instance == q_generation;
    assert _LocalGenerations[[q_slot]].consumers[[0]].state ==
           BundleConsumerDependency_Eligible;
    let resumed = CompleteBundleAt(Zeros{PTO_XLEN} + 0x110);
    assert resumed;
    assert _LastFault == Fault_None;
    assert _LocalGenerations[[parent_slot]].writer_count == 2;
    let p_ready = CompleteBundleLocalGenerationWriterEvent(parent_slot,
        _BundleExecutionDomainToken, 1, 1);
    if !p_ready || !_LocalGenerations[[parent_slot]].published ||
       !_LocalGenerations[[parent_slot]].committed_valid ||
       _Tiles[[parent]].storage_kind != TileStorage_PredicateCell ||
       _Tiles[[parent]].predicate_basis_type != TileDataType_U8 ||
       _Tiles[[parent]].rows != 16 || _Tiles[[parent]].columns != 16 ||
       _Tiles[[parent]].valid_rows != 2 ||
       _Tiles[[parent]].valid_columns != 11 then return FALSE; end;
    return ReadTileElement(parent,0,8) == Zeros{PTO_XLEN} + 1 &&
           ReadTileElement(parent,0,9) == Zeros{PTO_XLEN} + 1;
end;
func main() => integer
begin
    let resumed = RunPredicateMergeDependencyScenario(0);
    assert resumed;
    let aborted = RunPredicateMergeDependencyScenario(1);
    assert aborted;
    let wrong_identity = RunPredicateMergeDependencyScenario(2);
    assert wrong_identity;
    return 0;
end;
