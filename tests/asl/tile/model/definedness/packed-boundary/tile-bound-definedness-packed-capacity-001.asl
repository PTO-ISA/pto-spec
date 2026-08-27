// PTO-TEST: {"id":"PTO-AVS-TILE-PACKED-CAPACITY-BOUNDARY-001","source":"asl/tile/model/definedness/packed-boundary.asl","requirements":[],"kind":"boundary","summary":"Decoded BSTART.TLOAD Local B.IOT SizeCode=10 and Shared B.IOS SizeCode=12 commit their maximum packed U4 shapes through dispatch, binding, translated preflight, and execution before carrier-tail observation.","pass_condition":"The Local path commits a 64 KiB/U4 shape and observes logical indices 65536 and 131071; the Shared path independently commits a 256 KiB/U4 shape and observes indices 393216 and 524287. Equivalent page-faulting translated probes reject both paths before destination or Shared descriptor publication.","related_sources":["asl/block/execution/BSTART.TLOAD.asl","asl/block/model/dispatch/tile-execution.asl","asl/block/model/dispatch/shared-tlsu.asl","asl/block/operands/B.IOT.asl","asl/block/operands/B.IOS.asl","asl/tile/model/memory/load-store.asl","asl/tile/model/memory/shared-movement.asl","asl/tile/model/state/allocation.asl","asl/tile/model/state/shared-registers.asl","asl/tile/model/definedness/elements.asl"]}
pure func PackedCapacityStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00011181;
    instruction[31:27] = Zeros{5} + 28;
    return instruction;
end;

pure func PackedCapacityLocalDestination() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00006013;
    instruction[18:15] = Zeros{4} + 10;
    instruction[11:9] = '001';
    instruction[19] = '1';
    return instruction;
end;

