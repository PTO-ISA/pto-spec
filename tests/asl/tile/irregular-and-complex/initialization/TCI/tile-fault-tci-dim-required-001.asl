// PTO-TEST: {"id":"PTO-AVS-TILE-TCI-DIM-REQUIRED-001","source":"asl/tile/irregular-and-complex/initialization/TCI.asl","requirements":["PTO-INST-TILE-TCI"],"kind":"fault","summary":"TCI requires an explicit B.DIM LB0 write even though other operations default omitted dimensions to one","pass_condition":"a RowMajor TCI bundle and a CUBE_M16 TCI bundle with every B.DIM omitted both raise Fault_TileLegality before destination allocation","related_sources":["asl/block/model/dispatch/generation-schema.asl","asl/block/model/schema/dimensions.asl"]}
pure func TCIDimRequiredStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00019181;
    instruction[26:25] = '11';
    instruction[24:20] = '00110';
    instruction[31:27] = Zeros{5} + 26;
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    let started = ExecuteCommandInstruction(TCIDimRequiredStart(), 32);
    assert started == CommandExecution_Executed;
    AddBundleTileBinding(
        TRUE,
        0,
        1,
        '1111',
        FALSE,
        FALSE,
        0,
        0,
        TRUE);

    let completed = ExecuteBundleTileOperation();
    assert !completed;
    assert _LastFault == Fault_TileLegality;
    assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;
    assert !_Tiles[[0]].allocated;

    ResetProfileState();
    let cube_started = ExecuteCommandInstruction(TCIDimRequiredStart(), 32);
    assert cube_started == CommandExecution_Executed;
    SetBundleDataAttributeState(
        DTYPE_NONE, Zeros{5} + 31, Zeros{2}, Zeros{3}, Zeros{3}, FALSE, FALSE);
    _BundleDataAttributesPresent = TRUE;
    SetBundleDimension(1, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 4);
    AddBundleTileBinding(
        TRUE, 0, 1, '1111', FALSE, FALSE, 0, 0, TRUE);
    for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 looplimit 4 do
        WritePEGPR(pe as MemoryAgentId, 4, Zeros{PTO_XLEN} + 1);
        WritePEGPR(pe as MemoryAgentId, 5, Zeros{PTO_XLEN});
    end;
    SetBundleScalarBinding(0, 0, 4, 5, 0, 3);

    let cube_completed = ExecuteBundleTileOperation();
    assert !cube_completed;
    assert _LastFault == Fault_TileLegality;
    assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;
    assert !_Tiles[[0]].allocated;
    return 0;
end;
