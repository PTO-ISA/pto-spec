// PTO-TEST: {"id":"PTO-AVS-BLOCK-PREDICATECELL-LOGICAL-MERGE-SUBVIEW-WAIT-001","source":"asl/block/model/operands/local-generation-cube.asl","requirements":["PTO-B-ASSEMBLE-CUBE-PARENT-GEOMETRY-001","PTO-B-ASSEMBLE-CONSUMER-READINESS-001","PTO-B-SUBVIEW-DESCRIPTOR-001","PTO-TAND-CONTRACT-001"],"kind":"execution","summary":"A PredicateCell MERGE wait releases materialized source views and reconstructs them from original parents on retry","pass_condition":"typed source SUBVIEWs on a decoded logical continuation return to their original parent bindings with unchanged temporary allocation count and charge after repeated pending-Q waits; readiness resumes using the offset views and cleans up, while expiring an original parent is rejected on retry before new temporary effects","related_sources":["asl/block/model/dispatch/tile-execution.asl","asl/block/model/operands/subview-descriptor.asl","asl/block/model/dispatch/execution-mask-schema.asl","asl/block/model/operands/portable-carriers.asl"]}
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
pure func LogicalSubview(source_select: boolean) => bits(64)
begin
    var instruction = Zeros{64} + 0x001000d3;
    instruction[31] = if source_select then '1' else '0';
    return instruction;
end;
readonly func LogicalMergeAllocatedCount() => integer {0..64}
begin
    var count: integer {0..64} = 0;
    for index = 0 to 63 do
        if _Tiles[[index]].allocated then
            count = (count + 1) as integer {0..64};
        end;
    end;
    return count;
end;
readonly func LogicalMergeAllocatedCharge() => integer {0..16777216}
begin
    var charge: integer {0..16777216} = 0;
    for index = 0 to 63 do
        if _Tiles[[index]].allocated then
            charge = (charge + _Tiles[[index]].capacity_bytes)
                as integer {0..16777216};
        end;
    end;
    return charge;
end;
func LogicalAssemblyWriter(init: boolean, last: boolean,
    offset: integer {0,1}, columns: integer {1..8},
    with_views: boolean, complete_ready: boolean, expect_wait: boolean)
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
    var view0 = CommandExecution_Executed;
    var view1 = CommandExecution_Executed;
    if with_views then
        view0 = ExecuteCommandInstruction(LogicalSubview(FALSE),32);
        view1 = ExecuteCommandInstruction(LogicalSubview(TRUE),32);
    end;
    var parent_ref = CommandExecution_Executed;
    if !init then
        parent_ref = ExecuteCommandInstruction(
            Zeros{64} + 0x01185e13, 32);
    end;
    let assembled = ExecuteCommandInstruction(
        LogicalAssemblyModifier(init,last,offset), 32);
    assert started == CommandExecution_Executed;
    assert attributes == CommandExecution_Executed;
    assert mask == CommandExecution_Executed;
    assert bound == CommandExecution_Executed;
    assert view0 == CommandExecution_Executed;
    assert view1 == CommandExecution_Executed;
    assert parent_ref == CommandExecution_Executed;
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
    _LocalGenerations[[slot]].parent_descriptor.layout = _Tiles[[destination]].layout;
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
        _LocalGenerations[[slot]].per_pe_working_destination[[pe]] = destination;
    end;
