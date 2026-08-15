// PTO-TEST: {"id":"PTO-AVS-BLOCK-MCOPY-OVERLAP-001","source":"asl/block/lifecycle/MCOPY.asl","requirements":["PTO-INST-BLOCK-MCOPY"],"kind":"fault","summary":"MCOPY rejects exact and partial overlap before memory-step effects","pass_condition":"overlapping ranges raise Fault_IllegalInstruction at the current TPC and preserve destination bytes, memory events, progress, and last-command state","related_sources":["asl/block/model/commit/effects.asl"]}
pure func MCOPYInstruction(destination: Reg5Selector, source: Reg5Selector,
                           length: Reg5Selector) => bits(64)
begin
    var instruction = Zeros{64} + 0x00000031;
    instruction[19:15] = Zeros{5} + destination;
    instruction[24:20] = Zeros{5} + source;
    instruction[31:27] = Zeros{5} + length;
    return instruction;
end;

func AssertMCOPYOverlapRejected(destination: Word, source: Word)
begin
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x680);
    WriteGPR(2, destination);
    WriteGPR(3, source);
    WriteGPR(4, Zeros{PTO_XLEN} + 8);
    _LastMemoryCommandAddress = Ones{PTO_XLEN};
    _LastMemoryCommandSize = Ones{PTO_XLEN};
    StartMemoryEventCapture(0);
    for byte_index = 0 to 11 do
        WriteMemoryByte(
            Zeros{PTO_XLEN} + 0x100 +
                NaturalToWord(byte_index as integer {0..262144}),
            Zeros{8} + byte_index + 1);
    end;

    let status = ExecuteCommandInstruction(MCOPYInstruction(2, 3, 4), 32);

    assert status == CommandExecution_Rejected;
    assert _LastFault == Fault_IllegalInstruction;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x680;
    assert _MemoryEventCount == 0;
    assert _LastMemoryCommandAddress == Ones{PTO_XLEN};
    assert _LastMemoryCommandSize == Ones{PTO_XLEN};
    for byte_index = 0 to 11 do
        assert ReadMemoryByte(
            Zeros{PTO_XLEN} + 0x100 +
                NaturalToWord(byte_index as integer {0..262144})) ==
            Zeros{8} + byte_index + 1;
    end;
end;

func main() => integer
begin
    AssertMCOPYOverlapRejected(
        Zeros{PTO_XLEN} + 0x100, Zeros{PTO_XLEN} + 0x100);
    AssertMCOPYOverlapRejected(
        Zeros{PTO_XLEN} + 0x104, Zeros{PTO_XLEN} + 0x100);
    AssertMCOPYOverlapRejected(
        Zeros{PTO_XLEN} + 0x100, Zeros{PTO_XLEN} + 0x104);
    return 0;
end;
