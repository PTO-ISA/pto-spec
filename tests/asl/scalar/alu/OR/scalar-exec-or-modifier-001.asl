// PTO-TEST: {"id":"PTO-AVS-SCALAR-OR-MODIFIER-001","source":"asl/scalar/alu/OR.asl","requirements":["PTO-INST-SCALAR-OR"],"kind":"execution","summary":"OR applies raw SrcRType 10 as bitwise complement before the encoded left shift","pass_condition":"decoded modifier, shift ordering, inclusive OR result, and TPC match OR","related_sources":["asl/scalar/model/dispatch/decode.asl","asl/scalar/model/dispatch/alu.asl","asl/scalar/model/alu/semantics.asl"]}
func main() => integer
begin
    ResetProfileState();
    WriteGPR(1, Zeros{PTO_XLEN} + 0x0000000000000001);
    WriteGPR(2, Zeros{PTO_XLEN} + 0x0000000000000003);
    WriteTPC(Zeros{PTO_XLEN} + 0x40);

    var instruction: bits(48) = Zeros{48} + 0x00003005;
    instruction[11:7] = Zeros{5} + 1;
    instruction[19:15] = Zeros{5} + 1;
    instruction[24:20] = Zeros{5} + 2;
    instruction[26:25] = '10';
    instruction[31:27] = Zeros{5} + 1;

    let status = ExecuteScalarInstruction(instruction, 32);
    assert status == ScalarExecution_Executed;
    assert ReadGPR(1) == Zeros{PTO_XLEN} + 0xfffffffffffffff9;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x44;
    assert InstructionContractResult_OR(
        Zeros{PTO_XLEN} + 0x0000000000000001,
        Zeros{PTO_XLEN} + 0x0000000000000003,
        '10',
        1) == Zeros{PTO_XLEN} + 0xfffffffffffffff9;
    return 0;
end;
