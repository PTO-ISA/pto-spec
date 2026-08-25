// PTO-TEST: {"id":"PTO-AVS-BLOCK-MSET-RESERVATION-003","source":"asl/block/lifecycle/MSET.asl","requirements":["PTO-INST-BLOCK-MSET"],"kind":"execution","summary":"MSET fills in address order after full preflight and invalidates an overlapping reservation","pass_condition":"a three-byte fill publishes every byte, clears the overlapping reservation, records the command, and retires once","related_sources":["asl/block/model/commit/effects.asl"]}
pure func MSETReservationInstruction(destination: Reg5Selector,
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
    WriteGPR(2, Zeros{PTO_XLEN} + 0x100);
    WriteGPR(3, Zeros{PTO_XLEN} + 0x12ab);
    WriteGPR(4, Zeros{PTO_XLEN} + 3);
    _ReservationValid = TRUE;
    _ReservationAddress = Zeros{PTO_XLEN} + 0x101;
    _ReservationSize = 2;
    WriteTPC(Zeros{PTO_XLEN} + 0x7c0);

    let status = ExecuteCommandInstruction(
        MSETReservationInstruction(2, 3, 4), 32);

    assert status == CommandExecution_Executed;
    assert _LastFault == Fault_None;
    assert ReadMemoryByte(Zeros{PTO_XLEN} + 0x100) == Zeros{8} + 0xab;
    assert ReadMemoryByte(Zeros{PTO_XLEN} + 0x101) == Zeros{8} + 0xab;
    assert ReadMemoryByte(Zeros{PTO_XLEN} + 0x102) == Zeros{8} + 0xab;
    assert !_ReservationValid;
    assert _LastMemoryCommandAddress == Zeros{PTO_XLEN} + 0x100;
    assert _LastMemoryCommandSize == Zeros{PTO_XLEN} + 3;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x7c4;
    return 0;
end;
