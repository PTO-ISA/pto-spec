// PTO-TEST: {"id":"PTO-AVS-BLOCK-B-IOT-CAPACITY-003","source":"asl/block/operands/B.IOT.asl","requirements":["PTO-INST-BLOCK-B-IOT","PTO-INST-TILE-TLOAD"],"kind":"boundary","summary":"Decoded B.IOT charges each selected PE's independent Local capacity pool.","pass_condition":"The maximum legal Local SizeCode 10 with all four PEs commits one independent 64 KiB charge to every selected PE without a fault.","related_sources":["asl/block/model/dispatch/destination-shape.asl","asl/tile/model/state/allocation.asl"]}
pure func BIOTCapacityStart(data_type: bits(5)) => bits(64)
begin
    var instruction = Zeros{64} + 0x00011181;
    instruction[31:27] = data_type;
    return instruction;
end;

pure func BIOTCapacityDestination(size_code: bits(4), pe_mode: bits(3))
        => bits(64)
begin
    var instruction = Zeros{64} + 0x00006013;
    instruction[18:15] = size_code;
    instruction[11:9] = pe_mode;
    instruction[19] = '1';
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    let started = ExecuteCommandInstruction(
        BIOTCapacityStart(Zeros{5} + 24), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 1);
    let destination = ExecuteCommandInstruction(
        BIOTCapacityDestination('1010', '111'), 32);
    assert started == CommandExecution_Executed;
    assert destination == CommandExecution_Executed;
    let completed = ExecuteBundleTileOperation();
    assert completed;
    assert _LastFault == Fault_None;
    assert _Tiles[[0]].allocated;
    assert _TileAllocationMasks[[0]] == '1111';
    assert _Tiles[[0]].capacity_bytes == 65536;
    for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        assert TileCapacityInUseForPE(pe) == 65536;
    end;
    assert TileCapacityInUse() == 262144;
    return 0;
end;
