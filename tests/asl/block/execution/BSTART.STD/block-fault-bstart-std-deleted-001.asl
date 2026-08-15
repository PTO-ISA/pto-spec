// PTO-TEST: {"id":"PTO-AVS-BLOCK-BSTART-STD-DELETED-001","source":"asl/block/execution/BSTART.STD.asl","requirements":["PTO-INST-BLOCK-BSTART-STD"],"kind":"fault","summary":"Deleted bare STD call forms are not PTO instructions.","pass_condition":"Former CALL and ICALL words reject before BPC, BARG, return-address, or block-state effects.","related_sources":["asl/block/execution/BSTART.CALL.asl","asl/block/execution/BSTART.ICALL.asl"]}
func AssertDeletedSTDCall(instruction: bits(64))
begin
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x600);
    WriteBPC(Zeros{PTO_XLEN} + 0x580);
    _ReturnAddress = Zeros{PTO_XLEN} + 0x700;
    let status = ExecuteCommandInstruction(instruction, 32);
    assert status == CommandExecution_Rejected;
    assert _LastFault == Fault_IllegalInstruction;
    assert !_BundleActive;
    assert ReadBPC() == Zeros{PTO_XLEN} + 0x580;
    assert _ReturnAddress == Zeros{PTO_XLEN} + 0x700;
end;

func main() => integer
begin
    AssertDeletedSTDCall(Zeros{64} + 0x00004001);
    AssertDeletedSTDCall(Zeros{64} + 0x00006001);
    return 0;
end;
