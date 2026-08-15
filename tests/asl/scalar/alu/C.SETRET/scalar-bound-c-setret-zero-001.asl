// PTO-TEST: {"id":"PTO-AVS-SCALAR-C-SETRET-ZERO-001","source":"asl/scalar/alu/C.SETRET.asl","requirements":["PTO-INST-SCALAR-C-SETRET"],"kind":"boundary","summary":"C.SETRET zero preserves the pre-increment TPC as the return target","pass_condition":"ra and the architectural return state receive the instruction TPC while dispatch advances TPC by two bytes","related_sources":["asl/scalar/model/dispatch/alu.asl","asl/scalar/model/sys/semantics.asl"]}
func main() => integer
begin
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x200);

    let status = ExecuteScalarInstruction(Zeros{48} + 0x5016, 16);
    assert status == ScalarExecution_Executed;
    assert ReadGPR(10) == Zeros{PTO_XLEN} + 0x200;
    assert _ReturnAddress == Zeros{PTO_XLEN} + 0x200;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x202;
    return 0;
end;
