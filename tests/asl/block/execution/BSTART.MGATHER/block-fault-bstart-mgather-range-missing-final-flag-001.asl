// PTO-TEST: {"id":"PTO-AVS-BLOCK-I414-MALFORMED-MISSING-FINAL-FLAG-001","source":"asl/block/execution/BSTART.MGATHER.asl","requirements":["PTO-INDEXED-TLSU-RANGE-BINDING-001","PTO-B-IOR-BINDING-001","PTO-BSTART-MGATHER-SCHEMA-001"],"kind":"fault","summary":"missing final ExecMaskPresent in an otherwise valid combined CUBE mask","pass_condition":"A legal positive control executes the encoded U8 CUBE range-plus-two-word GPR mask. Changing only the final mask record ExecMaskPresent to zero produces a pre-effect TileLegality fault.","related_sources":["asl/block/model/dispatch/commands.asl","asl/block/model/dispatch/indexed-tlsu-range-command-stream.asl","asl/block/model/dispatch/indexed-tlsu-range-schema.asl","asl/block/model/dispatch/scalar-schema.asl"]}
pure func I414MalformedStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00411181;
    instruction[31:27] = TileDataTypeToEncoding(TileDataType_U8);
    return instruction;
end;

pure func I414MalformedAttributes() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001023;
    instruction[24:20] = DTYPE_NONE;
    instruction[11:7] = Zeros{5} + 31;
    instruction[13] = '1';
    return instruction;
end;

pure func I414MalformedInput() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[25:20] = Zeros{6} + 10;
    instruction[19] = '1';
    instruction[18:15] = '0011';
    instruction[11:9] = '001';
    return instruction;
end;

pure func I414MalformedIOR(source0: integer, source1: integer,
    source2: integer, destination: integer, mask_flag: boolean) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000013;
    instruction[19:15] = Zeros{5} + source0;
    instruction[24:20] = Zeros{5} + source1;
    instruction[31:27] = Zeros{5} + source2;
    instruction[11:7] = Zeros{5} + destination;
    instruction[26] = if mask_flag then '1' else '0';
    return instruction;
end;

func PrepareI414MalformedGather()
begin
    ResetProfileState();
    let ready = ConfigureCubeTile(10, 2048, 1, 8, TileDataType_U32,
        TileLayout_CUBE_M16);
    assert ready;
    for column = 0 to 7 looplimit 8 do
        WriteTileElement(10, 0, column as integer {0..65535},
            if column == 4 then Zeros{PTO_XLEN} + 4
            else if column == 0 then Zeros{PTO_XLEN}
            else Zeros{PTO_XLEN} + 1000);
    end;
    Store(Zeros{PTO_XLEN} + 0x900, 1, Zeros{PTO_XLEN} + 11);
    Store(Zeros{PTO_XLEN} + 0x904, 1, Zeros{PTO_XLEN} + 55);
    WritePEGPR(0, 2, Zeros{64} + 0x900);
    WritePEGPR(0, 3, Zeros{64});
    WritePEGPR(0, 4, Zeros{64} + 4);
    WritePEGPR(0, 5, Zeros{64} + 1);
    WritePEGPR(0, 6, Zeros{64} + 1);
    let started = ExecuteCommandInstruction(I414MalformedStart(), 32);
    let attributes = ExecuteCommandInstruction(
        I414MalformedAttributes(), 32);
    assert started == CommandExecution_Executed;
    assert attributes == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 8);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, NaturalToWord(_Tiles[[10]].columns));
    let input = ExecuteCommandInstruction(I414MalformedInput(), 32);
    assert input == CommandExecution_Executed;
end;

func AssertI414MalformedPositiveControl()
begin
    PrepareI414MalformedGather();
    let descriptor = ExecuteCommandInstruction(
        I414MalformedIOR(2, 3, 4, 0, FALSE), 32);
    let final_mask = ExecuteCommandInstruction(
        I414MalformedIOR(5, 6, 0, 0, TRUE), 32);
    assert descriptor == CommandExecution_Executed &&
           final_mask == CommandExecution_Executed;
    let decoded = DecodeTileOperation(TileDecode_TLSU,
        BundleOperationDecodeCode(_BundleOperation));
    let operation = decoded as integer
        {0..PTO_TILE_OPERATION_COUNT-1};
    assert BundleOperationBindingsComplete(operation);
    assert BundleOperationScalarBindingSchemaLegal(operation);
    assert BundleOperationGPRBindingValuesLegal(operation);
    assert BundleExecutionMaskGPRCarrierShapeLegal(operation);
    StartMemoryEventCapture(0);
    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
    assert _MemoryEventCount == 2;
    assert _MemoryEvents[[0]].address == Zeros{PTO_XLEN} + 0x900;
    assert _MemoryEvents[[1]].address == Zeros{PTO_XLEN} + 0x904;
    StopMemoryEventCapture();
    let destination = _BundleTileBindings[[0]].destination;
    assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN} + 11;
    assert ReadTileElement(destination, 0, 4) == Zeros{PTO_XLEN} + 55;
    assert ReadTileElement(destination, 0, 1) == Zeros{PTO_XLEN};
    assert ReadTileElement(destination, 0, 7) == Zeros{PTO_XLEN};
end;

func AssertI414MalformedOperationFault()
begin
    let decoded = DecodeTileOperation(TileDecode_TLSU,
        BundleOperationDecodeCode(_BundleOperation));
    let operation = decoded as integer
        {0..PTO_TILE_OPERATION_COUNT-1};
    assert !BundleOperationScalarBindingSchemaLegal(operation);
    StartMemoryEventCapture(0);
    let completed = ExecuteBundleTileOperation();
    assert !completed && _LastFault == Fault_TileLegality;
    assert _MemoryEventCount == 0;
    assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;
    StopMemoryEventCapture();
    let observed_1 = LoadUnsigned(Zeros{PTO_XLEN} + 0x900, 1);
    assert observed_1 == Zeros{PTO_XLEN} + 11;
    let observed_2 = LoadUnsigned(Zeros{PTO_XLEN} + 0x904, 1);
    assert observed_2 == Zeros{PTO_XLEN} + 55;
end;

func main() => integer
begin
    AssertI414MalformedPositiveControl();
        PrepareI414MalformedGather();
    let descriptor = ExecuteCommandInstruction(
        I414MalformedIOR(2, 3, 4, 0, FALSE), 32);
    let missing_final_flag = ExecuteCommandInstruction(
        I414MalformedIOR(5, 6, 0, 0, FALSE), 32);
    assert descriptor == CommandExecution_Executed &&
           missing_final_flag == CommandExecution_Executed;
    AssertI414MalformedOperationFault();
    return 0;
end;
