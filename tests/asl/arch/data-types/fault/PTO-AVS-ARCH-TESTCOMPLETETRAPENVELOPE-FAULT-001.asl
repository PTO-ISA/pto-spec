// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-ARCH-TESTCOMPLETETRAPENVELOPE-FAULT-001","source":"asl/arch/data-types/fault.asl","requirements":[],"kind":"fault","summary":"migrated independent behavior point for TestCompleteTrapEnvelope","pass_condition":"TestCompleteTrapEnvelope completes without assertion failure","related_sources":[]}
func CheckSynchronousTrapMapping(code: FaultCode, expected: TrapNumber)
begin
    ResetProfileState();
    SetCurrentACR(15);
    WriteTPC(Zeros{PTO_XLEN} + 0x1000);
    SetFault(code, Zeros{PTO_XLEN} + 0x2000);
    assert CurrentACR() == 1;
    // TRAP-WITNESS envelope/assert-number
    // SYSREG-EFFECT-WITNESS trap-status/reads-and-writes-trap-bank-fields
    assert _ACRTrapNumber[[1]] == expected;
    assert _ACRTrapArgumentValid[[1]];
    assert !_ACRTrapAsynchronous[[1]];
    assert _ACRTrapCause[[1]] == Zeros{24};
    // TRAP-WITNESS envelope/assert-argument
    // SYSREG-EFFECT-WITNESS trap-argument/reads-and-writes-trap-bank-argument
    assert _ACRTrapArgument0[[1]] == Zeros{PTO_XLEN} + 0x2000;
    assert _TrapContexts[[1]].valid;
    assert _TrapContexts[[1]].source_acr == 15;
    assert _TrapContexts[[1]].tpc == Zeros{PTO_XLEN} + 0x1000;
    let recovered = RecoverTrapContext(CurrentACR());
    assert recovered;
    // SYSREG-EFFECT-WITNESS execution-context-state/save-and-recovery-profile-state
    // SYSREG-EFFECT-WITNESS saved-execution-context/save-and-recovery-profile-state
    assert CurrentACR() == 15;
    // TRAP-WITNESS envelope/assert-restart
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x1000;
    assert !_TrapContexts[[1]].valid;
end;

func CheckServiceRequestTrapMapping()
begin
    ResetProfileState();
    WriteSystemRegisterAddress(Zeros{24} + 0x1f01,
        Zeros{PTO_XLEN} + 0x900);
    SetCurrentACR(2);
    WriteTPC(Zeros{PTO_XLEN} + 0x400);
    let entered = RaiseServiceRequest('0001');
    assert entered;
    assert _LastFault == Fault_ServiceRequest;
    assert _FaultAddress == Zeros{PTO_XLEN} + 0x400;
    assert CurrentACR() == 1;
    // TRAP-WITNESS scall/assert-number
    assert _ACRTrapNumber[[1]] == Zeros{6} + 6;
    // TRAP-WITNESS scall/assert-argument
    assert _ACRTrapArgument0[[1]] == Zeros{PTO_XLEN} + 0x400;
    // TRAP-WITNESS scall/assert-cause
    assert _ACRTrapCause[[1]] == Zeros{24} + 1;
    // TRAP-WITNESS scall/assert-synchronous
    assert !_ACRTrapAsynchronous[[1]];
    // TRAP-WITNESS scall/assert-argument-valid
    assert _ACRTrapArgumentValid[[1]];
    // TRAP-WITNESS scall/assert-saved-source
    assert _TrapContexts[[1]].source_acr == 2;
    // TRAP-WITNESS scall/assert-saved-restart
    assert _TrapContexts[[1]].tpc == Zeros{PTO_XLEN} + 0x404;
    // TRAP-WITNESS scall/assert-visible-restart
    assert PTOv0ReadContextRegister(1, 0x0f43) ==
        Zeros{PTO_XLEN} + 0x404;
    // TRAP-WITNESS scall/assert-vector-entry
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x900;
    let recovered = RecoverTrapContext(CurrentACR());
    assert recovered;
    assert CurrentACR() == 2;
    // TRAP-WITNESS scall/assert-restart
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x404;
    assert !_TrapContexts[[1]].valid;
