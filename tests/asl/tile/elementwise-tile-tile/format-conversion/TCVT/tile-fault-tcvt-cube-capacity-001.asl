// PTO-TEST: {"id":"PTO-AVS-TILE-TCVT-CUBE-CAPACITY-001","source":"asl/tile/elementwise-tile-tile/format-conversion/TCVT.asl","requirements":["PTO-TCVT-CONTRACT-001"],"kind":"fault","summary":"CUBE TCVT reports allocation failure only after logical-shape preflight","pass_condition":"a shape-matched FP16 16x9 source with an undersized FP32 destination TSize raises Fault_TileAllocation and publishes no destination","related_sources":["asl/block/model/dispatch/tcvt-schema.asl","asl/block/model/dispatch/tcvt-destination.asl"]}
func main() => integer
begin
    ResetProfileState();
    let source_ready = ConfigureCubeTile(
        1, 512, 16, 9, TileDataType_FP16,
        TileLayout_CUBE_M16, TileLocation_Matrix);
    assert source_ready;
    MarkTileValidRegionDefined(1);
    let capacity_before = TileCapacityInUse();
    let started = ExecuteCommandInstruction(
        Zeros{PTO_XLEN} + 0x21b19181, 32);
    assert started == CommandExecution_Executed;
    SetBundleDataAttributeState(
        Zeros{5} + 1, Zeros{5}, '11', Zeros{3}, Zeros{3}, FALSE, FALSE);
    _BundleDataAttributesPresent = TRUE;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 9);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 16);
    AddBundleTileBinding(TRUE, 0, 3, '1111', TRUE, FALSE, 1, 0, TRUE);
    let completed = ExecuteBundleTileOperation();
    assert !completed;
    assert _LastFault == Fault_TileAllocation;
    assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;
    assert TileCapacityInUse() == capacity_before;
    return 0;
end;
