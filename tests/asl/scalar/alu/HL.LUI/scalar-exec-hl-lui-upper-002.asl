// PTO-TEST: {"id":"PTO-AVS-SCALAR-HL-LUI-UPPER-002","source":"asl/scalar/alu/HL.LUI.asl","requirements":["PTO-INST-SCALAR-HL-LUI"],"kind":"execution","summary":"HL.LUI places its split immediate in result bits 63 through 32","pass_condition":"encoded immediate one materializes 0x0000000100000000 rather than sign-extending the immediate","related_sources":["asl/scalar/model/alu/semantics.asl","asl/scalar/model/dispatch/alu.asl"]}
func main() => integer
begin
    ResetProfileState();
    var instruction: bits(48) = Zeros{48} + 0x00000017000e;
    instruction[27:23] = Zeros{5} + 2;
    instruction[47:28] = Zeros{20} + 1;
    instruction[15:4] = Zeros{12};

    let status = ExecuteScalarInstruction(instruction, 48);

    assert status == ScalarExecution_Executed;
    assert ReadGPR(2) == Zeros{PTO_XLEN} + 0x0000000100000000;
    return 0;
end;
