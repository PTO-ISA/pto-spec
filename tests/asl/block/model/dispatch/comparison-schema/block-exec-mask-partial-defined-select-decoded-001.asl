// PTO-TEST: {"id":"PTO-AVS-BLOCK-EXECUTION-MASK-PARTIAL-DEFINED-SELECT-DECODED-001","source":"asl/block/model/dispatch/comparison-schema.asl","requirements":["PTO-TSEL-CONTRACT-001","PTO-TSELS-CONTRACT-001","PTO-TILE-MODEL-EXECUTION-MASK-APPLICABILITY-001","PTO-B-IOR-BINDING-001","PTO-B-IOT-STREAM-001"],"kind":"execution","summary":"Decoded TSEL and TSELS suppress undefined inactive CUBE source coordinates","pass_condition":"PredicateCell and GPR ExecutionMask carriers accept a defined active column with an undefined inactive column, while activating the undefined column rejects before destination allocation","related_sources":["asl/block/model/dispatch/comparison-schema.asl","asl/block/model/dispatch/tile-scalar-schema.asl","asl/block/model/dispatch/execution-mask-schema.asl"]}
pure func PartialSelectStart(selector: bits(10), data_type: bits(5))
    => bits(64)
begin
    var instruction = Zeros{64} + 0x00019181;
    instruction[26:25] = selector[6:5];
    instruction[24:20] = selector[4:0];
    instruction[31:27] = data_type;
    return instruction;
end;

pure func PartialSelectAttributes() => bits(64)
begin
    var instruction = Zeros{64} + 0x00001023;
    instruction[24:20] = DTYPE_NONE;
    instruction[11:7] = Zeros{5};
    instruction[13] = '1';
    return instruction;
end;

pure func PartialSelectInputs(source0: bits(6), source1: bits(6))
    => bits(64)
begin
    var instruction = Zeros{64} + 0x00004013;
    instruction[31:26] = source1;
    instruction[25:20] = source0;
    instruction[11:9] = '001';
    return instruction;
end;

pure func PartialSelectResult(source0: bits(6), source1: bits(6),
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

pure func PartialSelectIOR(destination: bits(5), source0: bits(5),
    source1: bits(5), present: boolean) => bits(64)
begin
    var instruction = Zeros{64} + 0x00000013;
    instruction[11:7] = destination;
    instruction[19:15] = source0;
    instruction[24:20] = source1;
    instruction[26] = if present then '1' else '0';
    return instruction;
end;

func BeginPartialSelect(selector: bits(10))
begin
    let started = ExecuteCommandInstruction(
        PartialSelectStart(selector,
            TileDataTypeToEncoding(TileDataType_U32)), 32);
    let attributes = ExecuteCommandInstruction(PartialSelectAttributes(), 32);
    assert started == CommandExecution_Executed;
    assert attributes == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 2);
end;

func RunPartialTSEL(mask_column0: boolean, should_complete: boolean)
begin
    ResetProfileState();
    let predicate_ready = ConfigurePredicateCell(
        8, 128, 1, 2, TileDataType_U32, TileLayout_CUBE_M16);
    let true_ready = ConfigureCubeTile(
        10, 128, 1, 2, TileDataType_U32, TileLayout_CUBE_M16);
    let false_ready = ConfigureCubeTile(
        11, 128, 1, 2, TileDataType_U32, TileLayout_CUBE_M16);
    let exec_mask_ready = ConfigurePredicateCell(
        12, 128, 1, 2, TileDataType_U32, TileLayout_CUBE_M16);
    assert predicate_ready && true_ready && false_ready && exec_mask_ready;
    InstallRelativeTileFixture(8, 8);
    InstallRelativeTileFixture(10, 10);
    InstallRelativeTileFixture(11, 11);
    InstallRelativeTileFixture(12, 12);
    WriteTileElement(8, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(8, 0, 1, Zeros{PTO_XLEN});
    WriteTileElement(10, 0, 1, Zeros{PTO_XLEN} + 201);
    WriteTileElement(11, 0, 1, Zeros{PTO_XLEN} + 101);
    WriteTileElement(12, 0, 0,
        if mask_column0 then Zeros{PTO_XLEN} + 1 else Zeros{PTO_XLEN});
    WriteTileElement(12, 0, 1,
        if mask_column0 then Zeros{PTO_XLEN} else Zeros{PTO_XLEN} + 1);
    _Tiles[[8]].contents_defined = TRUE;
    _Tiles[[12]].contents_defined = TRUE;

    BeginPartialSelect(Zeros{10} + 0x01a);
    let inputs = ExecuteCommandInstruction(
        PartialSelectInputs(Zeros{6} + 8, Zeros{6} + 10), 32);
    let result = ExecuteCommandInstruction(
        PartialSelectResult(Zeros{6} + 11, Zeros{6} + 12,
            Zeros{2}, Zeros{4} + 2), 32);
    assert inputs == CommandExecution_Executed &&
           result == CommandExecution_Executed;
    let completed = ExecuteBundleTileOperation();
    assert completed == should_complete;
    if should_complete then
        assert _LastFault == Fault_None;
        let destination = _BundleTileBindings[[1]].destination;
        assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN};
        assert ReadTileElement(destination, 0, 1) == Zeros{PTO_XLEN} + 101;
    else
        assert _LastFault == Fault_TileLegality;
        assert !_BundleTileBindings[[1]].destination_allocated_by_bundle;
    end;
end;

func RunPartialTSELS(mask_column0: boolean, should_complete: boolean)
begin
    ResetProfileState();
    let predicate_ready = ConfigurePredicateCell(
        8, 128, 1, 2, TileDataType_U32, TileLayout_CUBE_M16);
    let source_ready = ConfigureCubeTile(
        10, 128, 1, 2, TileDataType_U32, TileLayout_CUBE_M16);
    assert predicate_ready && source_ready;
    InstallRelativeTileFixture(8, 8);
    InstallRelativeTileFixture(10, 10);
    WriteTileElement(8, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(8, 0, 1, Zeros{PTO_XLEN});
    WriteTileElement(10, 0, 1, Zeros{PTO_XLEN} + 11);
    _Tiles[[8]].contents_defined = TRUE;
    WritePEGPR(0, 2, Zeros{PTO_XLEN} + 77);
    var exec_mask = Zeros{PTO_XLEN};
    if mask_column0 then exec_mask[0] = '1'; else exec_mask[16] = '1'; end;
    WritePEGPR(0, 3, exec_mask);

    BeginPartialSelect(Zeros{10} + 0x03a);
    let input = ExecuteCommandInstruction(
        PartialSelectResult(Zeros{6} + 8, Zeros{6} + 10,
            Zeros{2}, Zeros{4} + 2), 32);
    let scalar_mask = ExecuteCommandInstruction(
        PartialSelectIOR(Zeros{5}, Zeros{5} + 2,
            Zeros{5} + 3, TRUE), 32);
    assert input == CommandExecution_Executed &&
           scalar_mask == CommandExecution_Executed;
    let completed = ExecuteBundleTileOperation();
    assert completed == should_complete;
    if should_complete then
        assert _LastFault == Fault_None;
        let destination = _BundleTileBindings[[0]].destination;
        assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN};
        assert ReadTileElement(destination, 0, 1) == Zeros{PTO_XLEN} + 77;
    else
        assert _LastFault == Fault_TileLegality;
        assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;
    end;
end;

func main() => integer
begin
    RunPartialTSEL(FALSE, TRUE);
    RunPartialTSEL(TRUE, FALSE);
    RunPartialTSELS(FALSE, TRUE);
    RunPartialTSELS(TRUE, FALSE);
    return 0;
end;
