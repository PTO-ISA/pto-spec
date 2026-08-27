// PTO-TEST: {"id":"PTO-AVS-BLOCK-TMATMUL-SHARED-WAIT-002","source":"asl/block/execution/BSTART.TMATMUL.asl","requirements":["PTO-B-SHARED-WHOLE-PARENT-READY-001","PTO-TMATMUL-CONTRACT-001"],"kind":"state-transition","summary":"TMATMUL waits without fault for an unpublished Shared matrix source.","pass_condition":"The pending attempt preserves bindings and destination state; whole-parent publication lets the unchanged block retry and commit the matrix result.","related_sources":["asl/block/model/dispatch/shared-cube-matrix.asl","asl/block/model/dispatch/tile-execution.asl"]}
pure func WaitingTMATMULSharedSource(shared_tile_id: bits(6)) => bits(64)
begin
    var instruction = Zeros{64} + 0x00001013;
    instruction[25:20] = shared_tile_id;
    instruction[11:9] = '111';
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    let left_ready = ConfigureCubeTileForMask(1, 128, 1, 1,
        TileDataType_U16, TileLayout_CUBE_M16,
        TileLocation_Matrix, '1111');
    assert left_ready;
    ConfigureTile(2, 128, 1, 1, 1, 1, TileDataType_U8,
        TileLayout_RowMajor, TileLocation_Matrix);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 6);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 7);
    let shared_tile_id = (Zeros{6} + 9) as SharedTileID;
    let pending = AtomicUpdateSharedTileWithPublication(
        shared_tile_id, _Tiles[[2]], '1111', FALSE);
    assert pending && !SharedTilePublished(shared_tile_id);

    var start = Zeros{64} + 0x00031181;
    start[31:27] = Zeros{5} + 26;
    let started = ExecuteCommandInstruction(start, 32);
    assert started == CommandExecution_Executed;
    SetBundleFixedPointAttributeState(
        Zeros{6}, Zeros{3}, Zeros{4},
        FALSE, FALSE, FALSE, FALSE);
    SetBundleDataAttributeState(Zeros{5} + 27, Zeros{5}, Zeros{2},
        Zeros{3}, Zeros{3}, FALSE, FALSE);
    _BundleDataAttributesPresent = TRUE;
    let shared_bound = ExecuteCommandInstruction(
        WaitingTMATMULSharedSource(Zeros{6} + 9), 32);
    assert shared_bound == CommandExecution_Executed;
    AddBundleTileBinding(TRUE, 0, 1, '1111', TRUE, FALSE, 1, 0, TRUE);

    let waiting = ExecuteBundleTileOperation();
    assert !waiting && _LastFault == Fault_None;
    assert _BundleActive;
    assert !_BundleSharedBindings[[0]].consumed;
    assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;

    let index = SharedTileArrayIndex(shared_tile_id);
    _SharedTiles[[index]].whole_parent_ready = TRUE;
    _SharedTiles[[index]].published = TRUE;
    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
    assert _BundleSharedBindings[[0]].consumed;
    let destination = _BundleTileBindings[[0]].destination;
    assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN} + 42;
    return 0;
end;
