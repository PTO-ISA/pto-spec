// PTO-TEST: {"id":"PTO-AVS-ARCH-ENCODING-OWNERSHIP-B-TEXT-001","source":"asl/arch/overview/encoding-ownership.asl","requirements":["PTO-ARCH-ENCODING-OWNERSHIP-001"],"kind":"fault","summary":"The B.TEXT 32-bit root is extension-reserved and rejects before PTO state effects.","pass_condition":"Every tested B.TEXT-family word fails command decode and execution with Fault_IllegalInstruction while preserving pre-existing block state.","related_sources":["asl/block/model/dispatch/top-level.asl"]}
func AssertBTextReserved(instruction: bits(64))
begin
    ResetProfileState();
    WriteBPC(Zeros{PTO_XLEN} + 0x200);
    SetBundleArgument(Zeros{PTO_XLEN} + 0x55);

    let before_bpc = ReadBPC();
    let before_argument = _BundleArgument;
    assert DecodeCommandForm(instruction, 32) == PTO_COMMAND_FORM_COUNT;

    let status = ExecuteCommandInstruction(instruction, 32);
    assert status == CommandExecution_Rejected;
    assert _LastFault == Fault_IllegalInstruction;
    assert ReadBPC() == before_bpc;
    assert _BundleArgument == before_argument;
end;

func main() => integer
begin
    AssertBTextReserved(Zeros{64} + 0x00000003);
    AssertBTextReserved(Zeros{64} + 0xffffff83);
    return 0;
end;
