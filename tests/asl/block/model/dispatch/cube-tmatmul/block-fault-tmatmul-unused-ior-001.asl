// PTO-TEST: {"id":"PTO-AVS-BLOCK-TMATMUL-UNUSED-IOR-001","source":"asl/block/model/dispatch/cube-tmatmul.asl","requirements":["PTO-TMATMUL-CONTRACT-001"],"kind":"fault","summary":"plain TMATMUL rejects a nonzero unused scalar binding before effects","pass_condition":"Fault_TileLegality preserves the Shared source and unresolved destination","related_sources":["asl/block/model/dispatch/scalar-schema.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(1, 128, 1, 1, 1, 1, TileDataType_U16,
        TileLayout_RowMajor, TileLocation_Matrix);
    ConfigureTile(2, 128, 1, 1, 1, 1, TileDataType_U8,
        TileLayout_RowMajor, TileLocation_Matrix);
    MarkTileValidRegionDefined(2);
    InstallSharedTile((Zeros{6} + 30) as SharedTileID, _Tiles[[2]], '1111');
    var start: bits(64) = Zeros{64} + 0x00031181;
    start[31:27] = Zeros{5} + 26;
    let start_result = ExecuteCommandInstruction(start, 32);
    assert start_result == CommandExecution_Executed;
    SetBundleDataAttributeState(
        Zeros{5} + 27, Zeros{5}, Zeros{2}, Zeros{3}, Zeros{3},
        FALSE, FALSE);
    _BundleDataAttributesPresent = TRUE;
    SetBundleFixedPointAttributeState(
        Zeros{6}, Zeros{3}, Zeros{4}, FALSE, FALSE, FALSE, FALSE);
    BindBundleSharedIO((Zeros{6} + 30) as SharedTileID, 0, '1111');
    SetBundleScalarBinding(0, 0, 2, 0, 0, 1);
    AddBundleTileBinding(
        TRUE, 0, 1, '1111', TRUE, FALSE, 1, 0, TRUE);

    let completed = ExecuteBundleTileOperation();
    assert !completed;
    assert _LastFault == Fault_TileLegality;
    assert !_BundleSharedBindings[[0]].consumed;
    assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;
    return 0;
end;
