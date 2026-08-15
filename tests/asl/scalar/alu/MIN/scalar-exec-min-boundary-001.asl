// PTO-TEST: {"id":"PTO-AVS-SCALAR-MIN-BOUNDARY-001","source":"asl/scalar/alu/MIN.asl","requirements":["PTO-INST-SCALAR-MIN"],"kind":"execution","summary":"MIN applies its full-XLEN comparison at the signedness boundary","pass_condition":"decoded boundary result, mnemonic value function, and TPC match MIN","related_sources":["asl/scalar/model/dispatch/alu.asl","asl/scalar/model/alu/semantics.asl"]}
func main() => integer
begin
    ResetProfileState();
    WriteGPR(1, Zeros{PTO_XLEN} + 0x8000000000000000);
    WriteGPR(2, Zeros{PTO_XLEN} + 0x7fffffffffffffff);
    WriteTPC(Zeros{PTO_XLEN} + 0x80);

    var instruction: bits(48) = Zeros{48} + 0x0000505b;
    instruction[11:7] = Zeros{5} + 1;
    instruction[19:15] = Zeros{5} + 1;
    instruction[24:20] = Zeros{5} + 2;

    let status = ExecuteScalarInstruction(instruction, 32);
    assert status == ScalarExecution_Executed;
    assert ReadGPR(1) == Zeros{PTO_XLEN} + 0x8000000000000000;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x84;
    assert InstructionContractResult_MIN(
        Zeros{PTO_XLEN} + 0x8000000000000000,
        Zeros{PTO_XLEN} + 0x7fffffffffffffff) == Zeros{PTO_XLEN} + 0x8000000000000000;
    return 0;
end;
