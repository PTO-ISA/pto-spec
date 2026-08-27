// PTO-TEST: {"id":"PTO-AVS-BLOCK-B-IOT-SIZECODE-012-001","source":"asl/block/operands/B.IOT.asl","requirements":["PTO-INST-BLOCK-B-IOT","PTO-TILE-CAPACITY-PER-PE"],"kind":"boundary","summary":"A Local B.IOT destination rejects SizeCodes 11 and 12 before binding or allocation effects.","pass_condition":"Local SizeCodes 11 and 12 fault as illegal Local capacity selections with unchanged TPC, empty binding state, and zero Local capacity use.","related_sources":["asl/block/model/dispatch/commands.asl","asl/block/model/operands/tile-bindings.asl","asl/tile/model/state/descriptors.asl"]}
pure func BundleTestB_IOTSizeCode(size_code: bits(4)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[25:20] = Zeros{6};
    instruction[19] = '1';
    instruction[18:15] = size_code;
    instruction[11:9] = '001';
    instruction[8:7] = '00';
    return instruction;
end;

func AssertLocalSizeCodeRejected(size_code: integer {11..12})
begin
    ResetProfileState();
    if size_code == 11 then
        assert TileSizeCodeBytes(11) == 131072;
    else
        assert TileSizeCodeBytes(12) == 262144;
    end;
    assert !LocalTileSizeCodeIsLegal(size_code);
    let started = ExecuteCommandInstruction(Zeros{64} + 0x00019181, 32);
    assert started == CommandExecution_Executed;
    let before_tpc = ReadTPC();
    let rejected = ExecuteCommandInstruction(
        BundleTestB_IOTSizeCode((Zeros{4} + size_code) as bits(4)), 32);
    assert rejected == CommandExecution_Rejected;
    assert _LastFault == Fault_IllegalInstruction;
    assert ReadTPC() == before_tpc;
    assert BundleTileBindingCount() == 0;
    assert !_BundleTileBindings[[0]].valid;
    assert TileCapacityInUseForPE(0) == 0;
    assert TileCapacityInUse() == 0;
end;

func main() => integer
begin
    AssertLocalSizeCodeRejected(11);
    AssertLocalSizeCodeRejected(12);
    return 0;
end;
