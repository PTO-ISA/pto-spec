// PTO-TEST: {"id":"PTO-AVS-BLOCK-EXECUTION-MASK-PREDICATETILE-BINARY-001","source":"asl/block/model/dispatch/execution-mask-schema.asl","requirements":["PTO-REQ-TEPL-PREDICATE-CARRIER-001","PTO-TADD-CONTRACT-001","PTO-B-IOT-STREAM-001"],"kind":"execution","summary":"A final PredicateCell B.IOT source binds independently of the two TADD inputs and gates inactive CUBE results","pass_condition":"the existing two-source input record is followed by a final mask-source destination record; active coordinates add and inactive coordinates become typed zero","related_sources":["asl/block/model/dispatch/tile-schema.asl","asl/block/model/dispatch/tile-instruction-operands.asl","asl/tile/model/execution/elementwise.asl"]}
pure func ExecutionMaskTADDStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00019181;
    instruction[26:25] = Zeros{2};
    instruction[24:20] = Zeros{5};
    instruction[31:27] = TileDataTypeToEncoding(TileDataType_U16);
    return instruction;
end;

pure func ExecutionMaskCUBEM16ZeroAttributes() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001023;
    instruction[24:20] = DTYPE_NONE;
    instruction[11:7] = Zeros{5} + 31;
    instruction[13] = '1';
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    let left_ready = ConfigureCubeTile(
        1, 256, 2, 2, TileDataType_U16, TileLayout_CUBE_M16);
    let right_ready = ConfigureCubeTile(
        2, 256, 2, 2, TileDataType_U16, TileLayout_CUBE_M16);
    let predicate_ready = ConfigurePredicateCell(
        3, 128, 2, 2, TileDataType_FP32, TileLayout_CUBE_M16);
    assert left_ready && right_ready && predicate_ready;
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 10);
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 20);
    WriteTileElement(1, 1, 0, Zeros{PTO_XLEN} + 30);
    WriteTileElement(1, 1, 1, Zeros{PTO_XLEN} + 40);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(2, 0, 1, Zeros{PTO_XLEN} + 2);
    WriteTileElement(2, 1, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(2, 1, 1, Zeros{PTO_XLEN} + 4);
    WriteTileElement(3, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(3, 0, 1, Zeros{PTO_XLEN});
    WriteTileElement(3, 1, 0, Zeros{PTO_XLEN});
    WriteTileElement(3, 1, 1, Zeros{PTO_XLEN} + 1);
    MarkTileValidRegionDefined(1);
    MarkTileValidRegionDefined(2);
    _Tiles[[3]].contents_defined = TRUE;

    let started = ExecuteCommandInstruction(ExecutionMaskTADDStart(), 32);
    assert started == CommandExecution_Executed;
    let attributes = ExecuteCommandInstruction(
        ExecutionMaskCUBEM16ZeroAttributes(), 32);
    assert attributes == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 2);
    AddBundleTileBinding(
        FALSE, 0, 0, '1111', TRUE, TRUE, 1, 2, FALSE);
    AddBundleTileBinding(
        TRUE, 0, 1, '1111', TRUE, FALSE, 3, 0, TRUE);

    let operation = DecodeTileOperation(
        TileDecode_TEPL, Zeros{12})
        as integer {0..PTO_TILE_OPERATION_COUNT-1};
    assert BundleExecutionMaskTileCarrierPresent(operation);
    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
    let destination = _BundleTileBindings[[1]].destination;
    assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN} + 11;
    assert ReadTileElement(destination, 0, 1) == Zeros{PTO_XLEN};
    assert ReadTileElement(destination, 1, 0) == Zeros{PTO_XLEN};
    assert ReadTileElement(destination, 1, 1) == Zeros{PTO_XLEN} + 44;
    return 0;
end;
