// PTO-TEST: {"id":"PTO-AVS-BLOCK-TLOAD-REUSED-DESTINATION-SHAPE-009","source":"asl/block/model/dispatch/tlsu-layout-conversion.asl","requirements":["PTO-B-ASSEMBLE-LOCAL-GENERATION-001","PTO-CUBE-CELL-TRANSPORT-001"],"kind":"fault","summary":"CUBE TLOAD continuation validates the reused parent against the current writer descriptor without allocation.","pass_condition":"An exact capacity/shape/type/layout match reuses the existing CUBE destination; changed current dimensions raise Fault_TileLegality before allocation or TLOAD effects.","related_sources":["asl/block/model/operands/local-generation.asl","asl/block/model/dispatch/destination-shape.asl"]}
func main() => integer
begin
    ResetProfileState();
    let configured = ConfigureCubeTileForMask(1, 256, 2, 4,
        TileDataType_FP16, TileLayout_CUBE_M16, '1111');
    assert configured;
    SetBundleTileBinding(0, TRUE, 1, 2, '1111',
        FALSE, FALSE, 0, 0, TRUE);
    _BundleTileBindings[[0]].destination_reused_by_generation = TRUE;
    let matched = ResolveBundleCubeTransportDestination(
        2, 4, TileDataType_FP16, TileLayout_CUBE_M16);
    assert matched && _LastFault == Fault_None;
    assert _BundleTileBindings[[0]].destination == 1 &&
           !_BundleTileBindings[[0]].destination_allocated_by_bundle;

    ClearFault();
    let mismatched = ResolveBundleCubeTransportDestination(
        1, 4, TileDataType_FP16, TileLayout_CUBE_M16);
    assert !mismatched && _LastFault == Fault_TileLegality;
    assert _Tiles[[1]].allocated &&
           !_BundleTileBindings[[0]].destination_allocated_by_bundle;
    return 0;
end;
