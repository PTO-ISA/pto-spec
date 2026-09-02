// PTO-TEST: {"id":"PTO-AVS-SCALAR-HL-BFI-WRAP-001","source":"asl/scalar/alu/HL.BFI.asl","requirements":["PTO-INST-SCALAR-HL-BFI"],"kind":"execution","summary":"HL.BFI inserts source bits into a wrapping destination interval","pass_condition":"first=63 and last=0 insert source bits zero and one into destination bits 63 and 0","related_sources":["asl/scalar/model/alu/semantics.asl"]}
func main() => integer
begin
    ResetProfileState();
    WriteGPR(1, Zeros{PTO_XLEN});
    WriteGPR(2, Zeros{PTO_XLEN} + 3);
    var instruction: bits(48) = Zeros{48} + 0x0000204d000e;
    instruction[27:23] = Zeros{5} + 3;
    instruction[35:31] = Zeros{5} + 1;
    instruction[40:36] = Zeros{5} + 2;
    instruction[9:4] = Zeros{6} + 63;
    instruction[15:10] = Zeros{6};
    let status = ExecuteScalarInstruction(instruction, 48);
    assert status == ScalarExecution_Executed;
    assert ReadGPR(3) == Zeros{PTO_XLEN} + 0x8000000000000001;
    assert InstructionContractResult_HL_BFI(
        Zeros{PTO_XLEN},
        Zeros{PTO_XLEN} + 3,
        63,
        0) == Zeros{PTO_XLEN} + 0x8000000000000001;
    return 0;
end;
