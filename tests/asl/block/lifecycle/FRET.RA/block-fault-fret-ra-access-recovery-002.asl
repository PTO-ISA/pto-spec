// PTO-TEST: {"id":"PTO-AVS-BLOCK-FRET-RA-ACCESS-RECOVERY-002","source":"asl/block/lifecycle/FRET.RA.asl","requirements":["PTO-INST-BLOCK-FRET-RA"],"kind":"fault","summary":"FRET.RA recovery retries the first uncommitted load without adding sp twice or changing the retained target","pass_condition":"a page fault preserves adjusted sp and target; recovery restores the register and transfers to the pre-restore ra once","related_sources":["asl/block/model/lifecycle/lifetime.asl","asl/arch/state/trap-context.asl"]}
func main() => integer
begin
    ResetProfileState();
    WriteMemoryByte(Zeros{PTO_XLEN} + 3072, Zeros{8} + 0x44);
    WriteGPR(2, Zeros{PTO_XLEN} + 3072);
    WriteGPR(3, Zeros{PTO_XLEN} + 0x7777);
    WriteGPR(10, Zeros{PTO_XLEN} + 0x900);
    _ReturnAddress = Zeros{PTO_XLEN} + 0x900;
    _FrameDepth = 1;
    SetCurrentACR(2);
    PTOv0WriteContextRegister(1, 0x0f01, Zeros{PTO_XLEN} + 0x900);
    WriteTPC(Zeros{PTO_XLEN} + 0x740);
    ClearFault();

    ReturnFromFrame(3, 3, Zeros{PTO_XLEN} + 8, TRUE);
    assert _LastFault == Fault_DataPage;
    assert ReadGPR(2) == Zeros{PTO_XLEN} + 3080;
    assert ReadGPR(3) == Zeros{PTO_XLEN} + 0x7777;
    assert _TrapContexts[[1]].frame_template.progress == 0;

    let recovered = RecoverTrapContext(1);
    assert recovered;
    SetCurrentACR(0);
    ClearFault();
    ReturnFromFrame(3, 3, Zeros{PTO_XLEN} + 8, TRUE);
    assert _LastFault == Fault_None;
    assert ReadGPR(2) == Zeros{PTO_XLEN} + 3080;
    assert ReadGPR(3)[7:0] == Zeros{8} + 0x44;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x900;
    assert _FrameDepth == 0;
    return 0;
end;
