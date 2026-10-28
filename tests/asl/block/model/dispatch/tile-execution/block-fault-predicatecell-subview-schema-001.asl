// PTO-TEST: {"id":"PTO-AVS-BLOCK-PREDICATECELL-SUBVIEW-SCHEMA-FAULT-001","source":"asl/block/model/dispatch/tile-execution.asl","requirements":["PTO-B-SUBVIEW-DESCRIPTOR-001","PTO-TAND-CONTRACT-001"],"kind":"fault","summary":"Rejected predicate logical dimensions release typed views before trap capture","pass_condition":"invalid valid-column dimensions preserve parent allocations and replayable source bindings across fault and recovery without retaining view caches","related_sources":["asl/block/model/operands/subview-descriptor.asl","asl/arch/state/trap-context.asl"]}
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
pure func LogicalSubview(select: boolean) => bits(64)
begin
    var instruction = Zeros{64} + 0x001000d3;
    instruction[31] = if select then '1' else '0';
    return instruction;
end;
func main() => integer
begin
    ResetProfileState();
    let left = ConfigurePredicateCellForMask(1,256,2,11,TileDataType_U32,TileLayout_CUBE_M16,'1111');
    let right = ConfigurePredicateCellForMask(2,256,2,11,TileDataType_FP32,TileLayout_CUBE_M16,'1111');
    assert left && right;
    InstallRelativeTileFixture(1,1);
    InstallRelativeTileFixture(2,2);
    for row = 0 to 1 do
        for column = 0 to 10 do
            WriteTileElement(1,row as integer {0..65535},column as integer {0..65535},
                if column MOD 2 == 0 then Zeros{PTO_XLEN} + 1 else Zeros{PTO_XLEN});
            WriteTileElement(2,row as integer {0..65535},column as integer {0..65535},Zeros{PTO_XLEN} + 1);
        end;
    end;
    MarkTileValidRegionDefined(1); MarkTileValidRegionDefined(2);
    let started = ExecuteCommandInstruction(LogicalAssemblyStart(),32);
    let attrs = ExecuteCommandInstruction(Zeros{64} + 0x01f01fa3,32);
    SetBundleDimension(0,Zeros{PTO_XLEN} + 2);
    SetBundleDimension(1,Zeros{PTO_XLEN} + 2);
    SetBundleDimension(2,Zeros{PTO_XLEN} + 8);
    var binder = LogicalAssemblyInputs(TRUE);
    binder[18:15] = Zeros{4} + 1;
    binder[8:7] = Zeros{2};
    let bound = ExecuteCommandInstruction(binder,32);
    let view0 = ExecuteCommandInstruction(LogicalSubview(FALSE),32);
    let view1 = ExecuteCommandInstruction(LogicalSubview(TRUE),32);
    assert started == CommandExecution_Executed && attrs == CommandExecution_Executed &&
           bound == CommandExecution_Executed && view0 == CommandExecution_Executed && view1 == CommandExecution_Executed;
    let source_acr = CurrentACR();
    let fault_ring = TrapTargetForFault(source_acr);
    let completed = ExecuteBundleTileOperation();
    assert !completed && _LastFault == Fault_TileLegality;
    assert !_BundleTileBindings[[0]].source0_subview.materialized;
    assert !_BundleTileBindings[[0]].source1_subview.materialized;
    assert _BundleTileBindings[[0]].source0 == 1;
    assert _BundleTileBindings[[0]].source1 == 2;
    for index = 0 to 63 do
        assert _Tiles[[index]].allocated == (index == 1 || index == 2);
    end;
    assert CurrentACR() == fault_ring;
    let ring = fault_ring;
    assert !_TrapContexts[[ring]].bundle_tile_bindings[[0]].source0_subview.materialized;
    assert !_TrapContexts[[ring]].bundle_tile_bindings[[0]].source1_subview.materialized;
    assert _TrapContexts[[ring]].bundle_tile_bindings[[0]].source0 == 1 &&
           _TrapContexts[[ring]].bundle_tile_bindings[[0]].source1 == 2;
    assert _TrapContexts[[ring]].bundle_tile_bindings[[0]].source0_subview.valid &&
           _TrapContexts[[ring]].bundle_tile_bindings[[0]].source1_subview.valid;
    assert !_TrapContexts[[ring]].bundle_tile_bindings[[0]].source0_subview.derived.valid &&
           !_TrapContexts[[ring]].bundle_tile_bindings[[0]].source1_subview.derived.valid;
    assert _TrapContexts[[ring]].bundle_tile_bindings[[0]].source0_subview.materialized_index == 0 &&
           _TrapContexts[[ring]].bundle_tile_bindings[[0]].source1_subview.materialized_index == 0;
    assert _Tiles[[1]].capacity_bytes == 256 && _Tiles[[2]].capacity_bytes == 256;
    assert _Tiles[[1]].predicate_basis_type == TileDataType_U32 &&
           _Tiles[[2]].predicate_basis_type == TileDataType_FP32 &&
           ReadTileElement(1,0,8) == Zeros{PTO_XLEN} + 1;
    let recovered = RecoverTrapContext(fault_ring);
    assert recovered && CurrentACR() == source_acr;
    assert _BundleTileBindings[[0]].source0 == 1 &&
           _BundleTileBindings[[0]].source1 == 2 &&
           _BundleTileBindings[[0]].source0_subview.valid &&
           _BundleTileBindings[[0]].source1_subview.valid &&
           !_BundleTileBindings[[0]].source0_subview.materialized &&
           !_BundleTileBindings[[0]].source1_subview.materialized &&
           !_BundleTileBindings[[0]].source0_subview.derived.valid &&
           !_BundleTileBindings[[0]].source1_subview.derived.valid &&
           _BundleTileBindings[[0]].source0_subview.materialized_index == 0 &&
           _BundleTileBindings[[0]].source1_subview.materialized_index == 0;
    for index = 0 to 63 do
        assert _Tiles[[index]].allocated == (index == 1 || index == 2);
    end;
    return 0;
end;
