// PTO-TEST: {"id":"PTO-AVS-SCALAR-FCVTZ-NARROW-SOURCES-003","source":"asl/scalar/fsu/FCVTZ.asl","requirements":["PTO-COMMON-CONVERSION-PROFILE-001","PTO-FCVTZ-DECISION-BINDING-001","PTO-INST-SCALAR-FCVTZ"],"kind":"execution","summary":"FCVTZ accepts FP16 and E4M3 scalar sources","pass_condition":"raw FH-to-SB and FB-to-UB encodings round toward zero, publish normalized integers, accumulate NX, and advance","related_sources":["asl/arch/profile/reference-conversion.asl"]}
func main() => integer
begin
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x900);

    WriteGPR(1, Zeros{PTO_XLEN} + 0xc100);
    let half_status = ExecuteScalarInstruction(
        Zeros{48} + 0x3c00d1eb, 32);
    assert half_status == ScalarExecution_Executed;
    assert ReadGPR(3) == Ones{PTO_XLEN} - 1;
    assert ScalarFPFlags() == Zeros{5} + 0x10;

    WriteGPR(1, Zeros{PTO_XLEN} + 0x3c);
    let e4m3_status = ExecuteScalarInstruction(
        Zeros{48} + 0x1e00d1eb, 32);
    assert e4m3_status == ScalarExecution_Executed;
    assert ReadGPR(3) == Zeros{PTO_XLEN} + 1;
    assert ScalarFPFlags() == Zeros{5} + 0x10;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x908;
    return 0;
end;
