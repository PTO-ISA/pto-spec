// PTO-TEST: {"id":"PTO-AVS-BLOCK-FRET-STK-TARGET-001","source":"asl/block/lifecycle/FRET.STK.asl","requirements":["PTO-INST-BLOCK-FRET-STK"],"kind":"execution","summary":"FRET.STK obtains its target from stack slot zero and restores the remaining range before returning","pass_condition":"an even slot-zero target updates ra and TPC, the next slot restores the next ring register, and the frame completes once","related_sources":["asl/block/model/lifecycle/lifetime.asl"]}
pure func FRETSTKInstruction(begin_reg: Reg5Selector,
                             end_reg: Reg5Selector,
                             size: Word) => bits(64)
begin
    var instruction = Zeros{64} + 0x00003041;
    instruction[19:15] = Zeros{5} + begin_reg;
    instruction[24:20] = Zeros{5} + end_reg;
    instruction[31:25] = size[9:3];
    instruction[11:7] = size[14:10];
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x640);
    WriteGPR(2, Zeros{PTO_XLEN} + 0x2f0);
    WriteMemoryByte(Zeros{PTO_XLEN} + 0x2f8, Zeros{8});
    WriteMemoryByte(Zeros{PTO_XLEN} + 0x2f9, Zeros{8} + 9);
    WriteMemoryByte(Zeros{PTO_XLEN} + 0x2f0, Zeros{8} + 0xcd);
    WriteMemoryByte(Zeros{PTO_XLEN} + 0x2f1, Zeros{8} + 0xab);
    _FrameDepth = 1;

    let status = ExecuteCommandInstruction(
        FRETSTKInstruction(10, 11, Zeros{PTO_XLEN} + 16),
        32);

    assert status == CommandExecution_Executed;
    assert _LastFault == Fault_None;
    assert ReadGPR(10) == Zeros{PTO_XLEN} + 0x900;
    assert _ReturnAddress == Zeros{PTO_XLEN} + 0x900;
    assert ReadGPR(11) == Zeros{PTO_XLEN} + 0xabcd;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x900;
    assert _FrameDepth == 0;
    return 0;
end;
