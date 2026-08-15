// PTO-TEST: {"id":"PTO-AVS-BLOCK-C-BSTART-STD-BRTYPE-001","source":"asl/block/encoding/C.BSTART.STD.asl","requirements":["PTO-INST-BLOCK-C-BSTART-STD"],"kind":"execution","summary":"C.BSTART.STD maps its three assigned BrType values to standard block transfers","pass_condition":"FALL, IND, and RET select the normative transfer mapping and standard block kind","related_sources":["asl/block/model/dispatch/start.asl"]}
func main() => integer
begin
    assert InstructionContractBranchTypeLegal_C_BSTART_STD('001');
    assert InstructionContractBranchTypeLegal_C_BSTART_STD('101');
    assert InstructionContractBranchTypeLegal_C_BSTART_STD('111');
    assert InstructionContractTransfer_C_BSTART_STD('001') ==
        BundleTransfer_Fallthrough;
    assert InstructionContractTransfer_C_BSTART_STD('101') ==
        BundleTransfer_Indirect;
    assert InstructionContractTransfer_C_BSTART_STD('111') ==
        BundleTransfer_Return;

    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x100);
    let fall = ExecuteCommandInstruction(Zeros{64} + 0x0800, 16);
    assert fall == CommandExecution_Executed;
    assert _BARG.block_type == BundleKind_Standard;
    assert _BARG.transfer_type == BundleTransfer_Fallthrough;
    return 0;
end;
