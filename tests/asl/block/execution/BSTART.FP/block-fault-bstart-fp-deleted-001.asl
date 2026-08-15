// PTO-TEST: {"id":"PTO-AVS-BLOCK-BSTART-FP-DELETED-001","source":"asl/block/execution/BSTART.FP.asl","requirements":["PTO-INST-BLOCK-BSTART-FP"],"kind":"fault","summary":"Deleted bare FP call forms are not PTO instructions.","pass_condition":"Former CALL and ICALL words reject before BPC, BARG, return-address, or block-state effects.","related_sources":["asl/block/execution/BSTART.CALL.asl","asl/block/execution/BSTART.ICALL.asl"]}
func AssertDeletedFPCall(instruction: bits(64))
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
    AssertDeletedFPCall(Zeros{64} + 0x00004101);
    AssertDeletedFPCall(Zeros{64} + 0x00006101);
    return 0;
end;
