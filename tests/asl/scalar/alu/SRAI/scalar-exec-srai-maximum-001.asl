// PTO-TEST: {"id":"PTO-AVS-SCALAR-SRAI-MAXIMUM-001","source":"asl/scalar/alu/SRAI.asl","requirements":["PTO-INST-SCALAR-SRAI"],"kind":"execution","summary":"SRAI accepts shamt 63 and replicates the XLEN sign bit","pass_condition":"maximum arithmetic right shift, alias snapshot, TPC, and contract match SRAI","related_sources":["asl/scalar/model/dispatch/alu.asl","asl/scalar/model/alu/semantics.asl"]}
func main() => integer
begin
    ResetProfileState();
    WriteGPR(1, '1000000000000000000000000000000000000000000000000000000000000000');
    WriteTPC(Zeros{PTO_XLEN} + 0x40);
    var instruction: bits(48) = Zeros{48} + 0x00006015;
    instruction[11:7] = Zeros{5} + 1;
    instruction[19:15] = Zeros{5} + 1;
    instruction[25:20] = Ones{6};
    let status = ExecuteScalarInstruction(instruction, 32);
    assert status == ScalarExecution_Executed;
    assert ReadGPR(1) == Ones{PTO_XLEN};
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x44;
    assert InstructionContractShiftWidth_SRAI() == 6;
    assert !InstructionContractIsWordOperation_SRAI();
    return 0;
end;
