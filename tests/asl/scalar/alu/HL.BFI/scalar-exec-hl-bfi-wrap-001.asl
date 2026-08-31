// PTO-TEST: {"id":"PTO-AVS-SCALAR-HL-BFI-WRAP-001","source":"asl/scalar/alu/HL.BFI.asl","requirements":["PTO-INST-SCALAR-HL-BFI"],"kind":"execution","summary":"HL.BFI inserts source bytes into a wrapping destination interval","pass_condition":"M=7 and N=2 insert source bytes zero and one into destination bytes seven and zero","related_sources":["asl/scalar/model/alu/bitfield.asl"]}
func main() => integer
begin
    ResetProfileState();
    WriteGPR(1, Zeros{PTO_XLEN});
    WriteGPR(2, Zeros{PTO_XLEN} + 0x2211);
    var instruction: bits(48) = Zeros{48} + 0x0000204d000e;
    instruction[27:23] = Zeros{5} + 3;
    instruction[35:31] = Zeros{5} + 1;
    instruction[40:36] = Zeros{5} + 2;
    instruction[9:4] = Zeros{6} + 1;
    instruction[15:10] = Zeros{6} + 7;
    let status = ExecuteScalarInstruction(instruction, 48);
    assert status == ScalarExecution_Executed;
    assert ReadGPR(3) == Zeros{PTO_XLEN} + 0x1100000000000022;
    assert InstructionContractResult_HL_BFI(
        Zeros{PTO_XLEN},
        Zeros{PTO_XLEN} + 0x2211,
        7,
        2) == Zeros{PTO_XLEN} + 0x1100000000000022;
    return 0;
end;
