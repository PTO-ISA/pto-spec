// PTO-TEST: {"id":"PTO-AVS-BLOCK-PREDICATECELL-LOGICAL-MERGE-FINALIZED-READINESS-001","source":"asl/block/model/operands/local-generation-cube.asl","requirements":["PTO-B-ASSEMBLE-CUBE-PARENT-GEOMETRY-001","PTO-B-ASSEMBLE-CONSUMER-READINESS-001","PTO-TAND-CONTRACT-001"],"kind":"execution","summary":"A decoded logical consumer waits for a finalized implicit base before reading its final descriptor and then resumes","pass_condition":"decoded Q INIT and LAST form a final 2x11 parent while writer readiness remains pending; a 2x11 continuation with an appended PredicateCell ExecutionMask waits without effects, resumes with the unchanged Q after both writers publish, and the same setup with final 2x10 Q waits first then rejects only after publication","related_sources":["asl/block/model/dispatch/execution-mask-schema.asl","asl/block/model/operands/local-generation.asl","asl/block/model/operands/portable-carriers.asl"]}
pure func LogicalAssemblyStart() => bits(64)
begin
    var instruction = Zeros{64} + 0x00019181;
    instruction[24:20] = Zeros{5} + 6;
    instruction[31:27] = TileDataTypeToEncoding(TileDataType_U8);
    return instruction;
end;
pure func LogicalAssemblyInputs(init: boolean,
    source0: integer {0..63}, source1: integer {0..63},
    parent_size: integer {0..12}) => bits(64)
begin
    var instruction = Zeros{64} + 0x00004013;
    instruction[25:20] = Zeros{6} + source0;
    instruction[31:26] = Zeros{6} + source1;
    instruction[19] = if init then '1' else '0';
    instruction[18:15] = if init then Zeros{4} + parent_size
        else Zeros{4};
    instruction[11:9] = '111'; instruction[8:7] = if init then '01' else '00';
    return instruction;
end;
pure func LogicalAssemblyModifier(init: boolean, last: boolean,
    offset: integer {0..2}, writer_size: integer {1..2}) => bits(64)
begin
    var instruction = Zeros{64} + 0x00001053;
    instruction[31] = if init then '1' else '0';
    instruction[11] = if last then '1' else '0';
    instruction[10:7] = Zeros{4} + writer_size;
    instruction[30:20] = Zeros{11} + offset;
    return instruction;
end;
pure func LogicalAssemblyParent(parent_selector: integer {0,1})
    => bits(64)
begin
    var instruction = Zeros{64} + 0x00005013;
    instruction[25:20] = Zeros{6} + (16 + parent_selector);
    instruction[19] = '1';
    instruction[11:9] = '111';
    return instruction;
end;
pure func LogicalAssemblyMaskAndParent(mask_source: integer {0..63},
    parent_selector: integer {0,1}) => bits(64)
begin
    var instruction = Zeros{64} + 0x00004013;
    instruction[25:20] = Zeros{6} + mask_source;
    instruction[31:26] = Zeros{6} + (16 + parent_selector);
    instruction[19] = '1';
    instruction[11:9] = '111';
    return instruction;
end;
func LogicalAssemblyBlock(init: boolean, last: boolean,
    offset: integer {0..2}, columns: integer {1..11}, physical_columns: integer {8,16},
    source0: integer {0..63}, source1: integer {0..63},
    parent_size: integer {0..12}, writer_size: integer {1..2},
    parent_selector: integer {0,1}, merge_mask: boolean,
    mask_source: integer {0..63}, expect_wait: boolean)
    => boolean
begin
    let started = ExecuteCommandInstruction(LogicalAssemblyStart(),32);
    let attributes = ExecuteCommandInstruction(Zeros{64} + 0x01f01fa3,32);
    SetBundleDimension(0,Zeros{PTO_XLEN} + columns);
    SetBundleDimension(1,Zeros{PTO_XLEN} + 2);
    SetBundleDimension(2,Zeros{PTO_XLEN} + physical_columns);
    assert !init || !merge_mask;
    let bound = ExecuteCommandInstruction(
        LogicalAssemblyInputs(init,source0,source1,parent_size),32);
    var parent = CommandExecution_Executed;
    if !init then
        let parent_source = if merge_mask then
            LogicalAssemblyMaskAndParent(mask_source,parent_selector)
            else LogicalAssemblyParent(parent_selector);
        parent = ExecuteCommandInstruction(parent_source,32);
    end;
    let assembled = ExecuteCommandInstruction(
        LogicalAssemblyModifier(init,last,offset,writer_size),32);
    assert started == CommandExecution_Executed;
    assert attributes == CommandExecution_Executed;
    assert bound == CommandExecution_Executed;
    assert parent == CommandExecution_Executed;
    assert assembled == CommandExecution_Executed;
    let completed = CompleteBundleAt(
        Zeros{PTO_XLEN} + 0x100 + offset * 16);
    if expect_wait then
        assert !completed && _LastFault == Fault_None &&
               _BundleExecutionMask.merge_base_waiting;
        return TRUE;
    end;
    return completed;
end;
func ConfigurePredicateSource(index: TileIndex,
    columns: integer {1..11}, pattern: integer {0..2})
