// PTO-TEST: {"id":"PTO-AVS-SCALAR-ANDW-MODIFIER-001","source":"asl/scalar/alu/ANDW.asl","requirements":["PTO-INST-SCALAR-ANDW"],"kind":"execution","summary":"ANDW applies raw SrcRType 10 as bitwise complement before the encoded left shift","pass_condition":"decoded modifier, shift ordering, word conjunction result, and TPC match ANDW","related_sources":["asl/scalar/model/dispatch/decode.asl","asl/scalar/model/dispatch/alu.asl","asl/scalar/model/alu/semantics.asl"]}
func main() => integer
begin
    ResetProfileState();
    WriteGPR(1, Zeros{PTO_XLEN} + 0xffffffffffffffff);
    WriteGPR(2, Zeros{PTO_XLEN} + 0x0000000000000003);
    WriteTPC(Zeros{PTO_XLEN} + 0x40);

    var instruction: bits(48) = Zeros{48} + 0x00002025;
    instruction[11:7] = Zeros{5} + 1;
    instruction[19:15] = Zeros{5} + 1;
    instruction[24:20] = Zeros{5} + 2;
    instruction[26:25] = '10';
    instruction[31:27] = Zeros{5} + 1;

    let status = ExecuteScalarInstruction(instruction, 32);
    assert status == ScalarExecution_Executed;
    assert ReadGPR(1) == Zeros{PTO_XLEN} + 0xfffffffffffffff8;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x44;
    assert InstructionContractResult_ANDW(
        Zeros{PTO_XLEN} + 0xffffffffffffffff,
        Zeros{PTO_XLEN} + 0x0000000000000003,
        '10',
        1) == Zeros{PTO_XLEN} + 0xfffffffffffffff8;
    return 0;
end;
