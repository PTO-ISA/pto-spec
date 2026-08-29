// PTO-TEST: {"id":"PTO-AVS-ARCH-FUNCTIONAL-STEP-FAULT-CAUSE-006","source":"asl/arch/dispatch/functional-step.asl","requirements":["PTO-REQ-FUNCTIONAL-STEP-001"],"kind":"fault","summary":"A functional step observation snapshots the exact cause stored by the precise fault owner.","pass_condition":"An Assert fault with a nonzero cause produces Trap plus NotAttempted and preserves the exact 24-bit cause and original fault address in the immutable result.","related_sources":["asl/arch/memory-model/fault-precision.asl"]}
func main() => integer
begin
    let entry = Zeros{PTO_XLEN} + 0x100;
    InitializeFunctionalModel(entry);
    SetFaultWithCause(
        Fault_Assert,
        entry,
        Zeros{24} + 0x00a5c3);

    let result = EmptyFunctionalStepResult(
        PTOFunctionalStep_Trap,
        entry,
        Zeros{PTO_XLEN},
        0);

    assert result.status == PTOFunctionalStep_Trap;
    assert result.instruction_status == PTOFunctionalInstruction_NotAttempted;
    assert result.fault == Fault_Assert;
    assert result.fault_address == entry;
    assert result.fault_cause == Zeros{24} + 0x00a5c3;
    return 0;
end;
