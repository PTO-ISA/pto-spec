// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-SCALAR-TESTSCALARPAIRMEMORYCOMPLETION-EXECUTION-001","source":"asl/scalar/model/agu/memory.asl","requirements":[],"kind":"execution","summary":"migrated independent behavior point for TestScalarPairMemoryCompletion","pass_condition":"TestScalarPairMemoryCompletion completes without assertion failure","related_sources":[]}
func TestScalarPairMemoryCompletion()
begin
    WriteGPR(2, Zeros{PTO_XLEN} + 4088);
    WriteGPR(6, Zeros{PTO_XLEN} + 0x66);
    WriteGPR(7, Zeros{PTO_XLEN} + 0x77);
    Store(Zeros{PTO_XLEN} + 4088, 8, Zeros{PTO_XLEN} + 0x88);
    ClearFault();
    ExecuteScalarLoadPair(6, 7, 2, Zeros{PTO_XLEN}, 8, FALSE);
    assert _LastFault == Fault_DataPage;
    assert _FaultAddress == Zeros{PTO_XLEN} + 4096;
    assert ReadGPR(6) == Zeros{PTO_XLEN} + 0x66;
    assert ReadGPR(7) == Zeros{PTO_XLEN} + 0x77;
    assert ReadGPR(2) == Zeros{PTO_XLEN} + 4088;

    WriteGPR(3, Zeros{PTO_XLEN} + 0x33);
    WriteGPR(5, Zeros{PTO_XLEN} + 0x55);
    ClearFault();
    ExecuteScalarStorePair(3, 5, 2, Zeros{PTO_XLEN}, 8);
    assert _LastFault == Fault_DataPage;
    assert _FaultAddress == Zeros{PTO_XLEN} + 4096;
    assert ReadGPR(2) == Zeros{PTO_XLEN} + 4088;
    ClearFault();
    let preserved_first = LoadUnsigned(Zeros{PTO_XLEN} + 4088, 8);
    assert preserved_first == Zeros{PTO_XLEN} + 0x88;

    WriteGPR(2, Zeros{PTO_XLEN} + 4096);
    WriteGPR(6, Zeros{PTO_XLEN} + 0x66);
    WriteGPR(7, Zeros{PTO_XLEN} + 0x77);
    ClearFault();
    ExecuteScalarLoadPair(6, 7, 2, Zeros{PTO_XLEN}, 8, FALSE);
    assert _LastFault == Fault_DataPage;
    assert _FaultAddress == Zeros{PTO_XLEN} + 4096;
    assert ReadGPR(6) == Zeros{PTO_XLEN} + 0x66;
    assert ReadGPR(7) == Zeros{PTO_XLEN} + 0x77;

    Store(Zeros{PTO_XLEN} + 4000, 8, Zeros{PTO_XLEN} + 0x11);
    Store(Zeros{PTO_XLEN} + 4008, 8, Zeros{PTO_XLEN} + 0x22);
    WriteGPR(2, Zeros{PTO_XLEN} + 4000);
    ClearFault();
    ExecuteScalarLoadPair(6, 7, 2, Zeros{PTO_XLEN}, 8, FALSE);
    assert _LastFault == Fault_None;
    assert ReadGPR(6) == Zeros{PTO_XLEN} + 0x11;
    assert ReadGPR(7) == Zeros{PTO_XLEN} + 0x22;
    assert ReadGPR(2) == Zeros{PTO_XLEN} + 4000;
end;
func main() => integer
begin
    ResetProfileState();
    TestScalarPairMemoryCompletion();
    return 0;
end;
