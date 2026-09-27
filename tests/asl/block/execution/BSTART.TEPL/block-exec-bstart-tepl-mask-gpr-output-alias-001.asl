// PTO-TEST: {"id":"PTO-AVS-BLOCK-BSTART-TEPL-EXECUTION-MASK-GPR-OUTPUT-ALIAS-001","source":"asl/block/execution/BSTART.TEPL.asl","requirements":["PTO-TCMP-CONTRACT-001","PTO-TCMPS-CONTRACT-001","PTO-TILE-MODEL-EXECUTION-MASK-APPLICABILITY-001","PTO-B-IOR-BINDING-001","PTO-B-IOT-STREAM-001"],"kind":"execution","summary":"Decoded TCMP and TCMPS snapshot a GPR ExecutionMask before publishing the predicate result to the same GPR","pass_condition":"both GPR-carrier comparison bundles preserve the captured pre-operation mask while updating the aliased output destination under PredInv and MERGE","related_sources":["asl/block/model/dispatch/comparison-schema.asl","asl/block/model/dispatch/execution-mask-schema.asl","asl/tile/model/execution/comparison.asl"]}
pure func ComparisonAliasStart(selector: bits(10), data_type: bits(5))
    => bits(64)
begin
    var instruction = Zeros{64} + 0x00019181;
    instruction[26:25] = selector[6:5];
    instruction[24:20] = selector[4:0];
    instruction[31:27] = data_type;
    return instruction;
end;

pure func ComparisonAliasAttributes() => bits(64)
begin
    var instruction = Zeros{64} + 0x00001023;
    instruction[24:20] = DTYPE_NONE;
    // TCMP/TCMPS keep DATR Layout zero; their CUBE carrier is determined by
    // the actual local comparison inputs.
    instruction[11:7] = Zeros{5};
    instruction[14] = '1';
    return instruction;
end;

pure func ComparisonAliasTCMPInputs(left: bits(6), right: bits(6))
    => bits(64)
begin
    var instruction = Zeros{64} + 0x00004013;
    instruction[31:26] = right;
    instruction[25:20] = left;
    instruction[19] = '1';
    instruction[11:9] = '001';
    return instruction;
end;

pure func ComparisonAliasTCMPSInput(source: bits(6)) => bits(64)
begin
    var instruction = Zeros{64} + 0x00005013;
    instruction[25:20] = source;
    instruction[19] = '1';
    instruction[11:9] = '001';
    return instruction;
end;

pure func ComparisonAliasIOR(destination: bits(5), source0: bits(5),
    source1: bits(5), present: boolean) => bits(64)
begin
    var instruction = Zeros{64} + 0x00000013;
    instruction[11:7] = destination;
    instruction[19:15] = source0;
    instruction[24:20] = source1;
    instruction[26] = if present then '1' else '0';
    return instruction;
end;

func AssertComparisonAliasResult()
begin
    let captured = _BundleExecutionMask.low_word;
    let published = ReadPEGPR(0, 3);
    assert captured[0] == '0' && captured[16] == '1';
    assert published[0] == '1' && published[16] == '1';
end;

func main() => integer
begin
    ResetProfileState();
    let tcmp_left_ready = ConfigureCubeTile(
        8, 128, 1, 2, TileDataType_U32, TileLayout_CUBE_M16);
    let tcmp_right_ready = ConfigureCubeTile(
        10, 128, 1, 2, TileDataType_U32, TileLayout_CUBE_M16);
    assert tcmp_left_ready && tcmp_right_ready;
    InstallRelativeTileFixture(8, 8);
    InstallRelativeTileFixture(10, 10);
    WriteTileElement(8, 0, 0, Zeros{PTO_XLEN} + 5);
    WriteTileElement(8, 0, 1, Zeros{PTO_XLEN} + 9);
    WriteTileElement(10, 0, 0, Zeros{PTO_XLEN} + 5);
    WriteTileElement(10, 0, 1, Zeros{PTO_XLEN} + 9);
    MarkTileValidRegionDefined(8);
    MarkTileValidRegionDefined(10);
    var initial_mask = Zeros{PTO_XLEN};
    initial_mask[16] = '1';
    WritePEGPR(0, 3, initial_mask);
    let tcmp_started = ExecuteCommandInstruction(
        ComparisonAliasStart(Zeros{10} + 0x00d,
            TileDataTypeToEncoding(TileDataType_U32)), 32);
    assert tcmp_started == CommandExecution_Executed;
    let tcmp_attributes = ExecuteCommandInstruction(
        ComparisonAliasAttributes(), 32);
    assert tcmp_attributes == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 2);
    let tcmp_inputs = ExecuteCommandInstruction(
        ComparisonAliasTCMPInputs(Zeros{6} + 8, Zeros{6} + 10), 32);
    let tcmp_ior = ExecuteCommandInstruction(
        ComparisonAliasIOR(Zeros{5} + 3, Zeros{5} + 3,
            Zeros{5}, TRUE), 32);
    assert tcmp_inputs == CommandExecution_Executed;
    assert tcmp_ior == CommandExecution_Executed;
    let tcmp_operation = DecodeTileOperation(
        TileDecode_TEPL, Zeros{12} + 0x00d)
        as integer {0..PTO_TILE_OPERATION_COUNT-1};
    let tcmp_completed = ExecuteBundleTileOperation();
    assert tcmp_completed && _LastFault == Fault_None;
    AssertComparisonAliasResult();

    ResetProfileState();
    let tcmps_source_ready = ConfigureCubeTile(
        8, 128, 1, 2, TileDataType_U32, TileLayout_CUBE_M16);
    assert tcmps_source_ready;
    InstallRelativeTileFixture(8, 8);
    WriteTileElement(8, 0, 0, Zeros{PTO_XLEN} + 5);
    WriteTileElement(8, 0, 1, Zeros{PTO_XLEN} + 9);
    MarkTileValidRegionDefined(8);
    WritePEGPR(0, 2, Zeros{PTO_XLEN} + 5);
    WritePEGPR(0, 3, initial_mask);
    let tcmps_started = ExecuteCommandInstruction(
        ComparisonAliasStart(Zeros{10} + 0x02d,
            TileDataTypeToEncoding(TileDataType_U32)), 32);
    assert tcmps_started == CommandExecution_Executed;
    let tcmps_attributes = ExecuteCommandInstruction(
        ComparisonAliasAttributes(), 32);
    assert tcmps_attributes == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 2);
    let tcmps_input = ExecuteCommandInstruction(
        ComparisonAliasTCMPSInput(Zeros{6} + 8), 32);
    let tcmps_ior = ExecuteCommandInstruction(
        ComparisonAliasIOR(Zeros{5} + 3, Zeros{5} + 2,
            Zeros{5} + 3, TRUE), 32);
    assert tcmps_input == CommandExecution_Executed;
    assert tcmps_ior == CommandExecution_Executed;
    let tcmps_completed = ExecuteBundleTileOperation();
    assert tcmps_completed && _LastFault == Fault_None;
    AssertComparisonAliasResult();
    return 0;
end;
