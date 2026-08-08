// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-ARCH-TESTPREDICATESTATECONTRACT-STATE-TRANSITION-001","source":"asl/arch/programming-model/predicate-registers.asl","requirements":[],"kind":"state-transition","summary":"migrated independent behavior point for TestPredicateStateContract","pass_condition":"TestPredicateStateContract completes without assertion failure","related_sources":[]}
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
    assert !BundleKindUsesExecutionMask(BundleKind_Standard);
    assert !BundleKindUsesExecutionMask(BundleKind_Floating);
    assert !BundleKindUsesExecutionMask(BundleKind_System);
    assert BundleKindUsesExecutionMask(BundleKind_MachineParallel);
    assert BundleKindUsesExecutionMask(BundleKind_MachineSequential);
    assert !BundleKindUsesExecutionMask(BundleKind_TileElement);
    assert !BundleKindUsesExecutionMask(BundleKind_TileMemory);
    assert !BundleKindUsesExecutionMask(BundleKind_TileMatrix);
    assert !BundleKindUsesExecutionMask(BundleKind_FrameTemplate);

    WriteExecutionMask(Zeros{PTO_XLEN} + 0x55);
    _CommitArgument = Zeros{PTO_XLEN} + 0xcc;
    BeginBundle(BundleKind_Standard, BundleTransfer_Conditional,
        Zeros{PTO_XLEN} + 0x80, Zeros{PTO_XLEN} + 4,
        Zeros{PTO_XLEN} + 4, FALSE);
    assert BundleIsActive();
    assert ReadPredicateRegister(0) == Ones{PTO_PREDICATE_WIDTH};
    assert ReadExecutionMask() == Zeros{PTO_XLEN} + 0x55;
    EnterBundleBody();
    assert !ExecutionMaskIsActive();
    assert ReadBranchPredicate() == Zeros{PTO_XLEN} + 0xcc;
    StopBundleAt(Zeros{PTO_XLEN} + 4);
    assert !BundleIsActive();
    BeginBundle(BundleKind_MachineParallel, BundleTransfer_Direct,
        Zeros{PTO_XLEN} + 0x100, Zeros{PTO_XLEN} + 4,
        Zeros{PTO_XLEN} + 4, TRUE);
    EnterBundleBody();
    assert ExecutionMaskIsActive();
    assert ReadExecutionMask() == Ones{PTO_XLEN};
    assert ReadPredicateRegister(0) == Ones{PTO_PREDICATE_WIDTH};
    assert ReadPredicateRegister(1) ==
        Zeros{PTO_PREDICATE_WIDTH} + 0x11;
    assert ReadPredicateRegister(7) ==
        Zeros{PTO_PREDICATE_WIDTH} + 0x80000001;

    StopBundle();
    WriteExecutionMask(Zeros{PTO_XLEN} + 0x55);
    BeginBundle(BundleKind_MachineSequential, BundleTransfer_Direct,
        Zeros{PTO_XLEN} + 0x180, Zeros{PTO_XLEN} + 4,
        Zeros{PTO_XLEN} + 4, TRUE);
    EnterBundleBody();
    assert ExecutionMaskIsActive();
    assert ReadExecutionMask() == Ones{PTO_XLEN};

    // B.Z/B.NZ consume the independent EXEC mask in a bundle body.
    WriteExecutionMask(Zeros{PTO_XLEN});
    WritePredicateRegister(1, Ones{PTO_PREDICATE_WIDTH});
    assert ReadBranchPredicate() == Zeros{PTO_XLEN};

    WriteExecutionMask(Zeros{PTO_XLEN} + 0xaa);
    SetCurrentACR(15);
    WriteTPC(Zeros{PTO_XLEN} + 0x200);
    SetFault(Fault_Assert, Zeros{PTO_XLEN} + 0x200);
    assert CurrentACR() == 1;
    WriteExecutionMask(Zeros{PTO_XLEN});
    WritePredicateRegister(1, Zeros{PTO_PREDICATE_WIDTH});
    WritePredicateRegister(7, Zeros{PTO_PREDICATE_WIDTH});
    let recovered = RecoverTrapContext(CurrentACR());
    assert recovered;
    assert ReadExecutionMask() == Zeros{PTO_XLEN} + 0xaa;
    assert ReadPredicateRegister(0) == Ones{PTO_PREDICATE_WIDTH};
    assert ReadPredicateRegister(1) == Ones{PTO_PREDICATE_WIDTH};
    assert ReadPredicateRegister(7) ==
        Zeros{PTO_PREDICATE_WIDTH} + 0x80000001;
    WriteExecutionMask(Zeros{PTO_XLEN} + 0xbb);
    ArchitectureEnterRequest('0001');
    assert _LastFault == Fault_ExecutionStateCheck;
    assert ReadExecutionMask() == Zeros{PTO_XLEN} + 0xbb;
    ResetProfileState();
end;
func main() => integer
begin
    ResetProfileState();
    TestPredicateStateContract();
    return 0;
end;
