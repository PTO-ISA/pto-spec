// PTO-TEST: {"id":"PTO-AVS-TILE-TTRI-LB2-DEFAULT-001","source":"asl/tile/irregular-and-complex/initialization/TTRI.asl","requirements":["PTO-INST-TILE-TTRI","PTO-BUNDLE-DIMENSION-DEFAULT-001"],"kind":"execution","summary":"An omitted B.DIM LB2 selects ValidCol as the TTRI physical column count","pass_condition":"decoded RowMajor TTRI with LB0 greater than one and LB2 omitted executes without fault and publishes matching valid and physical columns","related_sources":["asl/block/model/dispatch/generation-schema.asl","asl/block/model/dispatch/destination-shape.asl","asl/block/model/schema/dimensions.asl"]}
pure func TTRILB2DefaultBundleStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00019181;
    instruction[26:25] = '11';
    instruction[24:20] = '00111';
    instruction[31:27] = Zeros{5} + 4;
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    let started = ExecuteCommandInstruction(TTRILB2DefaultBundleStart(), 32);
    assert started == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 4);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 2);
    AddBundleTileBinding(
        TRUE,
        0,
        1,
        '1111',
        FALSE,
        FALSE,
        0,
        0,
        TRUE);

    let operation = DecodeTileOperation(
        TileDecode_TEPL,
        Zeros{12} + 0x067)
        as integer {0..PTO_TILE_OPERATION_COUNT-1};
    assert BundleOperationBindingsComplete(operation);
    assert BundleOperationGPRBindingValuesLegal(operation);
    let data_attributes_legal =
        SelectedBundleTileDataAttributesLegal(operation);
    assert data_attributes_legal;
    assert SelectedBundleClosedGenerationSchemaLegal(operation);
    assert SelectedBundleTileMasksLegal();

    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
    let destination = _BundleTileBindings[[0]].destination;
    assert _Tiles[[destination]].valid_rows == 2;
    assert _Tiles[[destination]].valid_columns == 4;
    assert _Tiles[[destination]].columns == 4;
    assert ReadTileElement(destination, 0, 0) ==
        Zeros{PTO_XLEN} + 0x3c00;
    assert ReadTileElement(destination, 0, 1) == Zeros{PTO_XLEN};
    assert ReadTileElement(destination, 1, 1) ==
        Zeros{PTO_XLEN} + 0x3c00;
    return 0;
end;
