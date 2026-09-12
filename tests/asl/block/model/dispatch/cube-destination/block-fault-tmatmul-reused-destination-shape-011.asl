// PTO-TEST: {"id":"PTO-AVS-BLOCK-TMATMUL-REUSED-DESTINATION-SHAPE-011","source":"asl/block/model/dispatch/cube-destination.asl","requirements":["PTO-B-ASSEMBLE-LOCAL-GENERATION-001","PTO-TMATMUL-CONTRACT-001"],"kind":"fault","summary":"TMATMUL continuation validates the reused primary destination against current M/N/type/layout without allocation.","pass_condition":"An exact CUBE descriptor match reuses the parent; changed current M raises Fault_TileLegality before any destination allocation or execution assertion.","related_sources":["asl/block/model/dispatch/cube-tmatmul.asl","asl/block/model/operands/local-generation.asl"]}
func main() => integer
begin
    ResetProfileState();
    let configured = ConfigureCubeTileForMask(1, 128, 1, 1,
        TileDataType_FP32, TileLayout_CUBE_M16,
        TileLocation_Matrix, '1111');
    assert configured;
    SetBundleTileBinding(0, TRUE, 1, 1, '1111',
        FALSE, FALSE, 0, 0, TRUE);
    _BundleTileBindings[[0]].destination_reused_by_generation = TRUE;
    let matched = ResolveBundleTMATMULDestination(
        1, 1, TileDataType_FP32, TRUE, TileLayout_CUBE_M16, '1111');
    assert matched && _LastFault == Fault_None;
    assert _BundleTileBindings[[0]].destination == 1 &&
           !_BundleTileBindings[[0]].destination_allocated_by_bundle;

    ClearFault();
    let mismatched = ResolveBundleTMATMULDestination(
        2, 1, TileDataType_FP32, TRUE, TileLayout_CUBE_M16, '1111');
    assert !mismatched && _LastFault == Fault_TileLegality;
    assert _Tiles[[1]].allocated &&
           !_BundleTileBindings[[0]].destination_allocated_by_bundle;
    return 0;
end;
