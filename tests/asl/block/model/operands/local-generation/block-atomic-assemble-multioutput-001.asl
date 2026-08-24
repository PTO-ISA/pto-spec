// PTO-TEST: {"id":"PTO-AVS-BLOCK-ASSEMBLE-MULTIOUTPUT-001","source":"asl/block/model/operands/local-generation.asl","requirements":["PTO-B-ASSEMBLE-LOCAL-GENERATION-001","PTO-INST-BLOCK-B-IOT","PTO-INST-BLOCK-B-ASSEMBLE"],"kind":"atomicity","summary":"Decoded multi-output Local assembly preflights every writer before publication.","pass_condition":"Two independently bound output hands commit together with disjoint generation domains; when one output has incomplete coverage, neither destination allocates or advances.","related_sources":["asl/block/model/dispatch/destination-shape.asl","asl/block/model/faults/rollback.asl"]}
pure func Start() => bits(64)
begin
    var instruction = Zeros{64} + 0x00031181;
    instruction[31:27] = Zeros{5} + 4;
    return instruction;
end;
pure func Binding(hand: integer, last: boolean, with_sources: boolean) => bits(64)
begin
    var instruction = if with_sources then
        Zeros{64} + 0x00004013 else Zeros{64} + 0x00006013;
    if with_sources then
        instruction[31:26] = Zeros{6} + 2;
        instruction[25:20] = Zeros{6} + 1;
    end;
    instruction[19] = if last then '1' else '0';
    instruction[18:15] = Zeros{4} + 1;
    instruction[11:9] = '111'; instruction[8:7] = Zeros{2} + hand;
    return instruction;
end;
pure func View(select: boolean) => bits(64)
begin
    var instruction = Zeros{64} + 0x00000053;
    instruction[31] = if select then '1' else '0';
    instruction[10:7] = Zeros{4} + 1;
    return instruction;
end;
pure func Assemble(last: boolean, parent: integer) => bits(64)
begin
    var instruction = Zeros{64} + 0x00001053;
    instruction[31] = '1'; instruction[11] = if last then '1' else '0';
    instruction[10:7] = Zeros{4} + parent;
    return instruction;
end;
func Sources()
begin
    let left = ConfigureCubeTileForMask(1, 128, 1, 1,
        TileDataType_FP16, TileLayout_CUBE_M16, TileLocation_Matrix, '1111');
    let right = ConfigureCubeTileForMask(2, 128, 1, 1,
        TileDataType_FP16, TileLayout_CUBE_N8, TileLocation_Matrix, '1111');
    assert left && right;
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 2);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 3);
end;
func main() => integer
begin
    ResetProfileState(); Sources();
    let started = ExecuteCommandInstruction(Start(), 32);
    SetBundleFixedPointAttributeState(Zeros{6}, Zeros{3}, Zeros{4},
        TRUE, FALSE, FALSE, FALSE);
    let first = ExecuteCommandInstruction(Binding(0, FALSE, TRUE), 32);
    let first0 = ExecuteCommandInstruction(View(FALSE), 32);
    let first1 = ExecuteCommandInstruction(View(TRUE), 32);
    let first_assemble = ExecuteCommandInstruction(Assemble(TRUE, 1), 32);
    let second = ExecuteCommandInstruction(Binding(1, TRUE, FALSE), 32);
    let second_assemble = ExecuteCommandInstruction(Assemble(TRUE, 1), 32);
    assert started == CommandExecution_Executed;
    assert first == CommandExecution_Executed;
    assert first0 == CommandExecution_Executed;
    assert first1 == CommandExecution_Executed;
    assert first_assemble == CommandExecution_Executed;
    assert second == CommandExecution_Executed;
    assert second_assemble == CommandExecution_Executed;
    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
    let first_writer_completed = CompleteBundleLocalGenerationWriterEvent(
        BundleLocalGenerationSlot(0, '1111'), _BundleExecutionDomainToken, 0, 1);
    let second_writer_completed = CompleteBundleLocalGenerationWriterEvent(
        BundleLocalGenerationSlot(1, '1111'), _BundleExecutionDomainToken, 0, 1);
    assert first_writer_completed && second_writer_completed;
    assert _LocalGenerations[[BundleLocalGenerationSlot(0, '1111')]].published &&
           _LocalGenerations[[BundleLocalGenerationSlot(1, '1111')]].published;
    assert _LocalGenerations[[BundleLocalGenerationSlot(0, '1111')]].published_destination !=
           _LocalGenerations[[BundleLocalGenerationSlot(1, '1111')]].published_destination;

    ResetProfileState(); Sources();
    let bad_started = ExecuteCommandInstruction(Start(), 32);
    SetBundleFixedPointAttributeState(Zeros{6}, Zeros{3}, Zeros{4},
        TRUE, FALSE, FALSE, FALSE);
    let bad_first = ExecuteCommandInstruction(Binding(0, FALSE, TRUE), 32);
    let bad_first0 = ExecuteCommandInstruction(View(FALSE), 32);
    let bad_first1 = ExecuteCommandInstruction(View(TRUE), 32);
    let bad_first_assemble = ExecuteCommandInstruction(Assemble(TRUE, 1), 32);
    let bad_second = ExecuteCommandInstruction(Binding(1, TRUE, FALSE), 32);
    let bad_second_assemble = ExecuteCommandInstruction(Assemble(TRUE, 2), 32);
    assert bad_started == CommandExecution_Executed &&
           bad_first == CommandExecution_Executed &&
           bad_first0 == CommandExecution_Executed &&
           bad_first1 == CommandExecution_Executed &&
           bad_first_assemble == CommandExecution_Executed &&
           bad_second == CommandExecution_Executed &&
           bad_second_assemble == CommandExecution_Executed;
    let rejected = ExecuteBundleTileOperation();
    assert !rejected && _LastFault == Fault_TileLegality;
    assert !_LocalGenerations[[BundleLocalGenerationSlot(0, '1111')]].published &&
           !_LocalGenerations[[BundleLocalGenerationSlot(1, '1111')]].published;
    return 0;
end;
