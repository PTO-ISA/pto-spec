// PTO-TEST: {"id":"PTO-AVS-BLOCK-FRET-STK-RANGE-001","source":"asl/block/lifecycle/FRET.STK.asl","requirements":["PTO-INST-BLOCK-FRET-STK"],"kind":"fault","summary":"FRET.STK requires the inclusive restore range to begin at ra","pass_condition":"a different legal ring endpoint raises Fault_IllegalInstruction before sp, memory, registers, target, depth, or progress changes","related_sources":["asl/block/model/lifecycle/lifetime.asl"]}
func main() => integer
begin
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x680);
    WriteGPR(2, Zeros{PTO_XLEN} + 0x2f8);
    _FrameDepth = 1;

    ReturnFromFrame(9, 10, Zeros{PTO_XLEN} + 16, FALSE);

    assert _LastFault == Fault_IllegalInstruction;
    assert ReadGPR(2) == Zeros{PTO_XLEN} + 0x2f8;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x680;
    assert _FrameDepth == 1;
    assert !_FrameTemplate.active;
    return 0;
end;
