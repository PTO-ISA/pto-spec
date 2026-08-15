// PTO-TEST: {"id":"PTO-AVS-BLOCK-BSTART-ICALL-STANDALONE-REJECT-001","source":"asl/block/execution/BSTART.ICALL.asl","requirements":["PTO-INST-BLOCK-BSTART-ICALL"],"kind":"boundary","summary":"Bare compressed ICALL halfwords are not standalone PTO instructions.","pass_condition":"C.BSTART.STD and C.BSTART.FP with BrType ICALL reject before effects while the fused 32-bit BSTART.ICALL remains assigned.","related_sources":["asl/block/encoding/C.BSTART.FP.asl","asl/block/encoding/C.BSTART.STD.asl"]}
func main() => integer
begin
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x100);
    let std_status = ExecuteCommandInstruction(Zeros{64} + 0x3000, 16);
    assert std_status == CommandExecution_Rejected;
    assert _LastFault == Fault_IllegalInstruction;
    assert !_BundleActive;

    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x200);
    let fp_status = ExecuteCommandInstruction(Zeros{64} + 0x3080, 16);
    assert fp_status == CommandExecution_Rejected;
    assert _LastFault == Fault_IllegalInstruction;
    assert !_BundleActive;

    let fused = DecodeCommandForm(Zeros{64} + 0x50166001, 32);
    assert fused != PTO_COMMAND_FORM_COUNT;
    assert CommandBundleTransferOfForm(
        fused as integer {0..PTO_COMMAND_FORM_COUNT-1}) ==
        BundleTransfer_IndirectCall;
    return 0;
end;
