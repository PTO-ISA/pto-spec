// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-SCALAR-TESTSCALARDISPATCHEFFECTS-EXECUTION-001","source":"asl/scalar/model/alu/semantics.asl","requirements":[],"kind":"execution","summary":"migrated independent behavior point for TestScalarDispatchEffects","pass_condition":"TestScalarDispatchEffects completes without assertion failure","related_sources":[]}
func TestScalarDispatchEffects()
begin
    ClearFault();
    WriteTPC(Zeros{PTO_XLEN} + 0x100);
    WriteGPR(2, Zeros{PTO_XLEN} + 10);
    WriteGPR(3, Zeros{PTO_XLEN} + 3);
    var add_instruction: bits(48) = Zeros{48} + 0x00000005;
    add_instruction[11:7] = Zeros{5} + 5;
    add_instruction[19:15] = Zeros{5} + 2;
    add_instruction[24:20] = Zeros{5} + 3;
    add_instruction[26:25] = '11';
    add_instruction[31:27] = Zeros{5} + 1;
    let add_status = ExecuteScalarInstruction(add_instruction, 32);
    assert add_status == ScalarExecution_Executed;
    assert ReadGPR(5) == Zeros{PTO_XLEN} + 4;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x104;

    var addi_instruction: bits(48) = Zeros{48} + 0x00000015;
    addi_instruction[11:7] = Zeros{5} + 6;
    addi_instruction[19:15] = Zeros{5} + 2;
    addi_instruction[31:20] = Zeros{12} + 7;
    let addi_status = ExecuteScalarInstruction(addi_instruction, 32);
    assert addi_status == ScalarExecution_Executed;
    assert ReadGPR(6) == Zeros{PTO_XLEN} + 17;

    WriteGPR(2, Zeros{PTO_XLEN} + 0x7fffffff);
    WriteGPR(3, Zeros{PTO_XLEN} + 1);
    WriteGPR(4, Zeros{PTO_XLEN} + 1);
    var maddw_instruction: bits(48) = Zeros{48} + 0x00007047;
    maddw_instruction[11:7] = Zeros{5} + 7;
    maddw_instruction[19:15] = Zeros{5} + 3;
    maddw_instruction[24:20] = Zeros{5} + 4;
    maddw_instruction[31:27] = Zeros{5} + 2;
    let maddw_status = ExecuteScalarInstruction(maddw_instruction, 32);
    assert maddw_status == ScalarExecution_Executed;
    assert ReadGPR(7) == SignExtend{PTO_XLEN}(Zeros{32} + 0x80000000);

    WriteGPR(2, Zeros{PTO_XLEN} + 8);
    WriteGPR(3, Zeros{PTO_XLEN} + 9);
    var compressed_add: bits(48) = Zeros{48} + 0x0008;
    compressed_add[10:6] = Zeros{5} + 2;
    compressed_add[15:11] = Zeros{5} + 3;
    let compressed_status = ExecuteScalarInstruction(compressed_add, 16);
    assert compressed_status == ScalarExecution_Executed;
    assert ReadTemporaryQueue(TRUE, 0) == Zeros{PTO_XLEN} + 17;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x10e;

    ClearFault();
    WriteTPC(Zeros{PTO_XLEN} + 100);
    var specific_alias: bits(48) = Zeros{48} + 0x0016;
    specific_alias[15:11] = Zeros{5} + 10;
    let alias_status = ExecuteScalarInstruction(specific_alias, 16);
    assert alias_status == ScalarExecution_Executed;
    assert _ReturnAddress == Zeros{PTO_XLEN} + 100;
    assert ReadGPR(10) == Zeros{PTO_XLEN} + 100;
    assert _LastFault == Fault_None;

    WriteGPR(2, Zeros{PTO_XLEN} + 0x0f);
    WriteGPR(3, Zeros{PTO_XLEN} + 0xf0);
    var compare_and: bits(48) = Zeros{48} + 0x00002045;
    compare_and[11:7] = Zeros{5} + 8;
    compare_and[19:15] = Zeros{5} + 2;
    compare_and[24:20] = Zeros{5} + 3;
    let compare_and_zero_status = ExecuteScalarInstruction(compare_and, 32);
    assert compare_and_zero_status == ScalarExecution_Executed;
    assert ReadGPR(8) == Zeros{PTO_XLEN};
    compare_and[26:25] = '11';
    let compare_and_nonzero_status = ExecuteScalarInstruction(compare_and, 32);
    assert compare_and_nonzero_status == ScalarExecution_Executed;
    assert ReadGPR(8) == Zeros{PTO_XLEN} + 1;

    WriteGPR(2, Zeros{PTO_XLEN} + 8);
    var set_commit_immediate: bits(48) = Zeros{48} + 0x00000075;
    set_commit_immediate[11:7] = Zeros{5} + 3;
    set_commit_immediate[19:15] = Zeros{5} + 2;
    set_commit_immediate[31:20] = Zeros{12} + 1;
    let set_commit_status = ExecuteScalarInstruction(set_commit_immediate, 32);
    assert set_commit_status == ScalarExecution_Executed;
    assert _CommitArgument == Zeros{PTO_XLEN} + 1;

    SetCommitTarget(Zeros{PTO_XLEN});
    WritePC(Zeros{PTO_XLEN} + 100);
    var branch_zero: bits(48) = Zeros{48} + 0x00001037;
    branch_zero[31:15] = Zeros{17} + 3;
    let branch_taken_status = ExecuteScalarInstruction(branch_zero, 32);
    assert branch_taken_status == ScalarExecution_Executed;
    assert ReadPC() == Zeros{PTO_XLEN} + 106;
    SetCommitTarget(Zeros{PTO_XLEN} + 1);
    WritePC(Zeros{PTO_XLEN} + 100);
    let branch_fallthrough_status = ExecuteScalarInstruction(branch_zero, 32);
    assert branch_fallthrough_status == ScalarExecution_Executed;
    assert ReadPC() == Zeros{PTO_XLEN} + 104;

    WriteGPR(2, Zeros{PTO_XLEN} + 200);
    var jump_register: bits(48) = Zeros{48} + 0x00006027;
    jump_register[19:15] = Zeros{5} + 2;
    jump_register[31:25] = Zeros{7} + 2;
    let jump_register_status = ExecuteScalarInstruction(jump_register, 32);
    assert jump_register_status == ScalarExecution_Executed;
    assert ReadPC() == Zeros{PTO_XLEN} + 204;

    ClearFault();
    let reserved_status = ExecuteScalarInstruction(Zeros{48}, 32);
    assert reserved_status == ScalarExecution_Rejected;
    assert _LastFault == Fault_IllegalInstruction;
end;
func main() => integer
begin
    ResetProfileState();
    TestScalarDispatchEffects();
    return 0;
end;
