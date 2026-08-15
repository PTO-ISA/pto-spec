// PTO-TEST: {"id":"PTO-AVS-SCALAR-SLLI-MAXIMUM-001","source":"asl/scalar/alu/SLLI.asl","requirements":["PTO-INST-SCALAR-SLLI"],"kind":"execution","summary":"SLLI accepts shamt 63 and shifts into the XLEN sign bit","pass_condition":"maximum shift, alias snapshot, TPC, and contract match SLLI","related_sources":["asl/scalar/model/dispatch/alu.asl","asl/scalar/model/alu/semantics.asl"]}
func main() => integer
begin
    ResetProfileState();
    WriteGPR(1, Zeros{PTO_XLEN} + 1);
    WriteTPC(Zeros{PTO_XLEN} + 0x40);
    var instruction: bits(48) = Zeros{48} + 0x00007015;
    instruction[11:7] = Zeros{5} + 1;
    instruction[19:15] = Zeros{5} + 1;
    instruction[25:20] = Ones{6};
    let status = ExecuteScalarInstruction(instruction, 32);
    assert status == ScalarExecution_Executed;
    assert ReadGPR(1) == '1000000000000000000000000000000000000000000000000000000000000000';
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x44;
    assert InstructionContractShiftWidth_SLLI() == 6;
    assert !InstructionContractIsWordOperation_SLLI();
    return 0;
end;
