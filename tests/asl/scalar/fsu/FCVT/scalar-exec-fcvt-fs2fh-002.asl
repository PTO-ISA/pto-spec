// PTO-TEST: {"id":"PTO-AVS-SCALAR-FCVT-FS2FH-002","source":"asl/scalar/fsu/FCVT.asl","requirements":["PTO-INST-SCALAR-FCVT"],"kind":"execution","summary":"the exact compiler FCVT FS-to-FH encoding publishes a binary16 result","pass_condition":"raw 0x120c0feb reads FP32 0.1 from T1, converts it to FP16 0x2e66, pushes T, records NX, and advances once","related_sources":["asl/arch/profile/reference-profile.asl","asl/arch/profile/reference-quantization.asl"]}
func main() => integer
begin
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x900);
    PushTemporaryQueue(TRUE, Zeros{PTO_XLEN} + 0x3dcccccd);

    let status = ExecuteScalarInstruction(
        Zeros{48} + 0x120c0feb, 32);

    assert status == ScalarExecution_Executed;
    assert _LastFault == Fault_None;
    assert ReadTemporaryQueue(TRUE, 0) == Zeros{PTO_XLEN} + 0x2e66;
    assert ScalarFPFlags() == Zeros{5} + 0x10;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x904;
    return 0;
end;
