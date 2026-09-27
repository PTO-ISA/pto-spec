// PTO-TEST: {"id":"PTO-AVS-BLOCK-SELECT-MIXED-CARRIERS-DECODED-002","source":"asl/block/model/dispatch/comparison-schema.asl","requirements":["PTO-TSEL-CONTRACT-001","PTO-TSELS-CONTRACT-001","PTO-TILE-MODEL-EXECUTION-MASK-APPLICABILITY-001","PTO-B-IOR-BINDING-001","PTO-B-IOT-STREAM-001"],"kind":"execution","summary":"Decoded CUBE TSEL and TSELS route operation-owned GPR predicates independently of PredicateCell and GPR ExecutionMask carriers","pass_condition":"an appended PredicateCell mask preserves GPR selection routing and destination ownership, U8 operation plus ExecutionMask predicates consume a contiguous two-record B.IOR stream, and an unrelated second record rejects before allocation","related_sources":["asl/block/model/dispatch/tile-scalar-schema.asl","asl/block/model/dispatch/predicate-destination.asl","asl/block/model/dispatch/tile-execution.asl"]}
pure func MixedSelectStart(selector: bits(10), data_type: TileDataType)
    => bits(64)
begin
    var instruction = Zeros{64} + 0x00019181;
    instruction[26:25] = selector[6:5];
    instruction[24:20] = selector[4:0];
    instruction[31:27] = TileDataTypeToEncoding(data_type);
    return instruction;
end;

pure func MixedSelectAttributes() => bits(64)
begin
    var instruction = Zeros{64} + 0x00001023;
    instruction[24:20] = DTYPE_NONE;
    instruction[13] = '1';
    return instruction;
end;

pure func MixedSelectIOT(source0: bits(6), source1: bits(6),
    source1_valid: boolean, destination: bits(2), destination_valid: boolean,
    last: boolean) => bits(64)
begin
    var instruction = if source1_valid then
        Zeros{64} + 0x00004013 else Zeros{64} + 0x00005013;
    instruction[31:26] = source1;
    instruction[25:20] = source0;
    instruction[19] = if last then '1' else '0';
    instruction[18:15] = if destination_valid then '0010' else '0000';
    instruction[11:9] = '001';
    instruction[8:7] = destination;
    return instruction;
end;

pure func MixedSelectIOR(source0: bits(5), source1: bits(5),
    source2: bits(5), execution_mask_present: boolean) => bits(64)
begin
    var instruction = Zeros{64} + 0x00000013;
    instruction[19:15] = source0;
    instruction[24:20] = source1;
    instruction[31:27] = source2;
    instruction[26] = if execution_mask_present then '1' else '0';
    return instruction;
end;

func BeginMixedSelect(selector: bits(10), data_type: TileDataType)
begin
    let started = ExecuteCommandInstruction(
        MixedSelectStart(selector, data_type), 32);
    let attributes = ExecuteCommandInstruction(MixedSelectAttributes(), 32);
    assert started == CommandExecution_Executed;
    assert attributes == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 2);
end;

func InstallMixedNumericSources(data_type: TileDataType)
begin
    let true_ready = ConfigureCubeTile(
        10, 128, 1, 2, data_type, TileLayout_CUBE_M16);
    let false_ready = ConfigureCubeTile(
        11, 128, 1, 2, data_type, TileLayout_CUBE_M16);
    assert true_ready && false_ready;
    InstallRelativeTileFixture(10, 10);
    InstallRelativeTileFixture(11, 11);
    WriteTileElement(10, 0, 0, Zeros{PTO_XLEN} + 20);
    WriteTileElement(10, 0, 1, Zeros{PTO_XLEN} + 21);
    WriteTileElement(11, 0, 0, Zeros{PTO_XLEN} + 10);
    WriteTileElement(11, 0, 1, Zeros{PTO_XLEN} + 11);
    MarkTileValidRegionDefined(10);
    MarkTileValidRegionDefined(11);
end;

