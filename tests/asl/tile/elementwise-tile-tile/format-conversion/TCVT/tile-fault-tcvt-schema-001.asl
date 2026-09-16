// PTO-TEST: {"id":"PTO-AVS-TILE-TCVT-SCHEMA-001","source":"asl/tile/elementwise-tile-tile/format-conversion/TCVT.asl","requirements":["PTO-INST-TILE-TCVT","PTO-TCVT-CONTRACT-001"],"kind":"fault","summary":"TCVT accepts exactly one typed Local source and one new terminating Local destination","pass_condition":"the canonical schema passes while B.IOR, a second source, a source-type mismatch, explicit zero LB0, or an unsupported E6M2/RCPE6M2 RMode rejects before allocation and source effects","related_sources":["asl/block/model/dispatch/tile-schema.asl","asl/block/model/dispatch/tcvt-schema.asl","asl/block/model/dispatch/tile-execution.asl"]}
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
        TileLayout_RowMajor);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 4);
    let started = ExecuteCommandInstruction(
        Zeros{PTO_XLEN} + 0xd9b19181,
        32);
    assert started == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 2);
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

func AssertUnsupportedProfileRModeRejected(
    operation_type: TileDataType,
    source_type: TileDataType,
    destination_type: TileDataType,
    source_value: Word,
    start_encoding: Word)
begin
    ResetProfileState();
    ConfigureTile(
        1,
        128,
        64,
        2,
        1,
        2,
        source_type,
        TileLayout_RowMajor);
    WriteTileElement(1, 0, 0, source_value);
    WriteTileElement(1, 0, 1, source_value);
    let started = ExecuteCommandInstruction(start_encoding, 32);
    assert started == CommandExecution_Executed;
    assert TileDataTypeFromEncoding(
        _BundleOperation.data_type as TileDataTypeEncoding) == operation_type;
    SetBundleDataAttributeState(
        TileDataTypeToEncoding(destination_type),
        Zeros{5}, '00', Zeros{3}, Zeros{3} + 2, FALSE, FALSE);
    _BundleDataAttributesPresent = TRUE;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 2);
    AddBundleTileBinding(
        TRUE, 0, 1, '1111', TRUE, FALSE, 1, 0, TRUE);
    let capacity_before = TileCapacityInUse();
    assert !SelectedBundleClosedTCVTSchemaLegal(23);
    assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;
    let completed = ExecuteBundleTileOperation();
    assert !completed;
    assert _LastFault == Fault_TileLegality;
    assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;
    assert TileCapacityInUse() == capacity_before;
    assert ReadTileElement(1, 0, 0) == source_value;
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
    _BundleDimensions[[0]] = Zeros{PTO_XLEN};
    assert !SelectedBundleClosedTCVTSchemaLegal(23);
    AssertUnsupportedProfileRModeRejected(
        TileDataType_BF16, TileDataType_BF16, TileDataType_E6M2,
        Zeros{PTO_XLEN} + 0x3fc0,
        Zeros{PTO_XLEN} + 0x29b19181);
    AssertUnsupportedProfileRModeRejected(
        TileDataType_RCPE6M2, TileDataType_E6M2, TileDataType_FP16,
        Zeros{PTO_XLEN} + 0xc0,
        Zeros{PTO_XLEN} + 0xa9b19181);
    return 0;
end;
