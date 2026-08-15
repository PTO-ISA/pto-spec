// PTO-TEST: {"id":"PTO-AVS-BLOCK-BSTART-SYS-STATE-001","source":"asl/block/execution/BSTART.SYS.asl","requirements":["PTO-INST-BLOCK-BSTART-SYS"],"kind":"state-transition","summary":"BSTART.SYS publishes only the applicable system-block BARG state.","pass_condition":"The zero-payload form records BPC and SYS BlockType, canonicalizes inapplicable continuation fields, and commits sequentially.","related_sources":["asl/block/model/lifecycle/begin.asl","asl/block/model/state/barg.asl"]}
func main() => integer
begin
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x100);
    let started = ExecuteCommandInstruction(Zeros{64} + 0x00001081, 32);
    assert started == CommandExecution_Executed;
    assert ReadBPC() == Zeros{PTO_XLEN} + 0x100;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x104;
    assert _BARG.block_type == BundleKind_System;
    assert _BARG.transfer_type == BundleTransfer_Fallthrough;
    assert !_BARG.taken;
    assert _BARG.bpcn == Zeros{PTO_XLEN};
    let stopped = ExecuteCommandInstruction(Zeros{64} + 0x00000001, 32);
    assert stopped == CommandExecution_Executed;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x108;
    return 0;
end;
