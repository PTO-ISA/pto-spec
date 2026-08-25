// PTO-TEST: {"id":"PTO-AVS-BLOCK-MSET-DATAPAGE-002","source":"asl/block/lifecycle/MSET.asl","requirements":["PTO-INST-BLOCK-MSET"],"kind":"fault","summary":"MSET preflights the complete range and leaves all state unchanged on DataPage","pass_condition":"a range crossing the accessible boundary faults before its first byte, preserving memory, reservation, command state, and TPC","related_sources":["asl/block/model/commit/effects.asl"]}
pure func MSETFaultInstruction(destination: Reg5Selector,
                               value: Reg5Selector,
                               length: Reg5Selector) => bits(64)
begin
    var instruction = Zeros{64} + 0x00001031;
    instruction[19:15] = Zeros{5} + destination;
    instruction[24:20] = Zeros{5} + value;
    instruction[31:27] = Zeros{5} + length;
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    WriteMemoryByte(Zeros{PTO_XLEN} + 3070, Zeros{8} + 0x11);
    WriteMemoryByte(Zeros{PTO_XLEN} + 3071, Zeros{8} + 0x22);
    WriteGPR(2, Zeros{PTO_XLEN} + 3070);
    WriteGPR(3, Zeros{PTO_XLEN} + 0xaa);
    WriteGPR(4, Zeros{PTO_XLEN} + 4);
    _ReservationValid = TRUE;
    _ReservationAddress = Zeros{PTO_XLEN} + 3070;
    _ReservationSize = 4;
    _LastMemoryCommandAddress = Zeros{PTO_XLEN} + 0x88;
    _LastMemoryCommandSize = Zeros{PTO_XLEN} + 9;
    SetCurrentACR(2);
    PTOv0WriteContextRegister(1, 0x0f01, Zeros{PTO_XLEN} + 0x900);
    WriteTPC(Zeros{PTO_XLEN} + 0x780);
    ClearFault();

    let status = ExecuteCommandInstruction(MSETFaultInstruction(2, 3, 4), 32);

    assert status == CommandExecution_Rejected;
    assert _LastFault == Fault_DataPage;
    assert ReadMemoryByte(Zeros{PTO_XLEN} + 3070) == Zeros{8} + 0x11;
    assert ReadMemoryByte(Zeros{PTO_XLEN} + 3071) == Zeros{8} + 0x22;
    assert _ReservationValid;
    assert _LastMemoryCommandAddress == Zeros{PTO_XLEN} + 0x88;
    assert _LastMemoryCommandSize == Zeros{PTO_XLEN} + 9;
    assert _TrapContexts[[1]].tpc == Zeros{PTO_XLEN} + 0x780;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x900;
    return 0;
end;
