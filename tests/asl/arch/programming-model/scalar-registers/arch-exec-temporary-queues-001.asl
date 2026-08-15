// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-ARCH-TESTSCALARTEMPORARYQUEUES-EXECUTION-001","source":"asl/arch/programming-model/scalar-registers.asl","requirements":[],"kind":"execution","summary":"Covers Scalar Temporary Queues.","pass_condition":"TestScalarTemporaryQueues completes without assertion failure","related_sources":[]}
func TestScalarTemporaryQueues()
begin
    PushTemporaryQueue(TRUE, Zeros{PTO_XLEN} + 10);
    PushTemporaryQueue(TRUE, Zeros{PTO_XLEN} + 20);
    assert ReadScalarRegisterOperand(24) == Zeros{PTO_XLEN} + 20;
    assert ReadScalarRegisterOperand(25) == Zeros{PTO_XLEN} + 10;

    WriteScalarDestination(30, Zeros{PTO_XLEN} + 300);
    WriteScalarDestination(30, Zeros{PTO_XLEN} + 301);
    WriteScalarDestination(31, Zeros{PTO_XLEN} + 310);
    assert ReadScalarRegisterOperand(28) == Zeros{PTO_XLEN} + 301;
    assert ReadScalarRegisterOperand(29) == Zeros{PTO_XLEN} + 300;
    assert ReadScalarRegisterOperand(24) == Zeros{PTO_XLEN} + 310;

    WriteGPR(5, Zeros{PTO_XLEN} + 5);
    WriteScalarDestination(24, Ones{PTO_XLEN});
    assert ReadGPR(5) == Zeros{PTO_XLEN} + 5;
end;
func main() => integer
begin
    ResetProfileState();
    TestScalarTemporaryQueues();
    return 0;
end;
