// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-SCALAR-TESTSCALARFPFLAGLIFECYCLE-STATE-TRANSITION-001","source":"asl/scalar/model/fsu/arithmetic.asl","requirements":[],"kind":"state-transition","summary":"migrated independent behavior point for TestScalarFPFlagLifecycle","pass_condition":"TestScalarFPFlagLifecycle completes without assertion failure","related_sources":[]}
func TestScalarFPFlagLifecycle()
begin
    ResetProfileState();
    assert ScalarFPFlags() == Zeros{5};

    _SystemRegisters.core_state[63:40] = Ones{24};
    _SystemRegisters.core_state[31:4] = Ones{28};
    SetCurrentACR(15);
    ScalarFPRecordFlags('10101');
    assert ScalarFPFlags() == '10101';
    assert _SystemRegisters.core_state[63:40] == Ones{24};
    assert _SystemRegisters.core_state[31:4] == Ones{28};
    ScalarFPRecordFlags('01010');
    assert ScalarFPFlags() == Ones{5};

    var software_state = _SystemRegisters.core_state;
    software_state[36:32] = '00101';
    WriteSystemRegister(SystemRegister_CORE_STATE, software_state);
    // SYSREG-EFFECT-WITNESS core-state-control/write-selects-current-acr
    assert CurrentACR() == 15;
    assert ScalarFPFlags() == '00101';

    WriteTPC(Zeros{PTO_XLEN} + 0x200);
    SetFault(Fault_Assert, Zeros{PTO_XLEN} + 0x200);
    assert CurrentACR() == 1;
    _SystemRegisters.core_state[36:32] = Zeros{5};
    let recovered = RecoverTrapContext(CurrentACR());
    assert recovered;
    assert CurrentACR() == 15;
    assert ScalarFPFlags() == '00101';

    var rejected: bits(48) = Zeros{48} + 0x0000004b;
    rejected[11:7] = Zeros{5} + 4;
    rejected[19:15] = Zeros{5} + 2;
    rejected[24:20] = Zeros{5} + 3;
    rejected[26:25] = '10';
    let rejected_status = ExecuteScalarInstruction(rejected, 32);
    assert rejected_status == ScalarExecution_Rejected;
    assert _LastFault == Fault_IllegalInstruction;
    assert ScalarFPFlags() == '00101';
    ResetProfileState();
end;
func main() => integer
begin
    ResetProfileState();
    TestScalarFPFlagLifecycle();
    return 0;
end;
