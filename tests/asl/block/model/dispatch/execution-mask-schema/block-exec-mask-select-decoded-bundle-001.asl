// PTO-TEST: {"id":"PTO-AVS-BLOCK-EXECUTION-MASK-SELECT-DECODED-BUNDLE-001","source":"asl/block/model/dispatch/execution-mask-schema.asl","requirements":["PTO-TSEL-CONTRACT-001","PTO-TSELS-CONTRACT-001","PTO-TILE-MODEL-EXECUTION-MASK-APPLICABILITY-001","PTO-B-IOR-BINDING-001","PTO-B-IOT-STREAM-001"],"kind":"execution","summary":"Decoded TSEL and TSELS bundles keep their operation predicates separate from ExecutionMask","pass_condition":"TSEL combines distinct PredicateCell roles; TSELS combines a PredicateCell selector and GPR ExecutionMask; malformed control rejects before allocation, and RowMajor GPR carriers remain outside the Local CUBE intersection","related_sources":["asl/block/model/dispatch/comparison-schema.asl","asl/block/model/dispatch/execution-mask-schema.asl","asl/tile/model/execution/comparison.asl"]}
pure func DecodedSelectStart(selector: bits(10), data_type: bits(5))
    => bits(64)
begin
    var instruction = Zeros{64} + 0x00019181;
    instruction[26:25] = selector[6:5];
    instruction[24:20] = selector[4:0];
    instruction[31:27] = data_type;
    return instruction;
end;

pure func DecodedSelectAttributes() => bits(64)
begin
    var instruction = Zeros{64} + 0x00001023;
    instruction[24:20] = DTYPE_NONE;
    // TSEL/TSELS own B.DATR Layout=0; their Local CUBE applicability is
    // derived from source descriptors when ExecutionMask is present.
    instruction[11:7] = Zeros{5};
    instruction[13] = '1';
    return instruction;
end;

pure func DecodedSelectInputs(source0: bits(6), source1: bits(6))
    => bits(64)
begin
    var instruction = Zeros{64} + 0x00004013;
    instruction[31:26] = source1;
    instruction[25:20] = source0;
    instruction[11:9] = '001';
    return instruction;
end;

pure func DecodedSelectResult(source0: bits(6), source1: bits(6),
    destination: bits(2), size_code: bits(4)) => bits(64)
begin
    var instruction = Zeros{64} + 0x00004013;
    instruction[31:26] = source1;
    instruction[25:20] = source0;
    instruction[19] = '1';
    instruction[18:15] = size_code;
    instruction[11:9] = '001';
    instruction[8:7] = destination;
    return instruction;
end;

pure func DecodedSelectTSELSResult(source0: bits(6), source1: bits(6),
    destination: bits(2), size_code: bits(4)) => bits(64)
begin
    var instruction = Zeros{64} + 0x00004013;
    instruction[31:26] = source1;
    instruction[25:20] = source0;
    instruction[19] = '1';
    instruction[18:15] = size_code;
    instruction[11:9] = '001';
    instruction[8:7] = destination;
    return instruction;
end;

pure func DecodedSelectIOR(destination: bits(5), source0: bits(5),
    source1: bits(5), present: boolean) => bits(64)
begin
    var instruction = Zeros{64} + 0x00000013;
    instruction[11:7] = destination;
    instruction[19:15] = source0;
    instruction[24:20] = source1;
    instruction[26] = if present then '1' else '0';
    return instruction;
end;

