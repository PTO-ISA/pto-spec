// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-ARCH-TESTPREDICATESTATECONTRACT-STATE-TRANSITION-001","source":"asl/arch/programming-model/predicate-registers.asl","requirements":[],"kind":"state-transition","summary":"Covers Predicate State Contract.","pass_condition":"TestPredicateStateContract completes without assertion failure","related_sources":[]}
func TestPredicateStateContract()
begin
    ResetProfileState();
    assert ReadPredicateRegister(0) == Ones{PTO_PREDICATE_WIDTH};
    for index = 1 to PTO_PREDICATE_REGISTER_COUNT - 1 do
        assert ReadPredicateRegister(index as PredicateIndex) ==
            Zeros{PTO_PREDICATE_WIDTH};
    end;
    for index = 0 to PTO_PREDICATE_REGISTER_COUNT - 1 do
        assert !PredicateRegisterHasInstructionConsumer(index as PredicateIndex);
    end;

    WritePredicateRegister(0, Zeros{PTO_PREDICATE_WIDTH});
    assert ReadPredicateRegister(0) == Ones{PTO_PREDICATE_WIDTH};
    WritePredicateRegister(1, Zeros{PTO_PREDICATE_WIDTH} + 0x11);
    WritePredicateRegister(7,
        Zeros{PTO_PREDICATE_WIDTH} + 0x80000001);
    _CommitArgument = Zeros{PTO_XLEN} + 0xcc;
    BeginBundle(BundleKind_Standard, BundleTransfer_Conditional,
        Zeros{PTO_XLEN} + 0x80, Zeros{PTO_XLEN} + 4,
        Zeros{PTO_XLEN} + 4, FALSE);
    assert BundleIsActive();
    assert ReadPredicateRegister(0) == Ones{PTO_PREDICATE_WIDTH};
    EnterBundleBody();
    assert ReadBranchPredicate() == Zeros{PTO_XLEN} + 0xcc;
    assert ReadPredicateRegister(1) ==
        Zeros{PTO_PREDICATE_WIDTH} + 0x11;
    assert ReadPredicateRegister(7) ==
        Zeros{PTO_PREDICATE_WIDTH} + 0x80000001;
    StopBundleAt(Zeros{PTO_XLEN} + 4);
    assert !BundleIsActive();

    SetCurrentACR(15);
    WriteTPC(Zeros{PTO_XLEN} + 0x200);
    SetFault(Fault_Assert, Zeros{PTO_XLEN} + 0x200);
    assert CurrentACR() == 1;
    WritePredicateRegister(1, Zeros{PTO_PREDICATE_WIDTH});
    WritePredicateRegister(7, Zeros{PTO_PREDICATE_WIDTH});
    let recovered = RecoverTrapContext(CurrentACR());
    assert recovered;
    assert ReadPredicateRegister(0) == Ones{PTO_PREDICATE_WIDTH};
    assert ReadPredicateRegister(1) ==
        Zeros{PTO_PREDICATE_WIDTH} + 0x11;
    assert ReadPredicateRegister(7) ==
        Zeros{PTO_PREDICATE_WIDTH} + 0x80000001;
    ArchitectureEnterRequest('0001');
    assert _LastFault == Fault_ExecutionStateCheck;
    assert ReadPredicateRegister(7) ==
        Zeros{PTO_PREDICATE_WIDTH} + 0x80000001;
    ResetProfileState();
end;
func main() => integer
begin
    ResetProfileState();
    TestPredicateStateContract();
    return 0;
end;
