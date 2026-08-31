// PTO-TEST: {"id":"PTO-AVS-SCALAR-HL-BFI-ALIAS-001","source":"asl/scalar/alu/HL.BFI.asl","requirements":["PTO-INST-SCALAR-HL-BFI"],"kind":"boundary","summary":"HL.BFI snapshots aliased sources before destination publication","pass_condition":"An aliased SrcL and destination use the pre-instruction base while eight source bytes replace the complete word","related_sources":["asl/scalar/model/types/operands.asl"]}
func main() => integer
begin
    ResetProfileState();
    WriteGPR(1, Ones{PTO_XLEN});
    WriteGPR(2, Zeros{PTO_XLEN});
    var instruction: bits(48) = Zeros{48} + 0x0000204d000e;
    instruction[27:23] = Zeros{5} + 1;
    instruction[35:31] = Zeros{5} + 1;
    instruction[40:36] = Zeros{5} + 2;
    instruction[9:4] = Zeros{6} + 7;
    instruction[15:10] = Zeros{6};
    let status = ExecuteScalarInstruction(instruction, 48);
    assert status == ScalarExecution_Executed;
    assert ReadGPR(1) == Zeros{PTO_XLEN};
    return 0;
end;
