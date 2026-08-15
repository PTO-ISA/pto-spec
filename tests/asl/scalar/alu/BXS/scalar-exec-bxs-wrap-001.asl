// PTO-TEST: {"id":"PTO-AVS-SCALAR-BXS-WRAP-001","source":"asl/scalar/alu/BXS.asl","requirements":["PTO-INST-SCALAR-BXS"],"kind":"execution","summary":"BXS sign-extends a wrapping selected field","pass_condition":"M=63 and N=2 select source bits 63 and 0, produce signed field 11, and publish all ones","related_sources":["asl/scalar/model/alu/semantics.asl"]}
func main() => integer
begin
    ResetProfileState();
    WriteGPR(1, Zeros{PTO_XLEN} + 0x8000000000000001);
    var instruction: bits(48) = Zeros{48} + 0x00000067;
    instruction[11:7] = Zeros{5} + 2;
    instruction[19:15] = Zeros{5} + 1;
    instruction[25:20] = Zeros{6} + 1;
    instruction[31:26] = Zeros{6} + 63;
    let status = ExecuteScalarInstruction(instruction, 32);
    assert status == ScalarExecution_Executed;
    assert ReadGPR(2) == Ones{PTO_XLEN};
    assert InstructionContractResult_BXS(
        Zeros{PTO_XLEN} + 0x8000000000000001,
        2,
        63) == Ones{PTO_XLEN};
    return 0;
end;
