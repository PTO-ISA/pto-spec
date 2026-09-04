// PTO-TEST: {"id":"PTO-AVS-BLOCK-TIMG2COL-PARTICIPANT-PARAMETERS-001","source":"asl/block/model/dispatch/timg2col-execution.asl","requirements":["PTO-BSTART-TIMG2COL-PARAMS-001","PTO-BSTART-TIMG2COL-COOPERATIVE-001"],"kind":"fault","summary":"Every participating PE supplies identical TIMG2COL GMBase and packed parameter values.","pass_condition":"The four-PE preflight accepts equal raw carriers and rejects a parameter mismatch before execution effects.","related_sources":["asl/block/model/operands/timg2col-parameters.asl"]}
func main() => integer
begin
    ResetProfileState();
    _BundleScalarBindings[[0]].source0 = 2;
    _BundleScalarBindings[[1]].source0 = 3;
    _BundleScalarBindings[[1]].source1 = 4;
    _BundleScalarBindings[[1]].source2 = 5;
    for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        let agent = pe as MemoryAgentId;
        WritePEGPR(agent, 2, Zeros{PTO_XLEN} + 0x100);
        WritePEGPR(agent, 3, Zeros{PTO_XLEN} + 0x200);
        WritePEGPR(agent, 4, Zeros{PTO_XLEN} + 0x300);
        WritePEGPR(agent, 5, Zeros{PTO_XLEN} + 0x400);
    end;
    assert BundleTIMG2COLParticipantValuesEqual('1111');
    WritePEGPR(2, 4, Zeros{PTO_XLEN} + 0x301);
    assert !BundleTIMG2COLParticipantValuesEqual('1111');
    assert BundleTIMG2COLParticipantValuesEqual('0001');
    return 0;
end;
