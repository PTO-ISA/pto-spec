// PTO-TEST: {"id":"PTO-AVS-BLOCK-I414-GPR-MASK-COMPATIBILITY-001","source":"asl/block/execution/BSTART.MGATHER.asl","requirements":["PTO-INDEXED-TLSU-RANGE-BINDING-001","PTO-B-IOR-BINDING-001","PTO-TILE-MODEL-EXECUTION-MASK-APPLICABILITY-001","PTO-BSTART-MGATHER-SCHEMA-001","PTO-INST-BLOCK-BSTART-MGATHER","PTO-INST-TILE-MGATHER"],"kind":"execution","summary":"Indexed range descriptors compose with one- and two-word GPR masks while legacy one-record masks keep both word counts.","pass_condition":"Descriptor-plus-one-word and descriptor-plus-two-word forms use two records; the two-word mask selects columns 0 and 4; legacy flagged one-record masks with one and two words retain their mask roles.","related_sources":["asl/block/model/dispatch/indexed-tlsu-range-schema.asl","asl/block/model/dispatch/execution-mask-schema.asl","asl/block/model/dispatch/scalar-schema.asl","asl/tile/model/memory/gather-scatter.asl"]}
pure func RangeMaskGatherStart(data_type: bits(5)) => bits(64)
begin
    var instruction = Zeros{64} + 0x00411181;
    instruction[31:27] = data_type;
    return instruction;
end;

pure func RangeMaskGatherAttributes() => bits(64)
begin
    var instruction = Zeros{64} + 0x00001023;
    instruction[24:20] = DTYPE_NONE;
    instruction[11:7] = Zeros{5} + 31;
    instruction[13] = '1';
    return instruction;
end;

pure func RangeMaskGatherBinding(tile: bits(6), size_code: bits(4))
    => bits(64)
begin
    var instruction = Zeros{64} + 0x00005013;
    instruction[25:20] = tile;
    instruction[19] = '1';
    instruction[18:15] = size_code;
    instruction[11:9] = '001';
    return instruction;
end;

pure func RangeMaskGatherIOR(source0: bits(5), source1: bits(5),
    source2: bits(5), execution_mask_present: boolean) => bits(64)
begin
    var instruction = Zeros{64} + 0x00000013;
    instruction[19:15] = source0;
    instruction[24:20] = source1;
    instruction[31:27] = source2;
    instruction[26] = if execution_mask_present then '1' else '0';
    return instruction;
end;

func BeginRangeMaskGather(data_type: TileDataType,
    valid_columns: integer {1..8}, base_address: Word,
    descriptor_present: boolean, two_mask_words: boolean)
begin
    ResetProfileState();
    let index_capacity = if data_type == TileDataType_U8 then 2048 else 512;
    let index_ready = ConfigureCubeTile(10, index_capacity, 1,
        valid_columns, TileDataType_U32, TileLayout_CUBE_M16);
    assert index_ready;
    for column = 0 to valid_columns - 1 looplimit 8 do
        WriteTileElement(10, 0, column as integer {0..65535},
            if column == 0 then Zeros{PTO_XLEN}
            else if column == 4 then Zeros{PTO_XLEN} + 4
            else Zeros{PTO_XLEN} + 1000);
    end;
    Store(base_address, TileMemoryElementBytes(data_type),
        Zeros{PTO_XLEN} + 11);
    Store(base_address + Zeros{PTO_XLEN} + 4,
        TileMemoryElementBytes(data_type), Zeros{PTO_XLEN} + 55);
    WritePEGPR(0, 2, base_address);
    WritePEGPR(0, 3, Zeros{64});
    WritePEGPR(0, 4, Zeros{64} + 4);
    WritePEGPR(0, 5, Zeros{64} + 1);
    WritePEGPR(0, 6, Zeros{64} + 1);
    let started = ExecuteCommandInstruction(
        RangeMaskGatherStart(TileDataTypeToEncoding(data_type)), 32);
    let attributes = ExecuteCommandInstruction(RangeMaskGatherAttributes(), 32);
    assert started == CommandExecution_Executed;
    assert attributes == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + valid_columns);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, NaturalToWord(_Tiles[[10]].columns));
    let bound = ExecuteCommandInstruction(RangeMaskGatherBinding(
        Zeros{6} + 10, '0011'), 32);
    assert bound == CommandExecution_Executed;
    let first = ExecuteCommandInstruction(RangeMaskGatherIOR(
        Zeros{5} + 2,
        if descriptor_present then Zeros{5} + 3 else Zeros{5} + 5,
        if descriptor_present then Zeros{5} + 4
        else if two_mask_words then Zeros{5} + 6 else Zeros{5},
        !descriptor_present), 32);
    assert first == CommandExecution_Executed;
    if descriptor_present then
        let final_mask = ExecuteCommandInstruction(RangeMaskGatherIOR(
            Zeros{5} + 5,
            if two_mask_words then Zeros{5} + 6 else Zeros{5},
            Zeros{5}, TRUE), 32);
        assert final_mask == CommandExecution_Executed;
    end;
    let decoded_operation = DecodeTileOperation(TileDecode_TLSU,
        BundleOperationDecodeCode(_BundleOperation));
    let operation = decoded_operation as integer
        {0..PTO_TILE_OPERATION_COUNT-1};
    assert BundleOperationBindingsComplete(operation);
    assert BundleOperationScalarBindingSchemaLegal(operation);
    assert BundleOperationGPRBindingValuesLegal(operation);
    assert BundleExecutionMaskGPRCarrierShapeLegal(operation);
