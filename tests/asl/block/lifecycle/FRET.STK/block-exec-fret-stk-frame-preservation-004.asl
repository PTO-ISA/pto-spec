// PTO-TEST: {"id":"PTO-AVS-BLOCK-FRET-STK-FRAME-PRESERVATION-004","source":"asl/block/lifecycle/FRET.STK.asl","requirements":["PTO-INST-BLOCK-FRET-STK","PTO-FRET-STK-RESTARTABLE-FRAME-001"],"kind":"execution","summary":"FRET.STK restores the entry target after an in-frame arbitrary-length MSET","pass_condition":"FENTRY saves ra and s0 above a large fill that ends exactly before the saved slots, then FRET.STK restores both and returns to the entry target","related_sources":["asl/block/lifecycle/FENTRY.asl","asl/block/lifecycle/MSET.asl","asl/block/model/lifecycle/lifetime.asl","asl/block/model/commit/effects.asl"]}
func main() => integer
begin
    ResetProfileState();
    let caller_sp = Zeros{PTO_XLEN} + 0xf00;
    let frame_size = Zeros{PTO_XLEN} + 512;
    let return_target = Zeros{PTO_XLEN} + 0x900;
    WriteTPC(Zeros{PTO_XLEN} + 0x840);
    WriteGPR(1, caller_sp);
    WriteGPR(10, return_target);
    WriteGPR(11, Zeros{PTO_XLEN} + 0xbeef);
    _ReturnAddress = return_target;

    EnterFrame(10, 11, frame_size);

    assert _LastFault == Fault_None;
    assert ReadGPR(1) == caller_sp - frame_size;
    WriteGPR(10, Zeros{PTO_XLEN} + 0x1234);
    WriteGPR(11, Zeros{PTO_XLEN} + 0x5678);
    _ReturnAddress = Zeros{PTO_XLEN} + 0x1234;
    ExecuteMemorySet(
        (caller_sp - frame_size) + (Zeros{PTO_XLEN} + 64),
        Zeros{PTO_XLEN},
        Zeros{PTO_XLEN} + 432);
    assert _LastFault == Fault_None;

    ReturnFromFrame(10, 11, frame_size, FALSE);

    assert _LastFault == Fault_None;
    assert ReadGPR(1) == caller_sp;
    assert ReadGPR(10) == return_target;
    assert _ReturnAddress == return_target;
    assert ReadGPR(11) == Zeros{PTO_XLEN} + 0xbeef;
    assert ReadTPC() == return_target;
    return 0;
end;
