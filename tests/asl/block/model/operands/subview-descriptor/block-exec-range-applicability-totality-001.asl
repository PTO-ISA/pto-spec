// PTO-TEST: {"id":"PTO-AVS-BLOCK-RANGE-APPLICABILITY-TOTALITY-001","source":"asl/block/model/operands/subview-descriptor.asl","requirements":["PTO-B-SUBVIEW-DESCRIPTOR-001","PTO-BLOCK-TILE-OPERATION-APPLICABILITY-001"],"kind":"execution","summary":"Decoded CUBE range carriers reach normal dispatch while selected operation legality remains authoritative; the operation-index totality matrix is supplemental.","pass_condition":"A decoded legal CUBE source/destination group reaches descriptor preflight and commit, an incompatible Local dtype/layout group reports TileLegality before effects, and the supplemental accepted-operation matrix has no private family allowlist.","related_sources":["asl/block/model/dispatch/tile-execution.asl","asl/block/model/dispatch/tile-schema.asl"]}
pure func Start() => bits(64)
begin
    var instruction = Zeros{64} + 0x00031181;
    instruction[31:27] = Zeros{5} + 4;
    return instruction;
end;
pure func Binding() => bits(64)
begin
    var instruction = Zeros{64} + 0x00004013;
    instruction[31:26] = Zeros{6} + 2;
    instruction[25:20] = Zeros{6} + 1;
    instruction[19] = '1'; instruction[18:15] = Zeros{4} + 1;
    instruction[11:9] = '111'; instruction[8:7] = '00';
    return instruction;
end;
pure func View(select: boolean) => bits(64)
begin
    var instruction = Zeros{64} + 0x00000053;
    instruction[31] = if select then '1' else '0';
    instruction[10:7] = Zeros{4} + 1;
    return instruction;
end;
pure func Assemble() => bits(64)
begin
    var instruction = Zeros{64} + 0x00001053;
    instruction[31] = '1'; instruction[11] = '1';
    instruction[10:7] = Zeros{4} + 1;
    return instruction;
end;
func main() => integer
begin
    ResetProfileState();
    let a_ready = ConfigureCubeTileForMask(1, 128, 1, 1,
        TileDataType_FP16, TileLayout_CUBE_M16, TileLocation_Matrix, '1111');
    let b_ready = ConfigureCubeTileForMask(2, 128, 1, 1,
        TileDataType_FP16, TileLayout_CUBE_N8, TileLocation_Matrix, '1111');
    assert a_ready && b_ready;
    InstallRelativeTileFixture(1, 1);
    InstallRelativeTileFixture(2, 2);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 2);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 3);
    for operation = 0 to PTO_TILE_OPERATION_COUNT - 1 looplimit 109 do
        assert BundleSubviewOperationApplicabilityIsTotal(operation);
    end;
    let started = ExecuteCommandInstruction(Start(), 32);
    SetBundleFixedPointAttributeState(Zeros{6}, Zeros{3}, Zeros{4},
        FALSE, FALSE, FALSE, FALSE);
    let bound = ExecuteCommandInstruction(Binding(), 32);
    let view0 = ExecuteCommandInstruction(View(FALSE), 32);
    let view1 = ExecuteCommandInstruction(View(TRUE), 32);
    let assembled = ExecuteCommandInstruction(Assemble(), 32);
    assert started == CommandExecution_Executed &&
           bound == CommandExecution_Executed &&
           view0 == CommandExecution_Executed &&
           view1 == CommandExecution_Executed &&
           assembled == CommandExecution_Executed;
    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
    let writer_completed = CompleteBundleLocalGenerationWriterEvent(
        BundleLocalGenerationSlot(0, '1111'), _BundleExecutionDomainToken, 0, 1);
    assert writer_completed &&
        _LocalGenerations[[BundleLocalGenerationSlot(0, '1111')]].published;

    ResetProfileState();
    ConfigureTileForMask(1, 128, 1, 1, 1, 1,
        TileDataType_FP16, TileLayout_RowMajor, TileLocation_Any, '1111');
    InstallRelativeTileFixture(1, 1);
    assert _Tiles[[1]].allocated;
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 1);
    let bad_start = ExecuteCommandInstruction(Start(), 32);
    SetBundleFixedPointAttributeState(Zeros{6}, Zeros{3}, Zeros{4},
        FALSE, FALSE, FALSE, FALSE);
    let bad_binding = ExecuteCommandInstruction(Binding(), 32);
    let bad_view = ExecuteCommandInstruction(View(FALSE), 32);
    let bad_assemble = ExecuteCommandInstruction(Assemble(), 32);
    assert bad_start == CommandExecution_Executed &&
           bad_binding == CommandExecution_Executed &&
           bad_view == CommandExecution_Executed &&
           bad_assemble == CommandExecution_Executed;
    let rejected = ExecuteBundleTileOperation();
    assert !rejected && _LastFault == Fault_TileLegality;
    assert _Tiles[[1]].allocated && _Tiles[[1]].contents_defined;
    return 0;
end;
