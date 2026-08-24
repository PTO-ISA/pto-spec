// PTO-TEST: {"id":"PTO-AVS-BLOCK-ASSEMBLE-ALIAS-CONSUMER-001","source":"asl/block/model/operands/local-generation.asl","requirements":["PTO-B-ASSEMBLE-LOCAL-GENERATION-001","PTO-B-SUBVIEW-DESCRIPTOR-001","PTO-INST-BLOCK-B-IOT"],"kind":"execution","summary":"Decoded aliased assembly preserves the committed old mapping and payload across a failed replacement generation.","pass_condition":"The decoded source/destination alias publishes a new working object only at LAST, retains the bound old parent/subview value, and a subsequent decoded incomplete replacement aborts without losing the committed old destination/name/definedness; no pending-consumer carrier is claimed.","related_sources":["asl/block/model/dispatch/tile-execution.asl","asl/block/model/operands/subview-descriptor.asl"]}
pure func Start() => bits(64)
begin
    var instruction = Zeros{64} + 0x00031181;
    instruction[31:27] = Zeros{5} + 4;
    return instruction;
end;
pure func Binding() => bits(64)
begin
    var instruction = Zeros{64} + 0x00004013;
    instruction[31:26] = Zeros{6} + 1;
    instruction[25:20] = Zeros{6};
    instruction[19] = '1'; instruction[18:15] = Zeros{4} + 1;
    instruction[11:9] = '111'; instruction[8:7] = '00';
    return instruction;
end;
pure func View() => bits(64)
begin
    var instruction = Zeros{64} + 0x00000053;
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
pure func AssembleRange(init: boolean, last: boolean, parent: integer,
                        offset: integer) => bits(64)
begin
    var instruction = Zeros{64} + 0x00001053;
    instruction[31] = if init then '1' else '0';
    instruction[11] = if last then '1' else '0';
    instruction[10:7] = Zeros{4} + parent;
    instruction[30:20] = Zeros{11} + offset;
    return instruction;
end;
func main() => integer
begin
    ResetProfileState();
    let left = ConfigureCubeTileForMask(0, 128, 1, 1,
        TileDataType_FP16, TileLayout_CUBE_M16, TileLocation_Matrix, '1111');
    let right = ConfigureCubeTileForMask(1, 128, 1, 1,
        TileDataType_FP16, TileLayout_CUBE_N8, TileLocation_Matrix, '1111');
    assert left && right;
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 11);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 13);
    let started = ExecuteCommandInstruction(Start(), 32);
    SetBundleFixedPointAttributeState(Zeros{6}, Zeros{3}, Zeros{4},
        FALSE, FALSE, FALSE, FALSE);
    let bound = ExecuteCommandInstruction(Binding(), 32);
    let view = ExecuteCommandInstruction(View(), 32);
    let assembled = ExecuteCommandInstruction(Assemble(), 32);
    assert started == CommandExecution_Executed &&
           bound == CommandExecution_Executed &&
           view == CommandExecution_Executed &&
           assembled == CommandExecution_Executed;
    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
    let writer_completed = CompleteBundleLocalGenerationWriterEvent(
        BundleLocalGenerationSlot(0, '1111'), _BundleExecutionDomainToken, 0, 1);
    assert writer_completed &&
        _LocalGenerations[[BundleLocalGenerationSlot(0, '1111')]].published;
    let committed_value = ReadTileElement(0, 0, 0);
    assert committed_value == Zeros{PTO_XLEN} + 11;
    assert _Tiles[[0]].allocated && _Tiles[[0]].contents_defined;
    assert !_LocalGenerations[[BundleLocalGenerationSlot(0, '1111')]].open;
    assert _LocalGenerations[[BundleLocalGenerationSlot(0, '1111')]].published;
    assert _LocalGenerations[[BundleLocalGenerationSlot(0, '1111')]].published_destination != 0;
    assert BundleReadSubviewElement(0, FALSE, 0, 0) ==
        Zeros{PTO_XLEN} + 11;

    // A replacement generation faults at LAST before publication.  The
    // committed old object/name and payload remain the consumer snapshot.
    let old_destination = _LocalGenerations[[
        BundleLocalGenerationSlot(0, '1111')]].published_destination;
    let old_value = ReadTileElement(0, 0, 0);
    let restart_started = ExecuteCommandInstruction(Start(), 32);
    SetBundleFixedPointAttributeState(Zeros{6}, Zeros{3}, Zeros{4},
        FALSE, FALSE, FALSE, FALSE);
    let restart_bound = ExecuteCommandInstruction(Binding(), 32);
    let restart_view = ExecuteCommandInstruction(View(), 32);
    let restart_assemble = ExecuteCommandInstruction(
        AssembleRange(TRUE, TRUE, 2, 0), 32);
    assert restart_started == CommandExecution_Executed &&
           restart_bound == CommandExecution_Executed &&
           restart_view == CommandExecution_Executed &&
           restart_assemble == CommandExecution_Executed;
    let restart_completed = ExecuteBundleTileOperation();
    assert !restart_completed && _LastFault == Fault_TileLegality;
    let alias_slot = BundleLocalGenerationSlot(0, '1111');
    assert !_LocalGenerations[[alias_slot]].open &&
           _LocalGenerations[[alias_slot]].committed_valid &&
           _LocalGenerations[[alias_slot]].published_destination == old_destination &&
           _Tiles[[old_destination]].allocated &&
           ReadTileElement(0, 0, 0) == old_value;
    return 0;
end;
