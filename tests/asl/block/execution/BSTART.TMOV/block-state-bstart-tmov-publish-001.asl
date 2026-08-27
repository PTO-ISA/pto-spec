// PTO-TEST: {"id":"PTO-AVS-BLOCK-TMOV-PUBLISH-001","source":"asl/block/execution/BSTART.TMOV.asl","requirements":["PTO-B-SHARED-WHOLE-PARENT-READY-001","PTO-INST-BLOCK-BSTART-TMOV"],"kind":"state-transition","summary":"A Shared-to-Local TMOV waits for whole-parent publication without losing its bindings.","pass_condition":"The pending attempt has no fault or destination effect; publication lets the unchanged canonical Function 2 block retry and copy the complete parent.","related_sources":["asl/block/model/dispatch/shared-tlsu.asl","asl/tile/model/state/shared-registers.asl"]}
pure func WaitingTMOVSharedSource(shared_tile_id: bits(6)) => bits(64)
begin
    var instruction = Zeros{64} + 0x00001013;
    instruction[25:20] = shared_tile_id;
    instruction[11:9] = '001';
    return instruction;
end;

pure func WaitingTMOVLocalDestination() => bits(64)
begin
    var instruction = Zeros{64} + 0x00006013;
    instruction[18:15] = '0001';
    instruction[11:9] = '001';
    instruction[19] = '1';
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    let shared_tile_id = (Zeros{6} + 7) as SharedTileID;
    ConfigureTile(0, 128, 128, 1, 1, 1, TileDataType_U8,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0x33);
    let pending = AtomicUpdateSharedTileWithPublication(
        shared_tile_id, _Tiles[[0]], '1000', FALSE);
    assert pending;
    assert !SharedTileRecord(shared_tile_id).whole_parent_ready;
    assert !SharedTilePublished(shared_tile_id);

    var start = Zeros{64} + 0x00211181;
    start[31:27] = Zeros{5} + 27;
    let started = ExecuteCommandInstruction(start, 32);
    let shared_bound = ExecuteCommandInstruction(
        WaitingTMOVSharedSource(Zeros{6} + 7), 32);
    let local_bound = ExecuteCommandInstruction(
        WaitingTMOVLocalDestination(), 32);
    assert started == CommandExecution_Executed;
    assert shared_bound == CommandExecution_Executed;
    assert local_bound == CommandExecution_Executed;
    let waiting = ExecuteBundleTileOperation();
    assert !waiting && _LastFault == Fault_None;
    assert _BundleActive;
    assert !_BundleSharedBindings[[0]].consumed;
    assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;

    let index = SharedTileArrayIndex(shared_tile_id);
    _SharedTiles[[index]].whole_parent_ready = TRUE;
    _SharedTiles[[index]].published = TRUE;
    assert SharedTileDescriptorLegal(shared_tile_id);
    assert SharedTileReadSchemaLegalAtCapacity(shared_tile_id, 1, 1, 1,
        TileDataType_U8, TileLayout_RowMajor, 128);
    assert BundleSharedBindingCount() == 1;
    assert BundleTileBindingCount() == 1;
    assert _BundleTileBindings[[0]].valid;
    assert _BundleTileBindings[[0]].destination_valid;
    assert !_BundleTileBindings[[0]].source0_valid;
    assert !_BundleTileBindings[[0]].source1_valid;
    assert _BundleTileBindings[[0]].last;
    assert _BundleTileBindings[[0]].destination_size == 1;
    assert _BundleTileBindings[[0]].pe_mask ==
        BundleSharedBindingMask(0);
    assert !BundleSharedBindingIsDestination(0);
    assert BundleDestinationValidRows(FALSE, 0) == 1;
    assert BundleDestinationValidColumns(FALSE, 0) == 1;
    assert BundleDestinationPhysicalColumns(FALSE, 0) == 1;
    assert TileDataTypeFromEncoding(
        CurrentBundleTileOperationDataTypeCode() as TileDataTypeEncoding) ==
        TileDataType_U8;
    assert CurrentBundleTileLayout() == TileLayout_RowMajor;
    assert BundleSharedTMOVDestinationSchemaLegal(shared_tile_id, 2);
    let completed = ExecuteBundleTileOperation();
    assert _LastFault == Fault_None;
    assert completed;
    assert _BundleSharedBindings[[0]].consumed;
    let destination = _BundleTileBindings[[0]].destination;
    assert _Tiles[[destination]].contents_defined;
    assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN} + 0x33;
    return 0;
end;
