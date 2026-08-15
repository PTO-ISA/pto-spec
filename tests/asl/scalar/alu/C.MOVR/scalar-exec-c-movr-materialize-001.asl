// PTO-TEST: {"id":"PTO-AVS-SCALAR-C-MOVR-MATERIALIZE-001","source":"asl/scalar/alu/C.MOVR.asl","requirements":["PTO-INST-SCALAR-C-MOVR"],"kind":"execution","summary":"C.MOVR applies its assigned materialization or extension rule","pass_condition":"Decoded execution and the mnemonic result contract agree on the boundary value","related_sources":["asl/scalar/model/alu/semantics.asl"]}
func main() => integer
begin
    ResetProfileState();
    PushTemporaryQueue(TRUE, Zeros{PTO_XLEN} + 0x1234);
    var instruction: bits(48) = Zeros{48} + 0x0006;
    instruction[15:11] = Zeros{5} + 2;
    instruction[10:6] = Zeros{5} + 24;
    let execution = ExecuteScalarInstruction(instruction, 16);
    assert execution == ScalarExecution_Executed;
    assert ReadGPR(2) == Zeros{PTO_XLEN} + 0x1234;
    assert InstructionContractResult_C_MOVR(Zeros{PTO_XLEN} + 0x1234) == Zeros{PTO_XLEN} + 0x1234;
    return 0;
end;
