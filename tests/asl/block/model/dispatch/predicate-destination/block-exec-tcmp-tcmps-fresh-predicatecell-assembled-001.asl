// PTO-TEST: {"id":"PTO-AVS-BLOCK-TCMP-TCMPS-FRESH-PREDICATECELL-ASSEMBLED-001","source":"asl/block/model/dispatch/predicate-destination.asl","requirements":["PTO-TCMP-CONTRACT-001","PTO-TCMPS-CONTRACT-001","PTO-B-ASSEMBLE-LOCAL-GENERATION-001","PTO-TILE-MODEL-EXECUTION-MASK-APPLICABILITY-001","PTO-B-IOT-STREAM-001"],"kind":"execution","summary":"Encoded CUBE TCMP and TCMPS assemble fresh U16/U32 PredicateCell outputs through the Local writer path","pass_condition":"all four U16/U32 comparison forms complete B.ASSEMBLE INIT_LAST with a U8 PredicateCell parent whose basis, capacity, physical geometry, valid region, and numeric result match the operation","related_sources":["asl/block/model/dispatch/comparison-schema.asl","asl/block/model/dispatch/tile-scalar-schema.asl","asl/block/model/operands/local-generation-cube-writer-effects.asl","asl/tile/model/legality/destination-value-operations.asl"]}
pure func FreshCellCompareStart(data_type: TileDataType,
    scalar: boolean) => bits(64)
begin
    var instruction = Zeros{64} + 0x00019181;
    let selector = if scalar then Zeros{10} + 0x02d
        else Zeros{10} + 0x00d;
    instruction[26:25] = selector[6:5];
    instruction[24:20] = selector[4:0];
    instruction[31:27] = TileDataTypeToEncoding(data_type);
    return instruction;
end;

pure func FreshCellCompareAttributes() => bits(64)
begin
    var instruction = Zeros{64} + 0x00001023;
    instruction[24:20] = DTYPE_NONE;
    instruction[13] = '1';
    return instruction;
end;

pure func FreshCellTCMPSAttributes() => bits(64)
begin
    var instruction = Zeros{64} + 0x00001023;
    instruction[24:20] = DTYPE_NONE;
    return instruction;
end;

pure func FreshCellCompareTCMPIOT(source0: bits(6), source1: bits(6),
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

pure func FreshCellCompareTCMPSIOT(source: bits(6)) => bits(64)
begin
    var instruction = Zeros{64} + 0x00005013;
    instruction[25:20] = source;
    instruction[19] = '1';
    instruction[18:15] = '0010';
    instruction[11:9] = '001';
    return instruction;
end;

pure func FreshCellCompareIOR(source: bits(5)) => bits(64)
begin
    var instruction = Zeros{64} + 0x00000013;
    instruction[19:15] = source;
    return instruction;
end;

pure func FreshCellCompareAssemble() => bits(64)
begin
    var instruction = Zeros{64} + 0x00001053;
    instruction[31] = '1';
    instruction[11] = '1';
    instruction[10:7] = Zeros{4} + 1;
    return instruction;
end;

func AssertFreshCellResult(destination: TileIndex,
    data_type: TileDataType)
begin
    assert _Tiles[[destination]].storage_kind == TileStorage_PredicateCell;
    assert _Tiles[[destination]].data_type == TileDataType_U8;
    assert _Tiles[[destination]].predicate_basis_type == data_type;
    assert _Tiles[[destination]].capacity_bytes == 256 &&
           _Tiles[[destination]].rows == 16 &&
           _Tiles[[destination]].columns == 16;
    assert _Tiles[[destination]].valid_rows == 1 &&
           _Tiles[[destination]].valid_columns == 2;
    assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN} + 1;
    assert ReadTileElement(destination, 0, 1) == Zeros{PTO_XLEN};
end;

