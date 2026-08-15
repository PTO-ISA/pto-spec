// PTO-TEST: {"id":"PTO-AVS-TILE-TCI-DIRECTION-001","source":"asl/tile/irregular-and-complex/initialization/TCI.asl","requirements":["PTO-INST-TILE-TCI"],"kind":"fault","summary":"TCI direction accepts only the exact private-GPR values zero and one","pass_condition":"direction two raises Fault_TileLegality before destination allocation","related_sources":["asl/block/model/dispatch/scalar-schema.asl","asl/block/model/dispatch/generation-schema.asl"]}
pure func TCIDirectionStart() => bits(64)
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
    WriteGPR(2, Zeros{PTO_XLEN} + 2);
    let started = ExecuteCommandInstruction(TCIDirectionStart(), 32);
    assert started == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    SetBundleScalarBinding(0, 0, 0, 2, 0, 3);
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
    return 0;
end;
