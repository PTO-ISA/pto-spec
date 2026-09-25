// PTO-TEST: {"id":"PTO-AVS-BLOCK-MGATHER-MASK-EXECUTION-MASK-BUNDLE-001","source":"asl/block/execution/BSTART.MGATHER.MASK.asl","requirements":["PTO-MGATHER-MASK-PREDICATE-001","PTO-BSTART-MGATHER-MASK-SCHEMA-001","PTO-TILE-MODEL-EXECUTION-MASK-APPLICABILITY-001","PTO-B-IOR-BINDING-001","PTO-B-IOT-STREAM-001"],"kind":"execution","summary":"Decoded MGATHER.MASK keeps its operation predicate separate from a final PredicateCell ExecutionMask source","pass_condition":"different masks suppress complementary invalid-index lanes, malformed ExecutionMask rolls back before memory events, and the repaired bundle loads only their active intersection","related_sources":["asl/block/model/dispatch/tlsu-mgather-mask.asl","asl/block/model/dispatch/execution-mask-schema.asl","asl/tile/model/memory/gather-scatter.asl"]}
pure func DecodedMaskedGatherStart(data_type: bits(5)) => bits(64)
begin
    var instruction = Zeros{64} + 0x00011181;
    instruction[24:20] = Zeros{5} + 6;
    instruction[31:27] = data_type;
    return instruction;
end;

pure func DecodedMaskedGatherAttributes() => bits(64)
begin
    var instruction = Zeros{64} + 0x00001023;
    instruction[24:20] = DTYPE_NONE;
    instruction[11:7] = Zeros{5} + 31;
    instruction[13] = '1';
    return instruction;
end;

pure func DecodedMaskedGatherInputs(indices: bits(6),
    operation_mask: bits(6)) => bits(64)
begin
    var instruction = Zeros{64} + 0x00004013;
    instruction[31:26] = operation_mask;
    instruction[25:20] = indices;
    instruction[11:9] = '001';
    return instruction;
end;

pure func DecodedMaskedGatherResult(execution_mask: bits(6)) => bits(64)
begin
    var instruction = Zeros{64} + 0x00005013;
    instruction[25:20] = execution_mask;
    instruction[19] = '1';
    instruction[18:15] = Zeros{4} + 2;
    instruction[11:9] = '001';
    return instruction;
end;

pure func DecodedMaskedGatherIOR(base: bits(5)) => bits(64)
begin
    var instruction = Zeros{64} + 0x00000013;
    instruction[19:15] = base;
    return instruction;
end;

func SetupDecodedMaskedGather(invalid_execution_mask: boolean)
begin
    let indices_ready = ConfigureCubeTile(
        8, 256, 1, 4, TileDataType_S32, TileLayout_CUBE_M16);
    let operation_mask_ready = ConfigurePredicateCell(
        10, 256, 1, 4, TileDataType_U32, TileLayout_CUBE_M16);
    let execution_mask_ready = ConfigurePredicateCell(
        12, 256, 1, 4, TileDataType_U32, TileLayout_CUBE_M16);
    assert indices_ready;
    assert operation_mask_ready;
    assert execution_mask_ready;
    InstallRelativeTileFixture(8, 8);
    InstallRelativeTileFixture(10, 10);
    InstallRelativeTileFixture(12, 12);
    for column = 0 to 3 looplimit 4 do
        WriteTileElement(8, 0, column,
            if column == 1 || column == 2
            then Zeros{PTO_XLEN} + 0x7fff
            else Zeros{PTO_XLEN} + column * 4);
        WriteTileElement(10, 0, column,
            if column == 0 || column == 1 || column == 3
            then Zeros{PTO_XLEN} + 1 else Zeros{PTO_XLEN});
        WriteTileElement(12, 0, column,
            if column == 0 && invalid_execution_mask
            then Zeros{PTO_XLEN} + 2
            else if column == 0 || column == 2 || column == 3
            then Zeros{PTO_XLEN} + 1 else Zeros{PTO_XLEN});
    end;
    MarkTileValidRegionDefined(8);
    _Tiles[[10]].contents_defined = TRUE;
    _Tiles[[12]].contents_defined = TRUE;
    Store(Zeros{PTO_XLEN} + 0x100, 4, Zeros{PTO_XLEN} + 11);
    Store(Zeros{PTO_XLEN} + 0x104, 4, Zeros{PTO_XLEN} + 22);
    Store(Zeros{PTO_XLEN} + 0x108, 4, Zeros{PTO_XLEN} + 33);
    Store(Zeros{PTO_XLEN} + 0x10c, 4, Zeros{PTO_XLEN} + 44);
    WritePEGPR(0, 2, Zeros{PTO_XLEN} + 0x100);
end;

func BindDecodedMaskedGather()
begin
    let started = ExecuteCommandInstruction(
        DecodedMaskedGatherStart(
            TileDataTypeToEncoding(TileDataType_U32)), 32);
    assert started == CommandExecution_Executed;
    let attributes = ExecuteCommandInstruction(
        DecodedMaskedGatherAttributes(), 32);
    assert attributes == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 4);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 4);
    let first = ExecuteCommandInstruction(
        DecodedMaskedGatherInputs(Zeros{6} + 8, Zeros{6} + 10), 32);
    let last = ExecuteCommandInstruction(
        DecodedMaskedGatherResult(Zeros{6} + 12), 32);
    let base = ExecuteCommandInstruction(
        DecodedMaskedGatherIOR(Zeros{5} + 2), 32);
    assert first == CommandExecution_Executed;
    assert last == CommandExecution_Executed;
    assert base == CommandExecution_Executed;
end;

func main() => integer
begin
    ResetProfileState();
    SetupDecodedMaskedGather(FALSE);
    BindDecodedMaskedGather();
    StartMemoryEventCapture(0);
    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
    let destination = _BundleTileBindings[[1]].destination;
    assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN} + 11;
    assert ReadTileElement(destination, 0, 1) == Zeros{PTO_XLEN};
    assert ReadTileElement(destination, 0, 3) == Zeros{PTO_XLEN} + 44;
    assert _MemoryEventCount == 2;
    assert _MemoryEvents[[0]].address == Zeros{PTO_XLEN} + 0x100;
    assert _MemoryEvents[[1]].address == Zeros{PTO_XLEN} + 0x10c;
    StopMemoryEventCapture();

    // Invalid mask value 2 rejects and rolls back the new destination before
    // the gather can inspect either invalid-index lane or emit memory events.
    ResetProfileState();
    SetupDecodedMaskedGather(TRUE);
    BindDecodedMaskedGather();
    StartMemoryEventCapture(0);
    let rejected = ExecuteBundleTileOperation();
    assert !rejected && _LastFault == Fault_TileLegality;
    assert _MemoryEventCount == 0;
    assert !_BundleTileBindings[[1]].destination_allocated_by_bundle;
    StopMemoryEventCapture();
    return 0;
end;
