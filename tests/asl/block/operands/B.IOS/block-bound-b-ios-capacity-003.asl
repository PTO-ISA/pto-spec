// PTO-TEST: {"id":"PTO-AVS-BLOCK-B-IOS-CAPACITY-003","source":"asl/block/operands/B.IOS.asl","requirements":["PTO-INST-BLOCK-B-IOS","PTO-INST-TILE-TLOAD"],"kind":"boundary","summary":"Decoded B.IOS enforces Shared per-PE and aggregate capacity boundaries.","pass_condition":"128 KiB commits for one or two PEs, 256 KiB commits for one PE, and larger participating sets fault before descriptor publication.","related_sources":["asl/block/model/dispatch/destination-shape.asl","asl/tile/model/state/shared-registers.asl","asl/tile/model/capacity/shared.asl"]}
pure func BIOSCapacityStart(data_type: bits(5)) => bits(64)
begin
    var instruction = Zeros{64} + 0x00011181;
    instruction[31:27] = data_type;
    return instruction;
end;

pure func BIOSCapacityDestination(shared_id: bits(8), size_code: bits(4),
                                  pe_mode: bits(3)) => bits(64)
begin
    var instruction = Zeros{64} + 0x00001013;
    instruction[27:20] = shared_id;
    instruction[18:15] = size_code;
    instruction[11:9] = pe_mode;
    return instruction;
end;

func PrepareBIOSCapacity()
begin
    let started = ExecuteCommandInstruction(
        BIOSCapacityStart(Zeros{5} + 16), 32);
    assert started == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 1);
end;

func main() => integer
begin
    ResetProfileState();
    PrepareBIOSCapacity();
    let shared_128_one = ExecuteCommandInstruction(
        BIOSCapacityDestination(Zeros{8} + 1, '1011', '001'), 32);
    assert shared_128_one == CommandExecution_Executed;
    let shared_128_one_completed = ExecuteBundleTileOperation();
    assert shared_128_one_completed;
    assert _LastFault == Fault_None;
    assert SharedTileRecord(Zeros{8} + 1).allocation_mask == '1000';

    ResetProfileState();
    PrepareBIOSCapacity();
    let shared_128_two = ExecuteCommandInstruction(
        BIOSCapacityDestination(Zeros{8} + 2, '1011', '101'), 32);
    assert shared_128_two == CommandExecution_Executed;
    let shared_128_two_completed = ExecuteBundleTileOperation();
    assert shared_128_two_completed;
    assert _LastFault == Fault_None;
    assert SharedTileRecord(Zeros{8} + 2).allocation_mask == '1100';

    ResetProfileState();
    PrepareBIOSCapacity();
    let shared_128_three = ExecuteCommandInstruction(
        BIOSCapacityDestination(Zeros{8} + 3, '1011', '110'), 32);
    assert shared_128_three == CommandExecution_Executed;
    let shared_128_three_completed = ExecuteBundleTileOperation();
    assert !shared_128_three_completed;
    assert _LastFault == Fault_TileLegality;
    assert !SharedTileRecord(Zeros{8} + 3).descriptor_valid;

    ResetProfileState();
    PrepareBIOSCapacity();
    let shared_128_four = ExecuteCommandInstruction(
        BIOSCapacityDestination(Zeros{8} + 4, '1011', '111'), 32);
    assert shared_128_four == CommandExecution_Executed;
    let shared_128_four_completed = ExecuteBundleTileOperation();
    assert !shared_128_four_completed;
    assert _LastFault == Fault_TileLegality;
    assert !SharedTileRecord(Zeros{8} + 4).descriptor_valid;

    ResetProfileState();
    PrepareBIOSCapacity();
    let shared_256_one = ExecuteCommandInstruction(
        BIOSCapacityDestination(Zeros{8} + 5, '1100', '001'), 32);
    assert shared_256_one == CommandExecution_Executed;
    let shared_256_one_completed = ExecuteBundleTileOperation();
    assert shared_256_one_completed;
    assert _LastFault == Fault_None;
    assert SharedTileRecord(Zeros{8} + 5).allocation_mask == '1000';

    ResetProfileState();
    PrepareBIOSCapacity();
    let shared_256_two = ExecuteCommandInstruction(
        BIOSCapacityDestination(Zeros{8} + 6, '1100', '101'), 32);
    assert shared_256_two == CommandExecution_Executed;
    let shared_256_two_completed = ExecuteBundleTileOperation();
    assert !shared_256_two_completed;
    assert _LastFault == Fault_TileLegality;
    assert !SharedTileRecord(Zeros{8} + 6).descriptor_valid;
    return 0;
end;
