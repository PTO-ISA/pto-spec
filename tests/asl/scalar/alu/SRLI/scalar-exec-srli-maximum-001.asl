// PTO-TEST: {"id":"PTO-AVS-SCALAR-SRLI-MAXIMUM-001","source":"asl/scalar/alu/SRLI.asl","requirements":["PTO-INST-SCALAR-SRLI"],"kind":"execution","summary":"SRLI accepts shamt 63 and shifts the top bit to bit zero","pass_condition":"maximum logical right shift, alias snapshot, TPC, and contract match SRLI","related_sources":["asl/scalar/model/dispatch/alu.asl","asl/scalar/model/alu/semantics.asl"]}
func main() => integer
begin
    ResetProfileState();
    WriteGPR(1, Ones{PTO_XLEN});
    WriteTPC(Zeros{PTO_XLEN} + 0x40);
    var instruction: bits(48) = Zeros{48} + 0x00005015;
    instruction[11:7] = Zeros{5} + 1;
    instruction[19:15] = Zeros{5} + 1;
    instruction[25:20] = Ones{6};
    let status = ExecuteScalarInstruction(instruction, 32);
    assert status == ScalarExecution_Executed;
    assert ReadGPR(1) == Zeros{PTO_XLEN} + 1;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x44;
    assert InstructionContractShiftWidth_SRLI() == 6;
    assert !InstructionContractIsWordOperation_SRLI();
    return 0;
end;
