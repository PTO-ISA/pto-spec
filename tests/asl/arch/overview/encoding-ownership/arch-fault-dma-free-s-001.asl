// PTO-TEST: {"id":"PTO-AVS-ARCH-ENCODING-OWNERSHIP-DMA-FREE-S-001","source":"asl/arch/overview/encoding-ownership.asl","requirements":["PTO-ARCH-DMA-ENCODING-ONLY-001"],"kind":"fault","summary":"The DMA.FREE.S form is extension-reserved and rejects before scalar effects","pass_condition":"DMA.FREE.S fails scalar decode and execution with IllegalInstruction while preserving operand and control state","related_sources":["asl/arch/dispatch/top-level.asl"]}
func main() => integer
begin
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x100);
    WriteGPR(1, Zeros{PTO_XLEN} + 5);
    WriteGPR(2, Zeros{PTO_XLEN} + 5);
    var instruction: bits(48) = Zeros{48} + 0x0400700b;
    instruction[19:15] = Zeros{5} + 1;
    let before_tpc = ReadTPC();
    let before_left = ReadGPR(1);
    let before_right = ReadGPR(2);

    assert DecodeScalarForm(instruction, 32) == PTO_SCALAR_FORM_COUNT;
    let status = ExecuteScalarInstruction(instruction, 32);

    assert status == ScalarExecution_Rejected;
    assert _LastFault == Fault_IllegalInstruction;
    assert ReadTPC() == before_tpc;
    assert ReadGPR(1) == before_left;
    assert ReadGPR(2) == before_right;
    return 0;
end;
