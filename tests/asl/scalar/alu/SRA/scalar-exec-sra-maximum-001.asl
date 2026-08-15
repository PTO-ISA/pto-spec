// PTO-TEST: {"id":"PTO-AVS-SCALAR-SRA-MAXIMUM-001","source":"asl/scalar/alu/SRA.asl","requirements":["PTO-INST-SCALAR-SRA"],"kind":"execution","summary":"SRA uses the maximum masked register shift count","pass_condition":"maximum register count, alias snapshot, TPC, and mnemonic contract match SRA","related_sources":["asl/scalar/model/dispatch/alu.asl","asl/scalar/model/alu/semantics.asl"]}
func main() => integer
begin
    ResetProfileState();
    WriteGPR(1, '1000000000000000000000000000000000000000000000000000000000000000');
    WriteGPR(2, Zeros{PTO_XLEN} + 63);
    WriteTPC(Zeros{PTO_XLEN} + 0x40);

    var instruction: bits(48) = Zeros{48} + 0x00006005;
    instruction[11:7] = Zeros{5} + 1;
    instruction[19:15] = Zeros{5} + 1;
    instruction[24:20] = Zeros{5} + 2;

    let status = ExecuteScalarInstruction(instruction, 32);
    assert status == ScalarExecution_Executed;
    assert ReadGPR(1) == Ones{PTO_XLEN};
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x44;
    assert InstructionContractShiftAmount_SRA(Zeros{PTO_XLEN} + 63) == 63;
    assert InstructionContractResult_SRA('1000000000000000000000000000000000000000000000000000000000000000', Zeros{PTO_XLEN} + 63) == Ones{PTO_XLEN};
    return 0;
end;