end;
func PrepareSubviewMergeWaitScenario(expire_parent: boolean)
begin
    ResetProfileState();
    let configured1 = ConfigurePredicateCellForMask(1,128,2,8,
        TileDataType_U32,TileLayout_CUBE_M16,'1111');
    let configured2 = ConfigurePredicateCellForMask(2,128,2,8,
        TileDataType_FP32,TileLayout_CUBE_M16,'1111');
    let configured3 = ConfigurePredicateCellForMask(3,256,2,11,
        TileDataType_U32,TileLayout_CUBE_M16,'1111');
    let configured4 = ConfigurePredicateCellForMask(4,256,2,11,
        TileDataType_FP32,TileLayout_CUBE_M16,'1111');
    let configuredq = ConfigurePredicateCellForMask(17,128,2,3,
        TileDataType_U32,TileLayout_CUBE_M16,'1111');
    assert configured1 && configured2 && configured3 && configured4 &&
           configuredq;
    for index = 1 to 4 do
        for row = 0 to 1 do
            for column = 0 to _Tiles[[index]].valid_columns - 1
                looplimit 11 do
                WriteTileElement(index as TileIndex,
                    row as integer {0..65535},
                    column as integer {0..65535},
                    Zeros{PTO_XLEN} + 1);
            end;
        end;
        MarkTileValidRegionDefined(index as TileIndex);
        InstallRelativeTileFixture(index as TileIndex,index as TileIndex);
    end;
    for row = 0 to 1 do
        for column = 0 to 2 do
            WriteTileElement(17,row as integer {0..65535},
                column as integer {0..65535},Zeros{PTO_XLEN} + 1);
        end;
    end;
    MarkTileValidRegionDefined(17);

    LogicalAssemblyWriter(TRUE,FALSE,0,8,FALSE,TRUE,FALSE);
    let parent_slot = BundleLocalGenerationSlot(1,'1111');
    let parent = _LocalGenerations[[parent_slot]].working_destination;
    let parent_capacity = _Tiles[[parent]].capacity_bytes;
    let q_slot: integer {0..63} = 60;
    InstallPendingPredicateCellGeneration(q_slot,17);
    assert BundleLocalGenerationSlotForDestination(17) == q_slot;
    InstallRelativeTileFixture(17,parent);
    InstallRelativeTileFixture(16,17);
    for pe = 0 to 3 do
        WritePEGPR(pe as MemoryAgentId,2,Zeros{PTO_XLEN} + 1);
    end;

    let count_before = LogicalMergeAllocatedCount();
    let charge_before = LogicalMergeAllocatedCharge();
    LogicalAssemblyWriter(FALSE,TRUE,1,3,TRUE,FALSE,TRUE);
    assert LogicalMergeAllocatedCount() == count_before;
    assert LogicalMergeAllocatedCharge() == charge_before;
    assert _BundleTileBindings[[0]].source0 == 3;
    assert _BundleTileBindings[[0]].source1 == 4;
    assert !_BundleTileBindings[[0]].source0_subview.materialized;
    assert !_BundleTileBindings[[0]].source1_subview.materialized;
    assert !_BundleTileBindings[[0]].source0_subview.derived.valid;
    assert !_BundleTileBindings[[0]].source1_subview.derived.valid;
    assert _BundleTileBindings[[0]].parent_ref_valid;
    assert _BundleTileBindings[[0]].parent_ref == parent;
    assert _BundleTileBindings[[0]].destination == parent;

    if expire_parent then
        ConsumeTilePayloadForMask(3,'1111');
        let retry = CompleteBundleAt(Zeros{PTO_XLEN} + 0x110);
        assert !retry && !_BundleExecutionMask.merge_base_waiting &&
               _LastFault == Fault_TileLegality;
        assert LogicalMergeAllocatedCount() + 1 == count_before;
        assert LogicalMergeAllocatedCharge() + parent_capacity == charge_before;
        assert _BundleTileBindings[[0]].source0 == 3 &&
               _BundleTileBindings[[0]].source1 == 4 &&
               !_BundleTileBindings[[0]].source0_subview.materialized &&
               !_BundleTileBindings[[0]].source1_subview.materialized &&
               !_BundleTileBindings[[0]].source0_subview.derived.valid &&
               !_BundleTileBindings[[0]].source1_subview.derived.valid &&
               _BundleTileBindings[[0]].parent_ref == parent &&
               _BundleTileBindings[[0]].destination == parent;
        return;
    end;

    let repeated_wait = CompleteBundleAt(Zeros{PTO_XLEN} + 0x110);
    assert !repeated_wait && _BundleExecutionMask.merge_base_waiting &&
           _LastFault == Fault_None;
    assert LogicalMergeAllocatedCount() == count_before;
    assert LogicalMergeAllocatedCharge() == charge_before;
    assert _BundleTileBindings[[0]].source0 == 3 &&
           _BundleTileBindings[[0]].source1 == 4 &&
           !_BundleTileBindings[[0]].source0_subview.materialized &&
           !_BundleTileBindings[[0]].source1_subview.materialized &&
           !_BundleTileBindings[[0]].source0_subview.derived.valid &&
           !_BundleTileBindings[[0]].source1_subview.derived.valid &&
           _BundleTileBindings[[0]].destination == parent &&
           _BundleTileBindings[[0]].parent_ref == parent;

    let q_writer = _LocalGenerations[[q_slot]].writers[[0]];
    let q_ready = CompleteBundleLocalGenerationWriterEvent(q_slot,
        q_writer.identity.execution_domain_token,q_writer.offset_cells,
        q_writer.cell_count as integer {1..2048});
    assert q_ready && _LocalGenerations[[q_slot]].published;
    let resumed = CompleteBundleAt(Zeros{PTO_XLEN} + 0x110);
    assert resumed && _LastFault == Fault_None;
    let p_ready = CompleteBundleLocalGenerationWriterEvent(parent_slot,
        _BundleExecutionDomainToken,1,1);
    assert p_ready && _LocalGenerations[[parent_slot]].published;
    assert LogicalMergeAllocatedCount() == count_before &&
           LogicalMergeAllocatedCharge() == charge_before;
    assert _Tiles[[parent]].valid_columns == 11 &&
           ReadTileElement(parent,0,8) == Zeros{PTO_XLEN} + 1 &&
           ReadTileElement(parent,0,9) == Zeros{PTO_XLEN} + 1;
end;
func main() => integer
begin
    PrepareSubviewMergeWaitScenario(FALSE);
    PrepareSubviewMergeWaitScenario(TRUE);
    return 0;
end;
