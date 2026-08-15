// PTO-TEST: {"id":"PTO-AVS-BLOCK-THISTOGRAM-SCHEMA-001","source":"asl/block/model/dispatch/histogram-schema.asl","requirements":["PTO-INST-TILE-THISTOGRAM"],"kind":"boundary","summary":"The THISTOGRAM bundle schema requires explicit U32 output attributes","pass_condition":"the exact U16 source U8 filter destination schema is legal and omission of B.DATR is illegal","related_sources":["asl/block/model/dispatch/destination-shape.asl","asl/tile/model/legality/indexed-layout.asl"]}
pure func THISTOGRAMSchemaStart() => bits(64)
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
    WriteTileElement(16, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(16, 0, 1, Zeros{PTO_XLEN});

    let started = ExecuteCommandInstruction(THISTOGRAMSchemaStart(), 32);
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
    assert SelectedBundleClosedHistogramSchemaLegal(operation);
    _BundleDataAttributesPresent = FALSE;
    assert !SelectedBundleClosedHistogramSchemaLegal(operation);
    return 0;
end;
