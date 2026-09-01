// PTO-TEST: {"id":"PTO-AVS-SCALAR-FCVT-NARROW-SOURCES-003","source":"asl/scalar/fsu/FCVT.asl","requirements":["PTO-COMMON-CONVERSION-PROFILE-001","PTO-INST-SCALAR-FCVT"],"kind":"execution","summary":"FCVT accepts FP16 and E4M3 scalar sources","pass_condition":"exact raw FH-to-FS and FB-to-FS encodings convert 1.5 to FP32 and advance once each","related_sources":["asl/arch/profile/reference-conversion.asl"]}
func main() => integer
begin
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x900);

    WriteGPR(1, Zeros{PTO_XLEN} + 0x3e00);
    let half_status = ExecuteScalarInstruction(
        Zeros{48} + 0x0c0081eb, 32);
    assert half_status == ScalarExecution_Executed;
    assert ReadGPR(3) == Zeros{PTO_XLEN} + 0x3fc00000;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x904;

    WriteGPR(1, Zeros{PTO_XLEN} + 0x3c);
    let e4m3_status = ExecuteScalarInstruction(
        Zeros{48} + 0x0e0081eb, 32);
    assert e4m3_status == ScalarExecution_Executed;
    assert ReadGPR(3) == Zeros{PTO_XLEN} + 0x3fc00000;
    assert ScalarFPFlags() == Zeros{5};
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x908;
    return 0;
end;
