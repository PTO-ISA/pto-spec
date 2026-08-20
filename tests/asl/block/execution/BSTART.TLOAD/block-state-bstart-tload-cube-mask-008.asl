// PTO-TEST: {"id":"PTO-AVS-BLOCK-TLOAD-CUBE-MASK-008","source":"asl/block/execution/BSTART.TLOAD.asl","requirements":["PTO-CUBE-CELL-TRANSPORT-001"],"kind":"state-transition","summary":"CUBE TLOAD accepts partial PE participation and keeps mask zero a strict no-op","pass_condition":"mask 0011 charges two per-PE capacities and publishes that allocation mask while mask zero bypasses malformed CUBE schema without effects","related_sources":["asl/block/model/dispatch/tlsu-layout-conversion.asl","asl/tile/model/capacity/local.asl"]}
pure func CubeMaskStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00011181;
    instruction[31:27] = Zeros{5} + 4;
    return instruction;
end;

pure func CubeMaskAttributes(code: integer {22,25}) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001023;
    instruction[24:20] = DTYPE_NONE;
    instruction[11:7] = Zeros{5} + code;
    return instruction;
end;

pure func CubeMaskDestination(mask: bits(4)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00006013;
    instruction[11:9] = '001';
    instruction[18:15] = mask;
    instruction[19] = '1';
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    Store(Zeros{PTO_XLEN}, 2, Zeros{PTO_XLEN} + 0x1234);
    let start_status = ExecuteCommandInstruction(CubeMaskStart(), 32);
    let datr_status = ExecuteCommandInstruction(CubeMaskAttributes(22), 32);
    assert start_status == CommandExecution_Executed;
    assert datr_status == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    let destination_status = ExecuteCommandInstruction(
        CubeMaskDestination('0011'), 32);
    assert destination_status == CommandExecution_Executed;
    let completed = ExecuteBundleTileOperation();
    assert completed;
    let destination = _BundleTileBindings[[0]].destination;
    assert _TileAllocationMasks[[destination]] == '0011';
    assert CoreTileCapacityInUse() == 256;
    let tile = _Tiles[[destination]];
    assert tile.payload[[TileStorageIndex(tile, 0, 0)]] ==
        Zeros{PTO_XLEN} + 0x1234;

    ResetProfileState();
    let zero_start = ExecuteCommandInstruction(CubeMaskStart(), 32);
    let wrong_direction = ExecuteCommandInstruction(
        CubeMaskAttributes(25), 32);
    let zero_destination = ExecuteCommandInstruction(
        CubeMaskDestination('0000'), 32);
    assert zero_start == CommandExecution_Executed;
    assert wrong_direction == CommandExecution_Executed;
    assert zero_destination == CommandExecution_Executed;
    let zero_completed = ExecuteBundleTileOperation();
    assert zero_completed;
    assert _LastFault == Fault_None;
    assert CoreTileCapacityInUse() == 0;
    assert _MemoryEventCount == 0;
    assert BundleTileBindingCount() == 0;
    return 0;
end;