func SetupDecodedTSEL()
begin
    let predicate_ready = ConfigurePredicateCell(
        8, 256, 1, 4, TileDataType_U32, TileLayout_CUBE_M16);
    let true_ready = ConfigureCubeTile(
        10, 256, 1, 4, TileDataType_U32, TileLayout_CUBE_M16);
    let false_ready = ConfigureCubeTile(
        11, 256, 1, 4, TileDataType_U32, TileLayout_CUBE_M16);
    let exec_mask_ready = ConfigurePredicateCell(
        12, 256, 1, 4, TileDataType_U32, TileLayout_CUBE_M16);
    assert predicate_ready;
    assert true_ready;
    assert false_ready;
    assert exec_mask_ready;
    InstallRelativeTileFixture(8, 8);
    InstallRelativeTileFixture(10, 10);
    InstallRelativeTileFixture(11, 11);
    InstallRelativeTileFixture(12, 12);
    for column = 0 to 3 looplimit 4 do
        WriteTileElement(8, 0, column,
            if column == 1 || column == 3 then Zeros{PTO_XLEN} + 1
            else Zeros{PTO_XLEN});
        WriteTileElement(10, 0, column, Zeros{PTO_XLEN} + 200 + column);
        WriteTileElement(11, 0, column, Zeros{PTO_XLEN} + 100 + column);
        WriteTileElement(12, 0, column, Zeros{PTO_XLEN});
    end;
    _Tiles[[8]].contents_defined = TRUE;
    MarkTileValidRegionDefined(10);
    MarkTileValidRegionDefined(11);
    _Tiles[[12]].contents_defined = TRUE;
end;

func BindDecodedTSEL()
begin
    let started = ExecuteCommandInstruction(
        DecodedSelectStart(Zeros{10} + 0x01a,
            TileDataTypeToEncoding(TileDataType_U32)), 32);
    assert started == CommandExecution_Executed;
    let attributes = ExecuteCommandInstruction(DecodedSelectAttributes(), 32);
    assert attributes == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 4);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 4);
    let first = ExecuteCommandInstruction(
        DecodedSelectInputs(Zeros{6} + 8, Zeros{6} + 10), 32);
    let last = ExecuteCommandInstruction(
        DecodedSelectResult(Zeros{6} + 11, Zeros{6} + 12,
            Zeros{2}, Zeros{4} + 2), 32);
    assert first == CommandExecution_Executed;
    assert last == CommandExecution_Executed;
end;

