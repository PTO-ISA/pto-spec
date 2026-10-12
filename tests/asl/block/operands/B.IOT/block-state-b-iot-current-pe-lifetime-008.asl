// PTO-TEST: {"id":"PTO-AVS-BLOCK-B-IOT-CURRENT-PE-LIFETIME-008","source":"asl/block/operands/B.IOT.asl","requirements":["PTO-B-IOT-STREAM-001","PTO-ARCH-LOCAL-VTAG-LIFETIME-001","PTO-ARCH-PE-EXECUTION-CONTEXT-001"],"kind":"state-transition","summary":"An encoded B.IOT last-use affects only the executing PE when that PE participates.","pass_condition":"A PE1-only encoded binding neither requires PE0 payload nor consumes PE1 payload while PE0 executes its Local bank.","related_sources":["asl/block/model/operands/tile-bindings.asl"]}
pure func CurrentPELifetimeB_IOT() => bits(64)
begin
    var instruction = Zeros{64} + 0x04005013;
    instruction[19] = '1';
    instruction[11:9] = '010';
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    SelectExecutionContext(0, 0);
    ConfigureTileForMask(7, 128, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor, '1100');
    InstallRelativeTileFixture(0, 7);
    ConsumeTilePayloadForMask(7, '1000');
    assert _TilePayloadLiveMasks[[7]] == '0100';

    var start: bits(64) = Zeros{64} + 0x00031181;
    start[31:27] = Zeros{5} + 26;
    let started = ExecuteCommandInstruction(start, 32);
    let bound = ExecuteCommandInstruction(CurrentPELifetimeB_IOT(), 32);
    assert started == CommandExecution_Executed;
    assert bound == CommandExecution_Executed;
    let resolved = ResolveBundleRelativeTileSources();
    assert resolved;
    assert _BundleTileBindings[[0]].source0 == 7;
    let payload_available = RequireBundleTileSourcePayloads();
    assert payload_available;

    FinalizeBundleTileAttempt(TileExecution_Executed);
    assert _TilePayloadLiveMasks[[7]] == '0100';
    return 0;
end;
