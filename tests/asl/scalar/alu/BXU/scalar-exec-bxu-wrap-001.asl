// PTO-TEST: {"id":"PTO-AVS-SCALAR-BXU-WRAP-001","source":"asl/scalar/alu/BXU.asl","requirements":["PTO-INST-SCALAR-BXU"],"kind":"execution","summary":"BXU zero-extends a wrapping selected field","pass_condition":"M=63 and N=2 select source bits 63 and 0 and produce unsigned field 3","related_sources":["asl/scalar/model/alu/semantics.asl"]}
func main() => integer
begin
    ResetProfileState();
    WriteGPR(1, Zeros{PTO_XLEN} + 0x8000000000000001);
    var instruction: bits(48) = Zeros{48} + 0x00001067;
    instruction[11:7] = Zeros{5} + 2;
    instruction[19:15] = Zeros{5} + 1;
    instruction[25:20] = Zeros{6} + 1;
    instruction[31:26] = Zeros{6} + 63;
    let status = ExecuteScalarInstruction(instruction, 32);
    assert status == ScalarExecution_Executed;
    assert ReadGPR(2) == Zeros{PTO_XLEN} + 3;
    assert InstructionContractResult_BXU(
        Zeros{PTO_XLEN} + 0x8000000000000001,
        2,
        63) == Zeros{PTO_XLEN} + 3;
    return 0;
end;
