// PTO-TEST: {"id":"PTO-AVS-BLOCK-TPREFETCH-SCHEMA-001","source":"asl/block/execution/BSTART.TPREFETCH.asl","requirements":["PTO-BSTART-TPREFETCH-MEMORY-001"],"kind":"boundary","summary":"TPREFETCH accepts no Tile binding and treats explicit zero dimensions as illegal values.","pass_condition":"A binding-free block succeeds while B.IOT, B.IOS, and explicit zero dimensions reject before allocation or Shared state changes.","related_sources":["asl/block/model/dispatch/tlsu-prefetch.asl"]}
pure func PrefetchSchemaStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00311181;
    instruction[31:27] = Zeros{5} + 27;
    return instruction;
end;

pure func PrefetchSchemaLocalDestination() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00006013;
    instruction[18:15] = '0001';
    instruction[11:9] = '111';
    instruction[19] = '1';
    return instruction;
end;

pure func PrefetchSchemaSharedDestination() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001013;
    instruction[27:20] = Zeros{8} + 7;
    instruction[18:15] = '0001';
    instruction[11:9] = '111';
    return instruction;
end;

func StartPrefetchSchemaBlock()
begin
    let started = ExecuteCommandInstruction(PrefetchSchemaStart(), 32);
    assert started == CommandExecution_Executed;
end;

func main() => integer
begin
    ResetProfileState();
    StartPrefetchSchemaBlock();
    let empty_completed = ExecuteBundleTileOperation();
    assert empty_completed;
    assert _LastFault == Fault_None;
    assert CoreTileCapacityInUse() == 0;

    ResetProfileState();
    StartPrefetchSchemaBlock();
    let local = ExecuteCommandInstruction(
        PrefetchSchemaLocalDestination(), 32);
    assert local == CommandExecution_Executed;
    let local_completed = ExecuteBundleTileOperation();
    assert !local_completed;
    assert _LastFault == Fault_TileLegality;
    assert CoreTileCapacityInUse() == 0;

    ResetProfileState();
    StartPrefetchSchemaBlock();
    let shared = ExecuteCommandInstruction(
        PrefetchSchemaSharedDestination(), 32);
    assert shared == CommandExecution_Executed;
    let shared_completed = ExecuteBundleTileOperation();
    assert !shared_completed;
    assert _LastFault == Fault_TileLegality;
    assert !SharedTileRecord(Zeros{8} + 7).descriptor_valid;

    ResetProfileState();
    StartPrefetchSchemaBlock();
    SetBundleDimension(0, Zeros{PTO_XLEN});
    let zero_completed = ExecuteBundleTileOperation();
    assert !zero_completed;
    assert _LastFault == Fault_TileLegality;
    return 0;
end;
