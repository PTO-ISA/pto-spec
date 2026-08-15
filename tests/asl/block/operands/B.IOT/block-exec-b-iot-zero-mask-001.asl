// PTO-TEST: {"id":"PTO-AVS-BLOCK-B-IOT-ZERO-MASK-001","source":"asl/block/operands/B.IOT.asl","requirements":["PTO-INST-BLOCK-B-IOT"],"kind":"execution","summary":"PE_MASK zero is a strict B.IOT no-op.","pass_condition":"A zero-mask source form records no binding and does not terminate the binding stream.","related_sources":["asl/block/model/dispatch/commands.asl"]}
func main() => integer
begin
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x100);
    let started = ExecuteCommandInstruction(Zeros{64} + 0x00019181, 32);
    assert started == CommandExecution_Executed;
    var zero_mask = Zeros{64} + 0x00005013;
    zero_mask[25:20] = Ones{6};
    zero_mask[19] = '1';
    let status = ExecuteCommandInstruction(zero_mask, 32);
    assert status == CommandExecution_Executed;
    assert BundleTileBindingCount() == 0;
    assert !BundleTileBindingStreamTerminated();
    assert SelectedBundleTileMaskIsZero();
    return 0;
end;
