// PTO-TEST: {"id":"PTO-AVS-SCALAR-C-SETRET-BOUND-001","source":"asl/scalar/alu/C.SETRET.asl","requirements":["PTO-INST-SCALAR-C-SETRET"],"kind":"execution","summary":"C.SETRET uses the pre-increment TPC and the maximum unsigned halfword displacement","pass_condition":"uimm5=31 writes TPC+62 to ra and captured return state, then sequentially advances TPC by two","related_sources":["asl/scalar/model/bru/semantics.asl","asl/scalar/model/dispatch/alu.asl"]}
func main() => integer
begin
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x100);

    var instruction: bits(48) = Zeros{48} + 0x5016;
    instruction[10:6] = Zeros{5} + 31;

    let status = ExecuteScalarInstruction(instruction, 16);
    assert status == ScalarExecution_Executed;
    assert ReadGPR(10) == Zeros{PTO_XLEN} + 0x13e;
    assert _ReturnAddress == Zeros{PTO_XLEN} + 0x13e;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x102;
    assert InstructionContractTarget_C_SETRET(
        Zeros{PTO_XLEN} + 0x100,
        Zeros{5} + 31) == Zeros{PTO_XLEN} + 0x13e;

    WriteGPR(10, Zeros{PTO_XLEN} + 0x777);
    assert _ReturnAddress == Zeros{PTO_XLEN} + 0x13e;
    return 0;
end;
