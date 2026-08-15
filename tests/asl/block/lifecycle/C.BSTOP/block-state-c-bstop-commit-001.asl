// PTO-TEST: {"id":"PTO-AVS-BLOCK-C-BSTOP-EXEC-001","source":"asl/block/lifecycle/C.BSTOP.asl","requirements":["PTO-INST-BLOCK-C-BSTOP"],"kind":"state-transition","summary":"C.BSTOP commits the active block through the common BARG boundary.","pass_condition":"The compressed stop commits, selects BARG.BPCN for a direct transfer, and clears BARG.","related_sources":["asl/block/model/commit/validation.asl"]}
func main() => integer
begin
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x200);
    let started = ExecuteCommandInstruction(Zeros{64} + 0x00000011, 32);
    assert started == CommandExecution_Executed;
    assert _BARG.bpcn == Zeros{PTO_XLEN} + 0x200;
    let stopped = ExecuteCommandInstruction(Zeros{64}, 16);
    assert stopped == CommandExecution_Executed;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x200;
    assert ReadBPC() == Zeros{PTO_XLEN};
    assert !_BundleActive;
    assert _BARG.transfer_type == BundleTransfer_Fallthrough;
    return 0;
end;
