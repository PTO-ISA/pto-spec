// PTO-TEST: {"id":"PTO-AVS-TILE-THISTOGRAM-BUNDLE-001","source":"asl/tile/irregular-and-complex/initialization/THISTOGRAM.asl","requirements":["PTO-INST-TILE-THISTOGRAM"],"kind":"execution","summary":"A complete THISTOGRAM bundle allocates the fixed U32 output shape","pass_condition":"a U16 source and explicit U32 ByteId1 attributes produce one by 256 cumulative output","related_sources":["asl/block/model/dispatch/histogram-schema.asl","asl/block/model/dispatch/destination-shape.asl"]}
pure func THISTOGRAMBundleStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00019181;
    instruction[26:25] = '11';
    instruction[24:20] = '01000';
    instruction[31:27] = Zeros{5} + 26;
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    ConfigureTile(
        16,
        128,
        16,
        4,
        1,
        2,
        TileDataType_U16,
        TileLayout_RowMajor,
        TileLocation_Any);
    ConfigureTile(
        17,
        128,
        128,
        1,
        1,
        1,
        TileDataType_U8,
        TileLayout_RowMajor,
        TileLocation_Any);
    WriteTileElement(16, 0, 0, Zeros{PTO_XLEN} + 0x0100);
    WriteTileElement(16, 0, 1, Zeros{PTO_XLEN} + 0x0200);

    let started = ExecuteCommandInstruction(THISTOGRAMBundleStart(), 32);
    assert started == CommandExecution_Executed;
    _BundleDataAttributesPresent = TRUE;
    SetBundleDataAttributeState(
        Zeros{5} + 25,
        Zeros{5},
        '01',
        Zeros{3},
        Zeros{3},
        FALSE,
        FALSE);
    AddBundleTileBinding(
        TRUE,
        0,
        4,
        '1111',
        TRUE,
        TRUE,
        16,
        17,
        TRUE);

    let operation = DecodeTileOperation(
        TileDecode_TEPL,
        Zeros{12} + 0x068)
        as integer {0..PTO_TILE_OPERATION_COUNT-1};
    assert BundleOperationBindingsComplete(operation);
    let attributes_legal = SelectedBundleTileDataAttributesLegal(operation);
    assert attributes_legal;
    assert SelectedBundleClosedHistogramSchemaLegal(operation);
    assert SelectedBundleTileMasksLegal();

    let completed = ExecuteBundleTileOperation();
    assert completed;
    let destination = _BundleTileBindings[[0]].destination;
    assert _Tiles[[destination]].data_type == TileDataType_U32;
    assert _Tiles[[destination]].valid_rows == 1;
    assert _Tiles[[destination]].valid_columns == 256;
    assert _Tiles[[destination]].columns == 256;
    assert ReadTileElement(destination, 0, 1) == Zeros{PTO_XLEN} + 1;
    assert ReadTileElement(destination, 0, 2) == Zeros{PTO_XLEN} + 2;
    return 0;
end;
