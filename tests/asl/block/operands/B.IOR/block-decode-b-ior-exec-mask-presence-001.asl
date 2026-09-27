// PTO-TEST: {"id":"PTO-AVS-BLOCK-B-IOR-EXEC-MASK-PRESENCE-001","source":"asl/block/operands/B.IOR.asl","requirements":["PTO-INST-BLOCK-B-IOR","PTO-B-IOR-BINDING-001"],"kind":"decode-positive","summary":"B.IOR bit 26 marks the final GPR ExecutionMask binding record.","pass_condition":"Flag-zero and flag-one B.IOR encodings decode to the same form, bit 26 extracts the flag, and fixed bit 25 still rejects.","related_sources":["asl/block/model/dispatch/commands.asl","asl/block/model/operands/scalar-bindings.asl"]}
func main() => integer
begin
    let legacy = Zeros{64} + 0x00000013;
    let mask_gpr0 = Zeros{64} + 0x04000013;
    let fixed_bit25 = Zeros{64} + 0x02000013;
    assert DecodeCommandForm(legacy, 32) == 7;
    assert DecodeCommandForm(mask_gpr0, 32) == 7;
    assert !CommandDecodedBool(legacy, 7,
        CommandField_ExecMaskPresent);
    assert CommandDecodedBool(mask_gpr0, 7,
        CommandField_ExecMaskPresent);
    assert DecodeCommandForm(fixed_bit25, 32) == PTO_COMMAND_FORM_COUNT;

    ResetProfileState();
    SetBundleScalarBindingWithExecutionMask(0, 0, 0, 0, 0, 3, TRUE);
    assert _BundleScalarBindings[[0]].valid;
    assert _BundleScalarBindings[[0]].source0 == 0;
    assert _BundleScalarBindings[[0]].execution_mask_present;
    return 0;
end;
