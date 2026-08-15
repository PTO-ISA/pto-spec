// PTO-TEST: {"id":"PTO-AVS-SCALAR-C-SETC-TGT-REL-001","source":"asl/scalar/alu/C.SETC.TGT.asl","requirements":["PTO-INST-SCALAR-C-SETC-TGT"],"kind":"execution","summary":"C.SETC.TGT snapshots a non-consuming relative source","pass_condition":"the selected T value remains queued and a later queue push cannot change BARG.BPCN","related_sources":["asl/scalar/model/types/operands.asl","asl/scalar/model/sys/semantics.asl"]}
func main() => integer
begin
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x200);
    BeginBundleAt(
        ReadTPC(),
        BundleKind_Floating,
        BundleTransfer_Conditional,
        Zeros{PTO_XLEN} + 0x400,
        Zeros{PTO_XLEN} + 0x202,
        Zeros{PTO_XLEN} + 0x202,
        FALSE);
    PushTemporaryQueue(TRUE, Zeros{PTO_XLEN} + 0x800);

    var instruction: bits(48) = Zeros{48} + 0x001c;
    instruction[10:6] = Zeros{5} + 24;

    let status = ExecuteScalarInstruction(instruction, 16);
    assert status == ScalarExecution_Executed;
    assert _BARG.bpcn == Zeros{PTO_XLEN} + 0x800;
    assert ReadTemporaryQueue(TRUE, 0) == Zeros{PTO_XLEN} + 0x800;

    PushTemporaryQueue(TRUE, Zeros{PTO_XLEN} + 0x900);
    assert _BARG.bpcn == Zeros{PTO_XLEN} + 0x800;
    assert ReadTemporaryQueue(TRUE, 0) == Zeros{PTO_XLEN} + 0x900;
    assert ReadTemporaryQueue(TRUE, 1) == Zeros{PTO_XLEN} + 0x800;
    return 0;
end;
