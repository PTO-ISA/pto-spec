// PTO-TEST: {"id":"PTO-AVS-BLOCK-CUBE-RAW-PARTIAL-POSTPROCESS-003","source":"asl/block/model/dispatch/cube-accumulator-routing.asl","requirements":["PTO-B-DATR-MATRIX-ACC-CONTROL-001","PTO-B-FPATR-MATRIX-POSTPROCESS-001","PTO-CUBE-ACCUMULATOR-OUTPUT-001"],"kind":"fault","summary":"Raw-partial CCTRL rejects final-output post-processing before destination allocation or source effects.","pass_condition":"TMATMUL CCTRL=01 with ReLU enabled raises Tile legality while preserving both sources and leaving D unresolved.","related_sources":["asl/block/model/dispatch/cube-tmatmul.asl","asl/block/model/dispatch/cube-destination.asl"]}
func main() => integer
begin
    ResetProfileState();
    let a_ready = ConfigureCubeTileForMask(1, 128, 1, 1,
        TileDataType_S16, TileLayout_CUBE_M16,
        TileLocation_Matrix, '1111');
    let b_ready = ConfigureCubeTileForMask(2, 128, 1, 1,
        TileDataType_S8, TileLayout_CUBE_N8,
        TileLocation_Matrix, '1111');
    assert a_ready && b_ready;
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 2);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 3);
    let a_before = ReadTileElement(1, 0, 0);
    let b_before = ReadTileElement(2, 0, 0);

    var start: bits(64) = Zeros{64} + 0x00031181;
    start[31:27] = Zeros{5} + 18;
    let started = ExecuteCommandInstruction(start, 32);
    assert started == CommandExecution_Executed;
    SetBundleDataAttributeState(
        Zeros{5} + 19, Zeros{5}, '01', Zeros{3}, Zeros{3},
        FALSE, FALSE);
    _BundleDataAttributesPresent = TRUE;
    SetBundleFixedPointAttributeState(
        Zeros{6}, Zeros{3} + 1, Zeros{4},
        FALSE, FALSE, FALSE, FALSE);
    AddBundleTileBinding(
        TRUE, 0, 1, '1111', TRUE, TRUE, 1, 2, TRUE);

    assert !BundleTMATMULPartialPostProcessLegal('01');
    let completed = ExecuteBundleTileOperation();
    assert !completed;
    assert _LastFault == Fault_TileLegality;
    assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;
    assert !_Tiles[[0]].allocated;
    assert ReadTileElement(1, 0, 0) == a_before;
    assert ReadTileElement(2, 0, 0) == b_before;
    return 0;
end;
