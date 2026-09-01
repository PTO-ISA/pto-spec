// PTO-TEST: {"id":"PTO-AVS-BLOCK-FENTRY-ACCESS-RECOVERY-002","source":"asl/block/lifecycle/FENTRY.asl","requirements":["PTO-INST-BLOCK-FENTRY"],"kind":"fault","summary":"FENTRY recovery retries the first uncommitted store without adjusting sp or repeating a store","pass_condition":"a page fault preserves adjusted sp and zero progress; recovery stores the snapshotted source once and completes the frame","related_sources":["asl/block/model/lifecycle/lifetime.asl","asl/arch/state/trap-context.asl"]}
func main() => integer
begin
    ResetProfileState();
    let instruction_pc = Zeros{PTO_XLEN} + 0x700;
    WriteGPR(1, Zeros{PTO_XLEN} + 3080);
    WriteGPR(3, Zeros{PTO_XLEN} + 0x55aa);
    SetCurrentACR(2);
    PTOv0WriteContextRegister(1, 0x0f01, Zeros{PTO_XLEN} + 0x900);
    WriteTPC(instruction_pc);
    ClearFault();

    EnterFrame(3, 3, Zeros{PTO_XLEN} + 8);

    assert _LastFault == Fault_DataPage;
    assert ReadGPR(1) == Zeros{PTO_XLEN} + 3072;
    assert _TrapContexts[[1]].frame_template.active;
    assert _TrapContexts[[1]].frame_template.stack_adjusted;
    assert _TrapContexts[[1]].frame_template.progress == 0;
    assert ReadMemoryByte(Zeros{PTO_XLEN} + 3072) == Zeros{8};

    let recovered = RecoverTrapContext(1);
    assert recovered;
    SetCurrentACR(0);
    ClearFault();
    EnterFrame(3, 3, Zeros{PTO_XLEN} + 8);

    assert _LastFault == Fault_None;
    assert ReadGPR(1) == Zeros{PTO_XLEN} + 3072;
    assert ReadMemoryByte(Zeros{PTO_XLEN} + 3072) == Zeros{8} + 0xaa;
    assert ReadMemoryByte(Zeros{PTO_XLEN} + 3073) == Zeros{8} + 0x55;
    assert _FrameDepth == 1;
    assert !_FrameTemplate.active;
    return 0;
end;
