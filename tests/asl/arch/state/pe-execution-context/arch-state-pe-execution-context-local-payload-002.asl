// PTO-TEST: {"id":"PTO-AVS-ARCH-PE-LOCAL-PAYLOAD-002","source":"asl/arch/state/pe-execution-context.asl","requirements":["PTO-ARCH-PE-EXECUTION-CONTEXT-001","PTO-REQ-TILE-001","PTO-ARCH-LOCAL-VTAG-LIFETIME-001"],"kind":"state-transition","summary":"Each PE context banks Local payload-live state and payload identity independently.","pass_condition":"Last-use by PE0 clears only PE0's saved Local payload state; exact-generation peer consumption clears PE1, and a stale completion cannot consume PE1 after the physical slot receives a newer identity.","related_sources":["asl/block/model/operands/tile-bindings.asl","asl/tile/model/state/local-registers.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTileForMask(7, 128, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor, '1100');
    InstallRelativeTileFixture(0, 7);

    SelectExecutionContext(0, 0);
    AddBundleTileBindingWithReuse(FALSE, 0, 0, '1100',
        TRUE, FALSE, 7, 0, FALSE, TRUE, TRUE);
    FinalizeBundleTileAttempt(TileExecution_Executed);
    assert _TilePayloadLiveMasks[[7]] == '0100';

    SelectExecutionContext(0, 1);
    assert _Tiles[[7]].allocated;
    assert _TilePayloadLiveMasks[[7]] == '1100';
    assert RelativeTileSourceAvailable(0);
    let pe1_generation = LocalTilePayloadGeneration(1, 7);

    SelectExecutionContext(0, 0);
    assert _Tiles[[7]].allocated;
    assert _TilePayloadLiveMasks[[7]] == '0100';
    assert RelativeTileSourceAvailable(0);

    ConsumeLocalTilePayloadGeneration(1, 7, pe1_generation);
    SelectExecutionContext(0, 1);
    assert _TilePayloadLiveMasks[[7]] == '1000';
    ConfigureTileForMask(7, 128, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor, '1100');
    assert LocalTilePayloadGeneration(1, 7) > pe1_generation;
    assert _TilePayloadLiveMasks[[7]] == '1100';

    SelectExecutionContext(0, 0);
    ConsumeLocalTilePayloadGeneration(1, 7, pe1_generation);
    SelectExecutionContext(0, 1);
    assert _TilePayloadLiveMasks[[7]] == '1100';
    return 0;
end;
