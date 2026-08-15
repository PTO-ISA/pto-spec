// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-ARCH-TESTSCALARQUEUEDISPATCH-EXECUTION-001","source":"asl/arch/programming-model/scalar-registers.asl","requirements":[],"kind":"execution","summary":"Covers Scalar Queue Dispatch.","pass_condition":"TestScalarQueueDispatch completes without assertion failure","related_sources":[]}
func TestScalarQueueDispatch()
begin
    WritePC(Zeros{PTO_XLEN} + 0x240);
    ClearFault();
    WriteGPR(2, Zeros{PTO_XLEN} + 10);
    WriteGPR(3, Zeros{PTO_XLEN} + 20);
    var compressed_add: bits(48) = Zeros{48} + 0x0008;
    compressed_add[10:6] = Zeros{5} + 2;
    compressed_add[15:11] = Zeros{5} + 3;
    let compressed_status = ExecuteScalarInstruction(compressed_add, 16);
    assert compressed_status == ScalarExecution_Executed;
    assert _LastFault == Fault_None;
    assert ReadScalarRegisterOperand(24) == Zeros{PTO_XLEN} + 30;

    ClearFault();
    PushTemporaryQueue(TRUE, Zeros{PTO_XLEN} + 7);
    WriteGPR(5, Zeros{PTO_XLEN} + 0x55);
    var queued_add: bits(48) = Zeros{48} + 0x00000005;
    queued_add[11:7] = Zeros{5} + 5;
    queued_add[19:15] = Zeros{5} + 24;
    queued_add[24:20] = Zeros{5} + 3;
    let queued_status = ExecuteScalarInstruction(queued_add, 32);
    assert queued_status == ScalarExecution_Executed;
    assert _LastFault == Fault_None;
    assert ReadGPR(5) == Zeros{PTO_XLEN} + 27;
end;
func main() => integer
begin
    ResetProfileState();
    TestScalarQueueDispatch();
    return 0;
end;
