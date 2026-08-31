// PTO-TEST: {"id":"PTO-AVS-TILE-TSELS-CELLREG-SCHEMA-001","source":"asl/tile/tile-scalar-and-immediate/logical/TSELS.asl","requirements":["PTO-INST-TILE-TSELS"],"kind":"fault","summary":"TSELS CellReg predicate form retains exactly one scalar-false B.IOR source","pass_condition":"the CellReg predicate form accepts its independent scalar-false source, while missing, surplus, or mixed-role B.IOR bindings reject","related_sources":["asl/block/model/dispatch/tile-scalar-schema.asl","asl/tile/model/state/allocation.asl"]}
func ConfigureTSELSCellRegSchema()
begin
    ResetProfileState();
    let predicate_configured = ConfigurePredicateCell(
        1, 128, 1, 1, TileLayout_CUBE_M32);
    let true_configured = ConfigureCubeTile(
        2, 128, 1, 1, TileDataType_FP32,
        TileLayout_CUBE_M32, TileLocation_Matrix);
    let destination_configured = ConfigureCubeTile(
        3, 128, 1, 1, TileDataType_FP32,
        TileLayout_CUBE_M32, TileLocation_Matrix);
    assert predicate_configured && true_configured && destination_configured;
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 10);
    WriteTileElement(3, 0, 0, Zeros{PTO_XLEN} + 20);
    _Tiles[[1]].contents_defined = TRUE;
    _Tiles[[2]].contents_defined = TRUE;
    _Tiles[[3]].contents_defined = TRUE;
    WriteGPR(4, Zeros{PTO_XLEN} + 99);
    let started = ExecuteCommandInstruction(
        Zeros{PTO_XLEN} + 0x0ba19181,
        32);
    assert started == CommandExecution_Executed;
    _BundleDimensionPresent[[0]] = TRUE;
    _BundleDimensions[[0]] = Zeros{PTO_XLEN} + 1;
    _BundleTileBindings[[0]].valid = TRUE;
    _BundleTileBindings[[0]].destination_valid = TRUE;
    _BundleTileBindings[[0]].destination = 3;
    _BundleTileBindings[[0]].destination_allocated_by_bundle = FALSE;
    _BundleTileBindings[[0]].destination_size = 1;
    _BundleTileBindings[[0]].pe_mask = '1111';
    _BundleTileBindings[[0]].source0_valid = TRUE;
    _BundleTileBindings[[0]].source1_valid = TRUE;
    _BundleTileBindings[[0]].source0 = 1;
    _BundleTileBindings[[0]].source1 = 2;
    _BundleTileBindings[[0]].last = TRUE;
    SetBundleScalarBinding(0, 0, 4, 0, 0, 1);
end;

func main() => integer
begin
    ConfigureTSELSCellRegSchema();
    assert SelectedBundleClosedTSELSSchemaLegal(38);

    ConfigureTSELSCellRegSchema();
    _BundleScalarBindings[[0]].valid = FALSE;
    assert !SelectedBundleClosedTSELSSchemaLegal(38);

    ConfigureTSELSCellRegSchema();
    SetBundleScalarBinding(0, 0, 4, 5, 0, 2);
    assert !SelectedBundleClosedTSELSSchemaLegal(38);

    ConfigureTSELSCellRegSchema();
    SetBundleScalarBinding(1, 0, 5, 0, 0, 1);
    assert !SelectedBundleClosedTSELSSchemaLegal(38);
    return 0;
end;
