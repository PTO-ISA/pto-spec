// PTO-TEST: {"id":"PTO-AVS-BLOCK-B-IOT-CONSUMER-001","source":"asl/block/operands/B.IOT.asl","requirements":["PTO-INST-BLOCK-B-IOT","PTO-INST-TILE-TLOAD"],"kind":"execution","summary":"A decoded B.IOT boundary SizeCode reaches the normal Local TLOAD consumer.","pass_condition":"A 256 KiB destination commits, while an oversized decoded shape faults before Local allocation.","related_sources":["asl/block/model/dispatch/shared-tlsu.asl","asl/tile/model/shape/valid-region.asl","asl/tile/model/state/descriptors.asl"]}
pure func BIOTConsumerStart(data_type: bits(5)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00011181;
    instruction[31:27] = data_type;
    return instruction;
end;

pure func BIOTConsumerDestination(size_code: bits(4), pe_mode: bits(3))
        => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00006013;
    instruction[18:15] = size_code;
    instruction[11:9] = pe_mode;
    instruction[19] = '1';
    return instruction;
end;

func PrepareBIOTConsumer(dim0: integer, dim1: integer, dim2: integer)
begin
    let started = ExecuteCommandInstruction(
        BIOTConsumerStart(Zeros{5} + 24), 32);
    assert started == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + dim0);
    SetBundleDimension(1, Zeros{PTO_XLEN} + dim1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + dim2);
end;

func main() => integer
begin
    ResetProfileState();
    PrepareBIOTConsumer(1, 1, 1);
    let destination = ExecuteCommandInstruction(
        BIOTConsumerDestination('1100', '100'), 32);
    assert destination == CommandExecution_Executed;
    let completed = ExecuteBundleTileOperation();
    assert completed;
    assert _LastFault == Fault_None;
    assert _Tiles[[0]].allocated;
    assert _Tiles[[0]].capacity_bytes == 262144;

    ResetProfileState();
    PrepareBIOTConsumer(16385, 2, 16385);
    let overflow_destination = ExecuteCommandInstruction(
        BIOTConsumerDestination('1100', '100'), 32);
    assert overflow_destination == CommandExecution_Executed;
    let overflow_completed = ExecuteBundleTileOperation();
    assert !overflow_completed;
    assert _LastFault == Fault_TileAllocation;
    assert !_Tiles[[0]].allocated;
    return 0;
end;
