// PTO-TEST: {"id":"PTO-AVS-TILE-TCMPS-CELLREG-SCHEMA-001","source":"asl/tile/tile-scalar-and-immediate/logical/TCMPS.asl","requirements":["PTO-INST-TILE-TCMPS"],"kind":"fault","summary":"TCMPS PredicateCell scalar binding is optional and otherwise exact","pass_condition":"the PredicateCell producer accepts an omitted or one-source scalar binding, while surplus or destination-role B.IOR bindings reject","related_sources":["asl/block/model/dispatch/tile-scalar-schema.asl","asl/tile/model/state/allocation.asl"]}
func ConfigureTCMPSCellRegSchema()
begin
    ResetProfileState();
    let source_configured = ConfigureCubeTile(
        1, 128, 1, 1, TileDataType_U8,
        TileLayout_CUBE_M32, TileLocation_Matrix);
    let predicate_configured = ConfigurePredicateCell(
        2, 128, 1, 1, TileDataType_U8, TileLayout_CUBE_M32);
    assert source_configured && predicate_configured;
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 1);
    _Tiles[[1]].contents_defined = TRUE;
    _Tiles[[2]].contents_defined = TRUE;
    WriteGPR(4, Zeros{PTO_XLEN} + 3);
    let started = ExecuteCommandInstruction(
        Zeros{PTO_XLEN} + 0xdad19181,
        32);
    assert started == CommandExecution_Executed;
    _BundleDimensionPresent[[0]] = TRUE;
    _BundleDimensions[[0]] = Zeros{PTO_XLEN} + 1;
    _BundleTileBindings[[0]].valid = TRUE;
    _BundleTileBindings[[0]].destination_valid = TRUE;
    _BundleTileBindings[[0]].destination = 2;
    _BundleTileBindings[[0]].destination_allocated_by_bundle = FALSE;
    _BundleTileBindings[[0]].destination_size = 1;
    _BundleTileBindings[[0]].pe_mask = '1111';
    _BundleTileBindings[[0]].source0_valid = TRUE;
    _BundleTileBindings[[0]].source1_valid = FALSE;
    _BundleTileBindings[[0]].source0 = 1;
    _BundleTileBindings[[0]].source1 = 0;
    _BundleTileBindings[[0]].last = TRUE;
    SetBundleScalarBinding(0, 0, 4, 0, 0, 1);
end;

func main() => integer
begin
    ConfigureTCMPSCellRegSchema();
    assert SelectedBundleClosedTCMPSSchemaLegal(37);

    ConfigureTCMPSCellRegSchema();
    _BundleScalarBindings[[0]].destination = 5;
    assert !SelectedBundleClosedTCMPSSchemaLegal(37);

    ConfigureTCMPSCellRegSchema();
    SetBundleScalarBinding(1, 0, 5, 0, 0, 1);
    assert !SelectedBundleClosedTCMPSSchemaLegal(37);

    ConfigureTCMPSCellRegSchema();
    _BundleScalarBindings[[0]].valid = FALSE;
    assert SelectedBundleClosedTCMPSSchemaLegal(37);
    return 0;
end;
