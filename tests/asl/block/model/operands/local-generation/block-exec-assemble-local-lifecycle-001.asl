// PTO-TEST: {"id":"PTO-AVS-BLOCK-ASSEMBLE-LOCAL-LIFECYCLE-001","source":"asl/block/model/operands/local-generation.asl","requirements":["PTO-B-ASSEMBLE-LOCAL-GENERATION-001","PTO-INST-BLOCK-B-ASSEMBLE","PTO-INST-BLOCK-B-IOT"],"kind":"execution","summary":"Decoded Local B.ASSEMBLE keeps one open generation across disjoint writers and publishes only at LAST.","pass_condition":"INIT opens one generation, an exact same-instance replay is idempotent, distinct MIDDLE writers reuse one destination without allocating another object, readiness and coverage accumulate out of order, and LAST closes and publishes atomically.","related_sources":["asl/block/model/dispatch/tile-execution.asl","asl/block/model/lifecycle/enter-stop.asl"]}
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
    instruction[19] = '1'; instruction[18:15] = Zeros{4} + 2;
    instruction[11:9] = '111'; instruction[8:7] = '00';
    return instruction;
end;
pure func Assemble(init: boolean, last: boolean, parent: integer,
                   offset: integer)
        => bits(64)
begin
    var instruction = Zeros{64} + 0x00001053;
    instruction[31] = if init then '1' else '0';
    instruction[11] = if last then '1' else '0';
    instruction[10:7] = Zeros{4} + parent;
    instruction[30:20] = Zeros{11} + offset;
    return instruction;
end;
func RunWriter(init: boolean, last: boolean, parent: integer,
               offset: integer)
        => boolean
begin
    let started = ExecuteCommandInstruction(Start(), 32);
    SetBundleFixedPointAttributeState(Zeros{6}, Zeros{3}, Zeros{4},
        FALSE, FALSE, FALSE, FALSE);
    let bound = ExecuteCommandInstruction(Binding(), 32);
    let assembled = ExecuteCommandInstruction(
        Assemble(init, last, parent, offset), 32);
    assert started == CommandExecution_Executed;
    assert bound == CommandExecution_Executed;
    assert assembled == CommandExecution_Executed;
    return CompleteBundleAt(Zeros{PTO_XLEN} + 0x700);
end;
readonly func AllocatedTileCount() => integer
begin
    var count: integer = 0;
    for index = 0 to PTO_TILE_REGISTER_COUNT - 1 do
        if _Tiles[[index]].allocated then count = count + 1; end;
    end;
    return count;
end;
func main() => integer
begin
    ResetProfileState();
    let source = ConfigureCubeTileForMask(1, 128, 1, 1,
        TileDataType_FP16, TileLayout_CUBE_M16, TileLocation_Matrix, '1111');
    let source1 = ConfigureCubeTileForMask(2, 128, 1, 1,
        TileDataType_FP16, TileLayout_CUBE_N8, TileLocation_Matrix, '1111');
    assert source && source1;
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 5);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 7);
    let init_done = RunWriter(TRUE, FALSE, 4, 4);
    assert init_done && _LastFault == Fault_None;
    assert AllocatedTileCount() == 3;
    assert _LocalGenerations[[BundleLocalGenerationSlot(0, '1111')]].open;
    assert !_LocalGenerations[[BundleLocalGenerationSlot(0, '1111')]].published;
    assert _LocalGenerations[[BundleLocalGenerationSlot(0, '1111')]].writer_count == 1;
    assert _LocalGenerations[[BundleLocalGenerationSlot(0, '1111')]].covered_cells[4] == '1';
    assert _LocalGenerations[[BundleLocalGenerationSlot(0, '1111')]].ready_cells[4] == '0';
    let init_completed = CompleteBundleLocalGenerationWriterEvent(
        BundleLocalGenerationSlot(0, '1111'), _BundleExecutionDomainToken,
        4, 2);
    assert init_completed &&
        _LocalGenerations[[BundleLocalGenerationSlot(0, '1111')]].ready_cells[4] == '1';
    let init_instance = ReadBPC();
    let init_domain = _BundleExecutionDomainToken;
    // Model an exact replay restoration. Normal BSTART allocation remains
    // monotonic; the dedicated dynamic-domain AVS proves distinct executions
    // receive distinct tokens.
    _NextBundleExecutionDomainToken = init_domain;
    WriteTPC(init_instance);
    let replay_done = RunWriter(FALSE, FALSE, 0, 4);
    assert replay_done && _LastFault == Fault_None;
    assert _LocalGenerations[[BundleLocalGenerationSlot(0, '1111')]].writer_count == 1;
    let middle_done = RunWriter(FALSE, FALSE, 0, 0);
    assert middle_done && _LastFault == Fault_None;
    let middle_domain = _BundleExecutionDomainToken;
    assert AllocatedTileCount() == 3;
    assert _LocalGenerations[[BundleLocalGenerationSlot(0, '1111')]].open;
    assert _LocalGenerations[[BundleLocalGenerationSlot(0, '1111')]].writer_count == 2;
    let middle2_done = RunWriter(FALSE, FALSE, 0, 6);
    assert middle2_done && _LastFault == Fault_None;
    let middle2_domain = _BundleExecutionDomainToken;
    assert _LocalGenerations[[BundleLocalGenerationSlot(0, '1111')]].writer_count == 3;
    let last_done = RunWriter(FALSE, TRUE, 0, 2);
    assert last_done && _LastFault == Fault_None;
    let last_domain = _BundleExecutionDomainToken;
    assert AllocatedTileCount() == 3;
    assert !_LocalGenerations[[BundleLocalGenerationSlot(0, '1111')]].open;
    assert _LocalGenerations[[BundleLocalGenerationSlot(0, '1111')]].closed;
    assert !_LocalGenerations[[BundleLocalGenerationSlot(0, '1111')]].published;
    assert _LocalGenerations[[BundleLocalGenerationSlot(0, '1111')]].covered_cells[0] == '1' &&
           _LocalGenerations[[BundleLocalGenerationSlot(0, '1111')]].ready_cells[0] == '0';
    // Complete the closed writer set out of order.  Publication occurs once,
    // atomically, only after the final required cells become ready.
    let last_completed = CompleteBundleLocalGenerationWriterEvent(
        BundleLocalGenerationSlot(0, '1111'), last_domain,
        2, 2);
    let middle2_completed = CompleteBundleLocalGenerationWriterEvent(
        BundleLocalGenerationSlot(0, '1111'), middle2_domain,
        6, 2);
    let middle_completed = CompleteBundleLocalGenerationWriterEvent(
        BundleLocalGenerationSlot(0, '1111'), middle_domain,
        0, 2);
    assert last_completed && middle2_completed && middle_completed;
    assert _LocalGenerations[[BundleLocalGenerationSlot(0, '1111')]].published;
    assert _LocalGenerations[[BundleLocalGenerationSlot(0, '1111')]].published_destination ==
        _LocalGenerations[[BundleLocalGenerationSlot(0, '1111')]].working_destination;
    return 0;
end;
