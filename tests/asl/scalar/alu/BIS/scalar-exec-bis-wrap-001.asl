// PTO-TEST: {"id":"PTO-AVS-SCALAR-BIS-WRAP-001","source":"asl/scalar/alu/BIS.asl","requirements":["PTO-INST-SCALAR-BIS"],"kind":"execution","summary":"BIS sets a wrapping selected field","pass_condition":"M=63 and N=2 set source bits 63 and 0 and preserve every other bit","related_sources":["asl/scalar/model/alu/semantics.asl"]}
func main() => integer
begin
    ResetProfileState();
    var instruction: bits(48) = Zeros{48} + 0x00003067;
    instruction[11:7] = Zeros{5} + 2;
    instruction[19:15] = Zeros{5} + 1;
    instruction[25:20] = Zeros{6} + 1;
    instruction[31:26] = Zeros{6} + 63;
    let status = ExecuteScalarInstruction(instruction, 32);
    assert status == ScalarExecution_Executed;
    assert ReadGPR(2) == Zeros{PTO_XLEN} + 0x8000000000000001;
    assert InstructionContractResult_BIS(Zeros{PTO_XLEN}, 2, 63) ==
        Zeros{PTO_XLEN} + 0x8000000000000001;
    return 0;
end;
