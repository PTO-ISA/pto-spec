// PTO-TEST: {"id":"PTO-AVS-TILE-TCMPS-LOCAL64-DECODED-CELL-001","source":"asl/tile/tile-scalar-and-immediate/logical/TCMPS.asl","requirements":["PTO-TCMPS-CONTRACT-001","PTO-CUBE-M32-B64-DOUBLE-CELL-001"],"kind":"execution","summary":"Decoded M32 TCMPS reaches its CELL carrier with full-width 64-bit operands.","pass_condition":"Decoded binder, datatype, predicate and destination allocation paths preserve logical predicate coordinates and both halves of selected 64-bit elements.","related_sources":["asl/block/model/dispatch/tile-scalar-schema.asl","asl/block/model/dispatch/destination-shape.asl","asl/tile/model/execution/comparison.asl"]}
pure func TCMPSStart() => bits(64)
begin
    var instruction = Zeros{64} + 0x00019181;
    instruction[26:25] = '01';
    instruction[24:20] = Zeros{5} + 13;
    instruction[31:27] = TileDataTypeToEncoding(TileDataType_FP64);
    return instruction;
end;

pure func TCMPSCellTiles(source: bits(6)) => bits(64)
begin
    var instruction = Zeros{64} + 0x00005013;
    instruction[25:20] = source;
    instruction[19] = '1';
    instruction[18:15] = Zeros{4} + 1;
    instruction[11:9] = '001';
    return instruction;
end;

pure func TCMPSCellScalar(source: bits(5)) => bits(64)
begin
    var instruction = Zeros{64} + 0x00000013;
    instruction[19:15] = source;
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    let source_ready = ConfigureCubeTile(
        10, 256, 1, 1, TileDataType_FP64,
        TileLayout_CUBE_M32);
    assert source_ready;
    WriteTileElement(10, 0, 0, Zeros{PTO_XLEN} + 0x3ff0000000000000);
    MarkTileValidRegionDefined(10);
    WriteGPR(4, Zeros{PTO_XLEN} + 0x3ff0000000000000);

    let started = ExecuteCommandInstruction(TCMPSStart(), 32);
    assert started == CommandExecution_Executed;
    SetBundleDataAttributeState(
        DTYPE_NONE, Zeros{5}, '01', Zeros{3}, Zeros{3}, FALSE, FALSE);
    _BundleDataAttributesPresent = TRUE;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    let tiles = ExecuteCommandInstruction(
        TCMPSCellTiles(Zeros{6} + 10), 32);
    let scalar = ExecuteCommandInstruction(
        TCMPSCellScalar(Zeros{5} + 4), 32);
    assert tiles == CommandExecution_Executed;
    assert scalar == CommandExecution_Executed;
    let operation = 37 as integer {0..PTO_TILE_OPERATION_COUNT-1};
    assert BundleOperationBindingsComplete(operation);
    assert BundleOperationGPRBindingValuesLegal(operation);
    let attributes_legal = SelectedBundleTileDataAttributesLegal(operation);
    assert attributes_legal;
    assert SelectedBundleClosedSchemasLegal(operation);
    assert SelectedBundleTileMasksLegal();

    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
    let destination = _BundleTileBindings[[0]].destination;
    assert _Tiles[[destination]].storage_kind == TileStorage_PredicateCell;
    assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN} + 1;
    assert TileElementDefined(destination, 0, 1);
    assert ReadTileElement(destination, 0, 1) == Zeros{PTO_XLEN} + 1;
    return 0;
end;
