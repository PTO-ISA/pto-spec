// PTO-TEST: {"id":"PTO-AVS-BLOCK-B-IOS-CONSUMER-001","source":"asl/block/operands/B.IOS.asl","requirements":["PTO-INST-BLOCK-B-IOS","PTO-INST-TILE-TLOAD"],"kind":"execution","summary":"A decoded B.IOS boundary SizeCode reaches the normal Shared TLOAD consumer.","pass_condition":"A 256 KiB one-PE destination publishes, while an oversized decoded shape faults before Shared descriptor publication.","related_sources":["asl/block/model/dispatch/shared-tlsu.asl","asl/tile/model/shape/valid-region.asl","asl/tile/model/state/shared-registers.asl"]}
pure func BIOSConsumerStart(data_type: bits(5)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00011181;
    instruction[31:27] = data_type;
    return instruction;
end;

pure func BIOSConsumerDestination(shared_id: bits(8), size_code: bits(4),
                                  pe_mode: bits(3)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001013;
    instruction[27:20] = shared_id;
    instruction[18:15] = size_code;
    instruction[11:9] = pe_mode;
    return instruction;
end;

func PrepareBIOSConsumer(dim0: integer, dim2: integer)
begin
    let started = ExecuteCommandInstruction(
        BIOSConsumerStart(Zeros{5} + 24), 32);
    assert started == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + dim0);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + dim2);
end;

func main() => integer
begin
    ResetProfileState();
    PrepareBIOSConsumer(1, 1);
    let destination = ExecuteCommandInstruction(
        BIOSConsumerDestination(Zeros{8} + 91, '1100', '100'), 32);
    assert destination == CommandExecution_Executed;
    let completed = ExecuteBundleTileOperation();
    assert completed;
    assert _LastFault == Fault_None;
    assert SharedTileRecord(Zeros{8} + 91).descriptor_valid;
    assert SharedTileRecord(Zeros{8} + 91).tile.capacity_bytes == 262144;
    assert SharedTileRecord(Zeros{8} + 91).allocation_mask == '0001';

    ResetProfileState();
    PrepareBIOSConsumer(32769, 32769);
    let overflow_destination = ExecuteCommandInstruction(
        BIOSConsumerDestination(Zeros{8} + 92, '1100', '100'), 32);
    assert overflow_destination == CommandExecution_Executed;
    let overflow_completed = ExecuteBundleTileOperation();
    assert !overflow_completed;
    assert _LastFault == Fault_TileLegality;
    assert !SharedTileRecord(Zeros{8} + 92).descriptor_valid;
    return 0;
end;
