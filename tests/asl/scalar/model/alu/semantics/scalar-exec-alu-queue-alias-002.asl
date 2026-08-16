// PTO-TEST: {"id":"PTO-AVS-SCALAR-ALU-QUEUE-ALIAS-EXEC-002","source":"asl/scalar/model/alu/semantics.asl","requirements":[],"kind":"execution","summary":"scalar ALU queue operands snapshot every T and U source position","pass_condition":"queue source and same-queue push assertions hold","related_sources":[]}
func TestScalarALUQueueAliases()
begin
    var add: bits(48) = Zeros{48} + 0x00000005;
    add[19:15] = Zeros{5} + 2;
    add[24:20] = Zeros{5} + 3;

    // Populate all source positions and prove a same-queue push consumes the
    // old queue snapshot before shifting it.
    ResetProfileState();
    PushTemporaryQueue(TRUE, Zeros{PTO_XLEN} + 1);
    PushTemporaryQueue(TRUE, Zeros{PTO_XLEN} + 2);
    PushTemporaryQueue(TRUE, Zeros{PTO_XLEN} + 3);
    PushTemporaryQueue(TRUE, Zeros{PTO_XLEN} + 4);
    PushTemporaryQueue(FALSE, Zeros{PTO_XLEN} + 10);
    PushTemporaryQueue(FALSE, Zeros{PTO_XLEN} + 20);
    PushTemporaryQueue(FALSE, Zeros{PTO_XLEN} + 30);
    PushTemporaryQueue(FALSE, Zeros{PTO_XLEN} + 40);

    // Every encoded T/U source position reaches the decoded ALU operand path.
    WriteGPR(1, Zeros{PTO_XLEN} + 100);
    add[11:7] = Zeros{5} + 4;
    add[24:20] = Zeros{5} + 1;
    // ALU-ALIAS-DECODED: queue-source-t1
    add[19:15] = Zeros{5} + 24;
    - = ExecuteScalarInstruction(add, 32);
    assert ReadGPR(4) == Zeros{PTO_XLEN} + 104;
    // ALU-ALIAS-DECODED: queue-source-t2
    add[19:15] = Zeros{5} + 25;
    - = ExecuteScalarInstruction(add, 32);
    assert ReadGPR(4) == Zeros{PTO_XLEN} + 103;
    // ALU-ALIAS-DECODED: queue-source-t3
    add[19:15] = Zeros{5} + 26;
    - = ExecuteScalarInstruction(add, 32);
    assert ReadGPR(4) == Zeros{PTO_XLEN} + 102;
    // ALU-ALIAS-DECODED: queue-source-t4
    add[19:15] = Zeros{5} + 27;
    - = ExecuteScalarInstruction(add, 32);
    assert ReadGPR(4) == Zeros{PTO_XLEN} + 101;
    // ALU-ALIAS-DECODED: queue-source-u1
    add[19:15] = Zeros{5} + 28;
    - = ExecuteScalarInstruction(add, 32);
    assert ReadGPR(4) == Zeros{PTO_XLEN} + 140;
    // ALU-ALIAS-DECODED: queue-source-u2
    add[19:15] = Zeros{5} + 29;
    - = ExecuteScalarInstruction(add, 32);
    assert ReadGPR(4) == Zeros{PTO_XLEN} + 130;
    // ALU-ALIAS-DECODED: queue-source-u3
    add[19:15] = Zeros{5} + 30;
    - = ExecuteScalarInstruction(add, 32);
    assert ReadGPR(4) == Zeros{PTO_XLEN} + 120;
    // ALU-ALIAS-DECODED: queue-source-u4
    add[19:15] = Zeros{5} + 31;
    - = ExecuteScalarInstruction(add, 32);
    assert ReadGPR(4) == Zeros{PTO_XLEN} + 110;

    // ALU-ALIAS-DECODED: cross-queue-source-pair
    WriteGPR(3, Zeros{PTO_XLEN} + 6);
    add[11:7] = Zeros{5} + 4;
    add[19:15] = Zeros{5} + 24;
    add[24:20] = Zeros{5} + 31;
    let all_queue_source_status = ExecuteScalarInstruction(add, 32);
    assert all_queue_source_status == ScalarExecution_Executed;
    assert ReadGPR(4) == Zeros{PTO_XLEN} + 14;
    assert ReadTemporaryQueue(TRUE, 0) == Zeros{PTO_XLEN} + 4;
    assert ReadTemporaryQueue(TRUE, 3) == Zeros{PTO_XLEN} + 1;
    assert ReadTemporaryQueue(FALSE, 0) == Zeros{PTO_XLEN} + 40;
    assert ReadTemporaryQueue(FALSE, 3) == Zeros{PTO_XLEN} + 10;

    // ALU-ALIAS-DECODED: push-t-snapshots-t-source
    add[11:7] = Zeros{5} + 31;
    add[19:15] = Zeros{5} + 24;
    add[24:20] = Zeros{5} + 3;
    let t_push_status = ExecuteScalarInstruction(add, 32);
    assert t_push_status == ScalarExecution_Executed;
    assert ReadTemporaryQueue(TRUE, 0) == Zeros{PTO_XLEN} + 10;
    assert ReadTemporaryQueue(TRUE, 1) == Zeros{PTO_XLEN} + 4;
    assert ReadTemporaryQueue(TRUE, 3) == Zeros{PTO_XLEN} + 2;

    // ALU-ALIAS-DECODED: push-u-snapshots-u-source
    add[11:7] = Zeros{5} + 30;
    add[19:15] = Zeros{5} + 31;
    let u_push_status = ExecuteScalarInstruction(add, 32);
    assert u_push_status == ScalarExecution_Executed;
    assert ReadTemporaryQueue(FALSE, 0) == Zeros{PTO_XLEN} + 16;
    assert ReadTemporaryQueue(FALSE, 1) == Zeros{PTO_XLEN} + 40;
    assert ReadTemporaryQueue(FALSE, 3) == Zeros{PTO_XLEN} + 20;
end;
func main() => integer
begin
    ResetProfileState();
    TestScalarALUQueueAliases();
    return 0;
end;
