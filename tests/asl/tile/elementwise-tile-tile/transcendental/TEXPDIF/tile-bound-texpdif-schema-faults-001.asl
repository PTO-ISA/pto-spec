// PTO-TEST: {"id":"PTO-AVS-TILE-TEXPDIF-SCHEMA-FAULTS-001","source":"asl/tile/elementwise-tile-tile/transcendental/TEXPDIF.asl","requirements":["PTO-INST-TILE-TEXPDIF","PTO-TEXPDIF-CONTRACT-001"],"kind":"boundary","summary":"TEXPDIF bundle schema rejects invalid attributes, dimensions, layouts, sources, and extra binding classes","pass_condition":"encoded FP64 DataType zero, missing or zero dimensions, undefined sources, mixed layouts, CUBE_N8, B.IOR, B.IOS, and extra B.IOT bindings reject; legal FP16 U16/S16 carriers pass","related_sources":["asl/block/model/dispatch/tile-schema.asl","asl/block/model/dispatch/descriptor-legality.asl","asl/block/model/dispatch/scalar-schema.asl","asl/tile/model/legality/expdif-operands.asl"]}
pure func TexdifSchemaStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00019181;
    instruction[24:20] = '11101';
    instruction[31:27] = TileDataTypeToEncoding(TileDataType_FP16);
    return instruction;
end;

pure func TexdifSchemaDATR(data_type: bits(5)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001023;
    instruction[28:27] = '11';
    instruction[24:20] = data_type;
    instruction[11:7] = Zeros{5};
    return instruction;
end;

func PrepareTexdifSchemaCase(
    source0_type: TileDataType,
    source1_type: TileDataType,
    datr_present: boolean,
    datr_data_type: bits(5),
    lb0_present: boolean,
    lb0_value: Word,
    invalid_dimension: integer {0..3},
    source_defined: boolean) => integer {0..PTO_TILE_OPERATION_COUNT-1}
begin
    ResetProfileState();
    ConfigureTile(1, 128, 16, 2, 1, 2,
        source0_type, TileLayout_RowMajor);
    ConfigureTile(2, 128, 16, 2, 1, 2,
        source1_type, TileLayout_RowMajor);
    if source_defined then
        WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 0x3c00);
        WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 0x3c00);
        WriteTileElement(2, 0, 0, Zeros{PTO_XLEN});
        WriteTileElement(2, 0, 1, Zeros{PTO_XLEN});
    end;
    let start_result = ExecuteCommandInstruction(
        TexdifSchemaStart(), 32);
    assert start_result == CommandExecution_Executed;
    if datr_present then
        let datr_result = ExecuteCommandInstruction(
            TexdifSchemaDATR(datr_data_type), 32);
        assert datr_result == CommandExecution_Executed;
    end;
    if lb0_present then
        SetBundleDimension(0, lb0_value);
    end;
    if invalid_dimension == 1 then
        SetBundleDimension(1, Zeros{PTO_XLEN});
    elsif invalid_dimension == 2 then
        SetBundleDimension(2, Zeros{PTO_XLEN});
    end;
    AddBundleTileBinding(TRUE, 0, 1, '1111',
        TRUE, TRUE, 1, 2, TRUE);
    return DecodeTileOperation(
        TileDecode_TEPL, '000000011101') as
        integer {0..PTO_TILE_OPERATION_COUNT-1};
end;

