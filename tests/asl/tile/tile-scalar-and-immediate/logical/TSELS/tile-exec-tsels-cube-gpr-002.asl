// PTO-TEST: {"id":"PTO-AVS-TILE-TSELS-CUBE-GPR-002","source":"asl/tile/tile-scalar-and-immediate/logical/TSELS.asl","requirements":["PTO-TSELS-CONTRACT-001"],"kind":"execution","summary":"Decoded U8 CUBE TSELS keeps two mask GPRs distinct from its false scalar","pass_condition":"two complete GPR mask words select only column zero while a third GPR supplies the independent false scalar to the allocated CUBE_M32 destination","related_sources":["asl/block/model/dispatch/tile-scalar-schema.asl","asl/block/model/dispatch/tile-execution.asl","asl/tile/model/execution/predicate-carriers.asl"]}
pure func TSELSStart() => bits(64)
begin
    var instruction = Zeros{64} + 0x00019181;
    instruction[26:25] = '01';
    instruction[24:20] = Zeros{5} + 26;
    instruction[31:27] = Zeros{5} + 27;
    return instruction;
end;

pure func TSELSGPRTiles(source_true: bits(6)) => bits(64)
begin
    var instruction = Zeros{64} + 0x00005013;
    instruction[25:20] = source_true;
    instruction[19] = '1';
    instruction[18:15] = Zeros{4} + 1;
    instruction[11:9] = '001';
    return instruction;
end;

pure func TSELSGPRBinding(
    mask_low: bits(5), mask_high: bits(5), scalar_false: bits(5)) => bits(64)
begin
    var instruction = Zeros{64} + 0x00000013;
    instruction[19:15] = mask_low;
    instruction[24:20] = mask_high;
    instruction[31:27] = scalar_false;
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    let source_ready = ConfigureCubeTile(
        10, 128, 1, 4, TileDataType_U8,
        TileLayout_CUBE_M32, TileLocation_Matrix);
    assert source_ready;
    WriteTileElement(10, 0, 0, Zeros{PTO_XLEN} + 10);
    WriteTileElement(10, 0, 1, Zeros{PTO_XLEN} + 11);
    WriteTileElement(10, 0, 2, Zeros{PTO_XLEN} + 12);
    WriteTileElement(10, 0, 3, Zeros{PTO_XLEN} + 13);
    MarkTileValidRegionDefined(10);
    WriteGPR(2, Zeros{PTO_XLEN} + 1);
    WriteGPR(3, Zeros{PTO_XLEN});
    WriteGPR(4, Zeros{PTO_XLEN} + 99);

    let started = ExecuteCommandInstruction(TSELSStart(), 32);
    assert started == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 4);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    let tiles = ExecuteCommandInstruction(
        TSELSGPRTiles(Zeros{6} + 10), 32);
    let binding = ExecuteCommandInstruction(
        TSELSGPRBinding(Zeros{5} + 2, Zeros{5} + 3, Zeros{5} + 4), 32);
    assert tiles == CommandExecution_Executed;
    assert binding == CommandExecution_Executed;
    let operation = 38 as integer {0..PTO_TILE_OPERATION_COUNT-1};
    assert BundleOperationBindingsComplete(operation);
    assert BundleOperationGPRBindingValuesLegal(operation);
    let attributes_legal = SelectedBundleTileDataAttributesLegal(operation);
    assert attributes_legal;
    assert SelectedBundleClosedSchemasLegal(operation);
    assert SelectedBundleTileMasksLegal();

    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
    let destination = _BundleTileBindings[[0]].destination;
    assert _Tiles[[destination]].layout == TileLayout_CUBE_M32;
    assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN} + 10;
    assert ReadTileElement(destination, 0, 1) == Zeros{PTO_XLEN} + 99;
    assert ReadTileElement(destination, 0, 2) == Zeros{PTO_XLEN} + 99;
    assert ReadTileElement(destination, 0, 3) == Zeros{PTO_XLEN} + 99;
    return 0;
end;
