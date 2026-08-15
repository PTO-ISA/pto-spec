// PTO-TEST: {"id":"PTO-AVS-TILE-TCI-BUNDLE-001","source":"asl/tile/irregular-and-complex/initialization/TCI.asl","requirements":["PTO-INST-TILE-TCI"],"kind":"execution","summary":"A complete TCI bundle uses omitted start and direction defaults","pass_condition":"the new U16 destination contains ascending values zero and one while physical padding remains undefined","related_sources":["asl/block/model/dispatch/generation-schema.asl","asl/block/model/dispatch/destination-shape.asl"]}
pure func TCIBundleStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00019181;
    instruction[26:25] = '11';
    instruction[24:20] = '00110';
    instruction[31:27] = Zeros{5} + 26;
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    let started = ExecuteCommandInstruction(TCIBundleStart(), 32);
    assert started == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
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
        Zeros{12} + 0x066)
        as integer {0..PTO_TILE_OPERATION_COUNT-1};
    assert BundleOperationBindingsComplete(operation);
    assert BundleOperationGPRBindingValuesLegal(operation);
    let data_attributes_legal =
        SelectedBundleTileDataAttributesLegal(operation);
    assert data_attributes_legal;
    assert SelectedBundleClosedGenerationSchemaLegal(operation);
    assert SelectedBundleTileMasksLegal();

    let completed = ExecuteBundleTileOperation();
    assert completed;
    let destination = _BundleTileBindings[[0]].destination;
    assert _Tiles[[destination]].data_type == TileDataType_U16;
    assert _Tiles[[destination]].valid_rows == 1;
    assert _Tiles[[destination]].valid_columns == 2;
    assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN};
    assert ReadTileElement(destination, 0, 1) == Zeros{PTO_XLEN} + 1;
    let padding = TileLinearIndex(_Tiles[[destination]], 1, 0);
    assert _Tiles[[destination]].defined_elements[padding] == '0';
    return 0;
end;
