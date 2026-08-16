// PTO-TEST: {"id":"PTO-AVS-ARCH-TRAP-PORTABLE-FAULT-004","source":"asl/arch/state/trap-context.asl","requirements":[],"kind":"fault","summary":"portable trap helpers restore every portable context leaf","pass_condition":"portable argument and return-state leaves recover exactly","related_sources":[]}
func TestPortableTrapLeafRecovery()
begin
    // Execute the portable default helper directly even under the PTO v0
    // profile, so the concrete override cannot hide default-path drift.
    ResetProfileState();
    SetCurrentACR(15);
    _BundleArgument = Zeros{PTO_XLEN} + 0x1110;
    _CommitArgument = Zeros{PTO_XLEN} + 0x2220;
    _FrameStackReturnTarget = Zeros{PTO_XLEN} + 0x3330;
    _ReturnAddress = Zeros{PTO_XLEN} + 0x4440;
    _BundleArgumentKind = Zeros{3} + 6;
    SavePortableTrapContext(2, 15);
    _BundleArgument = Zeros{PTO_XLEN};
    _CommitArgument = Zeros{PTO_XLEN};
    _FrameStackReturnTarget = Zeros{PTO_XLEN};
    _ReturnAddress = Zeros{PTO_XLEN};
    _BundleArgumentKind = Zeros{3};
    let recovered_portable_context = RecoverPortableTrapContext(2);
    assert recovered_portable_context;
    assert _BundleArgument == Zeros{PTO_XLEN} + 0x1110;
    assert _CommitArgument == Zeros{PTO_XLEN} + 0x2220;
    assert _FrameStackReturnTarget == Zeros{PTO_XLEN} + 0x3330;
    assert _ReturnAddress == Zeros{PTO_XLEN} + 0x4440;
    assert _BundleArgumentKind == Zeros{3} + 6;
end;
func main() => integer
begin
    ResetProfileState();
    TestPortableTrapLeafRecovery();
    return 0;
end;
