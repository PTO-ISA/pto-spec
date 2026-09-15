// PTO-TEST: {"id":"PTO-AVS-BLOCK-ASSEMBLE-LOCAL-LIFECYCLE-001","source":"asl/block/model/operands/local-generation.asl","requirements":["PTO-B-ASSEMBLE-LOCAL-GENERATION-001","PTO-INST-BLOCK-B-ASSEMBLE","PTO-INST-BLOCK-B-IOT"],"kind":"execution","summary":"Decoded Local B.ASSEMBLE executes INIT and ParentRef continuation writers against one semantic destination.","pass_condition":"INIT retains ParentCapacity and records WriterSizeCode; a pure final ParentRef carrier folds into the ordinary source binding, reaches the TREM handler with the existing working destination, closes the generation, and allocates no continuation Tile.","related_sources":["asl/block/model/dispatch/descriptor-legality.asl","asl/block/model/operands/range-modifiers.asl","asl/block/model/dispatch/tile-execution.asl"]}
pure func Start() => bits(64)
begin
    return Zeros{64} + 0x20419181;
end;
pure func LocalBinder(init: boolean, source0: integer, source1: integer,
                     last: boolean) => bits(64)
begin
    var instruction = Zeros{64} + 0x00004013;
    instruction[31:26] = Zeros{6} + source1;
    instruction[25:20] = Zeros{6} + source0;
    instruction[19] = if last then '1' else '0';
    instruction[18:15] = if init then '0011' else '0000';
    instruction[11:9] = '101'; instruction[8:7] = '00';
    return instruction;
end;
pure func Assemble(init: boolean, last: boolean, writer: integer,
                   offset: integer) => bits(64)
begin
    var instruction = Zeros{64} + 0x00001053;
    instruction[31] = if init then '1' else '0';
    instruction[11] = if last then '1' else '0';
    instruction[10:7] = Zeros{4} + writer;
    instruction[30:20] = Zeros{11} + offset;
    return instruction;
end;
pure func ParentBinder(parent: integer) => bits(64)
begin
    var instruction = Zeros{64} + 0x00005013;
    instruction[25:20] = Zeros{6} + parent;
    instruction[19] = '1';
    instruction[11:9] = '101';
    return instruction;
end;
func Source()
begin
    ConfigureTileForMask(1, 512, 64, 4, 1, 4,
        TileDataType_FP16, TileLayout_RowMajor, '1100');
    ConfigureTileForMask(2, 512, 64, 4, 1, 4,
        TileDataType_FP16, TileLayout_RowMajor, '1100');
    assert _Tiles[[1]].allocated && _Tiles[[2]].allocated;
    InstallRelativeTileFixture(1, 1);
    InstallRelativeTileFixture(2, 2);
    MarkTileValidRegionDefined(1);
    MarkTileValidRegionDefined(2);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 0x4000);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 0x3c00);
end;
func ResetFixture()
begin
    ResetBundleControlState();
    ClearFault();
    WriteTPC(Zeros{PTO_XLEN} + 0x700);
end;
func StartAndBind(init: boolean, source0: integer, source1: integer,
                  last: boolean)
begin
    let started = ExecuteCommandInstruction(Start(), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 4);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 4);
    let bound = ExecuteCommandInstruction(
        LocalBinder(init, source0, source1, last), 32);
    assert started == CommandExecution_Executed;
    assert bound == CommandExecution_Executed;
