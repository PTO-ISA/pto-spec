// PTO-TEST: {"id":"PTO-AVS-SCALAR-SRAIW-MAXIMUM-001","source":"asl/scalar/alu/SRAIW.asl","requirements":["PTO-INST-SCALAR-SRAIW"],"kind":"execution","summary":"SRAIW accepts shamt 31 and replicates the word sign bit","pass_condition":"maximum word arithmetic shift, alias snapshot, TPC, and contract match SRAIW","related_sources":["asl/scalar/model/dispatch/alu.asl","asl/scalar/model/alu/semantics.asl"]}
func main() => integer
begin
    ResetProfileState();
    WriteGPR(1, Zeros{PTO_XLEN} + 0x80000000);
    WriteTPC(Zeros{PTO_XLEN} + 0x40);
    var instruction: bits(48) = Zeros{48} + 0x00006035;
    instruction[11:7] = Zeros{5} + 1;
    instruction[19:15] = Zeros{5} + 1;
    instruction[24:20] = Ones{5};
    let status = ExecuteScalarInstruction(instruction, 32);
    assert status == ScalarExecution_Executed;
    assert ReadGPR(1) == Ones{PTO_XLEN};
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x44;
    assert InstructionContractShiftWidth_SRAIW() == 5;
    assert InstructionContractIsWordOperation_SRAIW();
    return 0;
end;
