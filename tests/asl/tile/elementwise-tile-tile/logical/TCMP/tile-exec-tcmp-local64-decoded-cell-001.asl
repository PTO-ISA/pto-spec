// PTO-TEST: {"id":"PTO-AVS-TILE-TCMP-LOCAL64-DECODED-CELL-001","source":"asl/tile/elementwise-tile-tile/logical/TCMP.asl","requirements":["PTO-TCMP-CONTRACT-001","PTO-CUBE-M32-B64-DOUBLE-CELL-001"],"kind":"execution","summary":"Decoded M32 TCMP reaches its CELL carrier with full-width 64-bit operands.","pass_condition":"Decoded binder, datatype, predicate and destination allocation paths preserve logical predicate coordinates and both halves of selected 64-bit elements.","related_sources":["asl/block/model/dispatch/comparison-schema.asl","asl/block/model/dispatch/destination-shape.asl","asl/tile/model/execution/comparison.asl"]}
pure func TCMPStart() => bits(64)
begin
    var instruction = Zeros{64} + 0x00019181;
    instruction[26:25] = '00';
    instruction[24:20] = Zeros{5} + 13;
    instruction[31:27] = TileDataTypeToEncoding(TileDataType_FP64);
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
        10, 512, 2, 2, TileDataType_FP64,
        TileLayout_CUBE_M32);
    let right_ready = ConfigureCubeTile(
        11, 512, 2, 2, TileDataType_FP64,
        TileLayout_CUBE_M32);
    assert left_ready && right_ready;
    WriteTileElement(10, 0, 0, Zeros{PTO_XLEN} + 0x3ff0000000000000);
    WriteTileElement(10, 0, 1, Zeros{PTO_XLEN} + 0x4000000000000000);
    WriteTileElement(10, 1, 0, Zeros{PTO_XLEN} + 0x4008000000000000);
    WriteTileElement(10, 1, 1, Zeros{PTO_XLEN} + 0x4010000000000000);
    WriteTileElement(11, 0, 0, Zeros{PTO_XLEN} + 0x3ff0000000000000);
    WriteTileElement(11, 0, 1, Zeros{PTO_XLEN} + 0x4008000000000000);
    WriteTileElement(11, 1, 0, Zeros{PTO_XLEN} + 0x4008000000000000);
    WriteTileElement(11, 1, 1, Zeros{PTO_XLEN} + 0x4014000000000000);
    MarkTileValidRegionDefined(10);
    MarkTileValidRegionDefined(11);

    let started = ExecuteCommandInstruction(TCMPStart(), 32);
    assert started == CommandExecution_Executed;
    SetBundleDataAttributeState(
        DTYPE_NONE, Zeros{5}, '01', Zeros{3}, Zeros{3}, FALSE, FALSE);
    _BundleDataAttributesPresent = TRUE;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 2);
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
