// PTO-TEST: {"id":"PTO-AVS-BLOCK-C-BSTART-FP-BRTYPE-001","source":"asl/block/encoding/C.BSTART.FP.asl","requirements":["PTO-INST-BLOCK-C-BSTART-FP"],"kind":"execution","summary":"C.BSTART.FP maps its three assigned BrType values to FP block transfers","pass_condition":"FALL, IND, and RET install the matching FP BARG transfer and candidate target","related_sources":["asl/block/model/dispatch/start.asl","asl/block/model/state/barg.asl"]}
func main() => integer
begin
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x100);
    let fall = ExecuteCommandInstruction(Zeros{64} + 0x0880, 16);
    assert fall == CommandExecution_Executed;
    assert _BARG.block_type == BundleKind_Floating;
    assert _BARG.transfer_type == BundleTransfer_Fallthrough;
    assert _BARG.bpcn == Zeros{PTO_XLEN} + 0x102;

    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x200);
    BeginBundleAt(
        ReadTPC(),
        BundleKind_Standard,
        BundleTransfer_Direct,
        Zeros{PTO_XLEN} + 0x440,
        Zeros{PTO_XLEN} + 0x202,
        Zeros{PTO_XLEN} + 0x202,
        TRUE);
    let indirect = ExecuteCommandInstruction(Zeros{64} + 0x2880, 16);
    assert indirect == CommandExecution_Executed;
    assert _BARG.block_type == BundleKind_Floating;
    assert _BARG.transfer_type == BundleTransfer_Indirect;
    assert _BARG.bpcn == Zeros{PTO_XLEN} + 0x440;

    ResetProfileState();
    _ReturnAddress = Zeros{PTO_XLEN} + 0x520;
    WriteTPC(Zeros{PTO_XLEN} + 0x300);
    let returned = ExecuteCommandInstruction(Zeros{64} + 0x3880, 16);
    assert returned == CommandExecution_Executed;
    assert _BARG.block_type == BundleKind_Floating;
    assert _BARG.transfer_type == BundleTransfer_Return;
    assert _BARG.bpcn == Zeros{PTO_XLEN} + 0x520;

    assert InstructionContractBranchTypeLegal_C_BSTART_FP('001');
    assert InstructionContractTransfer_C_BSTART_FP('001') ==
        BundleTransfer_Fallthrough;
    assert InstructionContractTransfer_C_BSTART_FP('101') ==
        BundleTransfer_Indirect;
    assert InstructionContractTransfer_C_BSTART_FP('111') ==
        BundleTransfer_Return;
    return 0;
end;
