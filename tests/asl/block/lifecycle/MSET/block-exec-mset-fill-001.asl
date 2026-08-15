// PTO-TEST: {"id":"PTO-AVS-BLOCK-MSET-FILL-001","source":"asl/block/lifecycle/MSET.asl","requirements":["PTO-INST-BLOCK-MSET"],"kind":"execution","summary":"MSET replicates the low fill byte and records successful zero and nonzero ranges","pass_condition":"a three-byte fill publishes only the low byte, then a zero-length command performs no memory access while recording destination and zero size","related_sources":["asl/block/model/commit/effects.asl"]}
pure func MSETInstruction(destination: Reg5Selector, value: Reg5Selector,
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
    WriteTPC(Zeros{PTO_XLEN} + 0x5c0);
    WriteGPR(2, Zeros{PTO_XLEN} + 0x100);
    WriteGPR(3, Zeros{PTO_XLEN} + 0x12ab);
    WriteGPR(4, Zeros{PTO_XLEN} + 3);

    let fill = ExecuteCommandInstruction(MSETInstruction(2, 3, 4), 32);
    assert fill == CommandExecution_Executed;
    assert ReadMemoryByte(Zeros{PTO_XLEN} + 0x100) == Zeros{8} + 0xab;
    assert ReadMemoryByte(Zeros{PTO_XLEN} + 0x101) == Zeros{8} + 0xab;
    assert ReadMemoryByte(Zeros{PTO_XLEN} + 0x102) == Zeros{8} + 0xab;
    assert ReadMemoryByte(Zeros{PTO_XLEN} + 0x103) == Zeros{8};
    assert _LastMemoryCommandAddress == Zeros{PTO_XLEN} + 0x100;
    assert _LastMemoryCommandSize == Zeros{PTO_XLEN} + 3;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x5c4;

    WriteGPR(2, Zeros{PTO_XLEN} + 0x180);
    WriteGPR(4, Zeros{PTO_XLEN});
    let zero = ExecuteCommandInstruction(MSETInstruction(2, 3, 4), 32);
    assert zero == CommandExecution_Executed;
    assert ReadMemoryByte(Zeros{PTO_XLEN} + 0x180) == Zeros{8};
    assert _LastMemoryCommandAddress == Zeros{PTO_XLEN} + 0x180;
    assert _LastMemoryCommandSize == Zeros{PTO_XLEN};
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x5c8;
    return 0;
end;
