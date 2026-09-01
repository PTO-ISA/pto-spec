// PTO-TEST: {"id":"PTO-AVS-SCALAR-FCVTZ-RAW-SD-002","source":"asl/scalar/fsu/FCVTZ.asl","requirements":["PTO-INST-SCALAR-FCVTZ","PTO-FCVTZ-DECISION-BINDING-001"],"kind":"execution","summary":"exact compiler FCVTZ FS-to-SD encoding publishes the signed 64-bit result","pass_condition":"raw 0x220c5feb reads FP32 16.0 from T1, maps DstType raw four to SD, pushes signed 16 to T, and advances once","related_sources":["asl/scalar/model/dispatch/fsu.asl","asl/scalar/model/fsu/profile.asl"]}
func main() => integer
begin
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x900);
    PushTemporaryQueue(TRUE, Zeros{PTO_XLEN} + 0x41800000);

    let status = ExecuteScalarInstruction(
        Zeros{48} + 0x220c5feb, 32);

    assert status == ScalarExecution_Executed;
    assert _LastFault == Fault_None;
    assert ReadTemporaryQueue(TRUE, 0) == Zeros{PTO_XLEN} + 16;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x904;
    return 0;
end;
