// PTO-TEST: {"id":"PTO-AVS-BLOCK-PREDICATECELL-LOGICAL-MERGE-TRAP-SUBVIEW-001","source":"asl/block/model/operands/local-generation-cube.asl","requirements":["PTO-B-ASSEMBLE-CUBE-PARENT-GEOMETRY-001","PTO-B-SUBVIEW-DESCRIPTOR-001","PTO-TAND-CONTRACT-001"],"kind":"fault","summary":"A rejected PredicateCell MERGE saves replayable original SUBVIEW parents in TrapContext","pass_condition":"on a typed-view MERGE rejection, the saved fault context contains original allocated source parents and valid encoded views with cleared derived/materialized cache state; recovery does not revive released temporary Tiles, and the existing failed-generation abort releases its output destination","related_sources":["asl/arch/state/trap-context.asl","asl/block/model/dispatch/tile-execution.asl","asl/block/model/operands/subview-descriptor.asl"]}
pure func TrapSubviewAssemblyStart() => bits(64)
begin
    var instruction = Zeros{64} + 0x00019181;
    instruction[24:20] = Zeros{5} + 6;
    instruction[31:27] = TileDataTypeToEncoding(TileDataType_U8);
    return instruction;
end;
pure func TrapSubviewAssemblyInputs(init: boolean) => bits(64)
begin
    var instruction = Zeros{64} + 0x00004013;
    instruction[25:20] = if init then Zeros{6} + 1 else Zeros{6} + 3;
    instruction[31:26] = if init then Zeros{6} + 2 else Zeros{6} + 4;
    instruction[19] = if init then '1' else '0';
    instruction[18:15] = if init then Zeros{4} + 2 else Zeros{4};
    instruction[11:9] = '111';
    instruction[8:7] = if init then '01' else '00';
    return instruction;
end;
pure func TrapSubviewAssemblyModifier(init: boolean, last: boolean,
    offset: integer {0,1}) => bits(64)
begin
    var instruction = Zeros{64} + 0x00001053;
    instruction[31] = if init then '1' else '0';
    instruction[11] = if last then '1' else '0';
    instruction[10:7] = '0001';
    instruction[30:20] = Zeros{11} + offset;
    return instruction;
end;
pure func TrapSubviewInstruction(source_select: boolean) => bits(64)
begin
    var instruction = Zeros{64} + 0x001000d3;
    instruction[31] = if source_select then '1' else '0';
    return instruction;
end;
readonly func TrapSubviewTileCount() => integer {0..64}
begin
    var count: integer {0..64} = 0;
    for index = 0 to 63 do
        if _Tiles[[index]].allocated then
            count = (count + 1) as integer {0..64};
        end;
    end;
    return count;
end;
readonly func TrapSubviewTileCharge() => integer {0..16777216}
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
func TrapSubviewAssemblyWriter(init: boolean, last: boolean,
    offset: integer {0,1}, columns: integer {1..8}, with_views: boolean)
    => boolean
begin
    let started = ExecuteCommandInstruction(TrapSubviewAssemblyStart(), 32);
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
    let bound = ExecuteCommandInstruction(TrapSubviewAssemblyInputs(init), 32);
    var view0 = CommandExecution_Executed;
    var view1 = CommandExecution_Executed;
    if with_views then
        view0 = ExecuteCommandInstruction(TrapSubviewInstruction(FALSE),32);
        view1 = ExecuteCommandInstruction(TrapSubviewInstruction(TRUE),32);
    end;
    var parent_ref = CommandExecution_Executed;
    if !init then
        parent_ref = ExecuteCommandInstruction(Zeros{64} + 0x01185e13, 32);
    end;
    let assembled = ExecuteCommandInstruction(
        TrapSubviewAssemblyModifier(init,last,offset), 32);
    assert started == CommandExecution_Executed &&
           attributes == CommandExecution_Executed &&
           mask == CommandExecution_Executed &&
           bound == CommandExecution_Executed &&
           view0 == CommandExecution_Executed &&
           view1 == CommandExecution_Executed &&
           parent_ref == CommandExecution_Executed &&
           assembled == CommandExecution_Executed;
    return CompleteBundleAt(Zeros{PTO_XLEN} + 0x100 + offset * 16);
