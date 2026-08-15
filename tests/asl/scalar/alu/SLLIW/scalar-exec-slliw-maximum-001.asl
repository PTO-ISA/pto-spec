// PTO-TEST: {"id":"PTO-AVS-SCALAR-SLLIW-MAXIMUM-001","source":"asl/scalar/alu/SLLIW.asl","requirements":["PTO-INST-SCALAR-SLLIW"],"kind":"execution","summary":"SLLIW accepts shamt 31 and sign-extends the shifted word","pass_condition":"maximum word shift, alias snapshot, TPC, and contract match SLLIW","related_sources":["asl/scalar/model/dispatch/alu.asl","asl/scalar/model/alu/semantics.asl"]}
func main() => integer
begin
    ResetProfileState();
    WriteGPR(1, Zeros{PTO_XLEN} + 1);
    WriteTPC(Zeros{PTO_XLEN} + 0x40);
    var instruction: bits(48) = Zeros{48} + 0x00007035;
    instruction[11:7] = Zeros{5} + 1;
    instruction[19:15] = Zeros{5} + 1;
    instruction[24:20] = Ones{5};
    let status = ExecuteScalarInstruction(instruction, 32);
    assert status == ScalarExecution_Executed;
    assert ReadGPR(1) == '1111111111111111111111111111111110000000000000000000000000000000';
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x44;
    assert InstructionContractShiftWidth_SLLIW() == 5;
    assert InstructionContractIsWordOperation_SLLIW();
    return 0;
end;
