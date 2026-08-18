// PTO-TEST: {"id":"PTO-AVS-SCALAR-ADDTPC-SIGNED-001","source":"asl/scalar/bru/ADDTPC.asl","requirements":["PTO-INST-SCALAR-ADDTPC","PTO-ADDTPC-PAGE-001"],"kind":"boundary","summary":"ADDTPC sign-extends imm20 and wraps its page-scaled result at XLEN","pass_condition":"decoded imm20 minus one subtracts 0x1000 and decoded plus one wraps a high TPC modulo 64 bits","related_sources":["asl/scalar/model/bru/semantics.asl","asl/scalar/model/dispatch/bru.asl"]}
pure func ADDTPCBoundaryInstruction(destination: Reg5Selector,
                                    immediate: bits(20)) => bits(48)
begin
    var instruction: bits(48) = Zeros{48} + 0x00000007;
    instruction[11:7] = Zeros{5} + destination;
    instruction[31:12] = immediate;
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x800);
    let negative_status = ExecuteScalarInstruction(
        ADDTPCBoundaryInstruction(3, Ones{20}),
        32);
    assert negative_status == ScalarExecution_Executed;
    assert _LastFault == Fault_None;
    assert ReadGPR(3) == Zeros{PTO_XLEN} + 0xfffffffffffff800;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x804;

    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0xfffffffffffff800);
    let wrap_status = ExecuteScalarInstruction(
        ADDTPCBoundaryInstruction(3, Zeros{20} + 1),
        32);
    assert wrap_status == ScalarExecution_Executed;
    assert _LastFault == Fault_None;
    assert ReadGPR(3) == Zeros{PTO_XLEN} + 0x800;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0xfffffffffffff804;
    return 0;
end;
