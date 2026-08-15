// PTO-TEST: {"id":"PTO-AVS-BLOCK-B-FPATR-NONMATRIX-001","source":"asl/block/attributes/B.FPATR.asl","requirements":["PTO-INST-BLOCK-B-FPATR"],"kind":"fault","summary":"B.FPATR is illegal in a non-Matrix block","pass_condition":"Fault_BundleControl is raised before fixed-point descriptor state is latched","related_sources":["asl/block/model/dispatch/commands.asl"]}
func main() => integer
begin
    ResetProfileState();
    _BundleActive = TRUE;
    _BundleOperation.valid = TRUE;
    _BundleOperation.operation_class = BundleOperation_TileElement;

    let status = ExecuteCommandInstruction(
        Zeros{64} + 0x00002023, 32);
    assert status == CommandExecution_Rejected;
    assert _LastFault == Fault_BundleControl;
    assert !_BundleFixedPointAttributes.valid;
    return 0;
end;
