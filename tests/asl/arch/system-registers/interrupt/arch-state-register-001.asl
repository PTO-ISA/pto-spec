// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-ARCH-TESTINTERRUPTREGISTERSTATE-STATE-TRANSITION-001","source":"asl/arch/system-registers/interrupt.asl","requirements":[],"kind":"state-transition","summary":"Covers Interrupt Register State.","pass_condition":"TestInterruptRegisterState completes without assertion failure","related_sources":[]}
func TestInterruptRegisterState()
begin
    ResetProfileState();
    _SystemRegisters.cycle = Zeros{PTO_XLEN} + 9;
    let timer_alias = ReadSystemRegisterAddress(Zeros{24} + 0x0f20);
    // SYSREG-EFFECT-WITNESS timer-time/aliases-architectural-time
    assert timer_alias == Zeros{PTO_XLEN} + 9;
    BeginArchitecturalInstructionAttempt();
    // SYSREG-EFFECT-WITNESS architectural-time/advances-on-every-execution-attempt
    assert _SystemRegisters.cycle == Zeros{PTO_XLEN} + 10;
    ResetProfileState();
    assert _ExtendedSystemRegisters[[0x0f07]] == Zeros{PTO_XLEN} + 3;
    assert _ExtendedSystemRegisters[[0xff07]] == Zeros{PTO_XLEN} + 3;
    let reset_pending = ReadSystemRegisterAddress(Zeros{24} + 0x0f08);
    assert reset_pending == Zeros{PTO_XLEN};

    SetInterruptPending(0, 7);
    SetInterruptPending(0, 2);
    let pending = ReadSystemRegisterAddress(Zeros{24} + 0x0f08);
    let top = ReadSystemRegisterAddress(Zeros{24} + 0x0f09);
    // SYSREG-EFFECT-WITNESS interrupt-pending/reflects-external-and-timer-pending-sources
    assert pending[7] == '1' && pending[2] == '1';
    // SYSREG-EFFECT-WITNESS top-pending-interrupt/priority-derived-from-pending-bitmap
    assert top == Zeros{PTO_XLEN} + 2;
    _ACRTrapAsynchronous[[0]] = TRUE;
    _ACRTrapArgumentValid[[0]] = TRUE;
    WriteSystemRegisterAddress(Zeros{24} + 0x0f0a,
        Zeros{PTO_XLEN} + 2);
    let remaining_top = ReadSystemRegisterAddress(Zeros{24} + 0x0f09);
    assert remaining_top == Zeros{PTO_XLEN} + 7;
    WriteSystemRegisterAddress(Zeros{24} + 0x0f0a,
        Zeros{PTO_XLEN} + 7);
    let acknowledged_pending = ReadSystemRegisterAddress(Zeros{24} + 0x0f08);
    // SYSREG-EFFECT-WITNESS end-of-interrupt/clears-selected-pending-id
    assert acknowledged_pending == Zeros{PTO_XLEN};
    // SYSREG-EFFECT-WITNESS end-of-interrupt/clears-asynchronous-trap-status
    assert !_ACRTrapAsynchronous[[0]] && !_ACRTrapArgumentValid[[0]];

    // Both endpoints of the architectural interrupt-ID domain become pending
    // without taking a trap when external interrupt entry is disabled.
    WriteSystemRegisterAddress(Zeros{24} + 0x0f07, Zeros{PTO_XLEN} + 2);
    ClearFault();
    WriteTPC(Zeros{PTO_XLEN} + 0x5150);
    RaiseInterrupt(0, Zeros{24} + 0x50);
    RaiseInterrupt(63, Zeros{24} + 0x5f);
    // SYSREG-EFFECT-WITNESS interrupt-configuration/controls-external-and-timer-trap-entry
    assert _LastFault == Fault_None;
    assert CurrentACR() == 0;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x5150;
    assert _ACRTrapNumber[[0]] == Zeros{6};
    assert !_ACRTrapAsynchronous[[0]];
    assert !_TrapContexts[[0]].valid;
    let boundary_pending = ReadSystemRegisterAddress(Zeros{24} + 0x0f08);
    let zero_is_top = ReadSystemRegisterAddress(Zeros{24} + 0x0f09);
    assert boundary_pending[0] == '1' && boundary_pending[63] == '1';
    assert zero_is_top == Zeros{PTO_XLEN};
    WriteSystemRegisterAddress(Zeros{24} + 0x0f0a,
        Zeros{PTO_XLEN});
    let maximum_is_top = ReadSystemRegisterAddress(Zeros{24} + 0x0f09);
    assert maximum_is_top == Zeros{PTO_XLEN} + 63;
    WriteSystemRegisterAddress(Zeros{24} + 0x0f0a,
        Zeros{PTO_XLEN} + 63);
    let boundary_acknowledged = ReadSystemRegisterAddress(Zeros{24} + 0x0f08);
    assert boundary_acknowledged == Zeros{PTO_XLEN};

    // Ring-one timer interrupt ID 3 follows the compare value. Acknowledge can
    // clear it transiently, but it reasserts until software clears comparison.
    _SystemRegisters.cycle = Zeros{PTO_XLEN} + 9;
    WriteSystemRegisterAddress(Zeros{24} + 0x1f21,
        Zeros{PTO_XLEN} + 10);
    let timer_before = ReadSystemRegisterAddress(Zeros{24} + 0x1f08);
    assert timer_before[3] == '0';
    _SystemRegisters.cycle = Zeros{PTO_XLEN} + 10;
    let timer_at_compare = ReadSystemRegisterAddress(Zeros{24} + 0x1f08);
    let timer_top = ReadSystemRegisterAddress(Zeros{24} + 0x1f09);
    // SYSREG-EFFECT-WITNESS timer-compare/refreshes-timer-pending-state
    assert timer_at_compare[3] == '1';
    assert timer_top == Zeros{PTO_XLEN} + 3;
    WriteSystemRegisterAddress(Zeros{24} + 0x1f0a,
        Zeros{PTO_XLEN} + 3);
    let timer_reasserted = ReadSystemRegisterAddress(Zeros{24} + 0x1f08);
    assert timer_reasserted[3] == '1';
    WriteSystemRegisterAddress(Zeros{24} + 0x1f21,
        Zeros{PTO_XLEN});
    let timer_disabled = ReadSystemRegisterAddress(Zeros{24} + 0x1f08);
    assert timer_disabled[3] == '0';
    ResetProfileState();
end;
func main() => integer
begin
    ResetProfileState();
    TestInterruptRegisterState();
    return 0;
end;
