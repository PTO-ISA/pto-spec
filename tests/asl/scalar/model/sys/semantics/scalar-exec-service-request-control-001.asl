// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-SCALAR-TESTSERVICEREQUESTCONTROL-EXECUTION-001","source":"asl/scalar/model/sys/semantics.asl","requirements":[],"kind":"execution","summary":"Covers Service Request Control.","pass_condition":"TestServiceRequestControl completes without assertion failure","related_sources":[]}
func TestServiceRequestControl()
begin
    assert !ServiceRequestPermitted(0, '0000');
    assert ServiceRequestPermitted(1, '0000');
    assert !ServiceRequestPermitted(1, '0001');
    assert ServiceRequestPermitted(1, '0010');
    assert ServiceRequestPermitted(2, '0001');
    assert ServiceRequestPermitted(15, '0010');
    assert !ServiceRequestPermitted(15, '0011');
    assert ServiceRequestTarget(1, '0000') == 0;
    assert ServiceRequestTarget(2, '0001') == 1;
    assert ServiceRequestTarget(15, '0010') == 0;

    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x100);
    let invalid_epoch = _ArchitectureRequestEpoch;
    ArchitectureCloseRequest('0000');
    assert _LastFault == Fault_IllegalInstruction;
    assert _ACRTrapNumber[[0]] == Zeros{6} + 4;
    assert _ArchitectureRequestEpoch == invalid_epoch;

    ResetProfileState();
    WriteSystemRegisterAddress(Zeros{24} + 0x1f01,
        Zeros{PTO_XLEN} + 0x900);
    SetCurrentACR(2);
    WriteTPC(Zeros{PTO_XLEN} + 0x400);
    WriteBPC(Zeros{PTO_XLEN} + 0x380);
    let system_epoch = _ArchitectureRequestEpoch;
    ArchitectureCloseRequest('0001');
    assert _LastFault == Fault_ServiceRequest;
    assert CurrentACR() == 1;
    // SYSREG-EFFECT-WITNESS exception-vector-base/selects-trap-entry-tpc
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x900;
    assert _ACRTrapNumber[[1]] == Zeros{6} + 6;
    assert _ACRTrapCause[[1]][3:0] == '0001';
    assert _ACRTrapArgument0[[1]] == Zeros{PTO_XLEN} + 0x400;
    assert PTOv0ReadContextRegister(1, 0x0f43) ==
        Zeros{PTO_XLEN} + 0x404;
    assert _ArchitectureRequestEpoch == system_epoch + 1;
    ClearFault();
    _BundleActive = FALSE;
    _BundleBodyActive = FALSE;
    ClearBundleHeaderState();
    BeginBundle(BundleKind_System, BundleTransfer_Fallthrough,
        Zeros{PTO_XLEN}, Zeros{PTO_XLEN} + 0x904,
        Zeros{PTO_XLEN} + 0x904, FALSE);
    EnterBundleBody();
    ArchitectureEnterRequest('0001');
    assert _LastFault == Fault_None;
    assert CurrentACR() == 2;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x404;

    ResetProfileState();
    WriteSystemRegisterAddress(Zeros{24} + 0x0f01,
        Zeros{PTO_XLEN} + 0x800);
    SetCurrentACR(1);
    WriteTPC(Zeros{PTO_XLEN} + 0x500);
    ArchitectureCloseRequest('0000');
    assert _LastFault == Fault_ServiceRequest;
    assert CurrentACR() == 0;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x800;
    assert PTOv0ReadContextRegister(0, 0x0f43) ==
        Zeros{PTO_XLEN} + 0x504;

    ResetProfileState();
    SetCurrentACR(15);
    WriteTPC(Zeros{PTO_XLEN} + 0x600);
    ArchitectureCloseRequest('0010');
    assert _LastFault == Fault_ServiceRequest;
    assert CurrentACR() == 0;
    assert _ACRTrapNumber[[0]] == Zeros{6} + 6;

    ResetProfileState();
    SetCurrentACR(2);
    WriteTPC(Zeros{PTO_XLEN} + 0x700);
    ArchitectureCloseRequest('0011');
    assert _LastFault == Fault_IllegalInstruction;
    assert CurrentACR() == 1;
    assert _ACRTrapNumber[[1]] == Zeros{6} + 4;

    ResetProfileState();
end;
func main() => integer
begin
    ResetProfileState();
    TestServiceRequestControl();
    return 0;
end;
