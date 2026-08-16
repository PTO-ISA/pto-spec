// PTO-TEST: {"id":"PTO-AVS-SCALAR-ALU-CONTROL-ALIAS-EXEC-004","source":"asl/scalar/model/alu/semantics.asl","requirements":[],"kind":"execution","summary":"materialization, move, and control forms resolve queue selectors","pass_condition":"materialization, move, control, and implicit queue assertions hold","related_sources":[]}
func TestScalarALUControlAliases()
begin
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
    WriteTPC(Zeros{PTO_XLEN} + 0x100);
    BeginBundleAt(
        ReadTPC(),
        BundleKind_Standard,
        BundleTransfer_Conditional,
        Zeros{PTO_XLEN} + 0x200,
        Zeros{PTO_XLEN} + 0x102,
        Zeros{PTO_XLEN} + 0x102,
        FALSE);
    PushTemporaryQueue(TRUE, Zeros{PTO_XLEN} + 21);
    PushTemporaryQueue(TRUE, Zeros{PTO_XLEN} + 22);
    set_commit_target[10:6] = Zeros{5} + 25;
    - = ExecuteScalarInstruction(set_commit_target, 16);
    assert _BARG.bpcn == Zeros{PTO_XLEN} + 21;
    // ALU-ALIAS-DECODED: control-u3-source
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x200);
    BeginBundleAt(
        ReadTPC(),
        BundleKind_Standard,
        BundleTransfer_Conditional,
        Zeros{PTO_XLEN} + 0x300,
        Zeros{PTO_XLEN} + 0x202,
        Zeros{PTO_XLEN} + 0x202,
        FALSE);
    PushTemporaryQueue(FALSE, Zeros{PTO_XLEN} + 31);
    PushTemporaryQueue(FALSE, Zeros{PTO_XLEN} + 32);
    PushTemporaryQueue(FALSE, Zeros{PTO_XLEN} + 33);
    set_commit_target[10:6] = Zeros{5} + 30;
    - = ExecuteScalarInstruction(set_commit_target, 16);
    assert _BARG.bpcn == Zeros{PTO_XLEN} + 31;

    // ALU-ALIAS-DECODED: implicit-t-source-and-push
    ResetProfileState();
    PushTemporaryQueue(TRUE, Zeros{PTO_XLEN} + 3);
    var shift_t: bits(48) = Zeros{48} + 0x102c;
    shift_t[10:6] = Zeros{5} + 1;
    - = ExecuteScalarInstruction(shift_t, 16);
    assert ReadTemporaryQueue(TRUE, 0) == Zeros{PTO_XLEN} + 6;
    assert ReadTemporaryQueue(TRUE, 1) == Zeros{PTO_XLEN} + 3;
end;
func main() => integer
begin
    ResetProfileState();
    TestScalarALUControlAliases();
    return 0;
end;
