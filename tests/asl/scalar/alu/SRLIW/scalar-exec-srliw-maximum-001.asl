// PTO-TEST: {"id":"PTO-AVS-SCALAR-SRLIW-MAXIMUM-001","source":"asl/scalar/alu/SRLIW.asl","requirements":["PTO-INST-SCALAR-SRLIW"],"kind":"execution","summary":"SRLIW accepts shamt 31 and logically shifts the word sign bit to bit zero","pass_condition":"maximum word logical shift, alias snapshot, TPC, and contract match SRLIW","related_sources":["asl/scalar/model/dispatch/alu.asl","asl/scalar/model/alu/semantics.asl"]}
func main() => integer
begin
    ResetProfileState();
    WriteGPR(1, Zeros{PTO_XLEN} + 0x80000000);
    WriteTPC(Zeros{PTO_XLEN} + 0x40);
    var instruction: bits(48) = Zeros{48} + 0x00005035;
    instruction[11:7] = Zeros{5} + 1;
    instruction[19:15] = Zeros{5} + 1;
    instruction[24:20] = Ones{5};
    let status = ExecuteScalarInstruction(instruction, 32);
    assert status == ScalarExecution_Executed;
    assert ReadGPR(1) == Zeros{PTO_XLEN} + 1;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x44;
    assert InstructionContractShiftWidth_SRLIW() == 5;
    assert InstructionContractIsWordOperation_SRLIW();
    return 0;
end;
