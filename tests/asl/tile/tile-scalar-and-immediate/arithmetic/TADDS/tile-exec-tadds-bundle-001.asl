// PTO-TEST: {"id":"PTO-AVS-TILE-TADDS-BUNDLE-001","source":"asl/tile/tile-scalar-and-immediate/arithmetic/TADDS.asl","requirements":["PTO-INST-TILE-TADDS"],"kind":"execution","summary":"TADDS resolves RegSrc0 and publishes one renamed Local destination","pass_condition":"the selected private GPR scalar is added to both source elements and the source persists","related_sources":["asl/block/model/dispatch/tile-scalar-schema.asl","asl/block/model/dispatch/destination-shape.asl"]}
func main() => integer
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
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 7);
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 9);
    WriteGPR(2, Zeros{PTO_XLEN} + 5);

    let started = ExecuteCommandInstruction(
        Zeros{PTO_XLEN} + 0xc2019181,
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
    SetBundleScalarBinding(0, 0, 2, 0, 0, 3);

    let operation = DecodeTileOperation(
        TileDecode_TEPL,
        Zeros{12} + 0x020)
        as integer {0..PTO_TILE_OPERATION_COUNT-1};
    assert BundleOperationBindingsComplete(operation);
    assert BundleOperationGPRBindingValuesLegal(operation);
    let attributes_legal =
        SelectedBundleTileDataAttributesLegal(operation);
    assert attributes_legal;
    assert SelectedBundleClosedTileScalarBinarySchemaLegal(operation);
    assert SelectedBundleTileMasksLegal();

    let completed = ExecuteBundleTileOperation();
    assert completed;
    let destination = _BundleTileBindings[[0]].destination;
    assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN} + 12;
    assert ReadTileElement(destination, 0, 1) == Zeros{PTO_XLEN} + 14;
    assert ReadTileElement(1, 0, 0) == Zeros{PTO_XLEN} + 7;
    return 0;
end;
