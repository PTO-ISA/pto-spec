// PTO-TEST: {"id":"PTO-AVS-BLOCK-PREDICATECELL-LOGICAL-BUNDLE-CONTROLS-001","source":"asl/block/model/dispatch/destination-operation.asl","requirements":["PTO-TAND-CONTRACT-001","PTO-B-ASSEMBLE-CUBE-PARENT-GEOMETRY-001"],"kind":"boundary","summary":"Decoded PredicateCell logical writers enforce bundle dimensions and selected layout before destination effects","pass_condition":"mismatched LB0, LB1, explicit LB2, omitted or incompatible layout reject; omitted LB2 remains capacity-derived","related_sources":["asl/block/model/dispatch/destination-shape.asl","asl/block/model/dispatch/tile-schema.asl","asl/block/model/dispatch/predicate-destination.asl"]}
pure func PredicateLogicalControlsStart() => bits(64)
begin
    var instruction = Zeros{64} + 0x00019181;
    instruction[24:20] = Zeros{5} + 6;
    instruction[31:27] = TileDataTypeToEncoding(TileDataType_U8);
    return instruction;
end;
pure func PredicateLogicalControlsInputs() => bits(64)
begin
    var instruction = Zeros{64} + 0x00004013;
    instruction[25:20] = Zeros{6} + 1;
    instruction[31:26] = Zeros{6} + 2;
    instruction[19] = '1';
    instruction[18:15] = Zeros{4} + 2;
    instruction[11:9] = '111';
    instruction[8:7] = '01';
    return instruction;
end;
pure func PredicateLogicalControlsAssemble() => bits(64)
begin
    var instruction = Zeros{64} + 0x00001053;
    instruction[31] = '1';
    instruction[11] = '1';
    instruction[10:7] = '0001';
    return instruction;
end;
readonly func PredicateLogicalAllocatedTileCount() => integer {0..64}
begin
    var count: integer {0..64} = 0;
    for index = 0 to 63 do
        if _Tiles[[index]].allocated then
            count = (count + 1) as integer {0..64};
        end;
    end;
    return count;
end;
func PreparePredicateLogicalControlSources()
begin
    let first = ConfigurePredicateCellForMask(1,128,2,8,
        TileDataType_U32,TileLayout_CUBE_M16,'1111');
    let second = ConfigurePredicateCellForMask(2,128,2,8,
        TileDataType_FP32,TileLayout_CUBE_M16,'1111');
    assert first && second;
    for row = 0 to 1 do
        for column = 0 to 7 do
            WriteTileElement(1,row as integer {0..65535},
                column as integer {0..65535},Zeros{PTO_XLEN} + 1);
            WriteTileElement(2,row as integer {0..65535},
                column as integer {0..65535},Zeros{PTO_XLEN} + 1);
        end;
    end;
    MarkTileValidRegionDefined(1);
    MarkTileValidRegionDefined(2);
    InstallRelativeTileFixture(1,1);
    InstallRelativeTileFixture(2,2);
end;
func PredicateLogicalControlRejects(
    lb0: integer {1..8}, lb1: integer {1..2}, lb2: integer {1..16},
    write_lb2: boolean, layout_mode: integer {0..2}) => boolean
begin
    ResetProfileState();
    PreparePredicateLogicalControlSources();
    let started = ExecuteCommandInstruction(PredicateLogicalControlsStart(),32);
    var attributes = CommandExecution_Executed;
    if layout_mode == 1 then
        attributes = ExecuteCommandInstruction(Zeros{64} + 0x01f01fa3,32);
    elsif layout_mode == 2 then
        attributes = ExecuteCommandInstruction(Zeros{64} + 0x01f01ea3,32);
    end;
    SetBundleDimension(0,Zeros{PTO_XLEN} + lb0);
    SetBundleDimension(1,Zeros{PTO_XLEN} + lb1);
    if write_lb2 then
        SetBundleDimension(2,Zeros{PTO_XLEN} + lb2);
    end;
    let bound = ExecuteCommandInstruction(PredicateLogicalControlsInputs(),32);
    let assembled = ExecuteCommandInstruction(PredicateLogicalControlsAssemble(),32);
    assert started == CommandExecution_Executed &&
           attributes == CommandExecution_Executed &&
           bound == CommandExecution_Executed &&
           assembled == CommandExecution_Executed;
    let allocated_before = PredicateLogicalAllocatedTileCount();
    let completed = CompleteBundleAt(Zeros{PTO_XLEN} + 0x100);
    return !completed && _LastFault == Fault_TileLegality &&
           PredicateLogicalAllocatedTileCount() == allocated_before;
end;
func PredicateLogicalOmittedLB2UsesCapacity() => boolean
begin
    ResetProfileState();
    PreparePredicateLogicalControlSources();
    let started = ExecuteCommandInstruction(PredicateLogicalControlsStart(),32);
    let attributes = ExecuteCommandInstruction(Zeros{64} + 0x01f01fa3,32);
    SetBundleDimension(0,Zeros{PTO_XLEN} + 8);
    SetBundleDimension(1,Zeros{PTO_XLEN} + 2);
    let bound = ExecuteCommandInstruction(PredicateLogicalControlsInputs(),32);
    let assembled = ExecuteCommandInstruction(PredicateLogicalControlsAssemble(),32);
    let completed = CompleteBundleAt(Zeros{PTO_XLEN} + 0x100);
    if started != CommandExecution_Executed ||
       attributes != CommandExecution_Executed ||
       bound != CommandExecution_Executed ||
       assembled != CommandExecution_Executed || !completed ||
       _LastFault != Fault_None then return FALSE; end;
    let slot = BundleLocalGenerationSlot(1, '1111');
    let ready = CompleteBundleLocalGenerationWriterEvent(
        slot, _BundleExecutionDomainToken, 0, 1);
    let parent = _LocalGenerations[[slot]].working_destination;
    return ready && _LocalGenerations[[slot]].published &&
           _Tiles[[parent]].columns == 16 &&
           _Tiles[[parent]].valid_columns == 8;
end;
func main() => integer
begin
    let bad_lb0 = PredicateLogicalControlRejects(7,2,8,TRUE,1);
    let bad_lb1 = PredicateLogicalControlRejects(8,1,8,TRUE,1);
    let bad_lb2 = PredicateLogicalControlRejects(8,2,7,TRUE,1);
    let wrong_layout = PredicateLogicalControlRejects(8,2,8,TRUE,2);
    let omitted_layout = PredicateLogicalControlRejects(8,2,8,TRUE,0);
    let omitted_lb2 = PredicateLogicalOmittedLB2UsesCapacity();
    assert bad_lb0;
    assert bad_lb1;
    assert bad_lb2;
    assert wrong_layout;
    assert omitted_layout;
    assert omitted_lb2;
    return 0;
end;
