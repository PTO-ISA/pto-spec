// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-SCALAR-TESTSCALARALUALIASMATRIX-EXECUTION-001","source":"asl/scalar/model/alu/semantics.asl","requirements":[],"kind":"execution","summary":"migrated independent behavior point for TestScalarALUAliasMatrix","pass_condition":"TestScalarALUAliasMatrix completes without assertion failure","related_sources":[]}
func TestScalarALUAliasMatrix()
begin
    var add: bits(48) = Zeros{48} + 0x00000005;
    add[19:15] = Zeros{5} + 2;
    add[24:20] = Zeros{5} + 3;

    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x2000);
    // ALU-ALIAS-DECODED: gpr-destination-overlaps-left
    WriteGPR(2, Zeros{PTO_XLEN} + 5);
    WriteGPR(3, Zeros{PTO_XLEN} + 7);
    add[11:7] = Zeros{5} + 2;
    let left_alias_status = ExecuteScalarInstruction(add, 32);
    assert left_alias_status == ScalarExecution_Executed;
    assert ReadGPR(2) == Zeros{PTO_XLEN} + 12;
    assert ReadGPR(3) == Zeros{PTO_XLEN} + 7;

    // ALU-ALIAS-DECODED: gpr-destination-overlaps-right
    WriteGPR(2, Zeros{PTO_XLEN} + 5);
    WriteGPR(3, Zeros{PTO_XLEN} + 7);
    add[11:7] = Zeros{5} + 3;
    let right_alias_status = ExecuteScalarInstruction(add, 32);
    assert right_alias_status == ScalarExecution_Executed;
    assert ReadGPR(2) == Zeros{PTO_XLEN} + 5;
    assert ReadGPR(3) == Zeros{PTO_XLEN} + 12;

    // ALU-ALIAS-DECODED: r0-source-and-destination-discard
    // R0 is zero as a source and discards as a destination.
    WriteGPR(1, Zeros{PTO_XLEN} + 9);
    add[11:7] = Zeros{5};
    add[19:15] = Zeros{5};
    add[24:20] = Zeros{5} + 1;
    let zero_status = ExecuteScalarInstruction(add, 32);
    assert zero_status == ScalarExecution_Executed;
    assert ReadGPR(0) == Zeros{PTO_XLEN};
    assert ReadGPR(1) == Zeros{PTO_XLEN} + 9;

    // ALU-ALIAS-DECODED: temporary-destination-discards-24-through-29
    // All six non-writing temporary destination encodings are equivalent.
    add[19:15] = Zeros{5} + 2;
    add[24:20] = Zeros{5} + 3;
    WriteGPR(2, Zeros{PTO_XLEN} + 5);
    WriteGPR(3, Zeros{PTO_XLEN} + 7);
    PushTemporaryQueue(TRUE, Zeros{PTO_XLEN} + 0x11);
    PushTemporaryQueue(FALSE, Zeros{PTO_XLEN} + 0x22);
    add[11:7] = Zeros{5} + 24;
    - = ExecuteScalarInstruction(add, 32);
    add[11:7] = Zeros{5} + 25;
    - = ExecuteScalarInstruction(add, 32);
    add[11:7] = Zeros{5} + 26;
    - = ExecuteScalarInstruction(add, 32);
    add[11:7] = Zeros{5} + 27;
    - = ExecuteScalarInstruction(add, 32);
    add[11:7] = Zeros{5} + 28;
    - = ExecuteScalarInstruction(add, 32);
    add[11:7] = Zeros{5} + 29;
    - = ExecuteScalarInstruction(add, 32);
    assert ReadTemporaryQueue(TRUE, 0) == Zeros{PTO_XLEN} + 0x11;
    assert ReadTemporaryQueue(FALSE, 0) == Zeros{PTO_XLEN} + 0x22;
    assert ReadGPR(2) == Zeros{PTO_XLEN} + 5;
    assert ReadGPR(3) == Zeros{PTO_XLEN} + 7;

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

    // Ternary arithmetic snapshots every source before an overlapping write.
    var madd: bits(48) = Zeros{48} + 0x00006047;
    madd[31:27] = Zeros{5} + 2;
    madd[19:15] = Zeros{5} + 3;
    madd[24:20] = Zeros{5} + 4;
    // ALU-ALIAS-DECODED: ternary-destination-overlaps-addend
    WriteGPR(2, Zeros{PTO_XLEN} + 5);
    WriteGPR(3, Zeros{PTO_XLEN} + 6);
    WriteGPR(4, Zeros{PTO_XLEN} + 7);
    madd[11:7] = Zeros{5} + 2;
    - = ExecuteScalarInstruction(madd, 32);
    assert ReadGPR(2) == Zeros{PTO_XLEN} + 47;
    assert ReadGPR(3) == Zeros{PTO_XLEN} + 6;
    assert ReadGPR(4) == Zeros{PTO_XLEN} + 7;
    // ALU-ALIAS-DECODED: ternary-destination-overlaps-left
    WriteGPR(2, Zeros{PTO_XLEN} + 5);
    WriteGPR(3, Zeros{PTO_XLEN} + 6);
    WriteGPR(4, Zeros{PTO_XLEN} + 7);
    madd[11:7] = Zeros{5} + 3;
    - = ExecuteScalarInstruction(madd, 32);
    assert ReadGPR(2) == Zeros{PTO_XLEN} + 5;
    assert ReadGPR(3) == Zeros{PTO_XLEN} + 47;
    assert ReadGPR(4) == Zeros{PTO_XLEN} + 7;
    // ALU-ALIAS-DECODED: ternary-destination-overlaps-right
    WriteGPR(2, Zeros{PTO_XLEN} + 5);
    WriteGPR(3, Zeros{PTO_XLEN} + 6);
    WriteGPR(4, Zeros{PTO_XLEN} + 7);
    madd[11:7] = Zeros{5} + 4;
    - = ExecuteScalarInstruction(madd, 32);
    assert ReadGPR(2) == Zeros{PTO_XLEN} + 5;
    assert ReadGPR(3) == Zeros{PTO_XLEN} + 6;
    assert ReadGPR(4) == Zeros{PTO_XLEN} + 47;

    // Bitfield insertion snapshots both the preserved base and inserted value.
    var bitfield_insert: bits(48) = Zeros{48} + 0x0000204d000e;
    bitfield_insert[35:31] = Zeros{5} + 2;
    bitfield_insert[40:36] = Zeros{5} + 3;
    bitfield_insert[9:4] = Zeros{6} + 63;
    bitfield_insert[15:10] = Zeros{6};
    // ALU-ALIAS-DECODED: bitfield-destination-overlaps-base
    WriteGPR(2, Zeros{PTO_XLEN});
    WriteGPR(3, Zeros{PTO_XLEN} + 3);
    bitfield_insert[27:23] = Zeros{5} + 2;
    - = ExecuteScalarInstruction(bitfield_insert, 48);
    assert ReadGPR(2) == Zeros{PTO_XLEN} + 0x8000000000000001;
    assert ReadGPR(3) == Zeros{PTO_XLEN} + 3;
    // ALU-ALIAS-DECODED: bitfield-destination-overlaps-insert
    WriteGPR(2, Zeros{PTO_XLEN});
    WriteGPR(3, Zeros{PTO_XLEN} + 3);
    bitfield_insert[27:23] = Zeros{5} + 3;
    - = ExecuteScalarInstruction(bitfield_insert, 48);
    assert ReadGPR(2) == Zeros{PTO_XLEN};
    assert ReadGPR(3) == Zeros{PTO_XLEN} + 0x8000000000000001;

    // Select snapshots the true, false, and predicate operands independently.
    var select: bits(48) = Zeros{48} + 0x00000077;
    select[19:15] = Zeros{5} + 2;
    select[24:20] = Zeros{5} + 3;
    select[31:27] = Zeros{5} + 4;
    select[26:25] = Zeros{2};
    // ALU-ALIAS-DECODED: select-destination-overlaps-true
    WriteGPR(2, Zeros{PTO_XLEN} + 10);
    WriteGPR(3, Zeros{PTO_XLEN} + 20);
    WriteGPR(4, Zeros{PTO_XLEN} + 1);
    select[11:7] = Zeros{5} + 2;
    - = ExecuteScalarInstruction(select, 32);
    assert ReadGPR(2) == Zeros{PTO_XLEN} + 10;
    // ALU-ALIAS-DECODED: select-destination-overlaps-false
    WriteGPR(2, Zeros{PTO_XLEN} + 10);
    WriteGPR(3, Zeros{PTO_XLEN} + 20);
    WriteGPR(4, Zeros{PTO_XLEN});
    select[26:25] = Zeros{2} + 3;
    select[11:7] = Zeros{5} + 3;
    - = ExecuteScalarInstruction(select, 32);
    assert ReadGPR(3) == Zeros{PTO_XLEN} + 0xffffffffffffffec;
    // ALU-ALIAS-DECODED: select-destination-overlaps-predicate
    WriteGPR(2, Zeros{PTO_XLEN} + 10);
    WriteGPR(3, Zeros{PTO_XLEN} + 20);
    WriteGPR(4, Zeros{PTO_XLEN} + 1);
    select[26:25] = Zeros{2};
    select[11:7] = Zeros{5} + 4;
    - = ExecuteScalarInstruction(select, 32);
    assert ReadGPR(4) == Zeros{PTO_XLEN} + 10;

    // ALU-ALIAS-DECODED: select-queue-sources-and-push
    ResetProfileState();
    PushTemporaryQueue(TRUE, Zeros{PTO_XLEN} + 5);
    PushTemporaryQueue(FALSE, Zeros{PTO_XLEN} + 7);
    PushTemporaryQueue(FALSE, Zeros{PTO_XLEN} + 1);
    select[19:15] = Zeros{5} + 24;
    select[24:20] = Zeros{5} + 29;
    select[31:27] = Zeros{5} + 28;
    select[11:7] = Zeros{5} + 31;
    - = ExecuteScalarInstruction(select, 32);
    assert ReadTemporaryQueue(TRUE, 0) == Zeros{PTO_XLEN} + 5;
    assert ReadTemporaryQueue(TRUE, 1) == Zeros{PTO_XLEN} + 5;

    // Materialization still exercises the Reg5 destination classes.
    var move_immediate: bits(48) = Zeros{48} + 0x0016;
    move_immediate[10:6] = Zeros{5} + 1;
    // ALU-ALIAS-DECODED: materialize-push-u
    move_immediate[15:11] = Zeros{5} + 30;
    - = ExecuteScalarInstruction(move_immediate, 16);
    assert ReadTemporaryQueue(FALSE, 0) == Zeros{PTO_XLEN} + 1;
    // ALU-ALIAS-DECODED: materialize-push-t
    move_immediate[15:11] = Zeros{5} + 31;
    - = ExecuteScalarInstruction(move_immediate, 16);
    assert ReadTemporaryQueue(TRUE, 0) == Zeros{PTO_XLEN} + 1;

    // Move and control forms consume queue selectors through decoded operands.
    var move_register: bits(48) = Zeros{48} + 0x0006;
    // ALU-ALIAS-DECODED: move-t4-to-gpr
    ResetProfileState();
    PushTemporaryQueue(TRUE, Zeros{PTO_XLEN} + 2);
    PushTemporaryQueue(TRUE, Zeros{PTO_XLEN} + 3);
    PushTemporaryQueue(TRUE, Zeros{PTO_XLEN} + 4);
    PushTemporaryQueue(TRUE, Zeros{PTO_XLEN} + 5);
    move_register[10:6] = Zeros{5} + 27;
    move_register[15:11] = Zeros{5} + 2;
    - = ExecuteScalarInstruction(move_register, 16);
    assert ReadGPR(2) == Zeros{PTO_XLEN} + 2;

    // ALU-ALIAS-DECODED: move-u4-push-u
    ResetProfileState();
    PushTemporaryQueue(FALSE, Zeros{PTO_XLEN} + 11);
    PushTemporaryQueue(FALSE, Zeros{PTO_XLEN} + 12);
    PushTemporaryQueue(FALSE, Zeros{PTO_XLEN} + 13);
    PushTemporaryQueue(FALSE, Zeros{PTO_XLEN} + 14);
    move_register[10:6] = Zeros{5} + 31;
    move_register[15:11] = Zeros{5} + 30;
    - = ExecuteScalarInstruction(move_register, 16);
    assert ReadTemporaryQueue(FALSE, 0) == Zeros{PTO_XLEN} + 11;
    assert ReadTemporaryQueue(FALSE, 1) == Zeros{PTO_XLEN} + 14;

    var set_commit_target: bits(48) = Zeros{48} + 0x001c;
    // ALU-ALIAS-DECODED: control-t2-source
    ResetProfileState();
    PushTemporaryQueue(TRUE, Zeros{PTO_XLEN} + 21);
    PushTemporaryQueue(TRUE, Zeros{PTO_XLEN} + 22);
    set_commit_target[10:6] = Zeros{5} + 25;
    - = ExecuteScalarInstruction(set_commit_target, 16);
    assert _CommitArgument == Zeros{PTO_XLEN} + 21;
    // ALU-ALIAS-DECODED: control-u3-source
    PushTemporaryQueue(FALSE, Zeros{PTO_XLEN} + 31);
    PushTemporaryQueue(FALSE, Zeros{PTO_XLEN} + 32);
    PushTemporaryQueue(FALSE, Zeros{PTO_XLEN} + 33);
    set_commit_target[10:6] = Zeros{5} + 30;
    - = ExecuteScalarInstruction(set_commit_target, 16);
    assert _CommitArgument == Zeros{PTO_XLEN} + 31;

    // ALU-ALIAS-DECODED: implicit-t-source-and-push
    ResetProfileState();
    PushTemporaryQueue(TRUE, Zeros{PTO_XLEN} + 3);
    var shift_t: bits(48) = Zeros{48} + 0x102c;
    shift_t[10:6] = Zeros{5} + 1;
    - = ExecuteScalarInstruction(shift_t, 16);
    assert ReadTemporaryQueue(TRUE, 0) == Zeros{PTO_XLEN} + 6;
    assert ReadTemporaryQueue(TRUE, 1) == Zeros{PTO_XLEN} + 3;

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

    ResetProfileState();
end;
func main() => integer
begin
    ResetProfileState();
    TestScalarALUAliasMatrix();
    return 0;
end;
