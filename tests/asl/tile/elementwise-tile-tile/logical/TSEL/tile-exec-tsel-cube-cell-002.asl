// PTO-TEST: {"id":"PTO-AVS-TILE-TSEL-CUBE-CELL-002","source":"asl/tile/elementwise-tile-tile/logical/TSEL.asl","requirements":["PTO-TSEL-CONTRACT-001"],"kind":"execution","summary":"Decoded CUBE TSEL consumes PredicateCell values and allocates a CUBE destination","pass_condition":"canonical one and zero PredicateCell bytes select the true and false FP32 CUBE_M32 elements into a new CUBE destination","related_sources":["asl/block/model/dispatch/comparison-schema.asl","asl/block/model/dispatch/destination-shape.asl","asl/tile/model/execution/comparison.asl"]}
pure func TSELStart() => bits(64)
begin
    var instruction = Zeros{64} + 0x00019181;
    instruction[26:25] = '00';
    instruction[24:20] = Zeros{5} + 26;
    instruction[31:27] = Zeros{5} + 1;
    return instruction;
end;

pure func TSELCellInputs(mask: bits(6), source_true: bits(6)) => bits(64)
begin
    var instruction = Zeros{64} + 0x00004013;
    instruction[31:26] = source_true;
    instruction[25:20] = mask;
    instruction[11:9] = '001';
    return instruction;
end;

pure func TSELCellResult(source_false: bits(6)) => bits(64)
begin
    var instruction = Zeros{64} + 0x00005013;
    instruction[25:20] = source_false;
    instruction[19] = '1';
    instruction[18:15] = Zeros{4} + 2;
    instruction[11:9] = '001';
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    let predicate_ready = ConfigurePredicateCell(
        8, 128, 1, 2, TileDataType_FP32, TileLayout_CUBE_M32);
    let true_ready = ConfigureCubeTile(
        10, 256, 1, 2, TileDataType_FP32,
        TileLayout_CUBE_M32, TileLocation_Matrix);
    let false_ready = ConfigureCubeTile(
        11, 256, 1, 2, TileDataType_FP32,
        TileLayout_CUBE_M32, TileLocation_Matrix);
    assert predicate_ready && true_ready && false_ready;
    InstallRelativeTileFixture(8, 8);
    WriteTileElement(8, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(8, 0, 1, Zeros{PTO_XLEN});
    WriteTileElement(10, 0, 0, Zeros{PTO_XLEN} + 10);
    WriteTileElement(10, 0, 1, Zeros{PTO_XLEN} + 20);
    WriteTileElement(11, 0, 0, Zeros{PTO_XLEN} + 30);
    WriteTileElement(11, 0, 1, Zeros{PTO_XLEN} + 40);
    _Tiles[[8]].contents_defined = TRUE;
    MarkTileValidRegionDefined(10);
    MarkTileValidRegionDefined(11);

    let started = ExecuteCommandInstruction(TSELStart(), 32);
    assert started == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    let inputs = ExecuteCommandInstruction(
        TSELCellInputs(Zeros{6} + 8, Zeros{6} + 10), 32);
    let result_binding = ExecuteCommandInstruction(
        TSELCellResult(Zeros{6} + 11), 32);
    assert inputs == CommandExecution_Executed;
    assert result_binding == CommandExecution_Executed;
    let operation = 22 as integer {0..PTO_TILE_OPERATION_COUNT-1};
    assert BundleOperationBindingsComplete(operation);
    assert BundleOperationGPRBindingValuesLegal(operation);
    let attributes_legal = SelectedBundleTileDataAttributesLegal(operation);
    assert attributes_legal;
    assert SelectedBundleClosedSchemasLegal(operation);
    assert SelectedBundleTileMasksLegal();

    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
    let destination = _BundleTileBindings[[1]].destination;
    assert _Tiles[[destination]].layout == TileLayout_CUBE_M32;
    assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN} + 10;
    assert ReadTileElement(destination, 0, 1) == Zeros{PTO_XLEN} + 40;
    return 0;
end;
