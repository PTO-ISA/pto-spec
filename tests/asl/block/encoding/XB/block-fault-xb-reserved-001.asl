// PTO-TEST: {"id":"PTO-AVS-BLOCK-XB-RSVD-001","source":"asl/block/encoding/XB.asl","requirements":["PTO-INST-BLOCK-XB"],"kind":"fault","summary":"XB minimum and maximum field forms reject before effects","pass_condition":"both occupied boundary forms raise Fault_IllegalInstruction at the current TPC without changing cross-block or BARG state","related_sources":["asl/block/model/dispatch/commands.asl"]}
func AssertXBReserved(raw: bits(64))
begin
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x240);
    _LastCrossBlockACR = Ones{10};
    _LastCrossBlockID = Ones{7};
    _BARG.transfer_type = BundleTransfer_Return;

    let status = ExecuteCommandInstruction(raw, 32);

    assert status == CommandExecution_Rejected;
    assert _LastFault == Fault_IllegalInstruction;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x240;
    assert _LastCrossBlockACR == Ones{10};
    assert _LastCrossBlockID == Ones{7};
    assert _BARG.transfer_type == BundleTransfer_Return;
end;

func main() => integer
begin
    assert InstructionContractSupported_XB() == FALSE;
    assert InstructionContractRejectsBeforeEffects_XB();
    AssertXBReserved(Zeros{64} + 0x00006f81);
    AssertXBReserved(Zeros{64} + 0xffffef81);
    return 0;
end;
