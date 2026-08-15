// PTO-TEST: {"id":"PTO-AVS-SCALAR-SRLW-MAXIMUM-001","source":"asl/scalar/alu/SRLW.asl","requirements":["PTO-INST-SCALAR-SRLW"],"kind":"execution","summary":"SRLW uses the maximum masked register shift count","pass_condition":"maximum register count, alias snapshot, TPC, and mnemonic contract match SRLW","related_sources":["asl/scalar/model/dispatch/alu.asl","asl/scalar/model/alu/semantics.asl"]}
func main() => integer
begin
    ResetProfileState();
    WriteGPR(1, Zeros{PTO_XLEN} + 0x80000000);
    WriteGPR(2, Zeros{PTO_XLEN} + 31);
    WriteTPC(Zeros{PTO_XLEN} + 0x40);

    var instruction: bits(48) = Zeros{48} + 0x00005025;
    instruction[11:7] = Zeros{5} + 1;
    instruction[19:15] = Zeros{5} + 1;
    instruction[24:20] = Zeros{5} + 2;

    let status = ExecuteScalarInstruction(instruction, 32);
    assert status == ScalarExecution_Executed;
    assert ReadGPR(1) == Zeros{PTO_XLEN} + 1;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x44;
    assert InstructionContractShiftAmount_SRLW(Zeros{PTO_XLEN} + 31) == 31;
    assert InstructionContractResult_SRLW(Zeros{PTO_XLEN} + 0x80000000, Zeros{PTO_XLEN} + 31) == Zeros{PTO_XLEN} + 1;
    return 0;
end;
