// PTO-TEST: {"id":"PTO-AVS-BLOCK-B-IOT-LAST-USE-RETAIN-DOMINANT-003","source":"asl/block/operands/B.IOT.asl","requirements":["PTO-B-IOT-STREAM-001","PTO-ARCH-LOCAL-VTAG-LIFETIME-001","PTO-INST-BLOCK-B-IOT"],"kind":"state-transition","summary":"Duplicate B.IOT source occurrences aggregate lifetime markers with retain dominance.","pass_condition":"One reuse occurrence preserves the selected-PE payload despite another last-use occurrence, while all-last-use duplicates consume it once without removing the vtag.","related_sources":["asl/block/model/operands/tile-bindings.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTileForMask(7, 128, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor, '1100');
    InstallRelativeTileFixture(0, 7);

    AddBundleTileBindingWithReuse(FALSE, 0, 0, '1100',
        TRUE, FALSE, 7, 0, FALSE, TRUE, FALSE);
    AddBundleTileBindingWithReuse(FALSE, 0, 0, '1000',
        TRUE, FALSE, 7, 0, TRUE, TRUE, TRUE);
    FinalizeBundleTileAttempt(TileExecution_Executed);
    assert _TilePayloadLiveMasks[[7]] == '1000';

    ClearBundleHeaderState();
    AddBundleTileBindingWithReuse(FALSE, 0, 0, '1000',
        TRUE, FALSE, 7, 0, FALSE, TRUE, FALSE);
    AddBundleTileBindingWithReuse(FALSE, 0, 0, '1000',
        TRUE, FALSE, 7, 0, FALSE, TRUE, TRUE);
    FinalizeBundleTileAttempt(TileExecution_Executed);
    assert _TilePayloadLiveMasks[[7]] == '0000';
    assert RelativeTileSourceAvailable(0);
    assert ResolveRelativeTileSource(0) == 7;
    return 0;
end;
