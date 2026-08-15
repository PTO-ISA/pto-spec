// PTO-TEST: {"id":"PTO-AVS-BLOCK-B-FPATR-ZMASK-001","source":"asl/block/attributes/B.FPATR.asl","requirements":["PTO-INST-BLOCK-B-FPATR"],"kind":"execution","summary":"zero-participation B.IOT and B.IOS remain strict no-ops before B.FPATR","pass_condition":"both zero-mask commands install no operand binding and B.FPATR still latches successfully","related_sources":["asl/block/model/dispatch/commands.asl"]}
func main() => integer
begin
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x440);
    _BundleActive = TRUE;
    _BundleOperation.valid = TRUE;
    _BundleOperation.operation_class = BundleOperation_TileMatrix;

    let tile_noop = ExecuteCommandInstruction(
        Zeros{64} + 0x00005013, 32);
    let shared_noop = ExecuteCommandInstruction(
        Zeros{64} + 0x00001013, 32);
    assert tile_noop == CommandExecution_Executed;
    assert shared_noop == CommandExecution_Executed;
    assert BundleTileBindingCount() == 0;
    assert BundleSharedBindingCount() == 0;

    let fixed_point = ExecuteCommandInstruction(
        Zeros{64} + 0x00002023, 32);
    assert fixed_point == CommandExecution_Executed;
    assert _LastFault == Fault_None;
    assert _BundleFixedPointAttributes.valid;
    return 0;
end;
