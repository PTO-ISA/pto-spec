// PTO-TEST: {"id":"PTO-AVS-BLOCK-QUANTIZATION-SCHEMA-001","source":"asl/block/model/dispatch/quantization-schema.asl","requirements":[],"kind":"boundary","summary":"The quantization bundle schema requires one terminating Local source-destination binding and an explicit destination type","pass_condition":"a complete FP32 to S8 TQUANT schema is legal and becomes illegal when B.DATR is absent","related_sources":["asl/block/model/dispatch/scalar-schema.asl","asl/block/model/dispatch/destination-shape.asl"]}
pure func QuantizationSchemaStart(
    selector: bits(10),
    data_type: bits(5)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00019181;
    instruction[26:25] = selector[6:5];
    instruction[24:20] = selector[4:0];
    instruction[31:27] = data_type;
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    ConfigureTile(
        1,
        128,
        16,
        2,
        1,
        2,
        TileDataType_FP32,
        TileLayout_RowMajor,
        TileLocation_Any);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 0x3f800000);
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 0x40000000);

    let started = ExecuteCommandInstruction(
        QuantizationSchemaStart(Zeros{10} + 0x06a, Zeros{5} + 1),
        32);
    assert started == CommandExecution_Executed;
    SetBundleDataAttributeState(
        Zeros{5} + 19,
        Zeros{5},
        Zeros{2},
        Zeros{3},
        Zeros{3},
        FALSE,
        FALSE);
    _BundleDataAttributesPresent = TRUE;
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

    let operation = DecodeTileOperation(
        TileDecode_TEPL,
        Zeros{12} + 0x06a)
        as integer {0..PTO_TILE_OPERATION_COUNT-1};
    assert SelectedBundleClosedQuantizationSchemaLegal(operation);
    _BundleDataAttributesPresent = FALSE;
    assert !SelectedBundleClosedQuantizationSchemaLegal(operation);
    return 0;
end;
