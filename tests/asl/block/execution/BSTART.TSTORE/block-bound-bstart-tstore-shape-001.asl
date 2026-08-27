// PTO-TEST: {"id":"PTO-AVS-BLOCK-TSTORE-SHAPE-001","source":"asl/block/execution/BSTART.TSTORE.asl","requirements":["PTO-B-SHARED-WHOLE-PARENT-READY-001","PTO-INST-BLOCK-BSTART-TSTORE"],"kind":"boundary","summary":"the Shared readiness gate precedes validation of an oversized temporary TSTORE schema","pass_condition":"an unallocated Shared source keeps the block waiting without a fault, GM effect, binding consumption, or descriptor publication before shape validation","related_sources":["asl/block/model/dispatch/shared-tlsu.asl","asl/tile/model/shape/valid-region.asl","asl/tile/model/state/shared-registers.asl"]}
pure func TStoreShapeStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00011181;
    instruction[24:20] = '00001';
    instruction[31:27] = Zeros{5} + 24;
    return instruction;
end;

pure func TStoreShapeShared(shared_tile_id: bits(6)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001013;
    instruction[25:20] = shared_tile_id;
    instruction[18:15] = '0000';
    instruction[11:9] = '111';
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    let shared_tile_id = (Zeros{6} + 35) as SharedTileID;
    _Memory[[0]] = Zeros{8} + 0x5a;
    assert MinimumTileCapacityBytesForShape(
        32768, 9, 32768, TileDataType_U8) == 0;
    let start = ExecuteCommandInstruction(TStoreShapeStart(), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 32768);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 9);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 32768);
    let source = ExecuteCommandInstruction(TStoreShapeShared(shared_tile_id), 32);
    assert start == CommandExecution_Executed;
    assert source == CommandExecution_Executed;
    let completed = ExecuteBundleTileOperation();
    assert !completed;
    assert _LastFault == Fault_None;
    assert _BundleActive;
    assert BundleSharedBindingCount() == 1;
    assert !_BundleSharedBindings[[0]].consumed;
    assert _Memory[[0]] == Zeros{8} + 0x5a;
    assert !SharedTileRecord(shared_tile_id).descriptor_valid;
    return 0;
end;
