// PTO-TEST: {"id":"PTO-AVS-SCALAR-HL-SETC-NEI-DUPLICATE-002","source":"asl/scalar/bru/HL.SETC.NEI.asl","requirements":["PTO-INST-SCALAR-HL-SETC-NEI"],"kind":"fault","summary":"A second SETC condition setter in one block rejects before effects","pass_condition":"HL.SETC.NEI cannot overwrite the result of an earlier HL.SETC.EQI in the same conditional block","related_sources":["asl/scalar/model/sys/semantics.asl","asl/scalar/model/bru/semantics.asl","asl/block/model/state/control-state.asl"]}
func main() => integer
begin
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x100);
    WriteGPR(1, Zeros{PTO_XLEN});
    BeginBundle(
        BundleKind_Standard,
        BundleTransfer_Conditional,
        Zeros{PTO_XLEN} + 0x80,
        Zeros{PTO_XLEN} + 0x180,
        Zeros{PTO_XLEN},
        FALSE);
    EnterBundleBody();
    var equal: bits(48) = Zeros{48} + 0x00000075000e;
    equal[35:31] = Zeros{5} + 1;
    var not_equal: bits(48) = Zeros{48} + 0x00001075000e;
    not_equal[35:31] = Zeros{5} + 1;

    let first = ExecuteScalarInstruction(equal, 48);
    assert first == ScalarExecution_Executed;
    assert _CommitArgument == Zeros{PTO_XLEN} + 1;
    assert _BARG.taken;

    let second = ExecuteScalarInstruction(not_equal, 48);

    assert second == ScalarExecution_Rejected;
    assert _LastFault == Fault_BundleControl;
    assert _CommitArgument == Zeros{PTO_XLEN} + 1;
    assert _BARG.taken;
    return 0;
end;
