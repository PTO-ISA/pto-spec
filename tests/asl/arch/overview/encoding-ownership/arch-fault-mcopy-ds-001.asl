// PTO-TEST: {"id":"PTO-AVS-ARCH-ENCODING-OWNERSHIP-MCOPY-DS-001","source":"asl/arch/overview/encoding-ownership.asl","requirements":["PTO-ARCH-DMA-ENCODING-ONLY-001"],"kind":"fault","summary":"The MCOPY.DS form is extension-reserved and rejects before command effects","pass_condition":"MCOPY.DS fails command decode and execution with IllegalInstruction while preserving operand and control state","related_sources":["asl/arch/dispatch/top-level.asl"]}
func main() => integer
begin
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x100);
    WriteGPR(1, Zeros{PTO_XLEN} + 5);
    WriteGPR(2, Zeros{PTO_XLEN} + 5);
    var instruction: bits(64) = Zeros{64} + 0x02001031;
    instruction[19:15] = Zeros{5} + 1;
    instruction[24:20] = Zeros{5} + 2;
    WriteBPC(Zeros{PTO_XLEN} + 0x200);
    SetBundleArgument(Zeros{PTO_XLEN} + 0x55);
    let before_bpc = ReadBPC();
    let before_argument = _BundleArgument;
    let before_tpc = ReadTPC();
    let before_left = ReadGPR(1);
    let before_right = ReadGPR(2);

    assert DecodeCommandForm(instruction, 32) == PTO_COMMAND_FORM_COUNT;
    let status = ExecuteCommandInstruction(instruction, 32);

    assert status == CommandExecution_Rejected;
    assert _LastFault == Fault_IllegalInstruction;
    assert ReadTPC() == before_tpc;
    assert ReadBPC() == before_bpc;
    assert _BundleArgument == before_argument;
    assert ReadGPR(1) == before_left;
    assert ReadGPR(2) == before_right;
    return 0;
end;
