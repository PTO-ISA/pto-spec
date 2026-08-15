// PTO-TEST: {"id":"PTO-AVS-TILE-TCMP-SCHEMA-001","source":"asl/tile/elementwise-tile-tile/logical/TCMP.asl","requirements":["PTO-INST-TILE-TCMP"],"kind":"fault","summary":"TCMP accepts exactly two typed Local sources and one new terminating predicate destination","pass_condition":"the canonical binding passes while scalar input, an unsupported type, or a missing dimension rejects before allocation","related_sources":["asl/block/model/dispatch/comparison-schema.asl"]}
func ConfigureTCMPSchema()
begin
    ResetProfileState();
    ConfigureTile(
        1,
        128,
        8,
        2,
        1,
        2,
        TileDataType_U64,
        TileLayout_RowMajor,
        TileLocation_Any);
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
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 4);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 5);
    WriteTileElement(2, 0, 1, Zeros{PTO_XLEN} + 6);
    let started = ExecuteCommandInstruction(
        Zeros{PTO_XLEN} + 0xc0d19181,
        32);
    assert started == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    AddBundleTileBinding(
        TRUE,
        0,
        1,
        '1111',
        TRUE,
        TRUE,
        1,
        2,
        TRUE);
end;

func main() => integer
begin
    ConfigureTCMPSchema();
    assert SelectedBundleClosedTCMPSchemaLegal(12);

    SetBundleScalarBinding(0, 0, 1, 0, 0, 1);
    assert !SelectedBundleClosedTCMPSchemaLegal(12);

    ConfigureTCMPSchema();
    _Tiles[[2]].data_type = TileDataType_HiF8;
    assert !SelectedBundleClosedTCMPSchemaLegal(12);

    ConfigureTCMPSchema();
    _BundleDimensionPresent[[0]] = FALSE;
    assert !SelectedBundleClosedTCMPSchemaLegal(12);
    return 0;
end;
