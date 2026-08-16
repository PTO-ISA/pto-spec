// PTO-TEST: {"id":"PTO-AVS-SCALAR-ALU-GPR-ALIAS-EXEC-001","source":"asl/scalar/model/alu/semantics.asl","requirements":[],"kind":"execution","summary":"scalar ALU GPR aliases snapshot sources before destination writes","pass_condition":"GPR overlap, zero, and discard-destination assertions hold","related_sources":[]}
func TestScalarALUGPRAliases()
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
end;
func main() => integer
begin
    ResetProfileState();
    TestScalarALUGPRAliases();
    return 0;
end;
