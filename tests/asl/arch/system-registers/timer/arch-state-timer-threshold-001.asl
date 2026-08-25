// PTO-TEST: {"id":"PTO-AVS-ARCH-SYSTEM-REGISTERS-TIMER-THRESHOLD-001","source":"asl/arch/system-registers/timer.asl","requirements":[],"kind":"state-transition","summary":"timer refresh uses the per-ring interrupt ID and a nonzero inclusive cycle threshold","pass_condition":"zero and unmet comparisons clear pending while equality sets the correct per-ring timer interrupt","related_sources":[]}
func main() => integer
begin
    ResetProfileState();
    let ring0: AccessControlRing = 0;
    let ring1: AccessControlRing = 1;
    let comparison0 = ContextRegisterIndex(ring0, 0x0f21);
    let comparison1 = ContextRegisterIndex(ring1, 0x0f21);

    _SystemRegisters.cycle = Zeros{PTO_XLEN} + 100;
    _ExtendedSystemRegisters[[comparison0]] = Zeros{PTO_XLEN};
    RefreshTimerPending(ring0);
    assert _ExtendedSystemRegisters[[ContextRegisterIndex(ring0, 0x0f08)]][1]
        == '0';

    _ExtendedSystemRegisters[[comparison0]] = Zeros{PTO_XLEN} + 101;
    RefreshTimerPending(ring0);
    assert _ExtendedSystemRegisters[[ContextRegisterIndex(ring0, 0x0f08)]][1]
        == '0';

    _ExtendedSystemRegisters[[comparison0]] = Zeros{PTO_XLEN} + 100;
    RefreshTimerPending(ring0);
    assert _ExtendedSystemRegisters[[ContextRegisterIndex(ring0, 0x0f08)]][1]
        == '1';

    _ExtendedSystemRegisters[[comparison0]] = Zeros{PTO_XLEN};
    RefreshTimerPending(ring0);
    assert _ExtendedSystemRegisters[[ContextRegisterIndex(ring0, 0x0f08)]][1]
        == '0';

    _ExtendedSystemRegisters[[comparison1]] = Zeros{PTO_XLEN} + 100;
    RefreshTimerPending(ring1);
    assert _ExtendedSystemRegisters[[ContextRegisterIndex(ring1, 0x0f08)]][3]
        == '1';
    return 0;
end;
