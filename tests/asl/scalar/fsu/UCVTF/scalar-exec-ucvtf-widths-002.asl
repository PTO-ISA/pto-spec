// PTO-TEST: {"id":"PTO-AVS-SCALAR-UCVTF-WIDTHS-002","source":"asl/scalar/fsu/UCVTF.asl","requirements":["PTO-COMMON-CONVERSION-PROFILE-001","PTO-INST-SCALAR-UCVTF","PTO-UCVTF-DECISION-BINDING-001"],"kind":"execution","summary":"UCVTF accepts all four unsigned integer source widths","pass_condition":"UD, UW, UH, and UB raw encodings zero-extend two and publish exact FP32 two","related_sources":["asl/arch/profile/reference-conversion.asl"]}
func main() => integer
begin
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x900);

    WriteGPR(1, Zeros{PTO_XLEN} + 2);
    let ud_status = ExecuteScalarInstruction(
        Zeros{48} + 0x0800f1eb, 32);
    assert ud_status == ScalarExecution_Executed;
    assert ReadGPR(3) == Zeros{PTO_XLEN} + 0x40000000;
    let uw_status = ExecuteScalarInstruction(
        Zeros{48} + 0x0a00f1eb, 32);
    assert uw_status == ScalarExecution_Executed;
    assert ReadGPR(3) == Zeros{PTO_XLEN} + 0x40000000;
    let uh_status = ExecuteScalarInstruction(
        Zeros{48} + 0x0c00f1eb, 32);
    assert uh_status == ScalarExecution_Executed;
    assert ReadGPR(3) == Zeros{PTO_XLEN} + 0x40000000;
    let ub_status = ExecuteScalarInstruction(
        Zeros{48} + 0x0e00f1eb, 32);
    assert ub_status == ScalarExecution_Executed;
    assert ReadGPR(3) == Zeros{PTO_XLEN} + 0x40000000;
    assert ScalarFPFlags() == Zeros{5};
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x910;
    return 0;
end;
