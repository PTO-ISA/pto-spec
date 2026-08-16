// PTO-TEST: {"id":"PTO-AVS-SCALAR-ALU-PAIR-ALIAS-EXEC-005","source":"asl/scalar/model/alu/semantics.asl","requirements":[],"kind":"execution","summary":"pair-result operations snapshot sources before ordered destinations","pass_condition":"GPR and queue pair-result alias assertions hold","related_sources":[]}
func TestScalarALUPairAliases()
begin
    // Pair-result forms snapshot both sources, then write destination zero and
    // destination one. The same destination therefore retains result one.
    // ALU-ALIAS-DECODED: pair-destinations-overlap-sources
    var divide_pair: bits(48) = Zeros{48} + 0x00000057000e;
    divide_pair[35:31] = Zeros{5} + 2;
    divide_pair[40:36] = Zeros{5} + 3;
    WriteGPR(2, Zeros{PTO_XLEN} + 23);
    WriteGPR(3, Zeros{PTO_XLEN} + 5);
    divide_pair[27:23] = Zeros{5} + 2;
    divide_pair[15:11] = Zeros{5} + 3;
    let pair_source_alias_status = ExecuteScalarInstruction(divide_pair, 48);
    assert pair_source_alias_status == ScalarExecution_Executed;
    assert ReadGPR(2) == Zeros{PTO_XLEN} + 4;
    assert ReadGPR(3) == Zeros{PTO_XLEN} + 3;

    // ALU-ALIAS-DECODED: pair-destinations-same-gpr
    WriteGPR(2, Zeros{PTO_XLEN} + 23);
    WriteGPR(3, Zeros{PTO_XLEN} + 5);
    divide_pair[27:23] = Zeros{5} + 4;
    divide_pair[15:11] = Zeros{5} + 4;
    let pair_same_gpr_status = ExecuteScalarInstruction(divide_pair, 48);
    assert pair_same_gpr_status == ScalarExecution_Executed;
    assert ReadGPR(4) == Zeros{PTO_XLEN} + 3;

    // ALU-ALIAS-DECODED: pair-destinations-cross-queue
    ResetProfileState();
    PushTemporaryQueue(TRUE, Zeros{PTO_XLEN} + 1);
    PushTemporaryQueue(TRUE, Zeros{PTO_XLEN} + 2);
    PushTemporaryQueue(TRUE, Zeros{PTO_XLEN} + 3);
    PushTemporaryQueue(TRUE, Zeros{PTO_XLEN} + 23);
    PushTemporaryQueue(FALSE, Zeros{PTO_XLEN} + 10);
    PushTemporaryQueue(FALSE, Zeros{PTO_XLEN} + 20);
    PushTemporaryQueue(FALSE, Zeros{PTO_XLEN} + 30);
    PushTemporaryQueue(FALSE, Zeros{PTO_XLEN} + 5);
    divide_pair[35:31] = Zeros{5} + 24;
    divide_pair[40:36] = Zeros{5} + 28;
    divide_pair[27:23] = Zeros{5} + 31;
    divide_pair[15:11] = Zeros{5} + 30;
    let pair_cross_queue_status = ExecuteScalarInstruction(divide_pair, 48);
    assert pair_cross_queue_status == ScalarExecution_Executed;
    assert ReadTemporaryQueue(TRUE, 0) == Zeros{PTO_XLEN} + 4;
    assert ReadTemporaryQueue(TRUE, 1) == Zeros{PTO_XLEN} + 23;
    assert ReadTemporaryQueue(FALSE, 0) == Zeros{PTO_XLEN} + 3;
    assert ReadTemporaryQueue(FALSE, 1) == Zeros{PTO_XLEN} + 5;

    // ALU-ALIAS-DECODED: pair-destinations-same-queue
    WriteGPR(2, Zeros{PTO_XLEN} + 23);
    WriteGPR(3, Zeros{PTO_XLEN} + 5);
    divide_pair[35:31] = Zeros{5} + 2;
    divide_pair[40:36] = Zeros{5} + 3;
    divide_pair[27:23] = Zeros{5} + 31;
    divide_pair[15:11] = Zeros{5} + 31;
    let pair_same_queue_status = ExecuteScalarInstruction(divide_pair, 48);
    assert pair_same_queue_status == ScalarExecution_Executed;
    assert ReadTemporaryQueue(TRUE, 0) == Zeros{PTO_XLEN} + 3;
    assert ReadTemporaryQueue(TRUE, 1) == Zeros{PTO_XLEN} + 4;
    assert ReadTemporaryQueue(TRUE, 2) == Zeros{PTO_XLEN} + 4;

end;
func main() => integer
begin
    ResetProfileState();
    TestScalarALUPairAliases();
    return 0;
end;
