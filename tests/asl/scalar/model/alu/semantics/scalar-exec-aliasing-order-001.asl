// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-SCALAR-TESTSCALARALIASINGORDER-EXECUTION-001","source":"asl/scalar/model/alu/semantics.asl","requirements":[],"kind":"execution","summary":"Covers Scalar Aliasing Order.","pass_condition":"TestScalarAliasingOrder completes without assertion failure","related_sources":[]}
func TestScalarAliasingOrder()
begin
    Store(Zeros{PTO_XLEN} + 1024, 8, Zeros{PTO_XLEN} + 0x1122);
    WriteGPR(2, Zeros{PTO_XLEN} + 1024);
    var distinct_load: bits(48) = Zeros{48} + 0x00003019003e;
    distinct_load[27:23] = Zeros{5} + 6;
    distinct_load[15:11] = Zeros{5} + 7;
    distinct_load[35:31] = Zeros{5} + 2;
    distinct_load[47:36] = Zeros{12} + 1;
    ClearFault();
    let distinct_load_status = ExecuteScalarInstruction(distinct_load, 48);
    assert distinct_load_status == ScalarExecution_Executed;
    assert _LastFault == Fault_None;
    assert ReadGPR(6) == Zeros{PTO_XLEN} + 0x1122;
    assert ReadGPR(7) == Zeros{PTO_XLEN} + 1032;

    var overlap_load = distinct_load;
    overlap_load[15:11] = Zeros{5} + 6;
    WriteGPR(6, Zeros{PTO_XLEN} + 0x66);
    ClearFault();
    let overlap_load_status = ExecuteScalarInstruction(overlap_load, 48);
    assert overlap_load_status == ScalarExecution_Executed;
    assert _LastFault == Fault_None;
    assert ReadGPR(6) == Zeros{PTO_XLEN} + 1032;

    WriteGPR(2, Zeros{PTO_XLEN} + 1088);
    WriteGPR(3, Zeros{PTO_XLEN} + 0x3344);
    var distinct_store: bits(48) = Zeros{48} + 0x00003059003e;
    distinct_store[15:11] = Zeros{5} + 8;
    distinct_store[35:31] = Zeros{5} + 3;
    distinct_store[40:36] = Zeros{5} + 2;
    distinct_store[47:41] = Zeros{7} + 1;
    ClearFault();
    let distinct_store_status = ExecuteScalarInstruction(distinct_store, 48);
    assert distinct_store_status == ScalarExecution_Executed;
    assert _LastFault == Fault_None;
    let distinct_store_value = LoadUnsigned(Zeros{PTO_XLEN} + 1088, 8);
    assert distinct_store_value == Zeros{PTO_XLEN} + 0x3344;
    assert ReadGPR(8) == Zeros{PTO_XLEN} + 1096;

    Store(Zeros{PTO_XLEN} + 1088, 8, Zeros{PTO_XLEN} + 0x55);
    var overlap_store = distinct_store;
    overlap_store[15:11] = Zeros{5} + 3;
    ClearFault();
    let overlap_store_status = ExecuteScalarInstruction(overlap_store, 48);
    assert overlap_store_status == ScalarExecution_Executed;
    assert _LastFault == Fault_None;
    let overlap_store_value = LoadUnsigned(Zeros{PTO_XLEN} + 1088, 8);
    assert overlap_store_value == Zeros{PTO_XLEN} + 0x3344;
    assert ReadGPR(3) == Zeros{PTO_XLEN} + 1096;
end;
func main() => integer
begin
    ResetProfileState();
    TestScalarAliasingOrder();
    return 0;
end;