end;

func TestCompleteTrapEnvelope()
begin
    // TRAP-WITNESS case/EXEC_STATE_CHECK
    CheckSynchronousTrapMapping(Fault_ExecutionStateCheck, Zeros{6});
    // TRAP-WITNESS case/ILLEGAL_INST
    CheckSynchronousTrapMapping(Fault_IllegalInstruction, Zeros{6} + 4);
    // TRAP-WITNESS case/BUNDLE_TRAP
    CheckSynchronousTrapMapping(Fault_BundleControl, Zeros{6} + 5);
    CheckSynchronousTrapMapping(Fault_TileLegality, Zeros{6} + 5);
    CheckSynchronousTrapMapping(Fault_TileAllocation, Zeros{6} + 5);
    CheckSynchronousTrapMapping(Fault_ServiceRequest, Zeros{6} + 6);
    // TRAP-WITNESS case/SCALL
    CheckServiceRequestTrapMapping();
    // TRAP-WITNESS case/INST_PC_FAULT
    CheckSynchronousTrapMapping(Fault_InstructionPC, Zeros{6} + 32);
    // TRAP-WITNESS case/INST_PAGE_FAULT
    CheckSynchronousTrapMapping(Fault_InstructionPage, Zeros{6} + 33);
    // TRAP-WITNESS case/DATA_ALIGN_FAULT
    CheckSynchronousTrapMapping(Fault_DataAlignment, Zeros{6} + 34);
    // TRAP-WITNESS case/DATA_PAGE_FAULT
    CheckSynchronousTrapMapping(Fault_DataPage, Zeros{6} + 35);
    // TRAP-WITNESS case/HW_BREAKPOINT
    CheckSynchronousTrapMapping(Fault_HardwareBreakpoint, Zeros{6} + 49);
    // TRAP-WITNESS case/SW_BREAKPOINT
    CheckSynchronousTrapMapping(Fault_SoftwareBreakpoint, Zeros{6} + 50);
    // TRAP-WITNESS case/HW_WATCHPOINT
    CheckSynchronousTrapMapping(Fault_HardwareWatchpoint, Zeros{6} + 51);
    // TRAP-WITNESS case/ASSERT_FAIL
    CheckSynchronousTrapMapping(Fault_Assert, Zeros{6} + 52);

    ResetProfileState();
    SetCurrentACR(15);
    WriteTPC(Zeros{PTO_XLEN} + 0x3000);
    // TRAP-WITNESS case/INTERRUPT
    RaiseInterrupt(63, Zeros{24} + 0x55);
    assert CurrentACR() == 1;
    // TRAP-WITNESS interrupt/assert-number
    assert _ACRTrapNumber[[1]] == Zeros{6} + 44;
    // TRAP-WITNESS interrupt/assert-argument
    assert _ACRTrapArgument0[[1]] == Zeros{PTO_XLEN} + 63;
    assert _ACRTrapCause[[1]] == Zeros{24} + 0x55;
    assert _ACRTrapAsynchronous[[1]];
    assert _ACRTrapArgumentValid[[1]];
    assert _TrapContexts[[1]].source_acr == 15;
    assert _TrapContexts[[1]].tpc == Zeros{PTO_XLEN} + 0x3000;
    let recovered = RecoverTrapContext(CurrentACR());
    assert recovered;
    assert CurrentACR() == 15;
    // TRAP-WITNESS interrupt/assert-restart
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x3000;
    ResetProfileState();
end;
func main() => integer
begin
    ResetProfileState();
    TestCompleteTrapEnvelope();
    return 0;
end;
