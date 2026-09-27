// PTO-TEST: {"id":"PTO-AVS-BLOCK-TCVT-SOURCE-LAYOUT-MASK-DECODED-002","source":"asl/block/model/dispatch/tcvt-schema.asl","requirements":["PTO-TCVT-CONTRACT-001","PTO-TILE-MODEL-EXECUTION-MASK-APPLICABILITY-001","PTO-B-DATR-FIELDS-001","PTO-B-IOR-BINDING-001","PTO-B-IOT-STREAM-001"],"kind":"execution","summary":"Decoded CUBE TCVT derives ExecutionMask coordinates from its retained source while B.DATR Layout remains NORM","pass_condition":"a PredicateCell carrier applies ZERO to an inactive destination coordinate and a GPR carrier applies MERGE from the prior hand output, with both preserving the source CUBE layout in the converted destination","related_sources":["asl/block/model/dispatch/command-data-attributes.asl","asl/block/model/dispatch/scalar-schema.asl","asl/block/model/dispatch/execution-mask-schema.asl"]}
pure func MaskedTCVTStart() => bits(64)
begin
    var instruction = Zeros{64} + 0x00019181;
    let selector = Zeros{10} + 0x01b;
    instruction[26:25] = selector[6:5];
    instruction[24:20] = selector[4:0];
    instruction[31:27] = TileDataTypeToEncoding(TileDataType_U16);
    return instruction;
end;

pure func MaskedTCVTAttributes(zero_inactive: boolean) => bits(64)
begin
    var instruction = Zeros{64} + 0x00001023;
    instruction[24:20] = TileDataTypeToEncoding(TileDataType_U32);
    // Layout remains NORM even though the retained source is CUBE_M16.
    instruction[11:7] = Zeros{5};
    instruction[13] = if zero_inactive then '1' else '0';
    return instruction;
end;

pure func MaskedTCVTIOT(source0: bits(6), source1: bits(6),
    source1_valid: boolean) => bits(64)
begin
    var instruction = if source1_valid then
        Zeros{64} + 0x00004013 else Zeros{64} + 0x00005013;
    instruction[25:20] = source0;
    instruction[31:26] = source1;
    instruction[19] = '1';
    instruction[18:15] = '0001';
    instruction[11:9] = '001';
    return instruction;
end;

pure func MaskedTCVTIOR(mask: bits(5)) => bits(64)
begin
    var instruction = Zeros{64} + 0x00000013;
    instruction[19:15] = mask;
    instruction[26] = '1';
    return instruction;
end;

func BeginMaskedTCVT(zero_inactive: boolean)
begin
    let started = ExecuteCommandInstruction(MaskedTCVTStart(), 32);
    let attributes = ExecuteCommandInstruction(
        MaskedTCVTAttributes(zero_inactive), 32);
    assert started == CommandExecution_Executed &&
           attributes == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 1);
end;

func InstallMaskedTCVTSource()
begin
    let source_ready = ConfigureCubeTile(
        10, 128, 1, 2, TileDataType_U16, TileLayout_CUBE_M16);
    assert source_ready;
    InstallRelativeTileFixture(10, 10);
    WriteTileElement(10, 0, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(10, 0, 1, Zeros{PTO_XLEN} + 4);
    MarkTileValidRegionDefined(10);
end;

func RunMaskedTCVTPredicateZERO()
begin
    ResetProfileState();
    InstallMaskedTCVTSource();
    let mask_ready = ConfigurePredicateCell(
        11, 128, 1, 2, TileDataType_U16, TileLayout_CUBE_M16);
    assert mask_ready;
    InstallRelativeTileFixture(11, 11);
    WriteTileElement(11, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(11, 0, 1, Zeros{PTO_XLEN});
    MarkTileValidRegionDefined(11);
    BeginMaskedTCVT(TRUE);
    let bound = ExecuteCommandInstruction(
        MaskedTCVTIOT(Zeros{6} + 10, Zeros{6} + 11, TRUE), 32);
    assert bound == CommandExecution_Executed;
    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
    let destination = _BundleTileBindings[[0]].destination;
    assert _Tiles[[destination]].layout == TileLayout_CUBE_M16;
    assert _Tiles[[destination]].data_type == TileDataType_U32;
    assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN} + 3;
    assert ReadTileElement(destination, 0, 1) == Zeros{PTO_XLEN};
end;

func RunMaskedTCVTGPRMERGE()
begin
    ResetProfileState();
    InstallMaskedTCVTSource();
    let base_ready = ConfigureCubeTile(
        12, 128, 1, 2, TileDataType_U32, TileLayout_CUBE_M16);
    assert base_ready;
    InstallRelativeTileFixture(0, 12);
    WriteTileElement(12, 0, 0, Zeros{PTO_XLEN} + 90);
    WriteTileElement(12, 0, 1, Zeros{PTO_XLEN} + 91);
    MarkTileValidRegionDefined(12);
    WritePEGPR(0, 2, Zeros{PTO_XLEN} + 1);
    BeginMaskedTCVT(FALSE);
    let scalar = ExecuteCommandInstruction(
        MaskedTCVTIOR(Zeros{5} + 2), 32);
    let bound = ExecuteCommandInstruction(
        MaskedTCVTIOT(Zeros{6} + 10, Zeros{6}, FALSE), 32);
    assert scalar == CommandExecution_Executed &&
           bound == CommandExecution_Executed;
    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
    let destination = _BundleTileBindings[[0]].destination;
    assert destination == 0;
    assert _Tiles[[destination]].layout == TileLayout_CUBE_M16;
    assert _Tiles[[destination]].data_type == TileDataType_U32;
    assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN} + 3;
    assert ReadTileElement(destination, 0, 1) == Zeros{PTO_XLEN} + 91;
end;

func main() => integer
begin
    RunMaskedTCVTPredicateZERO();
    RunMaskedTCVTGPRMERGE();
    return 0;
end;
