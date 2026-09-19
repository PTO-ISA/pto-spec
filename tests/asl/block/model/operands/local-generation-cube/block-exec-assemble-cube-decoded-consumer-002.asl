// PTO-TEST: {"id":"PTO-AVS-BLOCK-ASSEMBLE-CUBE-DECODED-CONSUMER-002","source":"asl/block/model/operands/local-generation-cube.asl","requirements":["PTO-B-ASSEMBLE-CUBE-PARENT-GEOMETRY-001","PTO-INST-BLOCK-B-IOT","PTO-INST-BLOCK-B-ASSEMBLE","PTO-INST-BLOCK-BSTART-TMATMULMX"],"kind":"execution","summary":"Decoded Local B.IOT/B.ASSEMBLE INIT_LAST and multi-writer generations validate materialized CUBE writers before delayed publication and Local-A TMATMULMX consumption.","pass_condition":"Decoded 32x32 E2M1X2 writers with 512-byte envelopes complete explicitly; INIT_LAST publishes one capacity-slack parent, four writers at CELL offsets 0, 4, 8, and 12 publish 32x128 only after every writer event, Local-A TMATMULMX accepts M=32,K=128, and out-of-bounds or last-writer dtype/layout/row/tail mismatches roll back without partial publication.","related_sources":["asl/block/model/operands/local-generation.asl","asl/block/model/operands/portable-carriers.asl","asl/block/model/dispatch/cube-tmatmul.asl"]}
pure func CubeDecodedStartTMOV() => bits(64)
begin
    return Zeros{64} + 0x20419181;
end;
pure func CubeDecodedLocalBinder(init: boolean, last: boolean) => bits(64)
begin
    var instruction = Zeros{64} + 0x00004013;
    instruction[31:26] = Zeros{6} + 2;
    instruction[25:20] = Zeros{6} + 1;
    instruction[19] = if last then '1' else '0';
    instruction[18:15] = '0101';
    instruction[11:9] = '101'; instruction[8:7] = '00';
    return instruction;
end;
pure func CubeDecodedParentBinder(parent: integer) => bits(64)
begin
    var instruction = Zeros{64} + 0x00005013;
    instruction[25:20] = Zeros{6} + parent;
    instruction[19] = '1';
    instruction[11:9] = '101';
    return instruction;
end;
pure func CubeDecodedAssemble(init: boolean, last: boolean, offset: integer) => bits(64)
begin
    var instruction = Zeros{64} + 0x00001053;
    instruction[31] = if init then '1' else '0';
    instruction[11] = if last then '1' else '0';
    instruction[10:7] = Zeros{4} + 3;
    instruction[30:20] = Zeros{11} + offset;
    return instruction;
end;
func CubeDecodedPrepareSources()
begin
    let source0 = ConfigureCubeTileForMaskWithPhysical(1, 512,
        32, 32, 32, 32, TileDataType_E2M1X2,
        TileLayout_CUBE_M32, '1111');
    let source1 = ConfigureCubeTileForMaskWithPhysical(2, 512,
        32, 32, 32, 32, TileDataType_E2M1X2,
        TileLayout_CUBE_M32, '1111');
    assert source0 && source1;
    MarkTileValidRegionDefined(1);
    MarkTileValidRegionDefined(2);
end;
func CubeDecodedBeginBundle()
begin
    let started = ExecuteCommandInstruction(CubeDecodedStartTMOV(), 32);
    assert started == CommandExecution_Executed;
    SetBundleDataAttributeState(Zeros{5} + 11, Zeros{5} + 29,
        Zeros{2}, Zeros{3}, Zeros{3}, FALSE, FALSE);
    _BundleDataAttributesPresent = TRUE;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 32);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 32);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 32);