func main() => integer
begin
    let legal_carriers = PrepareTexdifSchemaCase(
        TileDataType_U16, TileDataType_S16, FALSE,
        Zeros{5}, TRUE, Zeros{PTO_XLEN} + 2, 0, TRUE);
    assert SelectedBundleClosedBinarySchemaLegal(legal_carriers);
    assert BundleOperationBindingsComplete(legal_carriers);
    _Tiles[[2]].data_type = TileDataType_FP32;
    assert !SelectedBundleClosedBinarySchemaLegal(legal_carriers);
    _Tiles[[2]].data_type = TileDataType_E2M1X2;
    assert !SelectedBundleClosedBinarySchemaLegal(legal_carriers);

    let mixed_layout = PrepareTexdifSchemaCase(
        TileDataType_FP16, TileDataType_FP16, FALSE,
        Zeros{5}, TRUE, Zeros{PTO_XLEN} + 2, 0, TRUE);
    _Tiles[[2]].layout = TileLayout_CUBE_M16;
    assert !SelectedBundleClosedBinarySchemaLegal(mixed_layout);

    let cube_n8 = PrepareTexdifSchemaCase(
        TileDataType_FP16, TileDataType_FP16, FALSE,
        Zeros{5}, TRUE, Zeros{PTO_XLEN} + 2, 0, TRUE);
    _Tiles[[1]].layout = TileLayout_CUBE_N8;
    _Tiles[[2]].layout = TileLayout_CUBE_N8;
    assert !SelectedBundleClosedBinarySchemaLegal(cube_n8);

    let fp64_zero = PrepareTexdifSchemaCase(
        TileDataType_FP16, TileDataType_FP16, TRUE,
        Zeros{5}, TRUE, Zeros{PTO_XLEN} + 2, 0, TRUE);
    assert !SelectedBundleClosedBinarySchemaLegal(fp64_zero);

    let missing_lb0 = PrepareTexdifSchemaCase(
        TileDataType_FP16, TileDataType_FP16, FALSE,
        Zeros{5}, FALSE, Zeros{PTO_XLEN}, 0, TRUE);
    assert !SelectedBundleClosedBinarySchemaLegal(missing_lb0);

    let zero_lb0 = PrepareTexdifSchemaCase(
        TileDataType_FP16, TileDataType_FP16, FALSE,
        Zeros{5}, TRUE, Zeros{PTO_XLEN}, 0, TRUE);
    assert !SelectedBundleClosedBinarySchemaLegal(zero_lb0);

    let zero_lb1 = PrepareTexdifSchemaCase(
        TileDataType_FP16, TileDataType_FP16, FALSE,
        Zeros{5}, TRUE, Zeros{PTO_XLEN} + 2, 1, TRUE);
    assert !SelectedBundleClosedBinarySchemaLegal(zero_lb1);

    let zero_lb2 = PrepareTexdifSchemaCase(
        TileDataType_FP16, TileDataType_FP16, FALSE,
        Zeros{5}, TRUE, Zeros{PTO_XLEN} + 2, 2, TRUE);
    assert !SelectedBundleClosedBinarySchemaLegal(zero_lb2);

    let undefined_source = PrepareTexdifSchemaCase(
        TileDataType_FP16, TileDataType_FP16, FALSE,
        Zeros{5}, TRUE, Zeros{PTO_XLEN} + 2, 0, FALSE);
    assert !SelectedBundleClosedBinarySchemaLegal(undefined_source);

    let ior = PrepareTexdifSchemaCase(
        TileDataType_FP16, TileDataType_FP16, FALSE,
        Zeros{5}, TRUE, Zeros{PTO_XLEN} + 2, 0, TRUE);
    SetBundleScalarBinding(0, 0, 0, 0, 0, 0);
    assert !BundleOperationBindingsComplete(ior);

    let ios = PrepareTexdifSchemaCase(
        TileDataType_FP16, TileDataType_FP16, FALSE,
        Zeros{5}, TRUE, Zeros{PTO_XLEN} + 2, 0, TRUE);
    BindBundleSharedIO(Zeros{6}, 1, '1111');
    assert !SelectedBundleClosedBinarySchemaLegal(ios);

    let extra_iot = PrepareTexdifSchemaCase(
        TileDataType_FP16, TileDataType_FP16, FALSE,
        Zeros{5}, TRUE, Zeros{PTO_XLEN} + 2, 0, TRUE);
    _BundleTileBindings[[0]].last = FALSE;
    AddBundleTileBinding(TRUE, 3, 1, '1111',
        TRUE, TRUE, 1, 2, TRUE);
    assert !SelectedBundleClosedBinarySchemaLegal(extra_iot);
    return 0;
end;
