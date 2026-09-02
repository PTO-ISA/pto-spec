// PTO-TEST: {"id":"PTO-AVS-BLOCK-BSTART-FP-STATE-001","source":"asl/block/execution/BSTART.FP.asl","requirements":["PTO-INST-BLOCK-BSTART-FP"],"kind":"state-transition","summary":"Accepted BSTART.FP forms install the unique FP BARG and defer continuation to block commit.","pass_condition":"DIRECT, COND, FALL, IND, and RET publish their exact transfer state and selected continuation.","related_sources":["asl/block/model/dispatch/start.asl","asl/block/model/state/barg.asl"]}
func main() => integer
begin
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x100);
    let direct = ExecuteCommandInstruction(Zeros{64} + 0x0000a101, 32);
    assert direct == CommandExecution_Executed;
    assert ReadBPC() == Zeros{PTO_XLEN} + 0x100;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x104;
    assert _BARG.block_type == BundleKind_Floating;
    assert _BARG.transfer_type == BundleTransfer_Direct;
    assert _BARG.taken;
    assert _BARG.bpcn == Zeros{PTO_XLEN} + 0x102;
    let direct_stop = ExecuteCommandInstruction(Zeros{64} + 0x00000001, 32);
    assert direct_stop == CommandExecution_Executed;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x102;

    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x200);
    let conditional = ExecuteCommandInstruction(Zeros{64} + 0x0000b101, 32);
    assert conditional == CommandExecution_Executed;
    assert _BARG.block_type == BundleKind_Floating;
    assert _BARG.transfer_type == BundleTransfer_Conditional;
    assert !_BARG.taken;
    assert _BARG.bpcn == Zeros{PTO_XLEN} + 0x202;
    let conditional_stop = ExecuteCommandInstruction(
        Zeros{64} + 0x00000001, 32);
    assert conditional_stop == CommandExecution_Executed;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x208;

    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x300);
    let fall = ExecuteCommandInstruction(Zeros{64} + 0x00001101, 32);
    assert fall == CommandExecution_Executed;
    assert _BARG.transfer_type == BundleTransfer_Fallthrough;
    assert _BARG.bpcn == Zeros{PTO_XLEN} + 0x304;

    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x400);
    BeginBundleAt(
        ReadTPC(),
        BundleKind_Standard,
        BundleTransfer_Conditional,
        Zeros{PTO_XLEN} + 0x440,
        Zeros{PTO_XLEN} + 0x400,
        Zeros{PTO_XLEN} + 0x404,
        FALSE);
    let indirect = ExecuteCommandInstruction(Zeros{64} + 0x00005101, 32);
    assert indirect == CommandExecution_Executed;
    assert _BARG.transfer_type == BundleTransfer_Indirect;
    assert _BARG.bpcn == Zeros{PTO_XLEN} + 0x440;

    ResetProfileState();
    _ReturnAddress = Zeros{PTO_XLEN} + 0x520;
    WriteTPC(Zeros{PTO_XLEN} + 0x500);
    let returned = ExecuteCommandInstruction(Zeros{64} + 0x00007101, 32);
    assert returned == CommandExecution_Executed;
    assert _BARG.transfer_type == BundleTransfer_Return;
    assert _BARG.bpcn == Zeros{PTO_XLEN} + 0x520;
    return 0;
end;
