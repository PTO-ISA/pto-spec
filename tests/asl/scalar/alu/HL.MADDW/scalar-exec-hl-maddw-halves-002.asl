// PTO-TEST: {"id":"PTO-AVS-SCALAR-HL-MADDW-HALVES-002","source":"asl/scalar/alu/HL.MADDW.asl","requirements":["PTO-INST-SCALAR-HL-MADDW"],"kind":"execution","summary":"HL.MADDW publishes sign-extended low and high word halves","pass_condition":"Dst0 is sign-extended result[31:0] and Dst1 is sign-extended result[63:32]","related_sources":["asl/scalar/model/alu/semantics.asl","asl/scalar/model/dispatch/alu.asl"]}
func main() => integer
begin
    ResetProfileState();
    WriteGPR(1, Zeros{PTO_XLEN});
    WriteGPR(2, Zeros{PTO_XLEN} + 0x7fffffff);
    WriteGPR(3, Zeros{PTO_XLEN} + 0x7fffffff);
    var instruction: bits(48) = Zeros{48} + 0x00007047000e;
    instruction[27:23] = Zeros{5} + 4;
    instruction[15:11] = Zeros{5} + 5;
    instruction[47:43] = Zeros{5} + 1;
    instruction[35:31] = Zeros{5} + 2;
    instruction[40:36] = Zeros{5} + 3;

    let status = ExecuteScalarInstruction(instruction, 48);

    assert status == ScalarExecution_Executed;
    assert ReadGPR(4) == Zeros{PTO_XLEN} + 1;
    assert ReadGPR(5) == Zeros{PTO_XLEN} + 0x3fffffff;
    return 0;
end;
