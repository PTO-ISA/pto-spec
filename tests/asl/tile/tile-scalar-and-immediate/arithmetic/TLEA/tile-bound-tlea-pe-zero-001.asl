// PTO-TEST: {"id":"PTO-AVS-TILE-TLEA-PE-ZERO-001","source":"asl/tile/tile-scalar-and-immediate/arithmetic/TLEA.asl","requirements":["PTO-INST-TILE-TLEA","PTO-TLEA-CONTRACT-001"],"kind":"boundary","summary":"Zero-participation TLEA declines before missing width and illegal source bindings.","pass_condition":"PE_MASK zero completes without allocation, memory events or numeric status change.","related_sources":["asl/block/model/dispatch/lea-schema.asl","asl/block/model/dispatch/descriptor-legality.asl","asl/block/model/dispatch/destination-operation.asl"]}
pure func LEAStart(source_type: TileDataType) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00019181;
    instruction[26:25] = '01';
    instruction[24:20] = '01110';
    instruction[31:27] = TileDataTypeToEncoding(source_type);
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    let started = ExecuteCommandInstruction(LEAStart(TileDataType_S16), 32);
    assert started == CommandExecution_Executed;
    RecordNumericStatusFlags('00100');
    let status_before = NumericStatusFlags();
    AddBundleTileBinding(FALSE, 0, 0, '0000', FALSE, FALSE, 62, 63, TRUE);
    let completed = ExecuteBundleTileOperation();
    assert completed;
    assert _LastFault == Fault_None;
    assert CoreTileCapacityInUse() == 0;
    assert NumericStatusFlags() == status_before;
    return 0;
end;
