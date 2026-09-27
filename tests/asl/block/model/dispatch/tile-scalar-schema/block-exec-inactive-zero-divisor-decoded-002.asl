// PTO-TEST: {"id":"PTO-AVS-BLOCK-TILE-SCALAR-INACTIVE-ZERO-DIVISOR-DECODED-002","source":"asl/block/model/dispatch/tile-scalar-schema.asl","requirements":["PTO-INST-TILE-TDIVS","PTO-INST-TILE-TREMS","PTO-TILE-MODEL-EXECUTION-MASK-APPLICABILITY-001","PTO-B-IOT-STREAM-001"],"kind":"execution","summary":"Decoded integer TDIVS and TREMS suppress zero-divisor legality when every ExecutionMask coordinate is inactive","pass_condition":"a structurally complete CUBE bundle with an all-inactive PredicateCell mask accepts an omitted zero scalar without reading an operand, while activating one coordinate restores zero-divisor rejection before destination allocation","related_sources":["asl/tile/model/execution/execution-mask-state.asl","asl/tile/model/legality/operand-schema.asl"]}
pure func InactiveScalarStart(selector: bits(10)) => bits(64)
begin
    var instruction = Zeros{64} + 0x00019181;
    instruction[26:25] = selector[6:5];
    instruction[24:20] = selector[4:0];
    instruction[31:27] = TileDataTypeToEncoding(TileDataType_U32);
    return instruction;
end;

pure func InactiveScalarAttributes() => bits(64)
begin
    var instruction = Zeros{64} + 0x00001023;
    instruction[24:20] = DTYPE_NONE;
    instruction[11:7] = Zeros{5} + 31;
    return instruction;
end;

pure func InactiveScalarBinding() => bits(64)
begin
    var instruction = Zeros{64} + 0x00004013;
    instruction[31:26] = Zeros{6} + 12;
    instruction[25:20] = Zeros{6} + 10;
    instruction[19] = '1';
    instruction[18:15] = '0010';
    instruction[11:9] = '001';
    return instruction;
end;

func RunInactiveZeroDivisor(selector: bits(10), active: boolean)
begin
    ResetProfileState();
    let source_ready = ConfigureCubeTile(
        10, 128, 1, 2, TileDataType_U32, TileLayout_CUBE_M16);
    let mask_ready = ConfigurePredicateCell(
        12, 128, 1, 2, TileDataType_U32, TileLayout_CUBE_M16);
    assert source_ready && mask_ready;
    InstallRelativeTileFixture(10, 10);
    InstallRelativeTileFixture(12, 12);
    WriteTileElement(10, 0, 0, Zeros{PTO_XLEN} + 8);
    WriteTileElement(10, 0, 1, Zeros{PTO_XLEN} + 9);
    MarkTileValidRegionDefined(10);
    WriteTileElement(12, 0, 0,
        if active then Zeros{PTO_XLEN} + 1 else Zeros{PTO_XLEN});
    WriteTileElement(12, 0, 1, Zeros{PTO_XLEN});
    _Tiles[[12]].contents_defined = TRUE;

    let started = ExecuteCommandInstruction(InactiveScalarStart(selector), 32);
    let attributes = ExecuteCommandInstruction(InactiveScalarAttributes(), 32);
    assert started == CommandExecution_Executed &&
           attributes == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 2);
    let binding = ExecuteCommandInstruction(InactiveScalarBinding(), 32);
    assert binding == CommandExecution_Executed;
    let operation = DecodeTileOperation(
        TileDecode_TEPL, Zeros{12} + UInt(selector))
        as integer {0..PTO_TILE_OPERATION_COUNT-1};
    let resolved = ResolveBundleRelativeTileSources();
    let marked = MarkSelectedBundleExecutionMaskCarrier(operation);
    let captured = CaptureSelectedBundleExecutionMask(operation);
    assert resolved && marked && captured;
    assert SelectedBundleClosedTileScalarBinarySchemaLegal(operation) != active;
    assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;
end;

func main() => integer
begin
    RunInactiveZeroDivisor(Zeros{10} + 0x023, FALSE);
    RunInactiveZeroDivisor(Zeros{10} + 0x023, TRUE);
    RunInactiveZeroDivisor(Zeros{10} + 0x024, FALSE);
    RunInactiveZeroDivisor(Zeros{10} + 0x024, TRUE);
    return 0;
end;
