// PTO-TEST: {"id":"PTO-AVS-BLOCK-PREDICATECELL-LOGICAL-MERGE-PROVISIONAL-BASE-001","source":"asl/block/model/operands/local-generation-cube.asl","requirements":["PTO-B-ASSEMBLE-CUBE-PARENT-GEOMETRY-001","PTO-B-ASSEMBLE-CONSUMER-READINESS-001","PTO-TAND-CONTRACT-001"],"kind":"execution","summary":"A decoded PredicateCell MERGE waits on an open implicit base before inspecting its provisional descriptor","pass_condition":"an open newest-hand PredicateCell Local generation with a provisional 2x8 descriptor creates a non-faulting whole-parent wait for the decoded 2x3 continuation consumer without changing allocation state","related_sources":["asl/block/model/dispatch/execution-mask-schema.asl","asl/block/model/operands/local-generation.asl","asl/block/model/operands/portable-carriers.asl"]}
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
    assert started == CommandExecution_Executed &&
           attributes == CommandExecution_Executed &&
           mask == CommandExecution_Executed &&
           bound == CommandExecution_Executed &&
           parent == CommandExecution_Executed &&
           assembled == CommandExecution_Executed;
    let completed = CompleteBundleAt(Zeros{PTO_XLEN} + 0x100 + offset * 16);
    if expect_wait then
        assert !completed;
        assert _BundleExecutionMask.merge_base_waiting;
        assert _LastFault == Fault_None;
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
func main() => integer
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
    assert configured1 && configured2 && configured3 && configured4;
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

    // Keep P open, then place a real decoded INIT generation Q at hand distance
    // zero. Q's first writer leaves its provisional valid prefix at 2x8.
    LogicalAssemblyWriter(TRUE,FALSE,0,8,FALSE,FALSE);
    let parent_slot = BundleLocalGenerationSlot(1, '1111');
    let parent = _LocalGenerations[[parent_slot]].working_destination;
    LogicalAssemblyWriter(TRUE,FALSE,0,8,FALSE,FALSE);
    let q = _TileRelativeOrder[[1]][[0]];
    let q_slot = BundleLocalGenerationSlotForDestination(q);
    assert q != parent && q_slot < 64 &&
           _LocalGenerations[[q_slot]].open &&
           !_LocalGenerations[[q_slot]].descriptor_finalized &&
           _LocalGenerations[[q_slot]].writer_count == 1 &&
           !_LocalGenerations[[q_slot]].writers[[0]].ready &&
           _Tiles[[q]].valid_rows == 2 && _Tiles[[q]].valid_columns == 8;

    for pe = 0 to 3 do
        WritePEGPR(pe as MemoryAgentId,2,Zeros{PTO_XLEN} + 1);
    end;
    var allocated_before: integer {0..64} = 0;
    for index = 0 to 63 do
        if _Tiles[[index]].allocated then
            allocated_before = (allocated_before + 1) as integer {0..64};
        end;
    end;
    LogicalAssemblyWriter(FALSE,TRUE,1,3,FALSE,TRUE);
    assert _BundleExecutionMask.merge_base_generation_valid &&
           _BundleExecutionMask.merge_base == q &&
           _BundleExecutionMask.merge_base_generation_slot == q_slot &&
           _BundleExecutionMask.merge_base_generation_instance ==
               _LocalGenerations[[q_slot]].generation_instance &&
           _BundleExecutionMask
               .merge_base_writer_instruction_instance ==
               _LocalGenerations[[q_slot]].writers[[0]]
                   .identity.instruction_instance &&
           _BundleExecutionMask
               .merge_base_writer_execution_domain_token ==
               _LocalGenerations[[q_slot]].writers[[0]]
                   .identity.execution_domain_token;
    assert _LocalGenerations[[q_slot]].consumer_count == 1 &&
           _LocalGenerations[[q_slot]].consumers[[0]].state ==
               BundleConsumerDependency_Waiting &&
           _LocalGenerations[[q_slot]].open &&
           _LocalGenerations[[parent_slot]].open;
    var allocated_after: integer {0..64} = 0;
    for index = 0 to 63 do
        if _Tiles[[index]].allocated then
            allocated_after = (allocated_after + 1) as integer {0..64};
        end;
    end;
    assert allocated_after == allocated_before;
    return 0;
end;
