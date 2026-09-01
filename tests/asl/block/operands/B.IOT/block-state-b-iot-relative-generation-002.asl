// PTO-TEST: {"id":"PTO-AVS-BLOCK-B-IOT-RELATIVE-GENERATION-002","source":"asl/block/operands/B.IOT.asl","requirements":["PTO-B-IOT-STREAM-001","PTO-REQ-TILE-001","PTO-INST-BLOCK-B-IOT"],"kind":"state-transition","summary":"B.IOT resolves each Local source relative to the newest published generation of its T/U/M/N hand.","pass_condition":"Publishing two new T destinations makes them T#1 then T#1/T#2 while preserving the older source as T#3, and decoded B.IOT T#1 binds the newest physical Tile.","related_sources":["asl/tile/model/state/descriptors.asl","asl/block/model/dispatch/decode.asl"]}
pure func RelativeGenerationStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00511181;
    instruction[31:27] = Zeros{5} + 27;
    return instruction;
end;

pure func RelativeGenerationSource(raw_source: bits(6)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[25:20] = raw_source;
    instruction[19] = '1';
    instruction[11:9] = '001';
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    ConfigureTile(0, 128, 1, 1, 1, 1, TileDataType_U8,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTileForMask(1, 128, 1, 1, 1, 1, TileDataType_U8,
        TileLayout_RowMajor, TileLocation_Any, '0001');
    ConfigureTileForMask(2, 128, 1, 1, 1, 1, TileDataType_U8,
        TileLayout_RowMajor, TileLocation_Any, '0001');

    assert ResolveRelativeTileSource(0) == 0;
    PublishRelativeTileDestination(1);
    PublishRelativeTileDestination(2);
    assert ResolveRelativeTileSource(0) == 2;
    assert ResolveRelativeTileSource(1) == 1;
    assert ResolveRelativeTileSource(2) == 0;
    assert _Tiles[[0]].allocated && _Tiles[[1]].allocated &&
           _Tiles[[2]].allocated;

    let started = ExecuteCommandInstruction(RelativeGenerationStart(), 32);
    assert started == CommandExecution_Executed;
    let bound = ExecuteCommandInstruction(
        RelativeGenerationSource(Zeros{6}), 32);
    assert bound == CommandExecution_Executed;
    assert _BundleTileBindings[[0]].source0_relative;
    let resolved = ResolveBundleRelativeTileSources();
    assert resolved;
    assert _BundleTileBindings[[0]].source0 == 2;
    return 0;
end;
