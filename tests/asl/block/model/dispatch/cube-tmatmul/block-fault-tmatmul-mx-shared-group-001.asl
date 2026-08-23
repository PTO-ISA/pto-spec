// PTO-TEST: {"id":"PTO-AVS-BLOCK-TMATMUL-MX-SHARED-GROUP-001","source":"asl/block/model/dispatch/cube-tmatmul.asl","requirements":["PTO-TMATMUL-MX-CONTRACT-001"],"kind":"fault","summary":"TMATMULMX rejects an incomplete Shared matrix-scale operand group","pass_condition":"one Shared source raises Fault_TileLegality before consumption or destination allocation","related_sources":["asl/tile/model/legality/matrix-functions.asl"]}
func main() => integer
begin
    ResetProfileState();
    var start: bits(64) = Zeros{64} + 0x00431181;
    start[31:27] = Zeros{5} + 7;
    let start_result = ExecuteCommandInstruction(start, 32);
    assert start_result == CommandExecution_Executed;
    SetBundleDataAttributeState(
        Zeros{5} + 8, Zeros{5}, Zeros{2}, Zeros{3}, Zeros{3},
        FALSE, FALSE);
    _BundleDataAttributesPresent = TRUE;
    SetBundleFixedPointAttributeState(
        Zeros{6}, Zeros{3}, Zeros{4}, FALSE, FALSE, FALSE, FALSE);
    BindBundleSharedIO((Zeros{6} + 60) as SharedTileID, 0, '1111');

    let completed = ExecuteBundleTileOperation();
    assert !completed;
    assert _LastFault == Fault_TileLegality;
    assert !_BundleSharedBindings[[0]].consumed;
    assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;
    return 0;
end;
