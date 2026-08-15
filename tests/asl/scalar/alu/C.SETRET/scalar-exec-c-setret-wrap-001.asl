// PTO-TEST: {"id":"PTO-AVS-SCALAR-C-SETRET-WRAP-001","source":"asl/scalar/alu/C.SETRET.asl","requirements":["PTO-INST-SCALAR-C-SETRET"],"kind":"execution","summary":"C.SETRET return-target and sequential-PC arithmetic wrap modulo XLEN","pass_condition":"the maximum displacement at TPC=2^64-2 writes target 60 and advances the instruction TPC to zero","related_sources":["asl/scalar/model/bru/semantics.asl"]}
func main() => integer
begin
    ResetProfileState();
    WriteTPC(Ones{PTO_XLEN} - 1);

    var instruction: bits(48) = Zeros{48} + 0x5016;
    instruction[10:6] = Zeros{5} + 31;

    let status = ExecuteScalarInstruction(instruction, 16);
    assert status == ScalarExecution_Executed;
    assert ReadGPR(10) == Zeros{PTO_XLEN} + 60;
    assert _ReturnAddress == Zeros{PTO_XLEN} + 60;
    assert ReadTPC() == Zeros{PTO_XLEN};
    return 0;
end;
