// PTO-TEST: {"id":"PTO-AVS-BLOCK-BSTART-SFU-ALIAS-COMMIT-001","source":"asl/block/execution/BSTART.SFU.asl","requirements":["PTO-INST-BLOCK-BSTART-SFU"],"kind":"state-transition","summary":"The canonical SFU alias installs and commits the inherited TEPL descriptor.","pass_condition":"TEXP FP32 starts through the TEPL carrier, retains its selector and data type, and completes through the common zero-participation commit path.","related_sources":["asl/block/execution/BSTART.TEPL.asl","asl/block/model/dispatch/start.asl"]}
func main() => integer
begin
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x400);

    // TEXP is TEPL Mode 0 Function 18; DataType 1 is FP32.
    let started = ExecuteCommandInstruction(Zeros{64} + 0x09219181, 32);
    assert started == CommandExecution_Executed;
    assert _BundleActive;
    assert _BundleOperation.valid;
    assert _BundleOperation.operation_class == BundleOperation_TileElement;
    assert _BundleOperation.selector_valid;
    assert _BundleOperation.selector == Zeros{10} + 18;
    assert _BundleOperation.data_type_valid;
    assert _BundleOperation.data_type == Zeros{5} + 1;

    // A decoded zero-participation binder makes the inherited TEPL block a
    // strict no-op while still exercising its normal completion path.
    _BundleZeroParticipationSeen = TRUE;
    let committed = CompleteBundleAt(Zeros{PTO_XLEN} + 0x404);
    assert committed;
    assert !_BundleActive;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x404;
    return 0;
end;
