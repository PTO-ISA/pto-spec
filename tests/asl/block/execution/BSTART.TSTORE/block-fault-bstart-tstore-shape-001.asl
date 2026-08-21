// PTO-TEST: {"id":"PTO-AVS-BLOCK-TSTORE-SHAPE-001","source":"asl/block/execution/BSTART.TSTORE.asl","requirements":["PTO-INST-BLOCK-BSTART-TSTORE"],"kind":"fault","summary":"an unallocated Shared source rejects a schema larger than the maximum temporary capacity","pass_condition":"shape rejection precedes GM and Shared state effects","related_sources":["asl/tile/model/shape/valid-region.asl"]}
pure func TStoreShapeStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00011181;
    instruction[24:20] = '00001';
    instruction[31:27] = Zeros{5} + 24;
    return instruction;
end;

pure func TStoreShapeShared(shared_id: bits(8)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001013;
    instruction[27:20] = shared_id;
    instruction[18:15] = '0000';
    instruction[11:9] = '111';
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    let shared_id = Zeros{8} + 99;
    _Memory[[0]] = Zeros{8} + 0x5a;
    assert MinimumTileCapacityBytesForShape(
        32768, 2, 32768, TileDataType_U8) == 0;
    let start = ExecuteCommandInstruction(TStoreShapeStart(), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 32768);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 32768);
    let source = ExecuteCommandInstruction(TStoreShapeShared(shared_id), 32);
    assert start == CommandExecution_Executed;
    assert source == CommandExecution_Executed;
    let completed = ExecuteBundleTileOperation();
    assert !completed;
    assert _LastFault == Fault_TileLegality;
    assert _Memory[[0]] == Zeros{8} + 0x5a;
    assert !SharedTileRecord(shared_id).descriptor_valid;
    return 0;
end;
