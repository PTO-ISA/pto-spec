// PTO-TEST: {"id":"PTO-AVS-BLOCK-BINDER-CAPACITY-BOUNDARIES-003","source":"asl/block/model/dispatch/commands.asl","requirements":["PTO-INST-BLOCK-B-IOT","PTO-INST-BLOCK-B-IOS","PTO-INST-TILE-TLOAD"],"kind":"boundary","summary":"Decoded Local and Shared capacity boundaries distinguish exact-fit participation from aggregate overflow.","pass_condition":"Local 64 KiB with all four PEs, Shared 128 KiB with one or two PEs, and Shared 256 KiB with one PE commit; the applicable three/four-PE Shared cases fault before descriptor publication.","related_sources":["asl/block/model/dispatch/destination-shape.asl","asl/tile/model/state/shared-registers.asl","asl/tile/model/capacity/shared.asl"]}
pure func CapacityBoundaryStart(data_type: bits(5)) => bits(64)
begin
    var instruction = Zeros{64} + 0x00011181;
    instruction[31:27] = data_type;
    return instruction;
end;

pure func CapacityBoundaryLocal(size_code: bits(4), pe_mode: bits(3))
        => bits(64)
begin
    var instruction = Zeros{64} + 0x00006013;
    instruction[18:15] = size_code;
    instruction[11:9] = pe_mode;
    instruction[19] = '1';
    return instruction;
end;

pure func CapacityBoundaryShared(shared_id: bits(8), size_code: bits(4),
                                 pe_mode: bits(3)) => bits(64)
begin
    var instruction = Zeros{64} + 0x00001013;
    instruction[27:20] = shared_id;
    instruction[18:15] = size_code;
    instruction[11:9] = pe_mode;
    return instruction;
end;

func PrepareCapacityBoundary(data_type: bits(5))
begin
    let started = ExecuteCommandInstruction(
        CapacityBoundaryStart(data_type), 32);
    assert started == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 1);
end;

func main() => integer
begin
    // All four 64 KiB Local participants exactly fill the 256 KiB model cap.
    ResetProfileState();
    PrepareCapacityBoundary(Zeros{5} + 25);
    let local = ExecuteCommandInstruction(
        CapacityBoundaryLocal('1010', '111'), 32);
    assert local == CommandExecution_Executed;
    let local_completed = ExecuteBundleTileOperation();
    assert local_completed;
    assert _LastFault == Fault_None;
    assert _Tiles[[0]].allocated;
    assert _TileAllocationMasks[[0]] == '1111';
    assert _Tiles[[0]].capacity_bytes == 65536;

    // 128 KiB Shared succeeds for one and two participating PEs.
    ResetProfileState();
    PrepareCapacityBoundary(Zeros{5} + 16);
    let shared_128_one = ExecuteCommandInstruction(
        CapacityBoundaryShared(Zeros{8} + 1, '1011', '001'), 32);
    assert shared_128_one == CommandExecution_Executed;
    let shared_128_one_completed = ExecuteBundleTileOperation();
    assert shared_128_one_completed;
    assert _LastFault == Fault_None;
    assert SharedTileRecord(Zeros{8} + 1).allocation_mask == '1000';

    ResetProfileState();
    PrepareCapacityBoundary(Zeros{5} + 16);
    let shared_128_two = ExecuteCommandInstruction(
        CapacityBoundaryShared(Zeros{8} + 2, '1011', '101'), 32);
    assert shared_128_two == CommandExecution_Executed;
    let shared_128_two_completed = ExecuteBundleTileOperation();
    assert shared_128_two_completed;
    assert _LastFault == Fault_None;
    assert SharedTileRecord(Zeros{8} + 2).allocation_mask == '1100';

    // Three and four 128 KiB participants exceed the aggregate cap.
    ResetProfileState();
    PrepareCapacityBoundary(Zeros{5} + 16);
    let shared_128_three = ExecuteCommandInstruction(
        CapacityBoundaryShared(Zeros{8} + 3, '1011', '110'), 32);
    assert shared_128_three == CommandExecution_Executed;
    let shared_128_three_completed = ExecuteBundleTileOperation();
    assert !shared_128_three_completed;
    assert _LastFault == Fault_TileLegality;
    assert !SharedTileRecord(Zeros{8} + 3).descriptor_valid;

    ResetProfileState();
    PrepareCapacityBoundary(Zeros{5} + 16);
    let shared_128_four = ExecuteCommandInstruction(
        CapacityBoundaryShared(Zeros{8} + 4, '1011', '111'), 32);
    assert shared_128_four == CommandExecution_Executed;
    let shared_128_four_completed = ExecuteBundleTileOperation();
    assert !shared_128_four_completed;
    assert _LastFault == Fault_TileLegality;
    assert !SharedTileRecord(Zeros{8} + 4).descriptor_valid;

    // 256 KiB Shared succeeds for one PE and overflows for two.
    ResetProfileState();
    PrepareCapacityBoundary(Zeros{5} + 16);
    let shared_256_one = ExecuteCommandInstruction(
        CapacityBoundaryShared(Zeros{8} + 5, '1100', '001'), 32);
    assert shared_256_one == CommandExecution_Executed;
    let shared_256_one_completed = ExecuteBundleTileOperation();
    assert shared_256_one_completed;
    assert _LastFault == Fault_None;
    assert SharedTileRecord(Zeros{8} + 5).allocation_mask == '1000';

    ResetProfileState();
    PrepareCapacityBoundary(Zeros{5} + 16);
    let shared_256_two = ExecuteCommandInstruction(
        CapacityBoundaryShared(Zeros{8} + 6, '1100', '101'), 32);
    assert shared_256_two == CommandExecution_Executed;
    let shared_256_two_completed = ExecuteBundleTileOperation();
    assert !shared_256_two_completed;
    assert _LastFault == Fault_TileLegality;
    assert !SharedTileRecord(Zeros{8} + 6).descriptor_valid;
    return 0;
end;
