// PTO-TEST: {"id":"PTO-AVS-BLOCK-TLOAD-CUBE-RETRY-004","source":"asl/block/execution/BSTART.TLOAD.asl","requirements":["PTO-CUBE-CELL-TRANSPORT-001","PTO-INST-BLOCK-BSTART-TLOAD"],"kind":"fault","summary":"A faulting CUBE TLOAD rolls back allocation and recovers as one complete block reissue","pass_condition":"recovery restores an unallocated destination binding and the corrected retry emits one event per valid element then publishes one descriptor","related_sources":["asl/block/model/faults/rollback.asl","asl/block/model/dispatch/tlsu-layout-conversion.asl"]}
pure func CubeRetryStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00011181;
    instruction[31:27] = Zeros{5} + 4;
    return instruction;
end;

pure func CubeRetryAttributes() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001023;
    instruction[24:20] = DTYPE_NONE;
    instruction[11:7] = Zeros{5} + 22;
    instruction[28:27] = '11';
    return instruction;
end;

pure func CubeRetryDestination() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00006013;
    instruction[11:9] = '001';
    instruction[18:15] = '0001';
    instruction[19] = '1';
    return instruction;
end;

pure func CubeRetryIOR() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000013;
    instruction[19:15] = Zeros{5} + 2;
    instruction[24:20] = Zeros{5} + 3;
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    Store(Zeros{PTO_XLEN}, 2, Zeros{PTO_XLEN} + 1);
    Store(Zeros{PTO_XLEN} + 2, 2, Zeros{PTO_XLEN} + 2);
    Store(Zeros{PTO_XLEN} + 4, 2, Zeros{PTO_XLEN} + 3);
    WriteGPR(2, Zeros{PTO_XLEN} + 1);
    WriteGPR(3, Zeros{PTO_XLEN} + 2);
    let start_status = ExecuteCommandInstruction(CubeRetryStart(), 32);
    let datr_status = ExecuteCommandInstruction(CubeRetryAttributes(), 32);
    assert start_status == CommandExecution_Executed;
    assert datr_status == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 3);
    let destination_status = ExecuteCommandInstruction(
        CubeRetryDestination(), 32);
    let ior_status = ExecuteCommandInstruction(CubeRetryIOR(), 32);
    assert destination_status == CommandExecution_Executed;
    assert ior_status == CommandExecution_Executed;
    StartMemoryEventCapture(0);

    let first_completed = ExecuteBundleTileOperation();

    assert !first_completed;
    assert _LastFault == Fault_DataAlignment;
    assert CoreTileCapacityInUse() == 0;
    assert _MemoryEventCount == 0;
    assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;
    assert _TrapContexts[[0]].valid;
    assert !_TrapContexts[[0]].bundle_tile_bindings[[0]]
        .destination_allocated_by_bundle;

    WriteGPR(2, Zeros{PTO_XLEN});
    let recovered = RecoverTrapContext(0);
    assert recovered;
    assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;
    ClearFault();

    let second_completed = ExecuteBundleTileOperation();

    assert second_completed;
    assert _LastFault == Fault_None;
    assert CoreTileCapacityInUse() == 128;
    assert _MemoryEventCount == 3;
    let destination = _BundleTileBindings[[0]].destination;
    let tile = _Tiles[[destination]];
    assert tile.payload[[TileStorageIndex(tile, 0, 0)]] ==
        Zeros{PTO_XLEN} + 1;
    assert tile.payload[[TileStorageIndex(tile, 2, 0)]] ==
        Zeros{PTO_XLEN} + 3;
    StopMemoryEventCapture();
    return 0;
end;
