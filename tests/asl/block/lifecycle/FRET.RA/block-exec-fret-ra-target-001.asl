// PTO-TEST: {"id":"PTO-AVS-BLOCK-FRET-RA-TARGET-001","source":"asl/block/lifecycle/FRET.RA.asl","requirements":["PTO-INST-BLOCK-FRET-RA"],"kind":"execution","summary":"FRET.RA snapshots the pre-restore return address and returns only after restoring the selected range","pass_condition":"frame loads may overwrite ra without changing the already validated return target, which becomes TPC after all loads","related_sources":["asl/block/model/lifecycle/lifetime.asl"]}
pure func FRETRAInstruction(begin_reg: Reg5Selector,
                            end_reg: Reg5Selector,
                            size: Word) => bits(64)
begin
    var instruction = Zeros{64} + 0x00002041;
    instruction[19:15] = Zeros{5} + begin_reg;
    instruction[24:20] = Zeros{5} + end_reg;
    instruction[31:25] = size[9:3];
    instruction[11:7] = size[14:10];
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x600);
    WriteGPR(2, Zeros{PTO_XLEN} + 0x2f0);
    WriteMemoryByte(Zeros{PTO_XLEN} + 0x2f8, Zeros{8} + 0x34);
    WriteMemoryByte(Zeros{PTO_XLEN} + 0x2f9, Zeros{8} + 0x12);
    _ReturnAddress = Zeros{PTO_XLEN} + 0x800;
    _FrameDepth = 1;

    let status = ExecuteCommandInstruction(
        FRETRAInstruction(10, 10, Zeros{PTO_XLEN} + 16),
        32);

    assert status == CommandExecution_Executed;
    assert _LastFault == Fault_None;
    assert ReadGPR(10) == Zeros{PTO_XLEN} + 0x1234;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x800;
    assert _FrameDepth == 0;
    return 0;
end;
