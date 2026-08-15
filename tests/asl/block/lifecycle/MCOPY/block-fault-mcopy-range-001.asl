// PTO-TEST: {"id":"PTO-AVS-BLOCK-MCOPY-RANGE-001","source":"asl/block/lifecycle/MCOPY.asl","requirements":["PTO-INST-BLOCK-MCOPY"],"kind":"fault","summary":"MCOPY rejects source or destination range overflow before memory-template effects","pass_condition":"a wrapping nonempty interval raises Fault_IllegalInstruction at the current TPC and preserves memory events, reservation, progress, last-command state, and destination memory","related_sources":["asl/block/model/commit/effects.asl"]}
pure func MCOPYInstruction(destination: Reg5Selector,
                           source: Reg5Selector,
                           length: Reg5Selector) => bits(64)
begin
    var instruction = Zeros{64} + 0x00000031;
    instruction[19:15] = Zeros{5} + destination;
    instruction[24:20] = Zeros{5} + source;
    instruction[31:27] = Zeros{5} + length;
    return instruction;
end;

func AssertMCOPYRangeOverflowRejected(destination: Word, source: Word)
begin
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x6c0);
    WriteGPR(2, destination);
    WriteGPR(3, source);
    WriteGPR(4, Zeros{PTO_XLEN} + 2);
    WriteMemoryByte(Zeros{PTO_XLEN} + 0x100, Zeros{8} + 0xa5);
    _ReservationValid = TRUE;
    _ReservationAddress = Zeros{PTO_XLEN} + 0x100;
    _ReservationSize = 8;
    _LastMemoryCommandAddress = Ones{PTO_XLEN};
    _LastMemoryCommandSize = Ones{PTO_XLEN};
    StartMemoryEventCapture(0);

    let status = ExecuteCommandInstruction(
        MCOPYInstruction(2, 3, 4),
        32);

    assert status == CommandExecution_Rejected;
    assert _LastFault == Fault_IllegalInstruction;
    assert _FaultAddress == Zeros{PTO_XLEN} + 0x6c0;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x6c0;
    assert _MemoryEventCount == 0;
    assert _ReservationValid;
    assert _LastMemoryCommandAddress == Ones{PTO_XLEN};
    assert _LastMemoryCommandSize == Ones{PTO_XLEN};
    assert ReadMemoryByte(Zeros{PTO_XLEN} + 0x100) == Zeros{8} + 0xa5;
end;

func main() => integer
begin
    AssertMCOPYRangeOverflowRejected(
        Ones{PTO_XLEN},
        Zeros{PTO_XLEN} + 0x100);
    AssertMCOPYRangeOverflowRejected(
        Zeros{PTO_XLEN} + 0x100,
        Ones{PTO_XLEN});
    return 0;
end;
