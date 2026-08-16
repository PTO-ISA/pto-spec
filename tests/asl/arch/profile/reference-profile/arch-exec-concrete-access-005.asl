// PTO-TEST: {"id":"PTO-AVS-ARCH-CONCRETE-ACCESS-EXEC-005","source":"asl/arch/profile/reference-profile.asl","requirements":[],"kind":"execution","summary":"reference-profile address, ACR, and trap access rules are exact","pass_condition":"address translation, access permission, and trap context assertions hold","related_sources":[]}
func TestConcreteAccessProfile()
begin
    assert AtomicAddress(Zeros{PTO_XLEN} + 128, FALSE) ==
        Zeros{PTO_XLEN} + 128;
    assert AtomicAddress(Zeros{PTO_XLEN} + 128, TRUE) ==
        Zeros{PTO_XLEN} + 128;
    let translated_address = TranslateDataAddress(
        Zeros{PTO_XLEN} + 256, 8, FALSE);
    assert translated_address == Zeros{PTO_XLEN} + 256;
    SetCurrentACR(2);
    let application_data_permitted = DataAccessPermitted(
        Zeros{PTO_XLEN} + 3064, 8, FALSE);
    let application_data_denied = DataAccessPermitted(
        Zeros{PTO_XLEN} + 3072, 8, FALSE);
    assert application_data_permitted;
    assert !application_data_denied;
    assert SystemRegisterAccessPermitted(
        Zeros{24} + 0x0000, FALSE, CurrentACR());
    assert !SystemRegisterAccessPermitted(
        Zeros{24} + 0x0f00, FALSE, CurrentACR());
    ClearFault();
    - = ReadSystemRegisterAddress(Zeros{24} + 0x0f00);
    assert _LastFault == Fault_IllegalInstruction;
    SetCurrentACR(0);
    let root_data_permitted = DataAccessPermitted(
        Zeros{PTO_XLEN} + 3072, 8, TRUE);
    assert root_data_permitted;
    assert SystemRegisterAccessPermitted(
        Zeros{24} + 0x0f00, TRUE, CurrentACR());

    WriteTPC(Zeros{PTO_XLEN} + 0x500);
    WriteBPC(Zeros{PTO_XLEN} + 0x600);
    _BundleArgument = Zeros{PTO_XLEN} + 0x77;
    PushTemporaryQueue(TRUE, Zeros{PTO_XLEN} + 0x11);
    SaveTrapContext(1, CurrentACR());
    let saved_control = ReadSystemRegisterAddress(Zeros{24} + 0x1f40);
    let saved_bpc = ReadSystemRegisterAddress(Zeros{24} + 0x1f41);
    let saved_tpc = ReadSystemRegisterAddress(Zeros{24} + 0x1f43);
    assert saved_control[4] == '1';
    assert saved_bpc == Zeros{PTO_XLEN} + 0x600;
    assert saved_tpc == Zeros{PTO_XLEN} + 0x500;
    WriteSystemRegisterAddress(Zeros{24} + 0x1f41,
        Zeros{PTO_XLEN} + 0x610);
    WriteSystemRegisterAddress(Zeros{24} + 0x1f43,
        Zeros{PTO_XLEN} + 0x510);
    WriteSystemRegisterAddress(Zeros{24} + 0x1f45,
        Zeros{PTO_XLEN} + 0x22);
    WriteTPC(Zeros{PTO_XLEN} + 0x700);
    WriteBPC(Zeros{PTO_XLEN} + 0x800);
    _BundleArgument = Zeros{PTO_XLEN};
    let recovered_context = RecoverTrapContext(1);
    assert recovered_context;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x510;
    assert ReadBPC() == Zeros{PTO_XLEN} + 0x610;
    assert _BundleArgument == Zeros{PTO_XLEN} + 0x77;
    assert ReadTemporaryQueue(TRUE, 0) == Zeros{PTO_XLEN} + 0x22;
    assert PTOv0ReadContextRegister(1, 0x0f40)[4] == '0';

    let before_failed_recovery = _ArchitectureRequestEpoch;
    ClearFault();
    ArchitectureEnterRequest('0001');
    assert _LastFault == Fault_ExecutionStateCheck;
    assert _ACRTrapNumber[[CurrentACR()]] == Zeros{6};
    assert _ACRTrapArgumentValid[[CurrentACR()]];
    assert _ACRTrapArgument0[[CurrentACR()]] == Zeros{PTO_XLEN} + 0x510;
    assert _ArchitectureRequestEpoch == before_failed_recovery;
end;
func main() => integer
begin
    ResetProfileState();
    TestConcreteAccessProfile();
    return 0;
end;
