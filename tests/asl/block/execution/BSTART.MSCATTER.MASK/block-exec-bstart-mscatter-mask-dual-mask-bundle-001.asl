// PTO-TEST: {"id":"PTO-AVS-BLOCK-MSCATTER-MASK-EXECUTION-MASK-BUNDLE-001","source":"asl/block/execution/BSTART.MSCATTER.MASK.asl","requirements":["PTO-MSCATTER-MASK-PREDICATE-001","PTO-BSTART-MSCATTER-MASK-SCHEMA-001","PTO-TILE-MODEL-EXECUTION-MASK-APPLICABILITY-001","PTO-B-IOR-BINDING-001","PTO-B-IOT-STREAM-001"],"kind":"execution","summary":"Decoded MSCATTER.MASK keeps its operation predicate separate from the final PredicateCell ExecutionMask source","pass_condition":"different masks suppress complementary invalid-index lanes, malformed ExecutionMask rejects before memory events, and only the active intersection scatters","related_sources":["asl/block/model/dispatch/tlsu-mscatter-mask.asl","asl/block/model/dispatch/execution-mask-schema.asl","asl/tile/model/memory/gather-scatter.asl"]}
pure func DecodedMaskedScatterStart(data_type: bits(5)) => bits(64)
begin
    var instruction = Zeros{64} + 0x00011181;
    instruction[24:20] = Zeros{5} + 7;
    instruction[31:27] = data_type;
    return instruction;
end;

pure func DecodedMaskedScatterAttributes() => bits(64)
begin
    var instruction = Zeros{64} + 0x00001023;
    instruction[24:20] = DTYPE_NONE;
    instruction[11:7] = Zeros{5} + 31;
    // MSCATTER.MASK has no tile destination, so Zero=1 is inapplicable.
    return instruction;
end;

pure func DecodedMaskedScatterInputs(data: bits(6), indices: bits(6))
    => bits(64)
begin
    var instruction = Zeros{64} + 0x00004013;
    instruction[31:26] = indices;
    instruction[25:20] = data;
    instruction[11:9] = '001';
    return instruction;
end;

pure func DecodedMaskedScatterMasks(operation_mask: bits(6),
    execution_mask: bits(6)) => bits(64)
begin
    var instruction = Zeros{64} + 0x00004013;
    instruction[31:26] = execution_mask;
    instruction[25:20] = operation_mask;
    instruction[19] = '1';
    instruction[11:9] = '001';
    return instruction;
end;

pure func DecodedMaskedScatterIOR(base: bits(5)) => bits(64)
begin
    var instruction = Zeros{64} + 0x00000013;
    instruction[19:15] = base;
    return instruction;
end;

func SetupDecodedMaskedScatter(invalid_execution_mask: boolean)
begin
    let data_ready = ConfigureCubeTile(
        8, 256, 1, 4, TileDataType_U32, TileLayout_CUBE_M16);
    let indices_ready = ConfigureCubeTile(
        10, 256, 1, 4, TileDataType_S32, TileLayout_CUBE_M16);
    let operation_mask_ready = ConfigurePredicateCell(
        11, 256, 1, 4, TileDataType_U32, TileLayout_CUBE_M16);
    let execution_mask_ready = ConfigurePredicateCell(
        12, 256, 1, 4, TileDataType_U32, TileLayout_CUBE_M16);
    assert data_ready;
    assert indices_ready;
    assert operation_mask_ready;
    assert execution_mask_ready;
    InstallRelativeTileFixture(8, 8);
    InstallRelativeTileFixture(10, 10);
    InstallRelativeTileFixture(11, 11);
    InstallRelativeTileFixture(12, 12);
    for column = 0 to 3 looplimit 4 do
        WriteTileElement(8, 0, column, Zeros{PTO_XLEN} + 21 + column);
        WriteTileElement(10, 0, column,
            if column == 1 || column == 2
            then Zeros{PTO_XLEN} + 0x7fff
            else Zeros{PTO_XLEN} + column * 4);
        WriteTileElement(11, 0, column,
            if column != 1 then Zeros{PTO_XLEN} + 1
            else Zeros{PTO_XLEN});
        WriteTileElement(12, 0, column,
            if column == 1 && invalid_execution_mask
            then Zeros{PTO_XLEN} + 2
            else if column != 2 then Zeros{PTO_XLEN} + 1
            else Zeros{PTO_XLEN});
    end;
    MarkTileValidRegionDefined(8);
    MarkTileValidRegionDefined(10);
    _Tiles[[11]].contents_defined = TRUE;
    _Tiles[[12]].contents_defined = TRUE;
    Store(Zeros{PTO_XLEN} + 0x200, 4, Zeros{PTO_XLEN} + 101);
    Store(Zeros{PTO_XLEN} + 0x20c, 4, Zeros{PTO_XLEN} + 404);
    WritePEGPR(0, 2, Zeros{PTO_XLEN} + 0x200);
end;

func BindDecodedMaskedScatter()
begin
    let started = ExecuteCommandInstruction(
        DecodedMaskedScatterStart(
            TileDataTypeToEncoding(TileDataType_U32)), 32);
    assert started == CommandExecution_Executed;
    let attributes = ExecuteCommandInstruction(
        DecodedMaskedScatterAttributes(), 32);
    assert attributes == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 4);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 4);
    let first = ExecuteCommandInstruction(
        DecodedMaskedScatterInputs(Zeros{6} + 8, Zeros{6} + 10), 32);
    let last = ExecuteCommandInstruction(
        DecodedMaskedScatterMasks(Zeros{6} + 11, Zeros{6} + 12), 32);
    let base = ExecuteCommandInstruction(
        DecodedMaskedScatterIOR(Zeros{5} + 2), 32);
    assert first == CommandExecution_Executed;
    assert last == CommandExecution_Executed;
    assert base == CommandExecution_Executed;
end;

func main() => integer
begin
    ResetProfileState();
    SetupDecodedMaskedScatter(FALSE);
    BindDecodedMaskedScatter();
    StartMemoryEventCapture(0);
    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
    assert _MemoryEventCount == 2;
    assert _MemoryEvents[[0]].address == Zeros{PTO_XLEN} + 0x200;
    assert _MemoryEvents[[1]].address == Zeros{PTO_XLEN} + 0x20c;
    StopMemoryEventCapture();
    let written_first = LoadUnsigned(Zeros{PTO_XLEN} + 0x200, 4);
    let written_last = LoadUnsigned(Zeros{PTO_XLEN} + 0x20c, 4);
    assert written_first == Zeros{PTO_XLEN} + 21;
    assert written_last == Zeros{PTO_XLEN} + 24;

    // A malformed ExecutionMask rejects before any index or memory effect;
    // lane 1 also has an invalid operation-owned masked index.
    ResetProfileState();
    SetupDecodedMaskedScatter(TRUE);
    BindDecodedMaskedScatter();
    StartMemoryEventCapture(0);
    let rejected = ExecuteBundleTileOperation();
    assert !rejected && _LastFault == Fault_TileLegality;
    assert _MemoryEventCount == 0;
    StopMemoryEventCapture();
    let unchanged_first = LoadUnsigned(Zeros{PTO_XLEN} + 0x200, 4);
    let unchanged_last = LoadUnsigned(Zeros{PTO_XLEN} + 0x20c, 4);
    assert unchanged_first == Zeros{PTO_XLEN} + 101;
    assert unchanged_last == Zeros{PTO_XLEN} + 404;
    return 0;
end;
