// PTO-TEST: {"id":"PTO-AVS-ARCH-EXTENSION-FIRST-USE-DEFAULT-001","source":"asl/arch/profile/extension-first-use.asl","requirements":["PTO-ARCH-EXTENSION-FIRST-USE-PROFILE-001"],"kind":"execution","summary":"portable extension first-use hooks are disabled and effect-free","pass_condition":"both kinds report disabled, raise no trap, and preserve trap, bundle, queue, memory, and fault state","related_sources":["asl/arch/programming-model/execution-context.asl","asl/arch/memory-model/fault-precision.asl"]}
func main() => integer
begin
    ResetProfileState();
    SetCurrentACR(2);
    WriteTPC(Zeros{PTO_XLEN} + 0x400);
    _BundleArgument = Zeros{PTO_XLEN} + 0x55;
    PushTemporaryQueue(TRUE, Zeros{PTO_XLEN} + 0x66);
    _MemoryEventCaptureEnabled = TRUE;
    let trap_number_before = _ACRTrapNumber[[1]];
    let trap_argument_before = _ACRTrapArgument0[[1]];
    let bundle_before = _BundleArgument;
    let queue_before = ReadTemporaryQueue(TRUE, 0);
    let memory_capture_before = _MemoryEventCaptureEnabled;
    let fault_before = _LastFault;

    assert ExtensionFirstUseKind_VECTOR != ExtensionFirstUseKind_CUBE;
    assert !ExtensionFirstUseEnabled(ExtensionFirstUseKind_VECTOR);
    assert !ExtensionFirstUseEnabled(ExtensionFirstUseKind_CUBE);
    let vector_raised = RaiseExtensionFirstUse(
        ExtensionFirstUseKind_VECTOR, CurrentACR(), 1);
    let cube_raised = RaiseExtensionFirstUse(
        ExtensionFirstUseKind_CUBE, CurrentACR(), 1);
    assert !vector_raised;
    assert !cube_raised;

    assert _ACRTrapNumber[[1]] == trap_number_before;
    assert _ACRTrapArgument0[[1]] == trap_argument_before;
    assert _BundleArgument == bundle_before;
    assert ReadTemporaryQueue(TRUE, 0) == queue_before;
    assert _MemoryEventCaptureEnabled == memory_capture_before;
    assert _LastFault == fault_before;
    return 0;
end;
