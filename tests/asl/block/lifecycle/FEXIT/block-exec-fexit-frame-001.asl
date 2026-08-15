// PTO-TEST: {"id":"PTO-AVS-BLOCK-FEXIT-FRAME-001","source":"asl/block/lifecycle/FEXIT.asl","requirements":["PTO-INST-BLOCK-FEXIT"],"kind":"execution","summary":"FEXIT restores an inclusive register range after adding the frame size to sp","pass_condition":"the caller sp is restored first, two descending slots load in range order, and the command retires once","related_sources":["asl/block/model/lifecycle/lifetime.asl"]}
pure func FEXITInstruction(begin_reg: Reg5Selector,
                           end_reg: Reg5Selector,
                           size: Word) => bits(64)
begin
    var instruction = Zeros{64} + 0x00001041;
    instruction[19:15] = Zeros{5} + begin_reg;
    instruction[24:20] = Zeros{5} + end_reg;
    instruction[31:25] = size[9:3];
    instruction[11:7] = size[14:10];
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x580);
    WriteGPR(2, Zeros{PTO_XLEN} + 0x2f0);
    WriteMemoryByte(Zeros{PTO_XLEN} + 0x2f8, Zeros{8} + 0x11);
    WriteMemoryByte(Zeros{PTO_XLEN} + 0x2f9, Zeros{8} + 0x11);
    WriteMemoryByte(Zeros{PTO_XLEN} + 0x2f0, Zeros{8} + 0x22);
    WriteMemoryByte(Zeros{PTO_XLEN} + 0x2f1, Zeros{8} + 0x22);
    _FrameDepth = 1;
    StartMemoryEventCapture(0);

    let status = ExecuteCommandInstruction(
        FEXITInstruction(3, 4, Zeros{PTO_XLEN} + 16),
        32);

    assert status == CommandExecution_Executed;
    assert _LastFault == Fault_None;
    assert ReadGPR(2) == Zeros{PTO_XLEN} + 0x300;
    assert ReadGPR(3) == Zeros{PTO_XLEN} + 0x1111;
    assert ReadGPR(4) == Zeros{PTO_XLEN} + 0x2222;
    assert _MemoryEventCount == 2;
    assert _FrameDepth == 0;
    assert !_FrameTemplate.active;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x584;
    return 0;
end;
