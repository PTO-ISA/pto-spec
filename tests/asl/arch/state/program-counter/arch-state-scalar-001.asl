// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-ARCH-PROGRAM-COUNTER-STATE-001","source":"asl/arch/state/program-counter.asl","requirements":[],"kind":"state-transition","summary":"Covers Scalar State.","pass_condition":"TestScalarState completes without assertion failure","related_sources":[]}
func TestScalarState()
begin
    WriteGPR(1, Zeros{PTO_XLEN} + 42);
    assert ReadGPR(1) == Zeros{PTO_XLEN} + 42;
    WriteGPR(0, Ones{PTO_XLEN});
    assert ReadGPR(0) == Zeros{PTO_XLEN};

    WritePC(Zeros{PTO_XLEN} + 16);
    assert ReadPC() == Zeros{PTO_XLEN} + 16;
    WritePredicateRegister(0, Zeros{PTO_PREDICATE_WIDTH});
    WritePredicateRegister(7, Zeros{PTO_PREDICATE_WIDTH} + 0x7f);
    // P0 is the hardwired always-active warp predicate. A write cannot
    // suppress it.
    assert ReadPredicateRegister(0) == Ones{PTO_PREDICATE_WIDTH};
    assert ReadPredicateRegister(7) ==
        Zeros{PTO_PREDICATE_WIDTH} + 0x7f;
    ClearFault();
    assert _LastFault == Fault_None;
end;
func main() => integer
begin
    ResetProfileState();
    TestScalarState();
    return 0;
end;
