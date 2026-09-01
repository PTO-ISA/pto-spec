// PTO-TEST: {"id":"PTO-AVS-SCALAR-SCVTF-WIDTHS-002","source":"asl/scalar/fsu/SCVTF.asl","requirements":["PTO-COMMON-CONVERSION-PROFILE-001","PTO-INST-SCALAR-SCVTF","PTO-SCVTF-DECISION-BINDING-001"],"kind":"execution","summary":"SCVTF accepts all four signed integer source widths","pass_condition":"SD, SW, SH, and SB raw encodings sign-extend negative two and publish exact FP32 negative two","related_sources":["asl/arch/profile/reference-conversion.asl"]}
func main() => integer
begin
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x900);

    WriteGPR(1, Ones{PTO_XLEN} - 1);
    let sd_status = ExecuteScalarInstruction(
        Zeros{48} + 0x0800e1eb, 32);
    assert sd_status == ScalarExecution_Executed;
    assert ReadGPR(3) == Zeros{PTO_XLEN} + 0xc0000000;
    WriteGPR(1, Zeros{PTO_XLEN} + 0xfffffffe);
    let sw_status = ExecuteScalarInstruction(
        Zeros{48} + 0x0a00e1eb, 32);
    assert sw_status == ScalarExecution_Executed;
    assert ReadGPR(3) == Zeros{PTO_XLEN} + 0xc0000000;
    WriteGPR(1, Zeros{PTO_XLEN} + 0xfffe);
    let sh_status = ExecuteScalarInstruction(
        Zeros{48} + 0x0c00e1eb, 32);
    assert sh_status == ScalarExecution_Executed;
    assert ReadGPR(3) == Zeros{PTO_XLEN} + 0xc0000000;
    WriteGPR(1, Zeros{PTO_XLEN} + 0xfe);
    let sb_status = ExecuteScalarInstruction(
        Zeros{48} + 0x0e00e1eb, 32);
    assert sb_status == ScalarExecution_Executed;
    assert ReadGPR(3) == Zeros{PTO_XLEN} + 0xc0000000;
    assert ScalarFPFlags() == Zeros{5};
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x910;
    return 0;
end;
