// PTO-TEST: {"id":"PTO-AVS-SCALAR-SUB-MODIFIER-001","source":"asl/scalar/alu/SUB.asl","requirements":["PTO-INST-SCALAR-SUB"],"kind":"execution","summary":"SUB applies raw SrcRType 10 as negation before the encoded left shift","pass_condition":"decoded modifier, shift ordering, subtraction result, and TPC match SUB","related_sources":["asl/scalar/model/dispatch/decode.asl","asl/scalar/model/dispatch/alu.asl","asl/scalar/model/alu/semantics.asl"]}
func main() => integer
begin
    ResetProfileState();
    WriteGPR(1, Zeros{PTO_XLEN} + 0x000000000000000a);
    WriteGPR(2, Zeros{PTO_XLEN} + 0x0000000000000003);
    WriteTPC(Zeros{PTO_XLEN} + 0x40);

    var instruction: bits(48) = Zeros{48} + 0x00001005;
    instruction[11:7] = Zeros{5} + 1;
    instruction[19:15] = Zeros{5} + 1;
    instruction[24:20] = Zeros{5} + 2;
    instruction[26:25] = '10';
    instruction[31:27] = Zeros{5} + 1;

    let status = ExecuteScalarInstruction(instruction, 32);
    assert status == ScalarExecution_Executed;
    assert ReadGPR(1) == Zeros{PTO_XLEN} + 0x0000000000000010;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x44;
    assert InstructionContractResult_SUB(
        Zeros{PTO_XLEN} + 0x000000000000000a,
        Zeros{PTO_XLEN} + 0x0000000000000003,
        '10',
        1) == Zeros{PTO_XLEN} + 0x0000000000000010;
    return 0;
end;
