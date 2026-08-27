// PTO-TEST: {"id":"PTO-AVS-BLOCK-TSTORE-UNDEF-001","source":"asl/block/execution/BSTART.TSTORE.asl","requirements":["PTO-B-SHARED-WHOLE-PARENT-READY-001","PTO-INST-BLOCK-BSTART-TSTORE"],"kind":"state-transition","summary":"An unpublished Shared TSTORE source keeps the completed block waiting.","pass_condition":"The first attempt has no fault, GM effect, or binding consumption; publishing the same parent lets the unchanged block retry and store successfully.","related_sources":["asl/block/model/dispatch/shared-tlsu.asl","asl/tile/model/state/shared-registers.asl"]}
pure func WaitingTSTORESharedSource(shared_tile_id: bits(6)) => bits(64)
begin
    var instruction = Zeros{64} + 0x00001013;
    instruction[25:20] = shared_tile_id;
    instruction[11:9] = '001';
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    let shared_tile_id = (Zeros{6} + 42) as SharedTileID;
    ConfigureTile(0, 128, 128, 1, 1, 1, TileDataType_U8,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0x5a);
    let pending = AtomicUpdateSharedTileWithPublication(
        shared_tile_id, _Tiles[[0]], '1000', FALSE);
    assert pending;
    assert SharedTileRecord(shared_tile_id).descriptor_valid;
    assert !SharedTilePublished(shared_tile_id);
    assert !SharedTileRecord(shared_tile_id).whole_parent_ready;

    var start = Zeros{64} + 0x00111181;
    start[31:27] = Zeros{5} + 27;
    let started = ExecuteCommandInstruction(start, 32);
    let bound = ExecuteCommandInstruction(
        WaitingTSTORESharedSource(Zeros{6} + 42), 32);
    assert started == CommandExecution_Executed;
    assert bound == CommandExecution_Executed;
    let waiting = ExecuteBundleTileOperation();
    assert !waiting && _LastFault == Fault_None;
    assert _BundleActive;
    assert !_BundleSharedBindings[[0]].consumed;
    assert _MemoryEventCount == 0;
    assert _Memory[[0]] == Zeros{8};

    let index = SharedTileArrayIndex(shared_tile_id);
    _SharedTiles[[index]].whole_parent_ready = TRUE;
    _SharedTiles[[index]].published = TRUE;
    assert SharedTileDescriptorLegal(shared_tile_id);
    assert SharedTileReadSchemaLegal(shared_tile_id, 1, 1, 1,
        TileDataType_U8, TileLayout_RowMajor);
    let completed = ExecuteBundleTileOperation();
    assert _LastFault == Fault_None;
    assert completed;
    assert _BundleSharedBindings[[0]].consumed;
    assert _Memory[[0]] == Zeros{8} + 0x5a;
    return 0;
end;
