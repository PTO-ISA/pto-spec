// PTO-TEST: {"id":"PTO-AVS-BLOCK-TLOAD-CUBE-TSIZE-006","source":"asl/block/execution/BSTART.TLOAD.asl","requirements":["PTO-CUBE-CELL-TRANSPORT-001"],"kind":"fault","summary":"CUBE TLOAD treats TSize only as a per-PE capacity limit","pass_condition":"a 512-byte destination rejects a 768-byte FP16 N8 descriptor before memory or allocation effects","related_sources":["asl/tile/model/shape/cube-cell.asl","asl/block/model/dispatch/tlsu-layout-conversion.asl"]}
func main() => integer
begin
    ResetProfileState();
    var start: bits(64) = Zeros{64} + 0x00011181;
    start[31:27] = Zeros{5} + 4;
    var datr: bits(64) = Zeros{64} + 0x00001023;
    datr[24:20] = DTYPE_NONE;
    datr[11:7] = Zeros{5} + 23;
    var destination: bits(64) = Zeros{64} + 0x00006013;
    destination[11:9] = '011';
    destination[18:15] = '0001';
    destination[19] = '1';
    let start_status = ExecuteCommandInstruction(start, 32);
    let datr_status = ExecuteCommandInstruction(datr, 32);
    assert start_status == CommandExecution_Executed;
    assert datr_status == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 19);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 13);
    let destination_status = ExecuteCommandInstruction(destination, 32);
    assert destination_status == CommandExecution_Executed;

    let completed = ExecuteBundleTileOperation();

    assert !completed;
    assert _LastFault == Fault_TileAllocation;
    assert CoreTileCapacityInUse() == 0;
    assert _MemoryEventCount == 0;
    assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;
    return 0;
end;
