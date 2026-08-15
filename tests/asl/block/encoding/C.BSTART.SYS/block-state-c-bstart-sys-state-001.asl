// PTO-TEST: {"id":"PTO-AVS-BLOCK-C-BSTART-SYS-STATE-001","source":"asl/block/encoding/C.BSTART.SYS.asl","requirements":["PTO-INST-BLOCK-C-BSTART-SYS"],"kind":"state-transition","summary":"C.BSTART.SYS opens the unique compressed sequential system block","pass_condition":"the fixed 16-bit form installs a SYS BARG with no selecting continuation fields","related_sources":["asl/block/model/lifecycle/begin.asl"]}
func main() => integer
begin
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x800);
    let status = ExecuteCommandInstruction(Zeros{64} + 0x0840, 16);
    assert status == CommandExecution_Executed;
    assert _BundleActive;
    assert ReadBPC() == Zeros{PTO_XLEN} + 0x800;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x802;
    assert _BARG.block_type == BundleKind_System;
    assert _BARG.transfer_type == BundleTransfer_Fallthrough;
    assert !_BARG.taken;
    assert _BARG.bpcn == Zeros{PTO_XLEN};
    assert InstructionContractKind_C_BSTART_SYS() == BundleKind_System;
    return 0;
end;