func RunFreshCellTCMP(data_type: TileDataType)
begin
    ResetProfileState();
    let left_ready = ConfigureCubeTile(10, 128, 1, 2, data_type,
        TileLayout_CUBE_M16);
    let right_ready = ConfigureCubeTile(11, 128, 1, 2, data_type,
        TileLayout_CUBE_M16);
    let mask_ready = ConfigurePredicateCell(12, 128, 1, 2, data_type,
        TileLayout_CUBE_M16);
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

    let started = ExecuteCommandInstruction(
        FreshCellCompareStart(data_type, FALSE), 32);
    let attributes = ExecuteCommandInstruction(
        FreshCellCompareAttributes(), 32);
    assert started == CommandExecution_Executed &&
           attributes == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 2);
    let inputs = ExecuteCommandInstruction(FreshCellCompareTCMPIOT(
        Zeros{6} + 10, Zeros{6} + 11, TRUE, FALSE, FALSE), 32);
    let result = ExecuteCommandInstruction(FreshCellCompareTCMPIOT(
        Zeros{6} + 12, Zeros{6}, FALSE, TRUE, TRUE), 32);
    assert inputs == CommandExecution_Executed &&
           result == CommandExecution_Executed;
    let assembled = ExecuteCommandInstruction(
        FreshCellCompareAssemble(), 32);
    assert assembled == CommandExecution_Executed;
    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
    AssertFreshCellResult(_BundleTileBindings[[1]].destination, data_type);
end;

func RunFreshCellTCMPS(data_type: TileDataType)
begin
    ResetProfileState();
    let source_ready = ConfigureCubeTile(10, 128, 1, 2, data_type,
        TileLayout_CUBE_M16);
    assert source_ready;
    InstallRelativeTileFixture(10, 10);
    WriteTileElement(10, 0, 0, Zeros{PTO_XLEN} + 5);
    WriteTileElement(10, 0, 1, Zeros{PTO_XLEN} + 4);
    MarkTileValidRegionDefined(10);
    WritePEGPR(0, 2, Zeros{PTO_XLEN} + 5);

    let started = ExecuteCommandInstruction(
        FreshCellCompareStart(data_type, TRUE), 32);
    let attributes = ExecuteCommandInstruction(
        FreshCellTCMPSAttributes(), 32);
    assert started == CommandExecution_Executed &&
           attributes == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 2);
    let scalar_binding = ExecuteCommandInstruction(
        FreshCellCompareIOR(Zeros{5} + 2), 32);
    let input = ExecuteCommandInstruction(
        FreshCellCompareTCMPSIOT(Zeros{6} + 10), 32);
    assert scalar_binding == CommandExecution_Executed &&
           input == CommandExecution_Executed;
    let assembled = ExecuteCommandInstruction(
        FreshCellCompareAssemble(), 32);
    assert assembled == CommandExecution_Executed;
    let operation = DecodeTileOperation(
        TileDecode_TEPL, Zeros{12} + 0x02d)
        as integer {0..PTO_TILE_OPERATION_COUNT-1};
    assert _BundleScalarBindings[[0]].valid &&
           _BundleScalarBindings[[0]].source0 == 2 &&
           _BundleScalarBindings[[0]].source1 == 0 &&
           _BundleScalarBindings[[0]].source2 == 0;
    assert BundleComparisonBindingUsesOneSource(
        _BundleScalarBindings[[0]]);
    assert SelectedBundleClosedTCMPSSchemaLegal(operation);
    let completed = ExecuteBundleTileOperation();
    assert _LastFault == Fault_None;
    assert completed;
    AssertFreshCellResult(_BundleTileBindings[[0]].destination, data_type);
end;

func main() => integer
begin
    RunFreshCellTCMP(TileDataType_U16);
    RunFreshCellTCMP(TileDataType_U32);
    RunFreshCellTCMPS(TileDataType_U16);
    RunFreshCellTCMPS(TileDataType_U32);
    return 0;
end;