func RunTSELPredicateCellExecutionMask()
begin
    ResetProfileState();
    InstallMixedNumericSources(TileDataType_U32);
    let mask_ready = ConfigurePredicateCell(
        12, 128, 1, 2, TileDataType_U32, TileLayout_CUBE_M16);
    assert mask_ready;
    InstallRelativeTileFixture(12, 12);
    WriteTileElement(12, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(12, 0, 1, Zeros{PTO_XLEN} + 1);
    _Tiles[[12]].contents_defined = TRUE;
    var select = Zeros{PTO_XLEN};
    select[0] = '1';
    select[16] = '1';
    WritePEGPR(0, 2, select);

    BeginMixedSelect(Zeros{10} + 0x01a, TileDataType_U32);
    let inputs = ExecuteCommandInstruction(
        MixedSelectIOT(Zeros{6} + 10, Zeros{6} + 11,
            TRUE, Zeros{2}, FALSE, FALSE), 32);
    let result = ExecuteCommandInstruction(
        MixedSelectIOT(Zeros{6} + 12, Zeros{6},
            FALSE, Zeros{2}, TRUE, TRUE), 32);
    let predicate = ExecuteCommandInstruction(
        MixedSelectIOR(Zeros{5} + 2, Zeros{5}, Zeros{5}, FALSE), 32);
    assert inputs == CommandExecution_Executed &&
           result == CommandExecution_Executed &&
           predicate == CommandExecution_Executed;
    let completed = ExecuteBundleTileOperation();
    assert completed;
    assert _LastFault == Fault_None;
    let destination = _BundleTileBindings[[1]].destination;
    assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN};
    assert ReadTileElement(destination, 0, 1) == Zeros{PTO_XLEN} + 21;
end;

func RunTSELSPredicateCellExecutionMask()
begin
    ResetProfileState();
    let source_ready = ConfigureCubeTile(
        10, 128, 1, 2, TileDataType_U32, TileLayout_CUBE_M16);
    let mask_ready = ConfigurePredicateCell(
        12, 128, 1, 2, TileDataType_U32, TileLayout_CUBE_M16);
    assert source_ready && mask_ready;
    InstallRelativeTileFixture(10, 10);
    InstallRelativeTileFixture(12, 12);
    WriteTileElement(10, 0, 0, Zeros{PTO_XLEN} + 20);
    WriteTileElement(10, 0, 1, Zeros{PTO_XLEN} + 21);
    MarkTileValidRegionDefined(10);
    WriteTileElement(12, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(12, 0, 1, Zeros{PTO_XLEN} + 1);
    _Tiles[[12]].contents_defined = TRUE;
    var select = Zeros{PTO_XLEN};
    select[0] = '1';
    select[16] = '1';
    WritePEGPR(0, 2, select);
    WritePEGPR(0, 3, Zeros{PTO_XLEN} + 7);

    BeginMixedSelect(Zeros{10} + 0x03a, TileDataType_U32);
    let binding = ExecuteCommandInstruction(
        MixedSelectIOT(Zeros{6} + 10, Zeros{6} + 12,
            TRUE, Zeros{2}, TRUE, TRUE), 32);
    let scalars = ExecuteCommandInstruction(
        MixedSelectIOR(Zeros{5} + 2, Zeros{5} + 3,
            Zeros{5}, FALSE), 32);
    assert binding == CommandExecution_Executed &&
           scalars == CommandExecution_Executed;
    let completed = ExecuteBundleTileOperation();
    assert completed;
    assert _LastFault == Fault_None;
    let destination = _BundleTileBindings[[0]].destination;
    assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN};
    assert ReadTileElement(destination, 0, 1) == Zeros{PTO_XLEN} + 21;
end;

func BindTwoWordTSEL(second_record: boolean)
begin
    BeginMixedSelect(Zeros{10} + 0x01a, TileDataType_U8);
    let binding = ExecuteCommandInstruction(
        MixedSelectIOT(Zeros{6} + 10, Zeros{6} + 11,
            TRUE, Zeros{2}, TRUE, TRUE), 32);
    let first = ExecuteCommandInstruction(
        MixedSelectIOR(Zeros{5} + 2, Zeros{5} + 3,
            Zeros{5} + 4, FALSE), 32);
    assert binding == CommandExecution_Executed &&
           first == CommandExecution_Executed;
    if second_record then
        let second = ExecuteCommandInstruction(
            MixedSelectIOR(Zeros{5} + 5, Zeros{5}, Zeros{5}, TRUE), 32);
        assert second == CommandExecution_Executed;
    end;
