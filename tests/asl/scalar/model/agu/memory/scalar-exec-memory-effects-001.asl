// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-SCALAR-TESTSCALARMEMORY-EXECUTION-001","source":"asl/scalar/model/agu/memory.asl","requirements":[],"kind":"execution","summary":"Covers Scalar Memory.","pass_condition":"TestScalarMemory completes without assertion failure","related_sources":[]}
func TestScalarMemory()
begin
    ClearFault();
    Store(Zeros{PTO_XLEN} + 16, 4, Zeros{PTO_XLEN} + 0x44332211);
    assert ReadMemoryByte(Zeros{PTO_XLEN} + 16) == '00010001';
    assert ReadMemoryByte(Zeros{PTO_XLEN} + 19) == '01000100';
    let loaded = LoadUnsigned(Zeros{PTO_XLEN} + 16, 4);
    assert loaded == Zeros{PTO_XLEN} + 0x44332211;

    ClearFault();
    assert ScalarPrefetchAddress(Ones{PTO_XLEN}, Zeros{PTO_XLEN} + 8) ==
        Zeros{PTO_XLEN} + 7;
    SetCurrentACR(2);
    _ReservationValid = TRUE;
    _ReservationAddress = Zeros{PTO_XLEN} + 64;
    StartMemoryEventCapture(0);
    for model = 0 to 31 do
        ScalarPrefetch(Ones{PTO_XLEN}, Zeros{PTO_XLEN} + 8, 8,
            Zeros{5} + model);
    end;
    assert _LastFault == Fault_None;
    assert _MemoryEventCount == 0;
    assert _ReservationValid;
    StopMemoryEventCapture();

    // Alignment precedes the PTO-v0 permission/page check. Permission and the
    // bounded-memory failure share the visible DataPage cause.
    ClearFault();
    - = LoadUnsigned(Zeros{PTO_XLEN} + 3073, 8);
    assert _LastFault == Fault_DataAlignment;
    assert _FaultAddress == Zeros{PTO_XLEN} + 3073;
    ClearFault();
    SetCurrentACR(2);
    - = LoadUnsigned(Zeros{PTO_XLEN} + 3072, 8);
    assert _LastFault == Fault_DataPage;
    assert _FaultAddress == Zeros{PTO_XLEN} + 3072;
    SetCurrentACR(0);

    // The reference profile keeps the configured array boundary.  External
    // profiles may replace DataAccessPermitted without inheriting a second
    // ProbeDataAccess bound.
    assert DataAccessPermitted(
        Zeros{PTO_XLEN} + (PTO_MODEL_MEMORY_BYTES - 1), 1, FALSE);
    assert !DataAccessPermitted(
        Zeros{PTO_XLEN} + PTO_MODEL_MEMORY_BYTES, 1, FALSE);

    ClearFault();
    - = LoadUnsigned(Zeros{PTO_XLEN} + 17, 4);
    assert _LastFault == Fault_DataAlignment;
    assert _FaultAddress == Zeros{PTO_XLEN} + 17;

    ClearFault();
    WriteGPR(2, Zeros{PTO_XLEN} + 64);
    WriteGPR(3, Zeros{PTO_XLEN} + 0x1122);
    ExecuteScalarStore(3, 2, Zeros{PTO_XLEN} + 8, 2, AddressUpdate_PreIndex);
    assert ReadGPR(2) == Zeros{PTO_XLEN} + 72;
    ExecuteScalarLoad(4, 2, Zeros{PTO_XLEN} + 2, 2, FALSE, AddressUpdate_PostIndex);
    assert ReadGPR(4) == Zeros{PTO_XLEN} + 0x1122;
    assert ReadGPR(2) == Zeros{PTO_XLEN} + 74;

    WriteGPR(5, Zeros{PTO_XLEN} + 0x3344);
    ExecuteScalarStorePair(3, 5, 2, Zeros{PTO_XLEN} + 6, 2);
    ExecuteScalarLoadPair(6, 7, 2, Zeros{PTO_XLEN} + 6, 2, FALSE);
    assert ReadGPR(6) == Zeros{PTO_XLEN} + 0x1122;
    assert ReadGPR(7) == Zeros{PTO_XLEN} + 0x3344;
end;
func main() => integer
begin
    ResetProfileState();
    TestScalarMemory();
    return 0;
end;