end;

func RunLegacyTwoWordMask()
begin
    BeginRangeMaskGather(TileDataType_U8, 8,
        Zeros{PTO_XLEN} + 0x700, FALSE, TRUE);
    StartMemoryEventCapture(0);
    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
    assert _MemoryEventCount == 2;
    assert _MemoryEvents[[0]].address == Zeros{PTO_XLEN} + 0x700;
    assert _MemoryEvents[[1]].address == Zeros{PTO_XLEN} + 0x704;
    StopMemoryEventCapture();
    let destination = _BundleTileBindings[[0]].destination;
    assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN} + 11;
    assert ReadTileElement(destination, 0, 4) == Zeros{PTO_XLEN} + 55;
    assert ReadTileElement(destination, 0, 1) == Zeros{PTO_XLEN};
    assert ReadTileElement(destination, 0, 7) == Zeros{PTO_XLEN};
end;

func RunOneWordDescriptorAndLegacyMask()
begin
    BeginRangeMaskGather(TileDataType_U32, 2,
        Zeros{PTO_XLEN} + 0x400, TRUE, FALSE);
    StartMemoryEventCapture(0);
    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
    assert _MemoryEventCount == 1;
    assert _MemoryEvents[[0]].address == Zeros{PTO_XLEN} + 0x400;
    StopMemoryEventCapture();
    let destination = _BundleTileBindings[[0]].destination;
    assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN} + 11;
    assert ReadTileElement(destination, 0, 1) == Zeros{PTO_XLEN};

    // The one-record flagged form is still Base plus one GPR mask word.
    BeginRangeMaskGather(TileDataType_U32, 2,
        Zeros{PTO_XLEN} + 0x500, FALSE, FALSE);
    StartMemoryEventCapture(0);
    let legacy_completed = ExecuteBundleTileOperation();
    assert legacy_completed && _LastFault == Fault_None;
    assert _MemoryEventCount == 1;
    assert _MemoryEvents[[0]].address == Zeros{PTO_XLEN} + 0x500;
    StopMemoryEventCapture();
    let legacy_destination = _BundleTileBindings[[0]].destination;
    assert ReadTileElement(legacy_destination, 0, 0) ==
        Zeros{PTO_XLEN} + 11;
    assert ReadTileElement(legacy_destination, 0, 1) == Zeros{PTO_XLEN};
end;

func RunTwoWordDescriptorMask()
begin
    BeginRangeMaskGather(TileDataType_U8, 8,
        Zeros{PTO_XLEN} + 0x600, TRUE, TRUE);
    StartMemoryEventCapture(0);
    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
    assert _MemoryEventCount == 2;
    assert _MemoryEvents[[0]].address == Zeros{PTO_XLEN} + 0x600;
    assert _MemoryEvents[[1]].address == Zeros{PTO_XLEN} + 0x604;
    StopMemoryEventCapture();
    let destination = _BundleTileBindings[[0]].destination;
    assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN} + 11;
    assert ReadTileElement(destination, 0, 4) == Zeros{PTO_XLEN} + 55;
    assert ReadTileElement(destination, 0, 1) == Zeros{PTO_XLEN};
    assert ReadTileElement(destination, 0, 7) == Zeros{PTO_XLEN};
end;

func main() => integer
begin
    RunOneWordDescriptorAndLegacyMask();
    RunTwoWordDescriptorMask();
    RunLegacyTwoWordMask();
    return 0;
end;
