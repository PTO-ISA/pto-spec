// PTO-TEST: {"id":"PTO-AVS-TILE-TCMP-CAPACITY-001","source":"asl/tile/elementwise-tile-tile/logical/TCMP.asl","requirements":["PTO-TCMP-CONTRACT-001"],"kind":"fault","summary":"TCMP rejects a predicate destination whose TSize cannot hold all physical predicate bits","pass_condition":"an eight-thousand-element source pair requires more than 128 predicate bytes and fails before destination allocation","related_sources":["asl/block/model/dispatch/destination-shape.asl","asl/tile/model/state/allocation.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(
        1,
        8192,
        64,
        128,
        64,
        128,
        TileDataType_U8,
        TileLayout_RowMajor,
        TileLocation_Any);
    ConfigureTile(
        2,
        8192,
        64,
        128,
        64,
        128,
        TileDataType_U8,
        TileLayout_RowMajor,
        TileLocation_Any);
    MarkTileValidRegionDefined(1);
    MarkTileValidRegionDefined(2);
    let started = ExecuteCommandInstruction(
        Zeros{PTO_XLEN} + 0xd8d19181,
        32);
    assert started == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 128);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 64);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 128);
    AddBundleTileBinding(
        TRUE,
        0,
        1,
        '0001',
        TRUE,
        TRUE,
        1,
        2,
        TRUE);

    let completed = ExecuteBundleTileOperation();
    assert !completed;
    assert _LastFault == Fault_TileAllocation;
    assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;
    assert _Tiles[[1]].allocated && _Tiles[[2]].allocated;
    return 0;
end;
