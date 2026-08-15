// PTO-TEST: {"id":"PTO-AVS-SCALAR-REV-WRAP-001","source":"asl/scalar/alu/REV.asl","requirements":["PTO-INST-SCALAR-REV"],"kind":"execution","summary":"REV reverses bytes in a wrapping selected field","pass_condition":"M=60 and N=16 select field 0x1234 across bit 63, produce low result 0x3412 with high zeros, write the GPR destination, and advance TPC once","related_sources":["asl/scalar/model/dispatch/alu.asl","asl/scalar/model/alu/semantics.asl"]}
func main() => integer
begin
    ResetProfileState();
    WriteGPR(1, Zeros{PTO_XLEN} + 0x4000000000000123);
    WriteTPC(Zeros{PTO_XLEN} + 0x100);
    var instruction: bits(48) = Zeros{48} + 0x00007067;
    instruction[11:7] = Zeros{5} + 2;
    instruction[19:15] = Zeros{5} + 1;
    instruction[25:20] = Zeros{6} + 15;
    instruction[31:26] = Zeros{6} + 60;
    let status = ExecuteScalarInstruction(instruction, 32);
    assert status == ScalarExecution_Executed;
    assert ReadGPR(2) == Zeros{PTO_XLEN} + 0x3412;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x104;
    assert InstructionContractResult_REV(
        Zeros{PTO_XLEN} + 0x4000000000000123,
        16,
        60) == Zeros{PTO_XLEN} + 0x3412;
    return 0;
end;
