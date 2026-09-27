// PTO-TEST: {"id":"PTO-AVS-BLOCK-TCMP-FRESH-PREDICATECELL-DECODED-003","source":"asl/block/model/dispatch/predicate-destination.asl","requirements":["PTO-TCMP-CONTRACT-001","PTO-TILE-MODEL-EXECUTION-MASK-APPLICABILITY-001","PTO-B-IOT-STREAM-001"],"kind":"execution","summary":"Decoded TCMP derives a fresh PredicateCell destination from its numeric source when a PredicateCell ExecutionMask is appended","pass_condition":"U16 and U32 comparisons allocate a destination with the operation basis and numeric source shape instead of treating the mask source as the destination type owner","related_sources":["asl/block/model/dispatch/comparison-schema.asl","asl/block/model/dispatch/execution-mask-schema.asl"]}
pure func FreshTCMPStart(data_type: TileDataType) => bits(64)
begin
    var instruction = Zeros{64} + 0x00019181;
    let selector = Zeros{10} + 0x00d;
    instruction[26:25] = selector[6:5];
    instruction[24:20] = selector[4:0];
    instruction[31:27] = TileDataTypeToEncoding(data_type);
    return instruction;
end;

pure func FreshTCMPAttributes() => bits(64)
begin
    var instruction = Zeros{64} + 0x00001023;
    instruction[24:20] = DTYPE_NONE;
    instruction[13] = '1';
    return instruction;
end;

pure func FreshTCMPIOT(source0: bits(6), source1: bits(6),
    source1_valid: boolean, destination_valid: boolean,
    last: boolean) => bits(64)
begin
    var instruction = if source1_valid then
        Zeros{64} + 0x00004013 else Zeros{64} + 0x00005013;
    instruction[31:26] = source1;
    instruction[25:20] = source0;
    instruction[19] = if last then '1' else '0';
    instruction[18:15] = if destination_valid then '0010' else '0000';
    instruction[11:9] = '001';
    return instruction;
end;

func RunFreshTCMP(data_type: TileDataType)
begin
    ResetProfileState();
    let left_ready = ConfigureCubeTile(
        10, 128, 1, 2, data_type, TileLayout_CUBE_M16);
    let right_ready = ConfigureCubeTile(
        11, 128, 1, 2, data_type, TileLayout_CUBE_M16);
    let mask_ready = ConfigurePredicateCell(
        12, 128, 1, 2, data_type, TileLayout_CUBE_M16);
    assert left_ready && right_ready && mask_ready;
    InstallRelativeTileFixture(10, 10);
    InstallRelativeTileFixture(11, 11);
    InstallRelativeTileFixture(12, 12);
    WriteTileElement(10, 0, 0, Zeros{PTO_XLEN} + 4);
    WriteTileElement(10, 0, 1, Zeros{PTO_XLEN} + 5);
    WriteTileElement(11, 0, 0, Zeros{PTO_XLEN} + 4);
    WriteTileElement(11, 0, 1, Zeros{PTO_XLEN} + 6);
    MarkTileValidRegionDefined(10);
    MarkTileValidRegionDefined(11);
    WriteTileElement(12, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(12, 0, 1, Zeros{PTO_XLEN} + 1);
    _Tiles[[12]].contents_defined = TRUE;

    let started = ExecuteCommandInstruction(FreshTCMPStart(data_type), 32);
    let attributes = ExecuteCommandInstruction(FreshTCMPAttributes(), 32);
    assert started == CommandExecution_Executed;
    assert attributes == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 2);
    let inputs = ExecuteCommandInstruction(
        FreshTCMPIOT(Zeros{6} + 10, Zeros{6} + 11,
            TRUE, FALSE, FALSE), 32);
    let result = ExecuteCommandInstruction(
        FreshTCMPIOT(Zeros{6} + 12, Zeros{6},
            FALSE, TRUE, TRUE), 32);
    assert inputs == CommandExecution_Executed &&
           result == CommandExecution_Executed;
    let completed = ExecuteBundleTileOperation();
    assert completed;
    assert _LastFault == Fault_None;
    let destination = _BundleTileBindings[[1]].destination;
    assert _Tiles[[destination]].storage_kind == TileStorage_PredicateCell;
    assert _Tiles[[destination]].predicate_basis_type == data_type;
    assert _Tiles[[destination]].valid_rows == 1;
    assert _Tiles[[destination]].valid_columns == 2;
    assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN} + 1;
    assert ReadTileElement(destination, 0, 1) == Zeros{PTO_XLEN};
end;

func main() => integer
begin
    RunFreshTCMP(TileDataType_U16);
    RunFreshTCMP(TileDataType_U32);
    return 0;
end;
