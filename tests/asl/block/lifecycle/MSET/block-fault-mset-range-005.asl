// PTO-TEST: {"id":"PTO-AVS-BLOCK-MSET-RANGE-005","source":"asl/block/lifecycle/MSET.asl","requirements":["PTO-INST-BLOCK-MSET","PTO-BLOCK-MSET-FILL-001"],"kind":"fault","summary":"MSET rejects a nonzero destination interval that wraps PTO_XLEN","pass_condition":"a wrapping two-byte range raises IllegalInstruction before memory, reservation, last-command, or TPC effects","related_sources":["asl/block/model/commit/effects.asl"]}
pure func MSETRangeInstruction(destination: Reg5Selector,
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
    let instruction_pc = Zeros{PTO_XLEN} + 0x880;
    WriteTPC(instruction_pc);
    WriteGPR(2, Ones{PTO_XLEN});
    WriteGPR(3, Zeros{PTO_XLEN} + 0xaa);
    WriteGPR(4, Zeros{PTO_XLEN} + 2);
    _ReservationValid = TRUE;
    _ReservationAddress = Zeros{PTO_XLEN} + 0x100;
    _ReservationSize = 8;
    _LastMemoryCommandAddress = Zeros{PTO_XLEN} + 0x120;
    _LastMemoryCommandSize = Zeros{PTO_XLEN} + 9;

    let status = ExecuteCommandInstruction(
        MSETRangeInstruction(2, 3, 4), 32);

    assert status == CommandExecution_Rejected;
    assert _LastFault == Fault_IllegalInstruction;
    assert _FaultAddress == instruction_pc;
    assert _ReservationValid;
    assert _LastMemoryCommandAddress == Zeros{PTO_XLEN} + 0x120;
    assert _LastMemoryCommandSize == Zeros{PTO_XLEN} + 9;
    assert ReadTPC() == instruction_pc;
    return 0;
end;
