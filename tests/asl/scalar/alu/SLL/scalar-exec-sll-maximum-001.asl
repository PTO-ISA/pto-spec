// PTO-TEST: {"id":"PTO-AVS-SCALAR-SLL-MAXIMUM-001","source":"asl/scalar/alu/SLL.asl","requirements":["PTO-INST-SCALAR-SLL"],"kind":"execution","summary":"SLL uses the maximum masked register shift count","pass_condition":"maximum register count, alias snapshot, TPC, and mnemonic contract match SLL","related_sources":["asl/scalar/model/dispatch/alu.asl","asl/scalar/model/alu/semantics.asl"]}
func main() => integer
begin
    ResetProfileState();
    WriteGPR(1, Zeros{PTO_XLEN} + 1);
    WriteGPR(2, Zeros{PTO_XLEN} + 63);
    WriteTPC(Zeros{PTO_XLEN} + 0x40);

    var instruction: bits(48) = Zeros{48} + 0x00007005;
    instruction[11:7] = Zeros{5} + 1;
    instruction[19:15] = Zeros{5} + 1;
    instruction[24:20] = Zeros{5} + 2;

    let status = ExecuteScalarInstruction(instruction, 32);
    assert status == ScalarExecution_Executed;
    assert ReadGPR(1) == '1000000000000000000000000000000000000000000000000000000000000000';
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x44;
    assert InstructionContractShiftAmount_SLL(Zeros{PTO_XLEN} + 63) == 63;
    assert InstructionContractResult_SLL(Zeros{PTO_XLEN} + 1, Zeros{PTO_XLEN} + 63) == '1000000000000000000000000000000000000000000000000000000000000000';
    return 0;
end;
