// PTO-TEST: {"id":"PTO-AVS-TILE-TCMP-CUBE-CELL-002","source":"asl/tile/elementwise-tile-tile/logical/TCMP.asl","requirements":["PTO-TCMP-CONTRACT-001"],"kind":"execution","summary":"Decoded CUBE TCMP allocates and publishes a PredicateCell destination","pass_condition":"FP32 CUBE_M32 equality publishes canonical 0x00/0x01 valid bytes, predicate Max padding, and a new PredicateCell descriptor","related_sources":["asl/block/model/dispatch/comparison-schema.asl","asl/block/model/dispatch/destination-shape.asl","asl/tile/model/execution/comparison.asl"]}
pure func TCMPStart() => bits(64)
begin
    var instruction = Zeros{64} + 0x00019181;
    instruction[26:25] = '00';
    instruction[24:20] = Zeros{5} + 13;
    instruction[31:27] = Zeros{5} + 1;
    return instruction;
end;

pure func TCMPCellTiles(source0: bits(6), source1: bits(6)) => bits(64)
begin
    var instruction = Zeros{64} + 0x00004013;
    instruction[31:26] = source1;
    instruction[25:20] = source0;
    instruction[19] = '1';
    instruction[18:15] = Zeros{4} + 1;
    instruction[11:9] = '001';
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    let left_ready = ConfigureCubeTile(
        10, 256, 2, 2, TileDataType_FP32,
        TileLayout_CUBE_M32, TileLocation_Matrix);
    let right_ready = ConfigureCubeTile(
        11, 256, 2, 2, TileDataType_FP32,
        TileLayout_CUBE_M32, TileLocation_Matrix);
    assert left_ready && right_ready;
    WriteTileElement(10, 0, 0, Zeros{PTO_XLEN} + 0x3f800000);
    WriteTileElement(10, 0, 1, Zeros{PTO_XLEN} + 0x40000000);
    WriteTileElement(10, 1, 0, Zeros{PTO_XLEN} + 0x40400000);
    WriteTileElement(10, 1, 1, Zeros{PTO_XLEN} + 0x40800000);
    WriteTileElement(11, 0, 0, Zeros{PTO_XLEN} + 0x3f800000);
    WriteTileElement(11, 0, 1, Zeros{PTO_XLEN} + 0x40400000);
    WriteTileElement(11, 1, 0, Zeros{PTO_XLEN} + 0x40400000);
    WriteTileElement(11, 1, 1, Zeros{PTO_XLEN} + 0x40a00000);
    MarkTileValidRegionDefined(10);
    MarkTileValidRegionDefined(11);

    let started = ExecuteCommandInstruction(TCMPStart(), 32);
    assert started == CommandExecution_Executed;
    SetBundleDataAttributeState(
        DTYPE_NONE, Zeros{5}, '01', Zeros{3}, Zeros{3}, FALSE, FALSE);
    _BundleDataAttributesPresent = TRUE;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 2);
    let tiles = ExecuteCommandInstruction(
        TCMPCellTiles(Zeros{6} + 10, Zeros{6} + 11), 32);
    assert tiles == CommandExecution_Executed;

    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
    let destination = _BundleTileBindings[[0]].destination;
    assert _Tiles[[destination]].storage_kind == TileStorage_PredicateCell;
    assert _Tiles[[destination]].layout == TileLayout_CUBE_M32;
    assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN} + 1;
    assert ReadTileElement(destination, 0, 1) == Zeros{PTO_XLEN};
    assert ReadTileElement(destination, 1, 0) == Zeros{PTO_XLEN} + 1;
    assert ReadTileElement(destination, 1, 1) == Zeros{PTO_XLEN};
    assert TileElementDefined(destination, 0, 2);
    assert ReadTileElement(destination, 0, 2) == Zeros{PTO_XLEN} + 1;
    return 0;
end;
