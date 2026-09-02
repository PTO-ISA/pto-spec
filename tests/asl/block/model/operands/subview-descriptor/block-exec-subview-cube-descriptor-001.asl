// PTO-TEST: {"id":"PTO-AVS-BLOCK-SUBVIEW-CUBE-DESCRIPTOR-001","source":"asl/block/model/operands/subview-descriptor.asl","requirements":["PTO-B-SUBVIEW-DESCRIPTOR-001","PTO-INST-BLOCK-B-SUBVIEW","PTO-INST-BLOCK-B-ASSEMBLE","PTO-INST-BLOCK-B-IOT"],"kind":"execution","summary":"Decoded Local CUBE M16, M32, and N8 subviews derive bounded descriptors and preserve parent lifetime before normal operation commit.","pass_condition":"Decoded BSTART/B.IOT/B.SUBVIEW/B.ASSEMBLE reaches normal preflight and commit for M16 and M32 parents with N8 peers; the supplementary CELL-order matrix asserts interior, repeat-boundary, clipped-tail, min/max, selected values, and exact non-CUBE/zero-valid/OOB TileLegality faults.","related_sources":["asl/block/model/dispatch/tile-execution.asl","asl/tile/model/state/allocation.asl"]}
pure func StartTMATMULFP16() => bits(64)
begin
    var instruction = Zeros{64} + 0x00031181;
    instruction[31:27] = Zeros{5} + 4;
    return instruction;
end;

pure func FullLocalBinding() => bits(64)
begin
    var instruction = Zeros{64} + 0x00004013;
    instruction[31:26] = Zeros{6} + 2;
    instruction[25:20] = Zeros{6} + 1;
    instruction[19] = '1';
    instruction[18:15] = Zeros{4} + 1;
    instruction[11:9] = '111';
    instruction[8:7] = '00';
    return instruction;
end;

pure func Subview(source_select: boolean, size_code: integer,
                  offset: integer) => bits(64)
begin
    var instruction = Zeros{64} + 0x00000053;
    instruction[31] = if source_select then '1' else '0';
    instruction[10:7] = Zeros{4} + size_code;
    instruction[30:20] = Zeros{11} + offset;
    return instruction;
end;

pure func Assemble(init: boolean, last: boolean, parent_size: integer)
        => bits(64)
