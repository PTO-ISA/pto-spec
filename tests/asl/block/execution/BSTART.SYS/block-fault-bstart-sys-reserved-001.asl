// PTO-TEST: {"id":"PTO-AVS-BLOCK-BSTART-SYS-RESERVED-001","source":"asl/block/execution/BSTART.SYS.asl","requirements":["PTO-INST-BLOCK-BSTART-SYS"],"kind":"fault","summary":"Nonzero BSTART.SYS Fixup payloads remain reserved outside PTO.","pass_condition":"Positive and negative nonzero simm17 boundary representatives reject before BPC or block-state effects.","related_sources":["asl/arch/overview/encoding-ownership.asl"]}
func AssertReservedSYSFixup(instruction: bits(64))
begin
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x600);
    WriteBPC(Zeros{PTO_XLEN} + 0x580);
    let status = ExecuteCommandInstruction(instruction, 32);
    assert status == CommandExecution_Rejected;
    assert _LastFault == Fault_IllegalInstruction;
    assert !_BundleActive;
    assert ReadBPC() == Zeros{PTO_XLEN} + 0x580;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x600;
end;

func main() => integer
begin
    AssertReservedSYSFixup(Zeros{64} + 0x00009081);
    AssertReservedSYSFixup(Zeros{64} + 0xffff9081);
    return 0;
end;
