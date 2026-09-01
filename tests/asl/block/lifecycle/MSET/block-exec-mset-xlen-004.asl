// PTO-TEST: {"id":"PTO-AVS-BLOCK-MSET-XLEN-004","source":"asl/block/lifecycle/MSET.asl","requirements":["PTO-INST-BLOCK-MSET","PTO-BLOCK-MSET-FILL-001"],"kind":"execution","summary":"MSET accepts a complete XLEN length above the obsolete 63-byte bound","pass_condition":"a 70-byte fill publishes every byte, preserves the following byte, records the full length, and advances TPC once","related_sources":["asl/block/model/commit/effects.asl"]}
pure func MSETXLENInstruction(destination: Reg5Selector,
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
    WriteTPC(Zeros{PTO_XLEN} + 0x840);
    WriteGPR(2, Zeros{PTO_XLEN} + 0x200);
    WriteGPR(3, Zeros{PTO_XLEN} + 0x12ab);
    WriteGPR(4, Zeros{PTO_XLEN} + 70);
    WriteMemoryByte(Zeros{PTO_XLEN} + 0x246, Zeros{8} + 0x5a);

    let status = ExecuteCommandInstruction(
        MSETXLENInstruction(2, 3, 4), 32);

    assert status == CommandExecution_Executed;
    assert _LastFault == Fault_None;
    for byte_index = 0 to 69 do
        let offset = NaturalToWord(byte_index as integer {0..262144});
        assert ReadMemoryByte(Zeros{PTO_XLEN} + 0x200 + offset) ==
            Zeros{8} + 0xab;
    end;
    assert ReadMemoryByte(Zeros{PTO_XLEN} + 0x246) == Zeros{8} + 0x5a;
    assert _LastMemoryCommandAddress == Zeros{PTO_XLEN} + 0x200;
    assert _LastMemoryCommandSize == Zeros{PTO_XLEN} + 70;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x844;
    return 0;
end;
