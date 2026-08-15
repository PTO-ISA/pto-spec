// PTO-TEST: {"id":"PTO-AVS-BLOCK-C-BSTART-TARGET-001","source":"asl/block/encoding/C.BSTART.asl","requirements":["PTO-INST-BLOCK-C-BSTART"],"kind":"execution","summary":"C.BSTART computes its compressed direct and conditional targets from P plus simm12 shifted by one","pass_condition":"positive, negative, direct, and conditional forms install the exact standard BARG target and taken default","related_sources":["asl/block/model/dispatch/start.asl"]}
func main() => integer
begin
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x100);
    let direct = ExecuteCommandInstruction(Zeros{64} + 0x0012, 16);
    assert direct == CommandExecution_Executed;
    assert _BARG.block_type == BundleKind_Standard;
    assert _BARG.transfer_type == BundleTransfer_Direct;
    assert _BARG.taken;
    assert _BARG.bpcn == Zeros{PTO_XLEN} + 0x102;

    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x200);
    let conditional = ExecuteCommandInstruction(Zeros{64} + 0xfff4, 16);
    assert conditional == CommandExecution_Executed;
    assert _BARG.transfer_type == BundleTransfer_Conditional;
    assert !_BARG.taken;
    assert _BARG.bpcn == Zeros{PTO_XLEN} + 0x1fe;

    assert InstructionContractTarget_C_BSTART(
        Zeros{PTO_XLEN} + 0x300, Zeros{12} + 1) ==
        Zeros{PTO_XLEN} + 0x302;
    assert InstructionContractTarget_C_BSTART(
        Zeros{PTO_XLEN} + 0x300, Ones{12}) ==
        Zeros{PTO_XLEN} + 0x2fe;
    return 0;
end;
