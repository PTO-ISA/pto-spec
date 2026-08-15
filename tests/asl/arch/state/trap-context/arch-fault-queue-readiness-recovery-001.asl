// PTO-UNIT: {"id":"PTO-TEST-ARCH-QUEUE-READINESS-RECOVERY-001","surface":"arch","classification":["state","trap-context","arch-fault-queue-readiness-recovery-001"],"depends_on":["PTO-ARCH-STATE-TRAP-CONTEXT"]}
// PTO-TEST: {"id":"PTO-AVS-ARCH-QUEUE-READINESS-RECOVERY-001","source":"asl/arch/state/trap-context.asl","requirements":["PTO-REQ-STATE-001"],"kind":"fault","summary":"Trap save and recovery preserve temporary queue values and their relative-source readiness","pass_condition":"after recovery the saved newest T/U entries remain available, older unsupplied entries remain unavailable, and post-save pushes are discarded","related_sources":["asl/arch/data-types/trap-context.asl","asl/arch/profile/reference-profile.asl"]}

func main() => integer
begin
    ResetProfileState();
    PushTemporaryQueue(TRUE, Zeros{PTO_XLEN} + 0x11);
    PushTemporaryQueue(FALSE, Zeros{PTO_XLEN} + 0x22);

    SaveTrapContext(1, 0);

    PushTemporaryQueue(TRUE, Zeros{PTO_XLEN} + 0x33);
    PushTemporaryQueue(FALSE, Zeros{PTO_XLEN} + 0x44);
    assert TemporaryQueueSourceAvailable(TRUE, 1);
    assert TemporaryQueueSourceAvailable(FALSE, 1);

    let recovered = RecoverTrapContext(1);
    assert recovered;
    assert TemporaryQueueSourceAvailable(TRUE, 0);
    assert !TemporaryQueueSourceAvailable(TRUE, 1);
    assert TemporaryQueueSourceAvailable(FALSE, 0);
    assert !TemporaryQueueSourceAvailable(FALSE, 1);
    assert ReadTemporaryQueue(TRUE, 0) == Zeros{PTO_XLEN} + 0x11;
    assert ReadTemporaryQueue(FALSE, 0) == Zeros{PTO_XLEN} + 0x22;
    return 0;
end;
