// PTO-TEST: {"id":"PTO-AVS-BLOCK-BINDER-SIZECODE-CONSUMERS-001","source":"asl/block/model/dispatch/commands.asl","requirements":["PTO-INST-BLOCK-B-IOT","PTO-INST-BLOCK-B-IOS","PTO-INST-TILE-TLOAD"],"kind":"execution","summary":"Decoded Local and Shared boundary SizeCodes reach normal TLOAD consumers and preflight capacity faults atomically.","pass_condition":"SizeCode 10 allocates a 64 KiB Local destination, SizeCode 12 allocates a 256 KiB Shared destination for one PE, and oversized decoded shapes reject with Fault_TileAllocation before allocation.","related_sources":["asl/block/model/dispatch/shared-tlsu.asl","asl/tile/model/shape/valid-region.asl","asl/tile/model/state/descriptors.asl"]}
pure func BinderConsumerStart(data_type: bits(5)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00011181;
    instruction[31:27] = data_type;
    return instruction;
end;

pure func BinderConsumerLocal(size_code: bits(4), pe_mode: bits(3))
        => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00006013;
    instruction[18:15] = size_code;
    instruction[11:9] = pe_mode;
    instruction[19] = '1';
    return instruction;
end;

pure func BinderConsumerShared(shared_id: bits(8), size_code: bits(4),
                               pe_mode: bits(3)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001013;
    instruction[27:20] = shared_id;
    instruction[18:15] = size_code;
    instruction[11:9] = pe_mode;
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    let local_start = ExecuteCommandInstruction(
        BinderConsumerStart(Zeros{5} + 25), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 1);
    let local_destination = ExecuteCommandInstruction(
        BinderConsumerLocal('1010', '100'), 32);
    assert local_start == CommandExecution_Executed;
    assert local_destination == CommandExecution_Executed;
    let local_completed = ExecuteBundleTileOperation();
    assert local_completed;
    assert _LastFault == Fault_None;
    assert _Tiles[[0]].allocated;
    assert _Tiles[[0]].capacity_bytes == 65536;

    ResetProfileState();
    let local_overflow_start = ExecuteCommandInstruction(
        BinderConsumerStart(Zeros{5} + 25), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 16385);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 16385);
    let local_overflow_destination = ExecuteCommandInstruction(
        BinderConsumerLocal('1010', '100'), 32);
    assert local_overflow_start == CommandExecution_Executed;
    assert local_overflow_destination == CommandExecution_Executed;
    let local_overflow_completed = ExecuteBundleTileOperation();
    assert !local_overflow_completed;
    assert _LastFault == Fault_TileAllocation;
    assert !_Tiles[[0]].allocated;

    ResetProfileState();
    let shared_start = ExecuteCommandInstruction(
        BinderConsumerStart(Zeros{5} + 24), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 1);
    let shared_destination = ExecuteCommandInstruction(
        BinderConsumerShared(Zeros{8} + 91, '1100', '100'), 32);
    assert shared_start == CommandExecution_Executed;
    assert shared_destination == CommandExecution_Executed;
    let shared_completed = ExecuteBundleTileOperation();
    assert shared_completed;
    assert _LastFault == Fault_None;
    assert SharedTileRecord(Zeros{8} + 91).descriptor_valid;
    assert SharedTileRecord(Zeros{8} + 91).tile.capacity_bytes == 262144;
    assert SharedTileRecord(Zeros{8} + 91).allocation_mask == '0001';

    ResetProfileState();
    let shared_overflow_start = ExecuteCommandInstruction(
        BinderConsumerStart(Zeros{5} + 24), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 32769);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 32769);
    let shared_overflow_destination = ExecuteCommandInstruction(
        BinderConsumerShared(Zeros{8} + 92, '1100', '100'), 32);
    assert shared_overflow_start == CommandExecution_Executed;
    assert shared_overflow_destination == CommandExecution_Executed;
    let shared_overflow_completed = ExecuteBundleTileOperation();
    assert !shared_overflow_completed;
    assert _LastFault == Fault_TileLegality;
    assert !SharedTileRecord(Zeros{8} + 92).descriptor_valid;
    return 0;
end;
