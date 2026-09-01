// PTO-TEST: {"id":"PTO-AVS-BLOCK-FRET-STK-ODD-TARGET-002","source":"asl/block/lifecycle/FRET.STK.asl","requirements":["PTO-INST-BLOCK-FRET-STK"],"kind":"fault","summary":"FRET.STK rejects an odd stack target before restoring ra","pass_condition":"slot-zero target validation raises InstructionPC with adjusted sp but zero load progress and no destination effect","related_sources":["asl/block/model/lifecycle/lifetime.asl","asl/arch/state/trap-context.asl"]}
func main() => integer
begin
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x680);
    WriteGPR(1, Zeros{PTO_XLEN} + 0x2f8);
    WriteGPR(10, Zeros{PTO_XLEN} + 0x777);
    WriteMemoryByte(Zeros{PTO_XLEN} + 0x2f8, Zeros{8} + 1);
    WriteMemoryByte(Zeros{PTO_XLEN} + 0x2f9, Zeros{8} + 9);
    _ReturnAddress = Zeros{PTO_XLEN} + 0x777;
    _FrameDepth = 1;

    ReturnFromFrame(10, 10, Zeros{PTO_XLEN} + 8, FALSE);

    assert _LastFault == Fault_InstructionPC;
    assert _FaultAddress == Zeros{PTO_XLEN} + 0x901;
    assert ReadGPR(1) == Zeros{PTO_XLEN} + 0x300;
    assert ReadGPR(10) == Zeros{PTO_XLEN} + 0x777;
    assert _ReturnAddress == Zeros{PTO_XLEN} + 0x777;
    assert _TrapContexts[[0]].valid;
    assert _TrapContexts[[0]].tpc == Zeros{PTO_XLEN} + 0x680;
    assert _FrameDepth == 1;
    assert _FrameTemplate.active;
    assert _FrameTemplate.stack_adjusted;
    assert _FrameTemplate.progress == 0;
    assert !_FrameTemplate.return_target_valid;
    return 0;
end;
