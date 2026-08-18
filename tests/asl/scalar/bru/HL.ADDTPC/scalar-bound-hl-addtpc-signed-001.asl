// PTO-TEST: {"id":"PTO-AVS-SCALAR-HL-ADDTPC-SIGNED-001","source":"asl/scalar/bru/HL.ADDTPC.asl","requirements":["PTO-INST-SCALAR-HL-ADDTPC","PTO-HL-ADDTPC-PAGE-001"],"kind":"boundary","summary":"HL.ADDTPC sign-extends its split imm32 and wraps the page-scaled result","pass_condition":"decoded split imm32 minus one subtracts 0x1000 and decoded plus one wraps a high TPC modulo 64 bits","related_sources":["asl/scalar/model/bru/semantics.asl","asl/scalar/model/dispatch/bru.asl"]}
pure func HLADDTPCBoundaryInstruction(destination: Reg5Selector,
                                      immediate: bits(32)) => bits(48)
begin
    var instruction: bits(48) = Zeros{48} + 0x00000007000e;
    instruction[27:23] = Zeros{5} + destination;
    instruction[47:28] = immediate[19:0];
    instruction[15:4] = immediate[31:20];
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x800);
    let negative_status = ExecuteScalarInstruction(
        HLADDTPCBoundaryInstruction(3, Ones{32}),
        48);
    assert negative_status == ScalarExecution_Executed;
    assert _LastFault == Fault_None;
    assert ReadGPR(3) == Zeros{PTO_XLEN} + 0xfffffffffffff800;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x806;

    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0xfffffffffffff800);
    let wrap_status = ExecuteScalarInstruction(
        HLADDTPCBoundaryInstruction(3, Zeros{32} + 1),
        48);
    assert wrap_status == ScalarExecution_Executed;
    assert _LastFault == Fault_None;
    assert ReadGPR(3) == Zeros{PTO_XLEN} + 0x800;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0xfffffffffffff806;
    return 0;
end;
