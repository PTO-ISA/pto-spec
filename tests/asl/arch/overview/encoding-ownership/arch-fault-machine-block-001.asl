// PTO-TEST: {"id":"PTO-AVS-ARCH-ENCODING-OWNERSHIP-MACHINE-BLOCK-001","source":"asl/arch/overview/encoding-ownership.asl","requirements":["PTO-ARCH-ENCODING-OWNERSHIP-001"],"kind":"fault","summary":"Machine-parallel and machine-sequential block starts are extension-reserved.","pass_condition":"Every tested long and compressed machine-block encoding rejects before PTO block effects.","related_sources":["asl/block/model/dispatch/top-level.asl"]}
func AssertMachineBlockReserved(instruction: bits(64),
                                length_bits: integer {16,32,48,64})
begin
    ResetProfileState();
    WriteBPC(Zeros{PTO_XLEN} + 0x200);
    SetBundleArgument(Zeros{PTO_XLEN} + 0x55);
    let before_bpc = ReadBPC();
    let before_argument = _BundleArgument;
    assert DecodeCommandForm(instruction, length_bits) ==
        PTO_COMMAND_FORM_COUNT;
    let status = ExecuteCommandInstruction(instruction, length_bits);
    assert status == CommandExecution_Rejected;
    assert _LastFault == Fault_IllegalInstruction;
    assert ReadBPC() == before_bpc;
    assert _BundleArgument == before_argument;
end;

func main() => integer
begin
    AssertMachineBlockReserved(Zeros{64} + 0x00001181, 32);
    AssertMachineBlockReserved(Zeros{64} + 0x02001181, 32);
    AssertMachineBlockReserved(Zeros{64} + 0x00009181, 32);
    AssertMachineBlockReserved(Zeros{64} + 0x06009181, 32);
    AssertMachineBlockReserved(Zeros{64} + 0x08c0, 16);
    AssertMachineBlockReserved(Zeros{64} + 0x48c0, 16);
    return 0;
end;
