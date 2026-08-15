// PTO-TEST: {"id":"PTO-AVS-TILE-TTRI-ORIENT-001","source":"asl/tile/irregular-and-complex/initialization/TTRI.asl","requirements":["PTO-INST-TILE-TTRI"],"kind":"fault","summary":"TTRI orientation accepts only the exact private-GPR values zero and one","pass_condition":"orientation two raises Fault_TileLegality before destination allocation","related_sources":["asl/block/model/dispatch/scalar-schema.asl","asl/block/model/dispatch/generation-schema.asl"]}
pure func TTRIOrientationStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00019181;
    instruction[26:25] = '11';
    instruction[24:20] = '00111';
    instruction[31:27] = Zeros{5} + 4;
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    WriteGPR(2, Zeros{PTO_XLEN} + 2);
    let started = ExecuteCommandInstruction(TTRIOrientationStart(), 32);
    assert started == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 3);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 4);
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
