// PTO-TEST: {"id":"PTO-AVS-TILE-TSEL-SCHEMA-001","source":"asl/tile/elementwise-tile-tile/logical/TSEL.asl","requirements":["PTO-INST-TILE-TSEL"],"kind":"fault","summary":"TSEL requires one nonterminating mask and true-source binding followed by one terminating false-source and destination binding","pass_condition":"the canonical two-binding schema passes while early termination, scalar input, or mismatched source type rejects before allocation","related_sources":["asl/block/model/dispatch/comparison-schema.asl"]}
func ConfigureTSELSchema()
begin
    ResetProfileState();
    ConfigurePredicateTile(1, 128, 8, 2, 1, 2);
    ConfigureTile(
        2,
        128,
        8,
        2,
        1,
        2,
        TileDataType_U64,
        TileLayout_RowMajor,
        TileLocation_Any);
    ConfigureTile(
        3,
        128,
        8,
        2,
        1,
        2,
        TileDataType_U64,
        TileLayout_RowMajor,
        TileLocation_Any);
    WriteTilePredicateBit(1, 0, 0, TRUE);
    WriteTilePredicateBit(1, 0, 1, FALSE);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 10);
    WriteTileElement(2, 0, 1, Zeros{PTO_XLEN} + 11);
    WriteTileElement(3, 0, 0, Zeros{PTO_XLEN} + 20);
    WriteTileElement(3, 0, 1, Zeros{PTO_XLEN} + 21);
    let started = ExecuteCommandInstruction(
        Zeros{PTO_XLEN} + 0xc1a19181,
        32);
    assert started == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    AddBundleTileBinding(
        FALSE,
        0,
        0,
        '1111',
        TRUE,
        TRUE,
        1,
        2,
        FALSE);
    AddBundleTileBinding(
        TRUE,
        0,
        1,
        '1111',
        TRUE,
        FALSE,
        3,
        0,
        TRUE);
end;

func main() => integer
begin
    ConfigureTSELSchema();
    assert SelectedBundleClosedTSELSchemaLegal(22);

    _BundleTileBindings[[0]].last = TRUE;
    assert !SelectedBundleClosedTSELSchemaLegal(22);

    ConfigureTSELSchema();
    SetBundleScalarBinding(0, 0, 1, 0, 0, 1);
    assert !SelectedBundleClosedTSELSchemaLegal(22);

    ConfigureTSELSchema();
    _Tiles[[3]].data_type = TileDataType_U32;
    assert !SelectedBundleClosedTSELSchemaLegal(22);
    return 0;
end;