pure func PackedCapacitySharedDestination(shared_tile_id: bits(6)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001013;
    instruction[25:20] = shared_tile_id;
    instruction[18:15] = Zeros{4} + 12;
    instruction[11:9] = '100';
    return instruction;
end;

pure func PackedCapacityIOR() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000013;
    instruction[19:15] = Zeros{5} + 2;
    instruction[24:20] = Zeros{5} + 3;
    return instruction;
end;

func PreparePackedCapacityBlock()
begin
    let started = ExecuteCommandInstruction(PackedCapacityStart(), 32);
    assert started == CommandExecution_Executed;
    let ior_status = ExecuteCommandInstruction(PackedCapacityIOR(), 32);
    assert ior_status == CommandExecution_Executed;
end;

func main() => integer
begin
    assert PTO_MODEL_TILE_ELEMENTS == 32768;
    assert PackedTileLogicalCapacity(262144, TileDataType_U4X2) == 524288;

    // The encoded BSTART.TLOAD + B.IOT path must resolve and commit the
    // Local maximum physical shape before this actual carrier-tail read.
    ResetProfileState();
    WriteGPR(2, Zeros{PTO_XLEN});
    WriteGPR(3, Zeros{PTO_XLEN});
    PreparePackedCapacityBlock();
    SetBundleDimension(0, Zeros{PTO_XLEN} + 16);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 8192);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 16);
    let local_destination_status = ExecuteCommandInstruction(
        PackedCapacityLocalDestination(), 32);
    assert local_destination_status == CommandExecution_Executed;
    let local_completed = ExecuteBundleTileOperation();
    assert local_completed;
    assert _LastFault == Fault_None;
    let local_tile = _BundleTileBindings[[0]].destination;
    assert _Tiles[[local_tile]].allocated;
    assert _Tiles[[local_tile]].capacity_bytes == 65536;
    assert _Tiles[[local_tile]].rows == 8192;
    assert _Tiles[[local_tile]].columns == 16;
    assert _Tiles[[local_tile]].valid_rows == 8192;
    assert _Tiles[[local_tile]].valid_columns == 16;
    let local_tail = TilePackedLinearIndex(_Tiles[[local_tile]], 4096, 0);
    assert local_tail == 65536;
    assert TileLogicalElementDefined(_Tiles[[local_tile]], local_tail);
    assert TileReadLogicalElement(_Tiles[[local_tile]], local_tail) ==
        Zeros{PTO_XLEN};
    let local_last = TilePackedLinearIndex(_Tiles[[local_tile]], 8191, 15);
    assert local_last == 131071;
    assert TileLogicalElementDefined(_Tiles[[local_tile]], local_last);
    assert TileReadLogicalElement(_Tiles[[local_tile]], local_last) ==
        Zeros{PTO_XLEN};

    // The encoded BSTART.TLOAD + B.IOS path must resolve and commit the
    // Shared maximum physical shape.  PE3 (PEMode=100) selects the final
    // quarter, while explicit zero stride keeps every decoded GM access in
    // the pinned 4 KiB model memory and still exercises the full shape.
    ResetProfileState();
    let shared_tile_id = (Zeros{6} + 35) as SharedTileID;
    WritePEGPR(3, 2, Zeros{PTO_XLEN});
    WritePEGPR(3, 3, Zeros{PTO_XLEN});
    PreparePackedCapacityBlock();
    SetBundleDimension(0, Zeros{PTO_XLEN} + 16);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 32768);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 16);
    let shared_destination_status = ExecuteCommandInstruction(
        PackedCapacitySharedDestination(shared_tile_id), 32);
    assert shared_destination_status == CommandExecution_Executed;
    let shared_completed = ExecuteBundleTileOperation();
    assert shared_completed;
    assert _LastFault == Fault_None;
    let shared = SharedTileRecord(shared_tile_id);
    assert shared.descriptor_valid;
    assert shared.allocation_mask == '0001';
    assert shared.initialized_mask == '0001';
    assert shared.tile.capacity_bytes == 262144;
    assert shared.tile.rows == 32768;
    assert shared.tile.columns == 16;
    assert TileLogicalElementDefined(shared.tile, 0);
    assert ReadSharedTileWord(shared_tile_id, 0) == Zeros{PTO_XLEN};
    let shared_tail = TilePackedLinearIndex(shared.tile, 24576, 0);
    assert shared_tail == 393216;
    assert TileLogicalElementDefined(shared.tile, shared_tail);
    assert TileReadLogicalElement(shared.tile, shared_tail) ==
        Zeros{PTO_XLEN};
    assert ReadSharedTileWord(shared_tile_id, shared_tail) == Zeros{PTO_XLEN};
    let shared_last = TilePackedLinearIndex(shared.tile, 32767, 15);
    assert shared_last == 524287;
    assert TileLogicalElementDefined(shared.tile, shared_last);
    assert TileReadLogicalElement(shared.tile, shared_last) ==
        Zeros{PTO_XLEN};
    assert ReadSharedTileWord(shared_tile_id, shared_last) == Zeros{PTO_XLEN};

    // A fast-eligible full shape still uses the ordinary translated probe.
    // The final distinct zero-stride byte is outside model memory, so the
    // decoded operation faults before either Local destination publication or
    // Shared descriptor commit.
    ResetProfileState();
    WriteGPR(2, Zeros{PTO_XLEN} + 4094);
    WriteGPR(3, Zeros{PTO_XLEN});
    PreparePackedCapacityBlock();
    SetBundleDimension(0, Zeros{PTO_XLEN} + 16);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 8192);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 16);
    let local_fault_destination_status = ExecuteCommandInstruction(
        PackedCapacityLocalDestination(), 32);
    assert local_fault_destination_status == CommandExecution_Executed;
    let local_fault_completed = ExecuteBundleTileOperation();
    assert !local_fault_completed;
    assert _LastFault == Fault_DataPage;
    assert CoreTileCapacityInUse() == 0;
    assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;

    ResetProfileState();
    let shared_fault_id = (Zeros{6} + 36) as SharedTileID;
    WritePEGPR(3, 2, Zeros{PTO_XLEN} + 4094);
    WritePEGPR(3, 3, Zeros{PTO_XLEN});
    PreparePackedCapacityBlock();
    SetBundleDimension(0, Zeros{PTO_XLEN} + 16);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 32768);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 16);
    let shared_fault_destination_status = ExecuteCommandInstruction(
        PackedCapacitySharedDestination(shared_fault_id), 32);
    assert shared_fault_destination_status == CommandExecution_Executed;
    let shared_fault_completed = ExecuteBundleTileOperation();
    assert !shared_fault_completed;
    assert _LastFault == Fault_DataPage;
    assert !SharedTileRecord(shared_fault_id).descriptor_valid;
    return 0;
end;
