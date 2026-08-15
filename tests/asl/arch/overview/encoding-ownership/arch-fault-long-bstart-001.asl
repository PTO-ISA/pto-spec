// PTO-TEST: {"id":"PTO-AVS-ARCH-ENCODING-OWNERSHIP-LONG-BSTART-001","source":"asl/arch/overview/encoding-ownership.asl","requirements":["PTO-ARCH-ENCODING-OWNERSHIP-001"],"kind":"fault","summary":"Half-long and long BSTART extension encodings are reserved by PTO.","pass_condition":"Every tested occupied HL/L BSTART form rejects before PTO block or return-address effects.","related_sources":["asl/block/model/dispatch/top-level.asl"]}
func AssertLongBStartReserved(instruction: bits(64),
                              length_bits: integer {48,64})
begin
    ResetProfileState();
    WriteBPC(Zeros{PTO_XLEN} + 0x200);
    WriteGPR(10, Zeros{PTO_XLEN} + 0xaaaa);
    SetBundleArgument(Zeros{PTO_XLEN} + 0x55);
    let before_bpc = ReadBPC();
    let before_ra = ReadGPR(10);
    let before_argument = _BundleArgument;
    assert DecodeCommandForm(instruction, length_bits) ==
        PTO_COMMAND_FORM_COUNT;
    let status = ExecuteCommandInstruction(instruction, length_bits);
    assert status == CommandExecution_Rejected;
    assert _LastFault == Fault_IllegalInstruction;
    assert ReadBPC() == before_bpc;
    assert ReadGPR(10) == before_ra;
    assert _BundleArgument == before_argument;
end;

func main() => integer
begin
    AssertLongBStartReserved(Zeros{64} + 0x501600000011, 48);
    AssertLongBStartReserved(Zeros{64} + 0x541600000091, 48);
    AssertLongBStartReserved(Zeros{64} + 0x00003101000e, 48);
    AssertLongBStartReserved(Zeros{64} + 0x00001101001e, 48);
    AssertLongBStartReserved(Zeros{64} + 0x00004101000e, 48);
    AssertLongBStartReserved(Zeros{64} + 0x00002101800e, 48);
    AssertLongBStartReserved(Zeros{64} + 0x00004001000e, 48);
    AssertLongBStartReserved(Zeros{64} + 0x00001001001e, 48);
    AssertLongBStartReserved(Zeros{64} + 0x00003001000e, 48);
    AssertLongBStartReserved(Zeros{64} + 0x00002001800e, 48);
    AssertLongBStartReserved(Zeros{64} + 0x00001081000e, 48);

    AssertLongBStartReserved(Zeros{64} + 0x000030810000000f, 64);
    AssertLongBStartReserved(Zeros{64} + 0x000020810000008f, 64);
    AssertLongBStartReserved(Zeros{64} + 0x000040810000000f, 64);
    AssertLongBStartReserved(Zeros{64} + 0x000090810000000f, 64);
    AssertLongBStartReserved(Zeros{64} + 0x000020010000000f, 64);
    AssertLongBStartReserved(Zeros{64} + 0x000040010000008f, 64);
    AssertLongBStartReserved(Zeros{64} + 0x000030010000000f, 64);
    AssertLongBStartReserved(Zeros{64} + 0x000090010000000f, 64);
    AssertLongBStartReserved(Zeros{64} + 0x000010110000000f, 64);
    return 0;
end;
