// PTO-TEST: {"id":"PTO-AVS-SCALAR-SUBI-RESULT-001","source":"asl/scalar/alu/SUBI.asl","requirements":["PTO-INST-SCALAR-SUBI"],"kind":"execution","summary":"SUBI subtracts a zero-extended unsigned immediate with XLEN wraparound","pass_condition":"source-destination alias, wraparound result, TPC, and mnemonic contract match SUBI","related_sources":["asl/scalar/model/dispatch/alu.asl","asl/scalar/model/alu/semantics.asl"]}
func main() => integer
begin
    ResetProfileState();
    WriteGPR(1, Zeros{PTO_XLEN});
    WriteTPC(Zeros{PTO_XLEN} + 0x40);
    var instruction: bits(48) = Zeros{48} + 0x00001015;
    instruction[11:7] = Zeros{5} + 1;
    instruction[19:15] = Zeros{5} + 1;
    instruction[31:20] = Zeros{12} + 1;
    let status = ExecuteScalarInstruction(instruction, 32);
    assert status == ScalarExecution_Executed;
    assert ReadGPR(1) == Ones{PTO_XLEN};
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x44;
    assert InstructionContractImmediateWidth_SUBI() == 12;
    assert InstructionContractImmediateIsUnsigned_SUBI();
    assert !InstructionContractIsWordOperation_SUBI();
    return 0;
end;
