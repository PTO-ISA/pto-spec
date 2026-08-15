// PTO-TEST: {"id":"PTO-AVS-BLOCK-ESAVE-RSVD-001","source":"asl/block/lifecycle/ESAVE.asl","requirements":["PTO-INST-BLOCK-ESAVE"],"kind":"fault","summary":"ESAVE boundary forms reject before context or memory-command effects","pass_condition":"minimum and maximum selector forms raise Fault_IllegalInstruction at the current TPC and preserve context-related state","related_sources":["asl/block/model/dispatch/commands.asl"]}
func AssertESAVEReserved(raw: bits(64))
begin
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x540);
    _LastMemoryCommandAddress = Ones{PTO_XLEN};
    _LastMemoryCommandSize = Ones{PTO_XLEN};
    _ControlRequestOperand = Ones{PTO_XLEN};
    _LastFrameBegin = 31;

    let status = ExecuteCommandInstruction(raw, 32);

    assert status == CommandExecution_Rejected;
    assert _LastFault == Fault_IllegalInstruction;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x540;
    assert _LastMemoryCommandAddress == Ones{PTO_XLEN};
    assert _LastMemoryCommandSize == Ones{PTO_XLEN};
    assert _ControlRequestOperand == Ones{PTO_XLEN};
    assert _LastFrameBegin == 31;
end;

func main() => integer
begin
    AssertESAVEReserved(Zeros{64} + 0x00002031);
    AssertESAVEReserved(Zeros{64} + 0xf9ffa031);
    return 0;
end;
