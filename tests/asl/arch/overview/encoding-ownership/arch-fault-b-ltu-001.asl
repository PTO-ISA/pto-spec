// PTO-TEST: {"id":"PTO-AVS-ARCH-ENCODING-OWNERSHIP-B-LTU-001","source":"asl/arch/overview/encoding-ownership.asl","requirements":["PTO-ARCH-ENCODING-OWNERSHIP-001"],"kind":"fault","summary":"The B.LTU form is extension-reserved and rejects before scalar effects","pass_condition":"B.LTU fails scalar decode and execution with IllegalInstruction while preserving control state","related_sources":["asl/arch/dispatch/top-level.asl"]}
func main() => integer
begin
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x100);
    var instruction: bits(48) = Zeros{48} + 0x00004027;
    WriteGPR(1, Zeros{PTO_XLEN} + 5);
    WriteGPR(2, Zeros{PTO_XLEN} + 5);
    instruction[19:15] = Zeros{5} + 1;
    instruction[24:20] = Zeros{5} + 2;
    let before_tpc = ReadTPC();

    assert DecodeScalarForm(instruction, 32) == PTO_SCALAR_FORM_COUNT;
    let status = ExecuteScalarInstruction(instruction, 32);

    assert status == ScalarExecution_Rejected;
    assert _LastFault == Fault_IllegalInstruction;
    assert ReadTPC() == before_tpc;
    return 0;
end;