end;
func main() => integer
begin
    ResetFixture();
    StartAndBind(TRUE, 1, 2, FALSE);
    let init_assemble = ExecuteCommandInstruction(
        Assemble(TRUE, FALSE, 2, 0), 32);
    assert init_assemble == CommandExecution_Executed;
    assert _BundleTileBindings[[0]].destination_valid;
    assert _BundleTileBindings[[0]].destination_size == 3;
    assert !_BundleTileBindings[[0]].parent_ref_valid;
    assert _BundleTileBindings[[0]].destination_assemble.init;
    assert _BundleTileBindings[[0]].destination_assemble.size_code == 2;

    ResetFixture();
    StartAndBind(FALSE, 2, 0, TRUE);
    let continuation = ExecuteCommandInstruction(
        Assemble(FALSE, TRUE, 2, 0), 32);
    assert continuation == CommandExecution_Executed;
    assert !_BundleTileBindings[[0]].destination_valid;
    assert !_BundleTileBindings[[0]].source1_valid;
    assert _BundleTileBindings[[0]].source0_valid;
    assert _BundleTileBindings[[0]].parent_ref_valid;
    assert _BundleTileBindings[[0]].parent_ref == 0;
    assert _BundleTileBindings[[0]].parent_ref_relative;
    assert _BundleTileBindings[[0]].destination_assemble.size_code == 2;
    assert !_BundleTileBindings[[0]].destination_assemble.init;
    assert _BundleTileBindings[[0]].destination_assemble.last;
    assert BundleLocalTileParentRefCount() == 1;
    assert BundleLocalTileParentRefIsFinal();

    // Execute an INIT followed by a source-only ParentRef continuation. The
    // pure ParentRef carrier is folded into the ordinary source binding, the
    // handler receives the original working destination, and no Tile is
    // allocated for the continuation.
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x700);
    Source();
    StartAndBind(TRUE, 1, 2, TRUE);
    let init_range = ExecuteCommandInstruction(
        Assemble(TRUE, FALSE, 1, 0), 32);
    assert init_range == CommandExecution_Executed;
    let init_done = CompleteBundleAt(Zeros{PTO_XLEN} + 0x800);
    assert init_done && _LastFault == Fault_None;
    let slot = BundleLocalGenerationSlot(0, '1100');
    let parent = _LocalGenerations[[slot]].working_destination;
    assert _LocalGenerations[[slot]].open;
    var allocated_before: integer {0..64} = 0;
    for tile = 0 to PTO_TILE_REGISTER_COUNT - 1 do
        if _Tiles[[tile]].allocated then
            allocated_before = (allocated_before + 1) as integer {0..64};
        end;
    end;

    let continued_start = ExecuteCommandInstruction(Start(), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 4);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 4);
    let ordinary_sources = ExecuteCommandInstruction(
        LocalBinder(FALSE, 2, 3, FALSE), 32);
    let parent_carrier = ExecuteCommandInstruction(ParentBinder(0), 32);
    let middle_range = ExecuteCommandInstruction(
        Assemble(FALSE, FALSE, 2, 1), 32);
    assert continued_start == CommandExecution_Executed &&
           ordinary_sources == CommandExecution_Executed &&
           parent_carrier == CommandExecution_Executed &&
           middle_range == CommandExecution_Executed;
    let middle = CompleteBundleAt(Zeros{PTO_XLEN} + 0x900);
    assert middle && _LastFault == Fault_None;

    let last_start = ExecuteCommandInstruction(Start(), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 4);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 4);
    let last_sources = ExecuteCommandInstruction(
        LocalBinder(FALSE, 2, 3, FALSE), 32);
    let last_parent = ExecuteCommandInstruction(ParentBinder(0), 32);
    let last_range = ExecuteCommandInstruction(
        Assemble(FALSE, TRUE, 1, 3), 32);
    assert last_start == CommandExecution_Executed &&
           last_sources == CommandExecution_Executed &&
           last_parent == CommandExecution_Executed &&
           last_range == CommandExecution_Executed;
    let continued = CompleteBundleAt(Zeros{PTO_XLEN} + 0xa00);
    assert continued && _LastFault == Fault_None;
    assert _LocalGenerations[[slot]].writer_count == 3;
    assert _LocalGenerations[[slot]].writers[[2]].destination == parent;
    var allocated_after: integer {0..64} = 0;
    for tile = 0 to PTO_TILE_REGISTER_COUNT - 1 do
        if _Tiles[[tile]].allocated then
            allocated_after = (allocated_after + 1) as integer {0..64};
        end;
    end;
    assert allocated_after == allocated_before;
    assert _LocalGenerations[[slot]].closed &&
           !_LocalGenerations[[slot]].open;
    return 0;
end;
