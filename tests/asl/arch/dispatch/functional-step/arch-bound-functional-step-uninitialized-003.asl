// PTO-TEST: {"id":"PTO-AVS-ARCH-FUNCTIONAL-STEP-UNINITIALIZED-001","source":"asl/arch/dispatch/functional-step.asl","requirements":["PTO-REQ-FUNCTIONAL-STEP-001"],"kind":"boundary","summary":"A functional step before named initialization is unsupported and has no architectural effect.","pass_condition":"ExecuteOnePTOStep returns Unsupported without fetch, time advance, fault, or PC/GPR mutation.","related_sources":["asl/arch/profile/functional-model.asl"]}
func main() => integer
begin
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x100);
    WriteGPR(2, Zeros{PTO_XLEN} + 0xaa);

    let result = ExecuteOnePTOStep();

    assert result.status == PTOFunctionalStep_Unsupported;
    assert result.pre_tpc == Zeros{PTO_XLEN} + 0x100;
    assert result.post_tpc == result.pre_tpc;
    assert result.length_bits == 0;
    assert result.fault == Fault_None;
    assert result.sequence == Zeros{PTO_XLEN};
    assert _SystemRegisters.cycle == Zeros{PTO_XLEN};
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x100;
    assert ReadGPR(2) == Zeros{PTO_XLEN} + 0xaa;
    return 0;
end;
