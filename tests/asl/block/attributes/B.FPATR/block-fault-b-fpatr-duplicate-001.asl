// PTO-TEST: {"id":"PTO-AVS-BLOCK-B-FPATR-DUPLICATE-001","source":"asl/block/attributes/B.FPATR.asl","requirements":["PTO-INST-BLOCK-B-FPATR"],"kind":"fault","summary":"a second B.FPATR in one Matrix header is illegal","pass_condition":"the duplicate raises Fault_BundleControl without replacing the first descriptor","related_sources":["asl/block/model/dispatch/commands.asl"]}
func main() => integer
begin
    ResetProfileState();
    _BundleActive = TRUE;
    _BundleOperation.valid = TRUE;
    _BundleOperation.operation_class = BundleOperation_TileMatrix;
    let first = ExecuteCommandInstruction(Zeros{64} + 0x00002023, 32);
    assert first == CommandExecution_Executed;
    assert _BundleFixedPointAttributes.valid;

    let duplicate = ExecuteCommandInstruction(
        Zeros{64} + 0x00002023, 32);
    assert duplicate == CommandExecution_Rejected;
    assert _LastFault == Fault_BundleControl;
    assert _BundleFixedPointAttributes.valid;
    assert _BundleFixedPointAttributes.pre_quant_mode == Zeros{6};
    return 0;
end;
