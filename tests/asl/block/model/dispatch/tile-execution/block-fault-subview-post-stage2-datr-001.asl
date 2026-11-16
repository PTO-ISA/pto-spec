// PTO-TEST: {"id":"PTO-AVS-BLOCK-SUBVIEW-POST-STAGE2-DATR-FAULT-001","source":"asl/block/model/dispatch/tile-execution.asl","requirements":["PTO-B-SUBVIEW-DESCRIPTOR-001","PTO-TAND-CONTRACT-001"],"kind":"fault","summary":"A post-stage2 DATR fault snapshots architectural SUBVIEW parents and releases both temporaries","pass_condition":"invalid ExecutionMask ZERO control after two valid views preserves original source bindings with cleared derived caches in live and saved state and releases both materialized Tiles","related_sources":["asl/arch/state/trap-context.asl","asl/block/model/dispatch/tile-schema.asl","asl/block/model/dispatch/gm-obligation-dispatch.asl","asl/block/model/operands/subview-descriptor.asl"]}
pure func PostStage2SubviewStart() => bits(64)
begin
    var instruction = Zeros{64} + 0x00019181;
    instruction[24:20] = Zeros{5} + 6;
    instruction[31:27] = TileDataTypeToEncoding(TileDataType_U8);
    return instruction;
end;

pure func PostStage2SubviewInputs() => bits(64)
begin
    var instruction = Zeros{64} + 0x00004013;
    instruction[25:20] = Zeros{6} + 1;
    instruction[31:26] = Zeros{6} + 2;
    instruction[19] = '1';
    instruction[18:15] = Zeros{4} + 1;
    instruction[11:9] = '111';
    return instruction;
end;

pure func PostStage2Subview(select: boolean) => bits(64)
begin
    var instruction = Zeros{64} + 0x001000d3;
    instruction[31] = if select then '1' else '0';
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    let left = ConfigurePredicateCellForMask(1,256,2,11,
        TileDataType_U32,TileLayout_CUBE_M16,'1111');
    let right = ConfigurePredicateCellForMask(2,256,2,11,
        TileDataType_FP32,TileLayout_CUBE_M16,'1111');
    assert left && right;
    InstallRelativeTileFixture(1,1);
    InstallRelativeTileFixture(2,2);
    for row = 0 to 1 do
        for column = 0 to 10 do
            WriteTileElement(1,row as integer {0..65535},
                column as integer {0..65535},Zeros{PTO_XLEN} + 1);
            WriteTileElement(2,row as integer {0..65535},
                column as integer {0..65535},Zeros{PTO_XLEN} + 1);
        end;
    end;
    MarkTileValidRegionDefined(1);
    MarkTileValidRegionDefined(2);

    let started = ExecuteCommandInstruction(PostStage2SubviewStart(),32);
    var datr = Zeros{64} + 0x01f01fa3;
    datr[13] = '1';
    let attributes = ExecuteCommandInstruction(datr,32);
    SetBundleDimension(0,Zeros{PTO_XLEN} + 3);
    SetBundleDimension(1,Zeros{PTO_XLEN} + 2);
    SetBundleDimension(2,Zeros{PTO_XLEN} + 8);
    let bound = ExecuteCommandInstruction(PostStage2SubviewInputs(),32);
    let first_view =
        ExecuteCommandInstruction(PostStage2Subview(FALSE),32);
    let second_view =
        ExecuteCommandInstruction(PostStage2Subview(TRUE),32);
    assert started == CommandExecution_Executed &&
           attributes == CommandExecution_Executed &&
           bound == CommandExecution_Executed &&
           first_view == CommandExecution_Executed &&
           second_view == CommandExecution_Executed;

    let source_acr = CurrentACR();
    let fault_ring = TrapTargetForFault(source_acr);
    let completed = ExecuteBundleTileOperation();
    assert !completed && _LastFault == Fault_TileLegality;
    assert CurrentACR() == fault_ring;
    assert _BundleTileBindings[[0]].source0 == 1 &&
           _BundleTileBindings[[0]].source1 == 2;
    assert !_BundleTileBindings[[0]].source0_subview.materialized &&
           !_BundleTileBindings[[0]].source1_subview.materialized &&
           !_BundleTileBindings[[0]].source0_subview.derived.valid &&
           !_BundleTileBindings[[0]].source1_subview.derived.valid &&
           _BundleTileBindings[[0]].source0_subview.materialized_index == 0 &&
           _BundleTileBindings[[0]].source1_subview.materialized_index == 0;
    assert _TrapContexts[[fault_ring]].bundle_tile_bindings[[0]].source0 == 1 &&
           _TrapContexts[[fault_ring]].bundle_tile_bindings[[0]].source1 == 2;
    assert !_TrapContexts[[fault_ring]].bundle_tile_bindings[[0]]
               .source0_subview.materialized &&
           !_TrapContexts[[fault_ring]].bundle_tile_bindings[[0]]
               .source1_subview.materialized &&
           !_TrapContexts[[fault_ring]].bundle_tile_bindings[[0]]
               .source0_subview.derived.valid &&
           !_TrapContexts[[fault_ring]].bundle_tile_bindings[[0]]
               .source1_subview.derived.valid &&
           _TrapContexts[[fault_ring]].bundle_tile_bindings[[0]]
               .source0_subview.materialized_index == 0 &&
           _TrapContexts[[fault_ring]].bundle_tile_bindings[[0]]
               .source1_subview.materialized_index == 0;
    for index = 0 to 63 do
        assert _Tiles[[index]].allocated == (index == 1 || index == 2);
    end;
    let recovered = RecoverTrapContext(fault_ring);
    assert recovered && CurrentACR() == source_acr;
    assert _BundleTileBindings[[0]].source0 == 1 &&
           _BundleTileBindings[[0]].source1 == 2;
    return 0;
end;
