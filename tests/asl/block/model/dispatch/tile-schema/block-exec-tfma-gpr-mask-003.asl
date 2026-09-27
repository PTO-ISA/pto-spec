// PTO-TEST: {"id":"PTO-AVS-BLOCK-TFMA-GPR-EXECUTION-MASK-003","source":"asl/block/model/dispatch/tile-schema.asl","requirements":["PTO-TFMA-CONTRACT-001","PTO-TILE-MODEL-EXECUTION-MASK-APPLICABILITY-001","PTO-B-IOR-BINDING-001"],"kind":"execution","summary":"A decoded Local CUBE TFMA accepts a validated GPR ExecutionMask binding without admitting operation-owned scalar operands.","pass_condition":"A final-record GPR mask carrier passes the TFMA closed schema and executes, while an otherwise identical unmarked B.IOR remains illegal.","related_sources":["asl/block/model/dispatch/execution-mask-schema.asl","asl/block/model/dispatch/scalar-schema.asl"]}
pure func TFMAMaskStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00019181;
    instruction[26:25] = '00';
    instruction[24:20] = '11100';
    instruction[31:27] = TileDataTypeToEncoding(TileDataType_U32);
    return instruction;
end;

pure func TFMAMaskAttributes() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001023;
    instruction[24:20] = DTYPE_NONE;
    instruction[11:7] = Zeros{5} + 31;
    instruction[13] = '1';
    return instruction;
end;

pure func TFMAMaskIOR(source0: bits(5), present: boolean) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000013;
    instruction[19:15] = source0;
    instruction[26] = if present then '1' else '0';
    return instruction;
end;

func PrepareDecodedTFMAMaskBundle(mask_present: boolean)
begin
    ResetProfileState();
    let left_ready = ConfigureCubeTile(
        1, 128, 1, 1, TileDataType_U32, TileLayout_CUBE_M16);
    let right_ready = ConfigureCubeTile(
        2, 128, 1, 1, TileDataType_U32, TileLayout_CUBE_M16);
    let addend_ready = ConfigureCubeTile(
        3, 128, 1, 1, TileDataType_U32, TileLayout_CUBE_M16);
    assert left_ready && right_ready && addend_ready;
    InstallRelativeTileFixture(1, 1);
    InstallRelativeTileFixture(2, 2);
    InstallRelativeTileFixture(3, 3);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 2);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(3, 0, 0, Zeros{PTO_XLEN} + 4);
    MarkTileValidRegionDefined(1);
    MarkTileValidRegionDefined(2);
    MarkTileValidRegionDefined(3);
    WritePEGPR(0, 2, Ones{PTO_XLEN});

    let started = ExecuteCommandInstruction(TFMAMaskStart(), 32);
    let attributed = ExecuteCommandInstruction(TFMAMaskAttributes(), 32);
    let masked = ExecuteCommandInstruction(
        TFMAMaskIOR(Zeros{5} + 2, mask_present), 32);
    assert started == CommandExecution_Executed;
    assert attributed == CommandExecution_Executed;
    assert masked == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    AddBundleTileBinding(
        FALSE, 0, 0, '1111', TRUE, TRUE, 1, 2, FALSE);
    AddBundleTileBinding(
        TRUE, 0, 1, '1111', TRUE, FALSE, 3, 0, TRUE);
end;

func main() => integer
begin
    let operation = DecodeTileOperation(
        TileDecode_TEPL, Zeros{12} + 0x01c)
        as integer {0..PTO_TILE_OPERATION_COUNT-1};

    PrepareDecodedTFMAMaskBundle(TRUE);
    assert BundleExecutionMaskGPRBindingSchemaLegal(operation);
    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
    let destination = _BundleTileBindings[[1]].destination;
    assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN} + 10;

    PrepareDecodedTFMAMaskBundle(FALSE);
    assert !BundleExecutionMaskGPRBindingSchemaLegal(operation);
    assert !SelectedBundleClosedTFMASchemaLegal(operation);
    return 0;
end;
