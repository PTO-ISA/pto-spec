// PTO-TEST: {"id":"PTO-AVS-ARCH-ENCODING-OWNERSHIP-FIXUP-001","source":"asl/arch/overview/encoding-ownership.asl","requirements":["PTO-ARCH-ENCODING-OWNERSHIP-001"],"kind":"boundary","summary":"Only zero-displacement PTO FALL forms are legal; nonzero Fixup payloads are extension-reserved.","pass_condition":"FP, STD, and SYS FALL zero forms are legal and representative nonzero payloads reject before block effects.","related_sources":["asl/block/execution/BSTART.FP.asl","asl/block/execution/BSTART.STD.asl","asl/block/execution/BSTART.SYS.asl"]}
func AssertFixupReserved(instruction: bits(64))
begin
    ResetProfileState();
    WriteBPC(Zeros{PTO_XLEN} + 0x200);
    SetBundleArgument(Zeros{PTO_XLEN} + 0x55);
    let before_bpc = ReadBPC();
    let before_argument = _BundleArgument;

    let decoded = DecodeCommandForm(instruction, 32);
    assert decoded != PTO_COMMAND_FORM_COUNT;
    assert !CommandFormOperandsLegal(
        instruction, decoded as integer {0..PTO_COMMAND_FORM_COUNT-1});
    let status = ExecuteCommandInstruction(instruction, 32);
    assert status == CommandExecution_Rejected;
    assert _LastFault == Fault_IllegalInstruction;
    assert ReadBPC() == before_bpc;
    assert _BundleArgument == before_argument;
end;

func main() => integer
begin
    let fp_fall = DecodeCommandForm(Zeros{64} + 0x00001101, 32);
    let std_fall = DecodeCommandForm(Zeros{64} + 0x00001001, 32);
    let sys_fall = DecodeCommandForm(Zeros{64} + 0x00001081, 32);
    assert fp_fall != PTO_COMMAND_FORM_COUNT;
    assert std_fall != PTO_COMMAND_FORM_COUNT;
    assert sys_fall != PTO_COMMAND_FORM_COUNT;
    assert CommandFormOperandsLegal(Zeros{64} + 0x00001101,
        fp_fall as integer {0..PTO_COMMAND_FORM_COUNT-1});
    assert CommandFormOperandsLegal(Zeros{64} + 0x00001001,
        std_fall as integer {0..PTO_COMMAND_FORM_COUNT-1});
    assert CommandFormOperandsLegal(Zeros{64} + 0x00001081,
        sys_fall as integer {0..PTO_COMMAND_FORM_COUNT-1});

    AssertFixupReserved(Zeros{64} + 0x00009101);
    AssertFixupReserved(Zeros{64} + 0x00009001);
    AssertFixupReserved(Zeros{64} + 0x00009081);
    AssertFixupReserved(Zeros{64} + 0xffff9101);
    AssertFixupReserved(Zeros{64} + 0xffff9001);
    AssertFixupReserved(Zeros{64} + 0xffff9081);
    return 0;
end;