begin
    var instruction = Zeros{64} + 0x00001053;
    instruction[31] = if init then '1' else '0';
    instruction[11] = if last then '1' else '0';
    instruction[10:7] = Zeros{4} + parent_size;
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    let source0_ready = ConfigureCubeTileForMask(1, 128, 1, 1,
        TileDataType_FP16, TileLayout_CUBE_M16, TileLocation_Matrix, '1111');
    let source1_ready = ConfigureCubeTileForMask(2, 128, 1, 1,
        TileDataType_FP16, TileLayout_CUBE_N8, TileLocation_Matrix, '1111');
    assert source0_ready && source1_ready;
    InstallRelativeTileFixture(1, 1);
    InstallRelativeTileFixture(2, 2);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 6);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 7);
    let started = ExecuteCommandInstruction(StartTMATMULFP16(), 32);
    SetBundleFixedPointAttributeState(Zeros{6}, Zeros{3}, Zeros{4},
        FALSE, FALSE, FALSE, FALSE);
    let bound = ExecuteCommandInstruction(FullLocalBinding(), 32);
    let source0 = ExecuteCommandInstruction(Subview(FALSE, 1, 0), 32);
    let source1 = ExecuteCommandInstruction(Subview(TRUE, 1, 0), 32);
    let assembled = ExecuteCommandInstruction(Assemble(TRUE, TRUE, 1), 32);
    assert started == CommandExecution_Executed;
    assert bound == CommandExecution_Executed;
    assert source0 == CommandExecution_Executed;
    assert source1 == CommandExecution_Executed;
    assert assembled == CommandExecution_Executed;
    let completed = ExecuteBundleTileOperation();
    assert completed;
    assert _LastFault == Fault_None;
    let first_writer_completed = CompleteBundleLocalGenerationWriterEvent(
        BundleLocalGenerationSlot(0, '1111'), _BundleExecutionDomainToken, 0, 1);
    assert first_writer_completed;
    assert _Tiles[[1]].allocated && _Tiles[[2]].allocated;
    assert _BundleTileBindings[[0]].source0_subview.derived.valid;
    assert _BundleTileBindings[[0]].source1_subview.derived.valid;
    assert _BundleTileBindings[[0]].source0_subview.derived.parent == 1;
    assert _BundleTileBindings[[0]].source1_subview.derived.parent == 2;
    assert BundleReadSubviewElement(0, FALSE, 0, 0) ==
        Zeros{PTO_XLEN} + 6;
    assert BundleReadSubviewElement(0, TRUE, 0, 0) ==
        Zeros{PTO_XLEN} + 7;
    assert !_LocalGenerations[[BundleLocalGenerationSlot(0, '1111')]].open;
    assert _LocalGenerations[[BundleLocalGenerationSlot(0, '1111')]].closed;
    assert _LocalGenerations[[BundleLocalGenerationSlot(0, '1111')]].published;

    // A second decoded block exercises the M32 parent and the N8 source
    // through the same ordinary dispatch/binding/preflight/commit path.
    ResetProfileState();
    let m32_source_ready = ConfigureCubeTileForMask(1, 256, 1, 1,
        TileDataType_FP16, TileLayout_CUBE_M32, TileLocation_Matrix, '1111');
    let n8_source_ready = ConfigureCubeTileForMask(2, 128, 1, 1,
        TileDataType_FP16, TileLayout_CUBE_N8, TileLocation_Matrix, '1111');
    assert m32_source_ready && n8_source_ready;
    InstallRelativeTileFixture(1, 1);
    InstallRelativeTileFixture(2, 2);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 16);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 17);
    MarkTileValidRegionDefined(1);
    MarkTileValidRegionDefined(2);
    let m32_started = ExecuteCommandInstruction(StartTMATMULFP16(), 32);
    SetBundleFixedPointAttributeState(Zeros{6}, Zeros{3}, Zeros{4},
        FALSE, FALSE, FALSE, FALSE);
    let m32_bound = ExecuteCommandInstruction(FullLocalBinding(), 32);
    let m32_view0 = ExecuteCommandInstruction(Subview(FALSE, 1, 0), 32);
    let m32_view1 = ExecuteCommandInstruction(Subview(TRUE, 1, 0), 32);
    let m32_assembled = ExecuteCommandInstruction(Assemble(TRUE, TRUE, 1), 32);
    assert m32_started == CommandExecution_Executed &&
           m32_bound == CommandExecution_Executed &&
           m32_view0 == CommandExecution_Executed &&
           m32_view1 == CommandExecution_Executed &&
           m32_assembled == CommandExecution_Executed;
    let m32_completed = ExecuteBundleTileOperation();
    assert m32_completed && _LastFault == Fault_None;
    let m32_writer_completed = CompleteBundleLocalGenerationWriterEvent(
        BundleLocalGenerationSlot(0, '1111'), _BundleExecutionDomainToken, 0, 1);
    assert m32_writer_completed &&
        _LocalGenerations[[BundleLocalGenerationSlot(0, '1111')]].published;
    assert _BundleTileBindings[[0]].source0_subview.derived.valid &&
           _BundleTileBindings[[0]].source0_subview.derived.parent == 1 &&
           _BundleTileBindings[[0]].source1_subview.derived.parent == 2;
    assert BundleReadSubviewElement(0, FALSE, 0, 0) ==
        Zeros{PTO_XLEN} + 16 &&
        BundleReadSubviewElement(0, TRUE, 0, 0) ==
        Zeros{PTO_XLEN} + 17;
    assert _Tiles[[1]].allocated && _Tiles[[1]].contents_defined &&
           _Tiles[[2]].allocated && _Tiles[[2]].contents_defined;

    // The decoded success above establishes the normal operation path.  Keep
    // the pure descriptor boundary matrix beside it so each CELL-order
    // layout, repeat boundary, clipped tail, and encoded size extreme has an
    // exact observable without granting the helper architectural ownership.
    let m16 = ConfigureCubeTileForMask(3, 256, 1, 8,
        TileDataType_FP16, TileLayout_CUBE_M16, TileLocation_Matrix, '1111');
    let m32 = ConfigureCubeTileForMask(4, 256, 1, 4,
        TileDataType_FP16, TileLayout_CUBE_M32, TileLocation_Matrix, '1111');
    let n8 = ConfigureCubeTileForMask(5, 512, 16, 16,
        TileDataType_FP16, TileLayout_CUBE_N8, TileLocation_Matrix, '1111');
    let n8_tail = ConfigureCubeTileForMask(6, 512, 10, 9,
        TileDataType_FP16, TileLayout_CUBE_N8, TileLocation_Matrix, '1111');
    assert m16 && m32 && n8 && n8_tail;
    let m16_interior = BundleCubeSubviewDescriptorOf(3, Zeros{PTO_XLEN} + 1, 1);
    assert m16_interior.valid && m16_interior.origin_row == 0 &&
           m16_interior.origin_column == 4 &&
           m16_interior.valid_columns == 4;
    let m32_interior = BundleCubeSubviewDescriptorOf(4, Zeros{PTO_XLEN} + 1, 1);
    assert m32_interior.valid && m32_interior.origin_row == 0 &&
           m32_interior.origin_column == 2 &&
           m32_interior.valid_columns == 2;
    let n8_interior = BundleCubeSubviewDescriptorOf(5, Zeros{PTO_XLEN} + 1, 1);
    let n8_repeat_boundary = BundleCubeSubviewDescriptorOf(
        5, Zeros{PTO_XLEN} + 2, 1);
    assert n8_interior.valid && n8_interior.origin_row == 8 &&
           n8_interior.origin_column == 0 &&
           n8_repeat_boundary.valid && n8_repeat_boundary.origin_row == 0 &&
           n8_repeat_boundary.origin_column == 8;
    let n8_tail_view = BundleCubeSubviewDescriptorOf(
        6, Zeros{PTO_XLEN} + 1, 1);
    let n8_min_view = BundleCubeSubviewDescriptorOf(
        6, Zeros{PTO_XLEN}, 1);
    let n8_max_view = BundleCubeSubviewDescriptorOf(
        6, Zeros{PTO_XLEN}, 10);
    let m16_max_view = BundleCubeSubviewDescriptorOf(
        3, Zeros{PTO_XLEN}, 10);
    assert n8_tail_view.valid && n8_tail_view.valid_rows == 2 &&
           n8_tail_view.valid_columns == 8 && n8_min_view.valid &&
           n8_max_view.valid && m16_max_view.valid &&
           m16_max_view.cell_count == 2;
    assert BundleCubeSubviewDescriptorOf(
               5, Zeros{PTO_XLEN} + 4, 1).valid == FALSE;
    assert _Tiles[[3]].allocated && _Tiles[[4]].allocated &&
           _Tiles[[5]].allocated && _Tiles[[6]].allocated;

    // Ordinary decoded faults reject before destination effects for zero-valid
    // and out-of-bounds Local CUBE parents.
    ResetProfileState();
    let zero_parent = ConfigureCubeTileForMask(1, 128, 1, 1,
        TileDataType_FP16, TileLayout_CUBE_M16, TileLocation_Matrix, '1111');
    let zero_right = ConfigureCubeTileForMask(2, 128, 1, 1,
        TileDataType_FP16, TileLayout_CUBE_N8, TileLocation_Matrix, '1111');
    assert zero_parent && zero_right;
    InstallRelativeTileFixture(1, 1);
    InstallRelativeTileFixture(2, 2);
    _Tiles[[1]].valid_rows = 0;
    let zero_start = ExecuteCommandInstruction(StartTMATMULFP16(), 32);
    SetBundleFixedPointAttributeState(Zeros{6}, Zeros{3}, Zeros{4},
        FALSE, FALSE, FALSE, FALSE);
    let zero_bound = ExecuteCommandInstruction(FullLocalBinding(), 32);
    let zero_view0 = ExecuteCommandInstruction(Subview(FALSE, 1, 0), 32);
    let zero_view1 = ExecuteCommandInstruction(Subview(TRUE, 1, 0), 32);
    let zero_assemble = ExecuteCommandInstruction(Assemble(TRUE, TRUE, 1), 32);
    assert zero_start == CommandExecution_Executed &&
           zero_bound == CommandExecution_Executed &&
           zero_view0 == CommandExecution_Executed &&
           zero_view1 == CommandExecution_Executed &&
           zero_assemble == CommandExecution_Executed;
    let zero_completed = ExecuteBundleTileOperation();
    assert !zero_completed && _LastFault == Fault_TileLegality &&
           _Tiles[[1]].allocated && !_Tiles[[0]].allocated;

    ResetProfileState();
    let oob_parent = ConfigureCubeTileForMask(1, 128, 1, 1,
        TileDataType_FP16, TileLayout_CUBE_M16, TileLocation_Matrix, '1111');
    let oob_right = ConfigureCubeTileForMask(2, 128, 1, 1,
        TileDataType_FP16, TileLayout_CUBE_N8, TileLocation_Matrix, '1111');
    assert oob_parent && oob_right;
    InstallRelativeTileFixture(1, 1);
    InstallRelativeTileFixture(2, 2);
    let oob_start = ExecuteCommandInstruction(StartTMATMULFP16(), 32);
    SetBundleFixedPointAttributeState(Zeros{6}, Zeros{3}, Zeros{4},
        FALSE, FALSE, FALSE, FALSE);
    let oob_bound = ExecuteCommandInstruction(FullLocalBinding(), 32);
    let oob_view0 = ExecuteCommandInstruction(Subview(FALSE, 1, 1), 32);
    let oob_view1 = ExecuteCommandInstruction(Subview(TRUE, 1, 0), 32);
    let oob_assemble = ExecuteCommandInstruction(Assemble(TRUE, TRUE, 1), 32);
    assert oob_start == CommandExecution_Executed &&
           oob_bound == CommandExecution_Executed &&
           oob_view0 == CommandExecution_Executed &&
           oob_view1 == CommandExecution_Executed &&
           oob_assemble == CommandExecution_Executed;
    let oob_completed = ExecuteBundleTileOperation();
    assert !oob_completed && _LastFault == Fault_TileLegality &&
           _Tiles[[1]].allocated && !_Tiles[[0]].allocated;
    return 0;
end;
