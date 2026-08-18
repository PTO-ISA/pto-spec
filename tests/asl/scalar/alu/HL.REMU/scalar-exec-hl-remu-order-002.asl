// PTO-TEST: {"id":"PTO-AVS-SCALAR-HL-REMU-ORDER-002","source":"asl/scalar/alu/HL.REMU.asl","requirements":["PTO-INST-SCALAR-HL-REMU"],"kind":"execution","summary":"HL.REMU duplicate destination retains the quotient","pass_condition":"RegDst0 and RegDst1 naming one GPR leaves the later quotient write visible","related_sources":["asl/scalar/model/alu/semantics.asl","asl/scalar/model/dispatch/alu.asl"]}
func main() => integer
begin
    ResetProfileState();
    WriteGPR(1, Zeros{PTO_XLEN} + 7);
    WriteGPR(2, Zeros{PTO_XLEN} + 3);
    var instruction: bits(48) = Zeros{48} + 0x00005057000e;
    instruction[27:23] = Zeros{5} + 3;
    instruction[15:11] = Zeros{5} + 3;
    instruction[35:31] = Zeros{5} + 1;
    instruction[40:36] = Zeros{5} + 2;

    let status = ExecuteScalarInstruction(instruction, 48);

    assert status == ScalarExecution_Executed;
    assert ReadGPR(3) == Zeros{PTO_XLEN} + 2;
    return 0;
end;
