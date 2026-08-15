// PTO-TEST: {"id":"PTO-AVS-BLOCK-ERCOV-RSVD-001","source":"asl/block/lifecycle/ERCOV.asl","requirements":["PTO-INST-BLOCK-ERCOV"],"kind":"fault","summary":"ERCOV boundary forms reject before context or memory-command effects","pass_condition":"minimum and maximum selector forms raise Fault_IllegalInstruction at the current TPC and preserve context-related state","related_sources":["asl/block/model/dispatch/commands.asl"]}
func AssertERCOVReserved(raw: bits(64))
begin
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x500);
    _LastMemoryCommandAddress = Ones{PTO_XLEN};
    _LastMemoryCommandSize = Ones{PTO_XLEN};
    _ControlRequestOperand = Ones{PTO_XLEN};
    _LastFrameBegin = 31;

    let status = ExecuteCommandInstruction(raw, 32);

    assert status == CommandExecution_Rejected;
    assert _LastFault == Fault_IllegalInstruction;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x500;
    assert _LastMemoryCommandAddress == Ones{PTO_XLEN};
    assert _LastMemoryCommandSize == Ones{PTO_XLEN};
    assert _ControlRequestOperand == Ones{PTO_XLEN};
    assert _LastFrameBegin == 31;
end;

func main() => integer
begin
    AssertERCOVReserved(Zeros{64} + 0x00003031);
    AssertERCOVReserved(Zeros{64} + 0xf9ffb031);
    return 0;
end;
