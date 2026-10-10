// PTO-TEST: {"id":"PTO-AVS-TILE-TSEL-LOCAL64-DECODED-CELL-001","source":"asl/tile/elementwise-tile-tile/logical/TSEL.asl","requirements":["PTO-TSEL-CONTRACT-001","PTO-CUBE-M32-B64-DOUBLE-CELL-001"],"kind":"execution","summary":"Decoded M32 TSEL reaches its CELL carrier with full-width 64-bit operands.","pass_condition":"Decoded binder, datatype, predicate and destination allocation paths preserve logical predicate coordinates and both halves of selected 64-bit elements.","related_sources":["asl/block/model/dispatch/comparison-schema.asl","asl/block/model/dispatch/destination-shape.asl","asl/tile/model/execution/comparison.asl"]}
pure func TSELStart() => bits(64)
begin
    var instruction = Zeros{64} + 0x00019181;
    instruction[26:25] = '00';
    instruction[24:20] = Zeros{5} + 26;
    instruction[31:27] = TileDataTypeToEncoding(TileDataType_FP64);
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
    instruction[18:15] = Zeros{4} + 3;
    instruction[11:9] = '001';
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    let predicate_ready = ConfigurePredicateCell(
        8, 128, 1, 2, TileDataType_FP64, TileLayout_CUBE_M32);
    let true_ready = ConfigureCubeTile(
        10, 512, 1, 2, TileDataType_FP64,
        TileLayout_CUBE_M32);
    let false_ready = ConfigureCubeTile(
        11, 512, 1, 2, TileDataType_FP64,
        TileLayout_CUBE_M32);
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
    SetBundleDimension(2, Zeros{PTO_XLEN} + 2);
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
