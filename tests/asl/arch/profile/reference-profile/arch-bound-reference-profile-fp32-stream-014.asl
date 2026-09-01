// PTO-TEST: {"id":"PTO-AVS-ARCH-REFERENCE-PROFILE-FP32-STREAM-014","source":"asl/arch/profile/reference-profile.asl","requirements":[],"kind":"boundary","summary":"the exact compiler SCVTF FMADD FCVTZ stream preserves the 16.0 FP32 exponent boundary","pass_condition":"raw compiler encodings with the matching U and T queue positions publish FP32 160, FP32 16, and signed integer 16","related_sources":["asl/scalar/fsu/SCVTF.asl","asl/scalar/fsu/FMADD.asl","asl/scalar/fsu/FCVTZ.asl","asl/scalar/model/dispatch/fsu.asl"]}
func main() => integer
begin
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x100);
    WriteGPR(2, Zeros{PTO_XLEN} + 160);

    let scvtf_status = ExecuteScalarInstruction(
        Zeros{48} + 0x0a016f6b, 32);
    assert scvtf_status == ScalarExecution_Executed;
    assert ReadTemporaryQueue(FALSE, 0) ==
        Zeros{PTO_XLEN} + 0x43200000;

    PushTemporaryQueue(TRUE, Zeros{PTO_XLEN} + 0x1111);
    PushTemporaryQueue(TRUE, Zeros{PTO_XLEN} + 0x3dcccccd);
    PushTemporaryQueue(TRUE, Zeros{PTO_XLEN} + 0x2222);
    PushTemporaryQueue(TRUE, Zeros{PTO_XLEN});
    let fmadd_status = ExecuteScalarInstruction(
        Zeros{48} + 0xc3ae4fcb, 32);
    assert fmadd_status == ScalarExecution_Executed;
    assert ReadTemporaryQueue(TRUE, 0) ==
        Zeros{PTO_XLEN} + 0x41800000;

    let fcvtz_status = ExecuteScalarInstruction(
        Zeros{48} + 0x220c5feb, 32);
    assert fcvtz_status == ScalarExecution_Executed;
    assert ReadTemporaryQueue(TRUE, 0) == Zeros{PTO_XLEN} + 16;
    return 0;
end;