begin
    let capacity = if columns > 8 then 256 else 128;
    let configured = ConfigurePredicateCellForMask(index,capacity,2,columns,
        TileDataType_U32,TileLayout_CUBE_M16,'1111');
    assert configured;
    for row = 0 to 1 do
        for column = 0 to columns - 1 looplimit 11 do
            var value = Zeros{PTO_XLEN};
            if pattern == 1 then
                value = Zeros{PTO_XLEN} + 1;
            elsif pattern == 2 && column MOD 2 == 0 then
                value = Zeros{PTO_XLEN} + 1;
            end;
            WriteTileElement(index,row as integer {0..65535},
                column as integer {0..65535},value);
        end;
    end;
    MarkTileValidRegionDefined(index);
    InstallRelativeTileFixture(index,index);
end;
func CompleteWriter(slot: integer {0..63}, ordinal: integer {0..1})
begin
    let writer = _LocalGenerations[[slot]].writers[[ordinal]];
    let ready = CompleteBundleLocalGenerationWriterEvent(slot,
        writer.identity.execution_domain_token,writer.offset_cells,
        writer.cell_count as integer {1..2048});
    assert ready;
end;
func RunFinalizedBaseScenario(final_columns: integer {10,11})
begin
    ResetProfileState();
    SelectExecutionContext(0,0);
    ConfigurePredicateSource(1,8,1);
    ConfigurePredicateSource(2,8,1);
    ConfigurePredicateSource(3,if final_columns == 11 then 3 else 2,0);
    ConfigurePredicateSource(4,if final_columns == 11 then 3 else 2,0);
    ConfigurePredicateSource(5,11,1);
    ConfigurePredicateSource(6,11,1);
    ConfigurePredicateSource(7,11,2);

    // P has one full-width 128-byte INIT writer. Q follows it at U#1 and
    // receives a decoded 2x8 INIT and a terminal 2x3 (or 2x2) LAST writer.
    let p_started = LogicalAssemblyBlock(TRUE,FALSE,0,8,8,1,2,3,1,0,
        FALSE,0,FALSE);
    assert p_started;
    let parent = _LocalGenerations[[BundleLocalGenerationSlot(1,'1111')]]
        .working_destination;
    let parent_slot = BundleLocalGenerationSlotForDestination(parent)
        as integer {0..63};
    CompleteWriter(parent_slot,0);
    let q_started = LogicalAssemblyBlock(TRUE,FALSE,0,8,8,1,2,2,1,0,
        FALSE,0,FALSE);
    assert q_started;
    let q = _TileRelativeOrder[[1]][[0]];
    let q_slot = BundleLocalGenerationSlotForDestination(q)
        as integer {0..63};
    assert q == _TileRelativeOrder[[1]][[0]] &&
           parent == _TileRelativeOrder[[1]][[1]];
    let q_finalized = LogicalAssemblyBlock(FALSE,TRUE,1,final_columns - 8,8,
        3,4,0,1,0,FALSE,0,FALSE);
    assert _LastFault == Fault_None;
    assert q_finalized;
    assert q == 17 && q_slot == 17 && q != parent &&
           _LocalGenerations[[q_slot]].closed &&
           _LocalGenerations[[q_slot]].descriptor_finalized &&
           !_LocalGenerations[[q_slot]].published &&
           _LocalGenerations[[q_slot]].writer_count == 2 &&
           !_LocalGenerations[[q_slot]].open &&
           _Tiles[[q]].valid_rows == 2 &&
           _Tiles[[q]].valid_columns == final_columns &&
           _Tiles[[q]].contents_defined &&
           !_LocalGenerations[[q_slot]].writers[[0]].ready &&
           !_LocalGenerations[[q_slot]].writers[[1]].ready;

    let waited = LogicalAssemblyBlock(FALSE,TRUE,1,11,16,5,6,0,2,1,
        TRUE,7,TRUE);
    assert waited;
    assert _BundleExecutionMask.merge_base_generation_valid &&
           _BundleExecutionMask.merge_base == q &&
           _LocalGenerations[[q_slot]].consumers[[0]].state ==
               BundleConsumerDependency_Waiting &&
           _LocalGenerations[[parent_slot]].open &&
           _LocalGenerations[[parent_slot]].writer_count == 1;

    CompleteWriter(q_slot,0);
    assert !_LocalGenerations[[q_slot]].published &&
           _LocalGenerations[[q_slot]].consumers[[0]].state ==
               BundleConsumerDependency_Waiting;
    CompleteWriter(q_slot,1);
    assert _LocalGenerations[[q_slot]].published &&
           _LocalGenerations[[q_slot]].consumers[[0]].state ==
               BundleConsumerDependency_Eligible;

    let resumed = CompleteBundleAt(Zeros{PTO_XLEN} + 0x110);
    if final_columns == 11 then
        assert resumed && _LastFault == Fault_None;
        CompleteWriter(parent_slot,1);
        assert _LocalGenerations[[parent_slot]].published &&
               _Tiles[[parent]].valid_columns == 19 &&
               ReadTileElement(parent,0,0) == Zeros{PTO_XLEN} + 1 &&
               ReadTileElement(parent,0,8) == Zeros{PTO_XLEN} + 1 &&
               ReadTileElement(parent,0,17) == Zeros{PTO_XLEN};
    else
        assert !resumed && !_BundleExecutionMask.merge_base_waiting &&
               _LastFault == Fault_TileLegality;
        assert _LocalGenerations[[q_slot]].published &&
               !_LocalGenerations[[parent_slot]].generation_identity_valid;
    end;
end;
func main() => integer
begin
    RunFinalizedBaseScenario(11);
    RunFinalizedBaseScenario(10);
    return 0;
end;
