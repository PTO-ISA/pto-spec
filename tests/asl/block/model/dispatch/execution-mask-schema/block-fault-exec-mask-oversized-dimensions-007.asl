// PTO-TEST: {"id":"PTO-AVS-BLOCK-EXECUTION-MASK-OVERSIZED-DIMENSIONS-007","source":"asl/block/model/dispatch/execution-mask-schema.asl","requirements":["PTO-TILE-MODEL-EXECUTION-MASK-APPLICABILITY-001","PTO-CUBE-CELL-TRANSPORT-001","PTO-TROWEXPAND-CONTRACT-001","PTO-B-DIM-WRITE-001","PTO-B-IOR-BINDING-001"],"kind":"fault","summary":"Predicated schemas reject raw bundle dimensions above the bounded Tile coordinate domain without narrowing them during mask preflight.","pass_condition":"Raw coordinate resolution preserves 65535 and 65536 distinctly, while decoded predicated CUBE TLOAD and TROWEXPAND bundles with an oversized row dimension raise TileLegality without an internal constrained-cast assertion or destination allocation.","related_sources":["asl/block/model/dispatch/tlsu-layout-conversion.asl","asl/block/model/dispatch/expansion-schema.asl","asl/block/model/schema/dimensions.asl"]}
pure func OversizedMaskAttributes() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001023;
    instruction[24:20] = DTYPE_NONE;
    instruction[11:7] = Zeros{5} + 31;
    instruction[13] = '1';
    return instruction;
end;

pure func OversizedMaskIOR() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000013;
    instruction[19:15] = Zeros{5} + 2;
    instruction[26] = '1';
    return instruction;
end;

pure func OversizedTLOADStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00011181;
    instruction[31:27] = TileDataTypeToEncoding(TileDataType_U16);
    return instruction;
end;

pure func OversizedTLOADDestination() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00006013;
    instruction[18:15] = '0001';
    instruction[11:9] = '111';
    instruction[19] = '1';
    instruction[8:7] = Zeros{2};
    return instruction;
end;

pure func OversizedTROWEXPANDStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00019181;
    instruction[26:25] = '10';
    instruction[24:20] = '00100';
    instruction[31:27] = TileDataTypeToEncoding(TileDataType_U32);
    return instruction;
end;

pure func OversizedTROWEXPANDBinding() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[25:20] = Zeros{6} + 10;
    instruction[19] = '1';
    instruction[18:15] = '0010';
    instruction[11:9] = '001';
    return instruction;
end;

func InstallOversizedDimensions()
begin
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 65536);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 1);
end;

func RunOversizedMaskedTLOAD()
begin
    ResetProfileState();
    WritePEGPR(0, 2, Zeros{PTO_XLEN} + 1);
    let started = ExecuteCommandInstruction(OversizedTLOADStart(), 32);
    let attributed = ExecuteCommandInstruction(OversizedMaskAttributes(), 32);
    let masked = ExecuteCommandInstruction(OversizedMaskIOR(), 32);
    assert started == CommandExecution_Executed;
    assert attributed == CommandExecution_Executed;
    assert masked == CommandExecution_Executed;
    InstallOversizedDimensions();
    let bound = ExecuteCommandInstruction(OversizedTLOADDestination(), 32);
    assert bound == CommandExecution_Executed;

    let operation = DecodeTileOperation(TileDecode_TLSU, Zeros{12})
        as integer {0..PTO_TILE_OPERATION_COUNT-1};
    assert BundleExecutionMaskCoordinateValidRows(operation) == 65536;
    let rejected = ExecuteBundleTileOperation();
    assert !rejected && _LastFault == Fault_TileLegality;
    assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;
end;

func RunOversizedMaskedTROWEXPAND()
begin
    ResetProfileState();
    let source_ready = ConfigureCubeTile(
        10, 128, 1, 1, TileDataType_U32, TileLayout_CUBE_M16);
    assert source_ready;
    InstallRelativeTileFixture(10, 10);
    WriteTileElement(10, 0, 0, Zeros{PTO_XLEN} + 7);
    MarkTileValidRegionDefined(10);
    WritePEGPR(0, 2, Zeros{PTO_XLEN} + 1);

    let started = ExecuteCommandInstruction(OversizedTROWEXPANDStart(), 32);
    let attributed = ExecuteCommandInstruction(OversizedMaskAttributes(), 32);
    let masked = ExecuteCommandInstruction(OversizedMaskIOR(), 32);
    assert started == CommandExecution_Executed;
    assert attributed == CommandExecution_Executed;
    assert masked == CommandExecution_Executed;
    InstallOversizedDimensions();
    let bound = ExecuteCommandInstruction(OversizedTROWEXPANDBinding(), 32);
    assert bound == CommandExecution_Executed;

    let operation = DecodeTileOperation(
        TileDecode_TEPL, Zeros{12} + 0x044)
        as integer {0..PTO_TILE_OPERATION_COUNT-1};
    assert BundleExecutionMaskCoordinateValidRows(operation) == 65536;
    let rejected = ExecuteBundleTileOperation();
    assert !rejected && _LastFault == Fault_TileLegality;
    assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;
end;

func main() => integer
begin
    ResetProfileState();
    _BundleOperation.valid = TRUE;
    _BundleOperation.operation_class = BundleOperation_TileMemory;
    _BundleOperation.selector_valid = TRUE;
    _BundleOperation.selector = Zeros{10};
    _BundleDataAttributesPresent = TRUE;
    _BundleDataAttributes.data_layout = Zeros{5} + 21;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 65535);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 65535);
    let transport = DecodeTileOperation(TileDecode_TLSU, Zeros{12})
        as integer {0..PTO_TILE_OPERATION_COUNT-1};
    assert BundleExecutionMaskCoordinateValidRows(transport) == 65535;
    assert BundleExecutionMaskCoordinateValidColumns(transport) == 65535;
    _BundleDimensions[[0]] = Zeros{PTO_XLEN} + 65536;
    _BundleDimensions[[1]] = Zeros{PTO_XLEN} + 65536;
    assert BundleExecutionMaskCoordinateValidRows(transport) == 65536;
    assert BundleExecutionMaskCoordinateValidColumns(transport) == 65536;

    RunOversizedMaskedTLOAD();
    RunOversizedMaskedTROWEXPAND();
    return 0;
end;
