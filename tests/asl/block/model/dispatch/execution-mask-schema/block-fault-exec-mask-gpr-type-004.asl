// PTO-TEST: {"id":"PTO-AVS-BLOCK-EXECUTION-MASK-GPR-TYPE-004","source":"asl/block/model/dispatch/execution-mask-schema.asl","requirements":["PTO-TILE-MODEL-EXECUTION-MASK-APPLICABILITY-001","PTO-B-IOR-BINDING-001","PTO-TABS-CONTRACT-001"],"kind":"fault","summary":"An unsupported CUBE operation type rejects a GPR ExecutionMask before predicate field mapping.","pass_condition":"A decoded E8M0 TABS bundle with a GPR mask raises TileLegality without an internal assertion or destination allocation.","related_sources":["asl/tile/model/legality/predicate-carriers.asl","asl/block/model/dispatch/scalar-schema.asl"]}
pure func UnsupportedMaskTypeStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00019181;
    instruction[26:25] = Zeros{2};
    instruction[24:20] = Zeros{5} + 0x0f;
    instruction[31:27] = TileDataTypeToEncoding(TileDataType_E8M0);
    return instruction;
end;

pure func UnsupportedMaskTypeAttributes() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001023;
    instruction[24:20] = DTYPE_NONE;
    instruction[11:7] = Zeros{5} + 31;
    return instruction;
end;

pure func UnsupportedMaskTypeIOR() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000013;
    instruction[19:15] = Zeros{5} + 2;
    instruction[26] = '1';
    return instruction;
end;

pure func UnsupportedMaskTypeIOT() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[25:20] = Zeros{6} + 10;
    instruction[19] = '1';
    instruction[18:15] = '0001';
    instruction[11:9] = '111';
    instruction[8:7] = Zeros{2};
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    let source_ready = ConfigureCubeTile(
        10, 128, 1, 1, TileDataType_U8, TileLayout_CUBE_M16);
    assert source_ready;
    InstallRelativeTileFixture(10, 10);
    WriteTileElement(10, 0, 0, Zeros{PTO_XLEN} + 0x7f);
    MarkTileValidRegionDefined(10);
    WritePEGPR(0, 2, Zeros{PTO_XLEN} + 1);

    let started = ExecuteCommandInstruction(UnsupportedMaskTypeStart(), 32);
    let attributed = ExecuteCommandInstruction(
        UnsupportedMaskTypeAttributes(), 32);
    let masked = ExecuteCommandInstruction(UnsupportedMaskTypeIOR(), 32);
    let bound = ExecuteCommandInstruction(UnsupportedMaskTypeIOT(), 32);
    assert started == CommandExecution_Executed;
    assert attributed == CommandExecution_Executed;
    assert masked == CommandExecution_Executed;
    assert bound == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 1);
    assert !_Tiles[[0]].allocated;

    let rejected = ExecuteBundleTileOperation();
    assert !rejected && _LastFault == Fault_TileLegality;
    assert !_Tiles[[0]].allocated;
    assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;
    return 0;
end;
