// PTO-TEST: {"id":"PTO-AVS-BLOCK-FENTRY-FRAME-001","source":"asl/block/lifecycle/FENTRY.asl","requirements":["PTO-INST-BLOCK-FENTRY"],"kind":"execution","summary":"FENTRY snapshots the inclusive register ring before updating sp and stores it in descending slots","pass_condition":"a two-register frame stores both explicit range registers from the pre-entry snapshot, updates the separate architectural sp once, records two stores, and retires","related_sources":["asl/block/model/lifecycle/lifetime.asl"]}
pure func FENTRYInstruction(begin_reg: Reg5Selector,
                            end_reg: Reg5Selector,
                            size: Word) => bits(64)
begin
    var instruction = Zeros{64} + 0x00000041;
    instruction[19:15] = Zeros{5} + begin_reg;
    instruction[24:20] = Zeros{5} + end_reg;
    instruction[31:25] = size[9:3];
    instruction[11:7] = size[14:10];
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x500);
    WriteGPR(1, Zeros{PTO_XLEN} + 0x300);
    WriteGPR(2, Zeros{PTO_XLEN} + 0x2233);
    WriteGPR(3, Zeros{PTO_XLEN} + 0x3344);
    StartMemoryEventCapture(0);

    let status = ExecuteCommandInstruction(
        FENTRYInstruction(2, 3, Zeros{PTO_XLEN} + 16),
        32);

    assert status == CommandExecution_Executed;
    assert ReadGPR(1) == Zeros{PTO_XLEN} + 0x2f0;
    assert ReadMemoryByte(Zeros{PTO_XLEN} + 0x2f8) == Zeros{8} + 0x33;
    assert ReadMemoryByte(Zeros{PTO_XLEN} + 0x2f9) == Zeros{8} + 0x22;
    assert ReadMemoryByte(Zeros{PTO_XLEN} + 0x2f0) == Zeros{8} + 0x44;
    assert ReadMemoryByte(Zeros{PTO_XLEN} + 0x2f1) == Zeros{8} + 0x33;
    assert _MemoryEventCount == 2;
    assert _FrameDepth == 1;
    assert !_FrameTemplate.active;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x504;
    return 0;
end;
