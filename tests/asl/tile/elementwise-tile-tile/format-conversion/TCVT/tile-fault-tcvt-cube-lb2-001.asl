// PTO-TEST: {"id":"PTO-AVS-TILE-TCVT-CUBE-LB2-001","source":"asl/tile/elementwise-tile-tile/format-conversion/TCVT.asl","requirements":["PTO-TCVT-CONTRACT-001"],"kind":"fault","summary":"CUBE TCVT rejects an explicit LB2 physical-column request","pass_condition":"present LB2 raises Fault_TileLegality before destination allocation because CUBE physical columns are derived from DataType and TSize","related_sources":["asl/block/model/dispatch/tcvt-schema.asl"]}
func main() => integer
begin
    ResetProfileState();
    let source_ready = ConfigureCubeTile(
        1, 128, 16, 1, TileDataType_FP32,
        TileLayout_CUBE_M16, TileLocation_Matrix);
    assert source_ready;
    MarkTileValidRegionDefined(1);
    let capacity_before = TileCapacityInUse();
    let started = ExecuteCommandInstruction(
        Zeros{PTO_XLEN} + 0x09b19181, 32);
    assert started == CommandExecution_Executed;
    SetBundleDataAttributeState(
        Zeros{5} + 5, Zeros{5}, '11', Zeros{3}, Zeros{3}, FALSE, FALSE);
    _BundleDataAttributesPresent = TRUE;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 16);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 1);
    AddBundleTileBinding(TRUE, 0, 1, '1111', TRUE, FALSE, 1, 0, TRUE);
    let completed = ExecuteBundleTileOperation();
    assert !completed;
    assert _LastFault == Fault_TileLegality;
    assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;
    assert TileCapacityInUse() == capacity_before;
    return 0;
end;
