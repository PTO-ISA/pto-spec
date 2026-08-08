// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-SCALAR-TESTSCALARBITFIELDBOUNDARYCONTRACT-BOUNDARY-001","source":"asl/scalar/model/alu/semantics.asl","requirements":[],"kind":"boundary","summary":"migrated independent behavior point for TestScalarBitfieldBoundaryContract","pass_condition":"TestScalarBitfieldBoundaryContract completes without assertion failure","related_sources":[]}
func TestScalarBitfieldBoundaryContract()
begin
    ClearFault();
    WriteTPC(Zeros{PTO_XLEN} + 0x1800);
    WriteGPR(2, Zeros{PTO_XLEN} + 0x1122334455667788);
    var reverse: bits(48) = Zeros{48} + 0x00007067;
    reverse[11:7] = Zeros{5} + 3;
    reverse[19:15] = Zeros{5} + 2;

    // Width 16 at offset 0.
    reverse[25:20] = Zeros{6} + 15;
    reverse[31:26] = Zeros{6};
    let low_half_status = ExecuteScalarInstruction(reverse, 32);
    assert low_half_status == ScalarExecution_Executed;
    assert ReadGPR(3) == Zeros{PTO_XLEN} + 0x8877;

    // Hold the width fixed and vary only the independently encoded offset.
    WriteGPR(2, Zeros{PTO_XLEN} + 0x1122334455667788);
    reverse[31:26] = Zeros{6} + 8;
    let shifted_half_status = ExecuteScalarInstruction(reverse, 32);
    assert shifted_half_status == ScalarExecution_Executed;
    assert ReadGPR(3) == Zeros{PTO_XLEN} + 0x7766;

    // Hold the offset fixed and vary only the independently encoded width.
    reverse[25:20] = Zeros{6} + 31;
    let shifted_word_status = ExecuteScalarInstruction(reverse, 32);
    assert shifted_word_status == ScalarExecution_Executed;
    assert ReadGPR(3) == Zeros{PTO_XLEN} + 0x77665544;

    reverse[31:26] = Zeros{6} + 60;
    reverse[25:20] = Zeros{6} + 15;
    let wrapping_status = ExecuteScalarInstruction(reverse, 32);
    assert wrapping_status == ScalarExecution_Executed;
    assert ReadGPR(3) == Zeros{PTO_XLEN} + 0x8178;

    reverse[31:26] = Zeros{6};
    reverse[25:20] = Zeros{6} + 6;
    let non_byte_status = ExecuteScalarInstruction(reverse, 32);
    assert non_byte_status == ScalarExecution_Executed;
    assert ReadGPR(3) == Zeros{PTO_XLEN};
    assert _LastFault == Fault_None;

    reverse[25:20] = Ones{6};
    let full_width_status = ExecuteScalarInstruction(reverse, 32);
    assert full_width_status == ScalarExecution_Executed;
    assert ReadGPR(3) == Zeros{PTO_XLEN} + 0x8877665544332211;

    // The source is snapshotted before the aliased absolute destination write.
    WriteGPR(2, Zeros{PTO_XLEN} + 0x1122334455667788);
    reverse[11:7] = Zeros{5} + 2;
    reverse[25:20] = Zeros{6} + 15;
    let alias_status = ExecuteScalarInstruction(reverse, 32);
    assert alias_status == ScalarExecution_Executed;
    assert ReadGPR(2) == Zeros{PTO_XLEN} + 0x8877;
end;
func main() => integer
begin
    ResetProfileState();
    TestScalarBitfieldBoundaryContract();
    return 0;
end;