func main() => integer
begin
    ResetProfileState();
    SetupDecodedTSEL();
    // The operation-owned PredicateCell selects false/true independently of
    // the appended PredicateCell ExecutionMask source.
    WriteTileElement(12, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(12, 0, 1, Zeros{PTO_XLEN});
    WriteTileElement(12, 0, 2, Zeros{PTO_XLEN} + 1);
    WriteTileElement(12, 0, 3, Zeros{PTO_XLEN} + 1);
    BindDecodedTSEL();
    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
    let tsel_destination = _BundleTileBindings[[1]].destination;
    assert ReadTileElement(tsel_destination, 0, 0) == Zeros{PTO_XLEN} + 100;
    assert ReadTileElement(tsel_destination, 0, 1) == Zeros{PTO_XLEN};
    assert ReadTileElement(tsel_destination, 0, 2) == Zeros{PTO_XLEN} + 102;
    assert ReadTileElement(tsel_destination, 0, 3) == Zeros{PTO_XLEN} + 203;

    ResetProfileState();
    SetupDecodedTSEL();
    WriteTileElement(12, 0, 0, Zeros{PTO_XLEN} + 2);
    BindDecodedTSEL();
    let rejected = ExecuteBundleTileOperation();
    assert !rejected && _LastFault == Fault_TileLegality;
    assert !_BundleTileBindings[[1]].destination_allocated_by_bundle;

    ResetProfileState();
    let tsels_predicate_ready = ConfigurePredicateCell(
        8, 128, 1, 2, TileDataType_U32, TileLayout_CUBE_M16);
    let tsels_source_ready = ConfigureCubeTile(
        10, 128, 1, 2, TileDataType_U32, TileLayout_CUBE_M16);
    assert tsels_predicate_ready;
    assert tsels_source_ready;
    InstallRelativeTileFixture(8, 8);
    InstallRelativeTileFixture(10, 10);
    for column = 0 to 1 looplimit 2 do
        WriteTileElement(8, 0, column,
            if column == 0 then Zeros{PTO_XLEN} + 1
            else Zeros{PTO_XLEN});
        WriteTileElement(10, 0, column, Zeros{PTO_XLEN} + 11 + column);
    end;
    _Tiles[[8]].contents_defined = TRUE;
    MarkTileValidRegionDefined(10);
    var mask_word = Zeros{PTO_XLEN};
    // For U32 CUBE_M16, column 1 is predicate bit 16.  Column 0 is
    // inactive under ExecutionMask while column 1 remains operation-active.
    mask_word[16] = '1';
    WritePEGPR(0, 2, Zeros{PTO_XLEN} + 77);
    WritePEGPR(0, 3, mask_word);
    let tsels_started = ExecuteCommandInstruction(
        DecodedSelectStart(Zeros{10} + 0x03a,
            TileDataTypeToEncoding(TileDataType_U32)), 32);
    assert tsels_started == CommandExecution_Executed;
    let tsels_attributes = ExecuteCommandInstruction(
        DecodedSelectAttributes(), 32);
    assert tsels_attributes == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 2);
    let tsels_iot = ExecuteCommandInstruction(
        DecodedSelectTSELSResult(Zeros{6} + 8, Zeros{6} + 10,
            Zeros{2}, Zeros{4} + 2), 32);
    let tsels_ior = ExecuteCommandInstruction(
        DecodedSelectIOR(Zeros{5}, Zeros{5} + 2, Zeros{5} + 3, TRUE), 32);
    assert tsels_iot == CommandExecution_Executed;
    assert tsels_ior == CommandExecution_Executed;
    let tsels_completed = ExecuteBundleTileOperation();
    assert tsels_completed && _LastFault == Fault_None;
    let tsels_destination = _BundleTileBindings[[0]].destination;
    assert ReadTileElement(tsels_destination, 0, 0) == Zeros{PTO_XLEN};
    assert ReadTileElement(tsels_destination, 0, 1) == Zeros{PTO_XLEN} + 77;

    ResetProfileState();
    ConfigureTile(
        10, 128, 1, 2, 1, 2, TileDataType_U32, TileLayout_RowMajor);
    ConfigureTile(
        11, 128, 1, 2, 1, 2, TileDataType_U32, TileLayout_RowMajor);
    assert _Tiles[[10]].allocated && _Tiles[[11]].allocated;
    InstallRelativeTileFixture(10, 10);
    InstallRelativeTileFixture(11, 11);
    WriteTileElement(10, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(10, 0, 1, Zeros{PTO_XLEN} + 2);
    WriteTileElement(11, 0, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(11, 0, 1, Zeros{PTO_XLEN} + 4);
    MarkTileValidRegionDefined(10);
    MarkTileValidRegionDefined(11);
    WritePEGPR(0, 2, Zeros{PTO_XLEN} + 1);
    WritePEGPR(0, 3, Zeros{PTO_XLEN} + 1);
    let row_start = ExecuteCommandInstruction(
        DecodedSelectStart(Zeros{10} + 0x01a,
            TileDataTypeToEncoding(TileDataType_U32)), 32);
    assert row_start == CommandExecution_Executed;
    let row_attributes = ExecuteCommandInstruction(
        DecodedSelectAttributes(), 32);
    assert row_attributes == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 2);
    let row_inputs = ExecuteCommandInstruction(
        DecodedSelectResult(Zeros{6} + 10, Zeros{6} + 11,
            Zeros{2}, Zeros{4} + 2), 32);
    let row_masks = ExecuteCommandInstruction(
        DecodedSelectIOR(Zeros{5}, Zeros{5} + 2, Zeros{5} + 3, TRUE), 32);
    assert row_inputs == CommandExecution_Executed;
    assert row_masks == CommandExecution_Executed;
    let row_rejected = ExecuteBundleTileOperation();
    assert !row_rejected && _LastFault == Fault_TileLegality;
    assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;
    return 0;
end;
