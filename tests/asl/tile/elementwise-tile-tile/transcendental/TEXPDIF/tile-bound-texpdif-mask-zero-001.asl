// PTO-TEST: {"id":"PTO-AVS-TILE-TEXPDIF-MASK-ZERO-001","source":"asl/tile/elementwise-tile-tile/transcendental/TEXPDIF.asl","requirements":["PTO-INST-TILE-TEXPDIF","PTO-TEXPDIF-CONTRACT-001"],"kind":"boundary","summary":"TEXPDIF zero participation returns before invalid sources or destination allocation","pass_condition":"a zero-mask binding with absent invalid sources, no dimensions, and a preexisting numeric status completes without a fault, tile allocation, or status change","related_sources":["asl/block/model/dispatch/tile-execution.asl","asl/block/model/state/control-state.asl"]}
func main() => integer
begin
    ResetProfileState();
    var start: bits(64) = Zeros{64} + 0x00019181;
    start[24:20] = '11101';
    start[31:27] = TileDataTypeToEncoding(TileDataType_FP32);
    let start_result = ExecuteCommandInstruction(start, 32);
    assert start_result == CommandExecution_Executed;
    RecordNumericStatusFlags('00100');
    let status_before = NumericStatusFlags();
    AddBundleTileBinding(FALSE, 0, 0, '0000',
        FALSE, FALSE, 62, 63, TRUE);
    let completed = ExecuteBundleTileOperation();
    assert completed;
    assert _LastFault == Fault_None;
    assert CoreTileCapacityInUse() == 0;
    assert NumericStatusFlags() == status_before;
    assert !_Tiles[[0]].allocated;
    return 0;
end;
