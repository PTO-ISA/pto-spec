// PTO-TEST: {"id":"PTO-AVS-SCALAR-HL-SETC-EQI-PLACE-002","source":"asl/scalar/bru/HL.SETC.EQI.asl","requirements":["PTO-INST-SCALAR-HL-SETC-EQI"],"kind":"fault","summary":"HL.SETC.EQI rejects outside an active conditional block","pass_condition":"placement fails before source or commit-state effects","related_sources":["asl/scalar/model/sys/semantics.asl","asl/scalar/model/bru/semantics.asl"]}
func main() => integer
begin
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x100);
    WriteGPR(1, Zeros{PTO_XLEN});
    _CommitArgument = Zeros{PTO_XLEN} + 0x55;
    var instruction: bits(48) = Zeros{48} + 0x00000075000e;
    instruction[35:31] = Zeros{5} + 1;

    let status = ExecuteScalarInstruction(instruction, 48);

    assert status == ScalarExecution_Rejected;
    assert _LastFault == Fault_BundleControl;
    assert _CommitArgument == Zeros{PTO_XLEN} + 0x55;
    assert ReadGPR(1) == Zeros{PTO_XLEN};
    return 0;
end;