end;
func main() => integer
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
    assert configured1 && configured2 && configured3 && configured4;
    for index = 1 to 4 do
        for row = 0 to 1 do
            for column = 0 to _Tiles[[index]].valid_columns - 1
                looplimit 11 do
                WriteTileElement(index as TileIndex,
                    row as integer {0..65535},
                    column as integer {0..65535},
                    if column MOD 2 == 0 then Zeros{PTO_XLEN} + 1
                    else Zeros{PTO_XLEN});
            end;
        end;
        MarkTileValidRegionDefined(index as TileIndex);
        InstallRelativeTileFixture(index as TileIndex,index as TileIndex);
    end;
    let parent_init = TrapSubviewAssemblyWriter(TRUE,FALSE,0,8,FALSE);
    assert parent_init;
    let parent_slot = BundleLocalGenerationSlot(1,'1111');
    let parent = _LocalGenerations[[parent_slot]].working_destination;
    let parent_capacity = _Tiles[[parent]].capacity_bytes;
    let source_acr = CurrentACR();
    let fault_ring = TrapTargetForFault(source_acr);
    let q_ready = ConfigurePredicateCellForMask(17,128,2,3,
        TileDataType_U32,TileLayout_CUBE_M16,'1111');
    assert q_ready;
    for row = 0 to 1 do
        for column = 0 to 2 do
            WriteTileElement(17,row as integer {0..65535},
                column as integer {0..65535},Zeros{PTO_XLEN} + 1);
        end;
    end;
    // The ready direct hand Tile has a defined but noncanonical active byte.
    WriteTileElement(17,0,2,Zeros{PTO_XLEN} + 3);
    MarkTileValidRegionDefined(17);
    InstallRelativeTileFixture(17,parent);
    InstallRelativeTileFixture(16,17);
    for pe = 0 to 3 do
        WritePEGPR(pe as MemoryAgentId,2,Zeros{PTO_XLEN} + 1);
    end;
    let count_before = TrapSubviewTileCount();
    let charge_before = TrapSubviewTileCharge();
    let rejected = TrapSubviewAssemblyWriter(FALSE,TRUE,1,3,TRUE);
    assert !rejected;
    assert _LastFault == Fault_TileLegality;
    assert CurrentACR() == fault_ring;
    let count_after = TrapSubviewTileCount();
    let charge_after = TrapSubviewTileCharge();
    assert !_Tiles[[parent]].allocated && count_after == count_before - 1 &&
           charge_after == charge_before - parent_capacity;
    assert _BundleTileBindings[[0]].source0 == 3 &&
           _BundleTileBindings[[0]].source1 == 4 &&
           !_BundleTileBindings[[0]].source0_subview.materialized &&
           !_BundleTileBindings[[0]].source1_subview.materialized;
    assert _BundleTileBindings[[0]].parent_ref_valid;
    assert _BundleTileBindings[[0]].parent_ref == parent;

    // The authoritative fault snapshot must already contain the replayable
    // encoded views and their original allocated parents, never released temps.
    assert _TrapContexts[[fault_ring]].bundle_tile_bindings[[0]].source0 == 3 &&
           _TrapContexts[[fault_ring]].bundle_tile_bindings[[0]].source1 == 4;
    assert _TrapContexts[[fault_ring]].bundle_tile_bindings[[0]].source0_subview.valid &&
           _TrapContexts[[fault_ring]].bundle_tile_bindings[[0]].source1_subview.valid;
    assert !_TrapContexts[[fault_ring]].bundle_tile_bindings[[0]]
               .source0_subview.materialized &&
           !_TrapContexts[[fault_ring]].bundle_tile_bindings[[0]]
               .source1_subview.materialized;
    assert _TrapContexts[[fault_ring]].bundle_tile_bindings[[0]]
               .source0_subview.materialized_index == 0 &&
           _TrapContexts[[fault_ring]].bundle_tile_bindings[[0]]
               .source1_subview.materialized_index == 0;
    assert !_TrapContexts[[fault_ring]].bundle_tile_bindings[[0]]
               .source0_subview.derived.valid &&
           !_TrapContexts[[fault_ring]].bundle_tile_bindings[[0]]
               .source1_subview.derived.valid;
    assert _TrapContexts[[fault_ring]].bundle_tile_bindings[[0]].parent_ref_valid;
    assert _TrapContexts[[fault_ring]].bundle_tile_bindings[[0]].parent_ref == parent;
    assert _Tiles[[3]].allocated && _Tiles[[4]].allocated &&
           _Tiles[[17]].allocated;

    let recovered = RecoverTrapContext(fault_ring);
    assert recovered && CurrentACR() == source_acr;
    assert _BundleTileBindings[[0]].source0 == 3 &&
           _BundleTileBindings[[0]].source1 == 4 &&
           _BundleTileBindings[[0]].source0_subview.valid &&
           _BundleTileBindings[[0]].source1_subview.valid &&
           !_BundleTileBindings[[0]].source0_subview.materialized &&
           !_BundleTileBindings[[0]].source1_subview.materialized &&
           _BundleTileBindings[[0]].source0_subview.materialized_index == 0 &&
           _BundleTileBindings[[0]].source1_subview.materialized_index == 0;
    assert !_Tiles[[parent]].allocated &&
           TrapSubviewTileCount() == count_after &&
           TrapSubviewTileCharge() == charge_after;
    return 0;
end;
