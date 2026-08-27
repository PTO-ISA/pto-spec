// PTO-TEST: {"id":"PTO-AVS-BLOCK-TMATMUL-MISSING-FPATR-001","source":"asl/block/model/dispatch/cube-tmatmul.asl","requirements":["PTO-INST-BLOCK-B-FPATR","PTO-TMATMUL-CONTRACT-001"],"kind":"fault","summary":"participating TMATMUL rejects a missing B.FPATR before consuming or allocating","pass_condition":"Fault_BundleControl preserves the Shared source and unresolved Local destination","related_sources":["asl/block/attributes/B.FPATR.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(1, 128, 1, 1, 1, 1, TileDataType_U16,
        TileLayout_RowMajor, TileLocation_Matrix);
    ConfigureTile(2, 128, 1, 1, 1, 1, TileDataType_U8,
        TileLayout_RowMajor, TileLocation_Matrix);
    MarkTileValidRegionDefined(2);
    InstallSharedTile((Zeros{6} + 31) as SharedTileID, _Tiles[[2]], '1111');
    var start: bits(64) = Zeros{64} + 0x00031181;
    start[31:27] = Zeros{5} + 26;
    let start_result = ExecuteCommandInstruction(start, 32);
    assert start_result == CommandExecution_Executed;
    SetBundleDataAttributeState(
        Zeros{5} + 27, Zeros{5}, Zeros{2}, Zeros{3}, Zeros{3},
        FALSE, FALSE);
    _BundleDataAttributesPresent = TRUE;
    BindBundleSharedIO((Zeros{6} + 31) as SharedTileID, 0, '1111');
    AddBundleTileBinding(
        TRUE, 0, 1, '1111', TRUE, FALSE, 1, 0, TRUE);

    let completed = ExecuteBundleTileOperation();
    assert !completed;
    assert _LastFault == Fault_BundleControl;
    assert !_BundleSharedBindings[[0]].consumed;
    assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;
    return 0;
end;
