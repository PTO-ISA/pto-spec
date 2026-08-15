// PTO-TEST: {"id":"PTO-AVS-BLOCK-MCOPY-XLEN-001","source":"asl/block/lifecycle/MCOPY.asl","requirements":["PTO-INST-BLOCK-MCOPY"],"kind":"execution","summary":"MCOPY accepts a complete XLEN length above the obsolete 63-byte bound","pass_condition":"a disjoint 70-byte range copies in forward memory steps, records the full length, and advances TPC once","related_sources":["asl/block/model/commit/effects.asl"]}
pure func MCOPYInstruction(destination: Reg5Selector, source: Reg5Selector,
                           length: Reg5Selector) => bits(64)
begin
    var instruction = Zeros{64} + 0x00000031;
    instruction[19:15] = Zeros{5} + destination;
    instruction[24:20] = Zeros{5} + source;
    instruction[31:27] = Zeros{5} + length;
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x640);
    WriteGPR(2, Zeros{PTO_XLEN} + 0x200);
    WriteGPR(3, Zeros{PTO_XLEN} + 0x100);
    WriteGPR(4, Zeros{PTO_XLEN} + 70);
    _ReservationValid = TRUE;
    _ReservationAddress = Zeros{PTO_XLEN} + 0x200;
    _ReservationSize = 8;
    for byte_index = 0 to 69 do
        WriteMemoryByte(
            Zeros{PTO_XLEN} + 0x100 +
                NaturalToWord(byte_index as integer {0..262144}),
            Zeros{8} + byte_index + 1);
    end;

    let status = ExecuteCommandInstruction(MCOPYInstruction(2, 3, 4), 32);

    assert status == CommandExecution_Executed;
    assert _LastFault == Fault_None;
    for byte_index = 0 to 69 do
        let offset = NaturalToWord(byte_index as integer {0..262144});
        assert ReadMemoryByte(Zeros{PTO_XLEN} + 0x200 + offset) ==
            ReadMemoryByte(Zeros{PTO_XLEN} + 0x100 + offset);
    end;
    assert _LastMemoryCommandAddress == Zeros{PTO_XLEN} + 0x200;
    assert _LastMemoryCommandSize == Zeros{PTO_XLEN} + 70;
    assert !_ReservationValid;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x644;
    return 0;
end;
