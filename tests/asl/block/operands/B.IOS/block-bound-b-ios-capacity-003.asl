// PTO-TEST: {"id":"PTO-AVS-BLOCK-B-IOS-CAPACITY-003","source":"asl/block/operands/B.IOS.asl","requirements":["PTO-INST-BLOCK-B-IOS","PTO-INST-TILE-TLOAD"],"kind":"boundary","summary":"Decoded B.IOS charges aggregate Shared capacity once, independently of PEMode.","pass_condition":"Two 128 KiB Shared objects exactly fill the independent Shared pool, a third allocation rejects, and one 256 KiB object succeeds for a partial PEMode while excluding another allocation.","related_sources":["asl/block/model/dispatch/destination-shape.asl","asl/tile/model/state/shared-registers.asl","asl/tile/model/capacity/shared.asl"]}
pure func BIOSCapacityStart(data_type: bits(5)) => bits(64)
begin
    var instruction = Zeros{64} + 0x00011181;
    instruction[31:27] = data_type;
    return instruction;
end;

pure func BIOSCapacityDestination(shared_tile_id: bits(6), size_code: bits(4),
                                  pe_mode: bits(3)) => bits(64)
begin
    var instruction = Zeros{64} + 0x00001013;
    instruction[25:20] = shared_tile_id;
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
    let first_128 = ExecuteCommandInstruction(
        BIOSCapacityDestination(Zeros{6} + 1, '1011', '001'), 32);
    assert first_128 == CommandExecution_Executed;
    let first_128_completed = ExecuteBundleTileOperation();
    assert first_128_completed;
    assert _LastFault == Fault_None;
    assert SharedTileRecord((Zeros{6} + 1) as SharedTileID)
        .allocation_mask == '1000';
    assert SharedTileCapacityInUse() == 131072;

    ResetBundleControlState();
    PrepareBIOSCapacity();
    let second_128 = ExecuteCommandInstruction(
        BIOSCapacityDestination(Zeros{6} + 2, '1011', '111'), 32);
    assert second_128 == CommandExecution_Executed;
    let second_128_completed = ExecuteBundleTileOperation();
    assert second_128_completed;
    assert _LastFault == Fault_None;
    assert SharedTileRecord((Zeros{6} + 2) as SharedTileID)
        .allocation_mask == '1111';
    assert SharedTileCapacityInUse() == 262144;

    ResetBundleControlState();
    PrepareBIOSCapacity();
    let overflow = ExecuteCommandInstruction(
        BIOSCapacityDestination(Zeros{6} + 3, '0001', '001'), 32);
    assert overflow == CommandExecution_Executed;
    let overflow_completed = ExecuteBundleTileOperation();
    assert !overflow_completed;
    assert _LastFault == Fault_TileLegality;
    assert !SharedTileRecord((Zeros{6} + 3) as SharedTileID)
        .descriptor_valid;
    assert SharedTileCapacityInUse() == 262144;

    ResetProfileState();
    PrepareBIOSCapacity();
    let full_256_partial_mode = ExecuteCommandInstruction(
        BIOSCapacityDestination(Zeros{6} + 5, '1100', '101'), 32);
    assert full_256_partial_mode == CommandExecution_Executed;
    let full_256_completed = ExecuteBundleTileOperation();
    assert full_256_completed;
    assert _LastFault == Fault_None;
    assert SharedTileRecord((Zeros{6} + 5) as SharedTileID)
        .allocation_mask == '1100';
    assert SharedTileCapacityInUse() == 262144;

    ResetBundleControlState();
    PrepareBIOSCapacity();
    let after_full = ExecuteCommandInstruction(
        BIOSCapacityDestination(Zeros{6} + 6, '0001', '100'), 32);
    assert after_full == CommandExecution_Executed;
    let after_full_completed = ExecuteBundleTileOperation();
    assert !after_full_completed;
    assert _LastFault == Fault_TileLegality;
    assert !SharedTileRecord((Zeros{6} + 6) as SharedTileID)
        .descriptor_valid;
    return 0;
end;
