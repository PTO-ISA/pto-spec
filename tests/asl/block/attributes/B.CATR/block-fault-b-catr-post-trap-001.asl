// PTO-TEST: {"id":"PTO-AVS-BLOCK-B-CATR-POST-TRAP-001","source":"asl/block/attributes/B.CATR.asl","requirements":["PTO-INST-BLOCK-B-CATR"],"kind":"fault","summary":"trap requests a synchronous trap only after successful block commit.","pass_condition":"The saved clean context resumes the selected continuation and contains no retired block state.","related_sources":["asl/block/model/lifecycle/enter-stop.asl","asl/arch/memory-model/fault-precision.asl"]}
func main() => integer
begin
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x100);
    BeginBundle(BundleKind_Standard, BundleTransfer_Fallthrough,
        Zeros{PTO_XLEN} + 0x180, Zeros{PTO_XLEN} + 0x104,
        Zeros{PTO_XLEN} + 0x104, TRUE);
    SetBundleControlAttributeState(TRUE, FALSE, FALSE, FALSE, FALSE, FALSE);
    let committed = CompleteBundleAt(Zeros{PTO_XLEN} + 0x104);
    assert !committed;
    assert _LastFault == Fault_BundlePostCommit;
    assert !_BundleActive;
    let trap_ring = CurrentACR();
    assert _TrapContexts[[trap_ring]].valid;
    assert _TrapContexts[[trap_ring]].tpc == Zeros{PTO_XLEN} + 0x104;
    assert !_TrapContexts[[trap_ring]].bundle_active;
    assert !_TrapContexts[[trap_ring]].bundle_control_attributes.present;
    let recovered = RecoverTrapContext(trap_ring);
    assert recovered;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x104;
    return 0;
end;
