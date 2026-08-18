// PTO-TEST: {"id":"PTO-AVS-BLOCK-FRET-STK-RESTART-003","source":"asl/block/lifecycle/FRET.STK.asl","requirements":["PTO-INST-BLOCK-FRET-STK"],"kind":"fault","summary":"FRET.STK retries the first uncommitted target load without adding sp twice","pass_condition":"a recoverable slot-zero page fault preserves adjusted sp and zero progress; retry restores ra and transfers to the even target once","related_sources":["asl/block/model/lifecycle/lifetime.asl","asl/arch/state/trap-context.asl"]}
func main() => integer
begin
    ResetProfileState();
    let instruction_pc = Zeros{PTO_XLEN} + 0x6c0;
    WriteMemoryByte(Zeros{PTO_XLEN} + 3072, Zeros{8});
    WriteMemoryByte(Zeros{PTO_XLEN} + 3073, Zeros{8} + 9);
    WriteGPR(2, Zeros{PTO_XLEN} + 3072);
    WriteGPR(10, Zeros{PTO_XLEN} + 0x777);
    _ReturnAddress = Zeros{PTO_XLEN} + 0x777;
    _FrameDepth = 1;
    SetCurrentACR(2);
    PTOv0WriteContextRegister(1, 0x0f01, Zeros{PTO_XLEN} + 0x900);
    WriteTPC(instruction_pc);
    ClearFault();

    ReturnFromFrame(10, 10, Zeros{PTO_XLEN} + 8, FALSE);

    assert _LastFault == Fault_DataPage;
    assert ReadGPR(2) == Zeros{PTO_XLEN} + 3080;
    assert ReadGPR(10) == Zeros{PTO_XLEN} + 0x777;
    assert _TrapContexts[[1]].frame_template.active;
    assert _TrapContexts[[1]].frame_template.stack_adjusted;
    assert _TrapContexts[[1]].frame_template.progress == 0;

    let recovered = RecoverTrapContext(1);
    assert recovered;
    SetCurrentACR(0);
    ClearFault();
    ReturnFromFrame(10, 10, Zeros{PTO_XLEN} + 8, FALSE);

    assert _LastFault == Fault_None;
    assert ReadGPR(2) == Zeros{PTO_XLEN} + 3080;
    assert ReadGPR(10) == Zeros{PTO_XLEN} + 0x900;
    assert _ReturnAddress == Zeros{PTO_XLEN} + 0x900;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x900;
    assert _FrameDepth == 0;
    assert !_FrameTemplate.active;
    return 0;
end;