end;
func CubeDecodedRunWriter(init: boolean, last: boolean, offset: integer)
begin
    CubeDecodedBeginBundle();
    let bound = ExecuteCommandInstruction(CubeDecodedLocalBinder(init, FALSE), 32);
    var parent_bound = CommandExecution_Executed;
    if !init then
        parent_bound = ExecuteCommandInstruction(CubeDecodedParentBinder(0), 32);
    end;
    let assembled = ExecuteCommandInstruction(
        CubeDecodedAssemble(init, last, offset), 32);
    assert bound == CommandExecution_Executed &&
           parent_bound == CommandExecution_Executed &&
           assembled == CommandExecution_Executed;
    assert _BundleTileBindings[[0]].destination_assemble.valid;
    assert _BundleTileBindings[[0]].destination_assemble.init == init;
    assert _BundleTileBindings[[0]].destination_assemble.last == last;
    if !init then assert _BundleTileBindings[[0]].parent_ref_valid; end;
    let completed = CompleteBundleAt(
        Zeros{PTO_XLEN} + (0x800 + offset * 0x10));
    assert completed && _LastFault == Fault_None;
    let slot = BundleLocalGenerationSlot(0, '1111');
    let writer = (_LocalGenerations[[slot]].writer_count - 1)
        as integer {0..15};
    assert !_LocalGenerations[[slot]].writers[[writer]].ready;
    if last then assert !_LocalGenerations[[slot]].published; end;
    let writer_completed = CompleteBundleLocalGenerationWriterEvent(
        slot, _BundleExecutionDomainToken, offset, 4);
    assert writer_completed &&
           _LocalGenerations[[slot]].writers[[writer]].ready;
    if last then assert _LocalGenerations[[slot]].published; end;
end;
func CubeDecodedRunBadWriter()
begin
    CubeDecodedBeginBundle();
    let bound = ExecuteCommandInstruction(CubeDecodedLocalBinder(FALSE, FALSE), 32);
    let parent_bound = ExecuteCommandInstruction(CubeDecodedParentBinder(0), 32);
    let assembled = ExecuteCommandInstruction(CubeDecodedAssemble(FALSE, FALSE, 16), 32);
    assert bound == CommandExecution_Executed &&
           parent_bound == CommandExecution_Executed &&
           assembled == CommandExecution_Executed;
    let completed = CompleteBundleAt(Zeros{PTO_XLEN} + 0x900);
    assert !completed && _LastFault == Fault_TileLegality;
end;
func CubeDecodedRunBadLast(offset: integer)
begin
    CubeDecodedBeginBundle();
    let bound = ExecuteCommandInstruction(
        CubeDecodedLocalBinder(FALSE, FALSE), 32);
    let parent_bound = ExecuteCommandInstruction(
        CubeDecodedParentBinder(0), 32);
    let assembled = ExecuteCommandInstruction(
        CubeDecodedAssemble(FALSE, TRUE, offset), 32);
    assert bound == CommandExecution_Executed &&
           parent_bound == CommandExecution_Executed &&
           assembled == CommandExecution_Executed;
    let completed = CompleteBundleAt(
        Zeros{PTO_XLEN} + (0xa00 + offset * 0x10));
    assert !completed && _LastFault == Fault_TileLegality;
end;
func CubeDecodedRunConsumer(parent: TileIndex)
begin
    let b_ready = ConfigureCubeTileForMask(3, 2048, 128, 1,
        TileDataType_E2M1X2, TileLayout_CUBE_N8, '1111');
    let a_scale_ready = ConfigureCubeTileForMask(4, 512, 32, 4,
        TileDataType_E8M0, TileLayout_CUBE_M32, '1111');
    let b_scale_ready = ConfigureCubeTileForMask(5, 512, 1, 4,
        TileDataType_E8M0, TileLayout_CUBE_M32, '1111');
    assert b_ready && a_scale_ready && b_scale_ready;
    MarkTileValidRegionDefined(3);
    MarkTileValidRegionDefined(4);
    MarkTileValidRegionDefined(5);
    var start = Zeros{64} + 0x00431181;
    start[31:27] = Zeros{5} + 11;
    let started = ExecuteCommandInstruction(start, 32);
    assert started == CommandExecution_Executed;
    SetBundleFixedPointAttributeState(
        Zeros{6}, Zeros{3}, Zeros{4}, FALSE, FALSE, FALSE, FALSE);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 32);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 128);
    assert UInt(_BundleDimensions[[0]]) == 32 &&
           UInt(_BundleDimensions[[1]]) == 1 &&
           UInt(_BundleDimensions[[2]]) == 128;
    AddBundleTileBinding(FALSE, 0, 0, '1111', TRUE, TRUE,
        parent, 4, FALSE);
    AddBundleTileBinding(TRUE, 0, 1, '1111', TRUE, TRUE,
        3, 5, TRUE);
    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
