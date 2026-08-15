// PTO-TEST: {"id":"PTO-AVS-SCALAR-SLLW-MAXIMUM-001","source":"asl/scalar/alu/SLLW.asl","requirements":["PTO-INST-SCALAR-SLLW"],"kind":"execution","summary":"SLLW uses the maximum masked register shift count","pass_condition":"maximum register count, alias snapshot, TPC, and mnemonic contract match SLLW","related_sources":["asl/scalar/model/dispatch/alu.asl","asl/scalar/model/alu/semantics.asl"]}
func main() => integer
begin
    ResetProfileState();
    WriteGPR(1, Zeros{PTO_XLEN} + 1);
    WriteGPR(2, Zeros{PTO_XLEN} + 31);
    WriteTPC(Zeros{PTO_XLEN} + 0x40);

    var instruction: bits(48) = Zeros{48} + 0x00007025;
    instruction[11:7] = Zeros{5} + 1;
    instruction[19:15] = Zeros{5} + 1;
    instruction[24:20] = Zeros{5} + 2;

    let status = ExecuteScalarInstruction(instruction, 32);
    assert status == ScalarExecution_Executed;
    assert ReadGPR(1) == Zeros{PTO_XLEN} + 0xffffffff80000000;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x44;
    assert InstructionContractShiftAmount_SLLW(Zeros{PTO_XLEN} + 31) == 31;
    assert InstructionContractResult_SLLW(
        Zeros{PTO_XLEN} + 1,
        Zeros{PTO_XLEN} + 31) ==
        Zeros{PTO_XLEN} + 0xffffffff80000000;
    return 0;
end;
