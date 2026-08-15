// PTO-TEST: {"id":"PTO-AVS-TILE-TCVT-SCHEMA-001","source":"asl/tile/elementwise-tile-tile/format-conversion/TCVT.asl","requirements":["PTO-INST-TILE-TCVT"],"kind":"fault","summary":"TCVT accepts exactly one typed Local source and one new terminating Local destination","pass_condition":"the canonical schema passes while B.IOR, a second source, a source-type mismatch, or missing LB0 rejects before allocation","related_sources":["asl/block/model/dispatch/tile-schema.asl","asl/block/model/dispatch/tile-execution.asl"]}
func ConfigureTCVTSchema()
begin
    ResetProfileState();
    ConfigureTile(
        1,
        128,
        64,
        2,
        1,
        2,
        TileDataType_U8,
        TileLayout_RowMajor,
        TileLocation_Any);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 4);
    let started = ExecuteCommandInstruction(
        Zeros{PTO_XLEN} + 0xd9b19181,
        32);
    assert started == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    AddBundleTileBinding(
        TRUE,
        0,
        1,
        '1111',
        TRUE,
        FALSE,
        1,
        0,
        TRUE);
end;

func main() => integer
begin
    ConfigureTCVTSchema();
    assert SelectedBundleClosedTCVTSchemaLegal(23);

    SetBundleScalarBinding(0, 0, 1, 0, 0, 1);
    assert !SelectedBundleClosedTCVTSchemaLegal(23);

    ConfigureTCVTSchema();
    _BundleTileBindings[[0]].source1_valid = TRUE;
    assert !SelectedBundleClosedTCVTSchemaLegal(23);

    ConfigureTCVTSchema();
    _Tiles[[1]].data_type = TileDataType_U16;
    assert !SelectedBundleClosedTCVTSchemaLegal(23);

    ConfigureTCVTSchema();
    _BundleDimensionPresent[[0]] = FALSE;
    assert !SelectedBundleClosedTCVTSchemaLegal(23);
    return 0;
end;