end;
func main() => integer
begin
    ResetProfileState();
    CubeDecodedPrepareSources();
    CubeDecodedRunWriter(TRUE, FALSE, 0);
    let slot = BundleLocalGenerationSlot(0, '1111');
    let parent = _LocalGenerations[[slot]].working_destination;
    assert _Tiles[[parent]].layout == TileLayout_CUBE_M32;
    assert _Tiles[[parent]].rows == 32 && _Tiles[[parent]].columns == 32;
    CubeDecodedRunWriter(FALSE, FALSE, 4);
    CubeDecodedRunWriter(FALSE, FALSE, 8);
    CubeDecodedRunWriter(FALSE, TRUE, 12);
    assert _LocalGenerations[[slot]].closed &&
           _LocalGenerations[[slot]].published &&
           _LocalGenerations[[slot]].descriptor_finalized;
    assert _Tiles[[parent]].capacity_bytes == 2048;
    assert _Tiles[[parent]].rows == 32 && _Tiles[[parent]].columns == 128;
    assert _Tiles[[parent]].valid_rows == 32 &&
           _Tiles[[parent]].valid_columns == 128;
    assert _Tiles[[parent]].cube_cell_count == 16;
    assert _LocalGenerations[[slot]].writer_count == 4;
    for writer = 0 to 3 do
        assert _LocalGenerations[[slot]].writers[[writer]].cell_count == 4 &&
               _LocalGenerations[[slot]].writers[[writer]].physical_rows == 32 &&
               _LocalGenerations[[slot]].writers[[writer]].physical_columns == 32;
    end;
    CubeDecodedRunConsumer(parent);

    // A decoded INIT_LAST validates the newly materialized 32x32 writer, not
    // the pre-allocation destination placeholder. Capacity slack is legal and
    // publication waits for the writer-completion event.
    ResetProfileState();
    CubeDecodedPrepareSources();
    CubeDecodedRunWriter(TRUE, TRUE, 0);
    let init_last_slot = BundleLocalGenerationSlot(0, '1111');
    let init_last_parent =
        _LocalGenerations[[init_last_slot]].published_destination;
    assert _LocalGenerations[[init_last_slot]].descriptor_finalized &&
           _LocalGenerations[[init_last_slot]].published &&
           _Tiles[[init_last_parent]].capacity_bytes == 2048 &&
           _Tiles[[init_last_parent]].rows == 32 &&
           _Tiles[[init_last_parent]].columns == 32;

    ResetProfileState();
    CubeDecodedPrepareSources();
    CubeDecodedRunWriter(TRUE, FALSE, 0);
    let bad_slot = BundleLocalGenerationSlot(0, '1111');
    let bad_parent = _LocalGenerations[[bad_slot]].working_destination;
    CubeDecodedRunBadWriter();
    assert !_LocalGenerations[[bad_slot]].open &&
           !_LocalGenerations[[bad_slot]].descriptor_finalized &&
           !_LocalGenerations[[bad_slot]].published;
    assert _Tiles[[bad_parent]].allocated == FALSE;

    // A decoded LAST must agree with every retained writer descriptor. Each
    // mismatch faults before registering the last writer or finalizing the
    // parent descriptor.
    ResetProfileState();
    CubeDecodedPrepareSources();
    CubeDecodedRunWriter(TRUE, FALSE, 0);
    let dtype_slot = BundleLocalGenerationSlot(0, '1111');
    _LocalGenerations[[dtype_slot]].writers[[0]].data_type =
        TileDataType_FP16;
    CubeDecodedRunBadLast(4);
    assert !_LocalGenerations[[dtype_slot]].published;

    ResetProfileState();
    CubeDecodedPrepareSources();
    CubeDecodedRunWriter(TRUE, FALSE, 0);
    let layout_slot = BundleLocalGenerationSlot(0, '1111');
    _LocalGenerations[[layout_slot]].writers[[0]].layout =
        TileLayout_CUBE_M16;
    CubeDecodedRunBadLast(4);
    assert !_LocalGenerations[[layout_slot]].published;

    ResetProfileState();
    CubeDecodedPrepareSources();
    CubeDecodedRunWriter(TRUE, FALSE, 0);
    let rows_slot = BundleLocalGenerationSlot(0, '1111');
    _LocalGenerations[[rows_slot]].writers[[0]].physical_rows = 16;
    CubeDecodedRunBadLast(4);
    assert !_LocalGenerations[[rows_slot]].published;

    ResetProfileState();
    CubeDecodedPrepareSources();
    CubeDecodedRunWriter(TRUE, FALSE, 0);
    let tail_slot = BundleLocalGenerationSlot(0, '1111');
    _LocalGenerations[[tail_slot]].writers[[0]].valid_columns = 20;
    CubeDecodedRunBadLast(4);
    assert !_LocalGenerations[[tail_slot]].published;
    return 0;
end;