end;

func RunTwoWordGPRMasks()
begin
    ResetProfileState();
    InstallMixedNumericSources(TileDataType_U8);
    var operation_low = Zeros{PTO_XLEN};
    operation_low[0] = '1';
    operation_low[16] = '1';
    var execution_low = Zeros{PTO_XLEN};
    execution_low[16] = '1';
    WritePEGPR(0, 2, operation_low);
    WritePEGPR(0, 3, Zeros{PTO_XLEN});
    WritePEGPR(0, 4, execution_low);
    WritePEGPR(0, 5, Zeros{PTO_XLEN});
    BindTwoWordTSEL(TRUE);
    let completed = ExecuteBundleTileOperation();
    assert completed;
    assert _LastFault == Fault_None;
    let destination = _BundleTileBindings[[0]].destination;
    assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN};
    assert ReadTileElement(destination, 0, 1) == Zeros{PTO_XLEN} + 21;

    // TSELS fills the first record with its two-word selection predicate and
    // scalar-false operand; its two ExecutionMask words therefore occupy the
    // second record.
    ResetProfileState();
    let source_ready = ConfigureCubeTile(
        10, 128, 1, 2, TileDataType_U8, TileLayout_CUBE_M16);
    assert source_ready;
    InstallRelativeTileFixture(10, 10);
    WriteTileElement(10, 0, 0, Zeros{PTO_XLEN} + 20);
    WriteTileElement(10, 0, 1, Zeros{PTO_XLEN} + 21);
    MarkTileValidRegionDefined(10);
    WritePEGPR(0, 2, operation_low);
    WritePEGPR(0, 3, Zeros{PTO_XLEN});
    WritePEGPR(0, 4, Zeros{PTO_XLEN} + 7);
    WritePEGPR(0, 5, execution_low);
    WritePEGPR(0, 6, Zeros{PTO_XLEN});
    BeginMixedSelect(Zeros{10} + 0x03a, TileDataType_U8);
    let tsels_binding = ExecuteCommandInstruction(
        MixedSelectIOT(Zeros{6} + 10, Zeros{6},
            FALSE, Zeros{2}, TRUE, TRUE), 32);
    let tsels_operation = ExecuteCommandInstruction(
        MixedSelectIOR(Zeros{5} + 2, Zeros{5} + 3,
            Zeros{5} + 4, FALSE), 32);
    let tsels_execution = ExecuteCommandInstruction(
        MixedSelectIOR(Zeros{5} + 5, Zeros{5} + 6,
            Zeros{5}, TRUE), 32);
    assert tsels_binding == CommandExecution_Executed &&
           tsels_operation == CommandExecution_Executed &&
           tsels_execution == CommandExecution_Executed;
    let tsels_completed = ExecuteBundleTileOperation();
    assert tsels_completed && _LastFault == Fault_None;
    let tsels_destination = _BundleTileBindings[[0]].destination;
    assert ReadTileElement(tsels_destination, 0, 0) == Zeros{PTO_XLEN};
    assert ReadTileElement(tsels_destination, 0, 1) == Zeros{PTO_XLEN} + 21;

    // Without ExecMaskPresent the second record is unrelated scalar state and
    // remains illegal for the closed TSEL schema.
    ResetProfileState();
    InstallMixedNumericSources(TileDataType_U8);
    BindTwoWordTSEL(FALSE);
    let surplus = ExecuteCommandInstruction(
        MixedSelectIOR(Zeros{5} + 5, Zeros{5}, Zeros{5}, FALSE), 32);
    assert surplus == CommandExecution_Executed;
    let rejected = ExecuteBundleTileOperation();
    assert !rejected;
    assert _LastFault == Fault_TileLegality;
    assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;
end;

func main() => integer
begin
    RunTSELPredicateCellExecutionMask();
    RunTSELSPredicateCellExecutionMask();
    RunTwoWordGPRMasks();
    return 0;
end;
