// PTO-TEST: {"id":"PTO-AVS-TILE-TCMP-CUBE-M16-CELL-005","source":"asl/tile/elementwise-tile-tile/logical/TCMP.asl","requirements":["PTO-TCMP-CONTRACT-001"],"kind":"execution","summary":"Decoded CUBE_M16 TCMP publishes a basis-tagged PredicateCell","pass_condition":"S16 equality publishes canonical valid bytes and Max padding across the M16 16-row by 8-column PredicateCell geometry","related_sources":["asl/block/model/dispatch/comparison-schema.asl","asl/block/model/dispatch/predicate-destination.asl","asl/tile/model/legality/predicate-carriers.asl"]}
pure func TCMPM16CellStart() => bits(64)
begin
    var instruction = Zeros{64} + 0x00019181;
    instruction[24:20] = Zeros{5} + 13;
    instruction[31:27] = Zeros{5} + 18;
    return instruction;
end;

pure func TCMPM16CellTiles(source0: bits(6), source1: bits(6)) => bits(64)
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
        10, 128, 2, 4, TileDataType_S16,
        TileLayout_CUBE_M16, TileLocation_Matrix);
    let right_ready = ConfigureCubeTile(
        11, 128, 2, 4, TileDataType_S16,
        TileLayout_CUBE_M16, TileLocation_Matrix);
    assert left_ready && right_ready;
    for row = 0 to 1 looplimit 2 do
        for column = 0 to 3 looplimit 4 do
            let value = Zeros{PTO_XLEN} + row * 4 + column + 1;
            WriteTileElement(10, row, column, value);
            WriteTileElement(11, row, column, value);
        end;
    end;
    WriteTileElement(11, 1, 3, Zeros{PTO_XLEN} + 99);
    MarkTileValidRegionDefined(10);
    MarkTileValidRegionDefined(11);

    let started = ExecuteCommandInstruction(TCMPM16CellStart(), 32);
    assert started == CommandExecution_Executed;
    SetBundleDataAttributeState(
        DTYPE_NONE, Zeros{5}, '01', Zeros{3}, Zeros{3}, FALSE, FALSE);
    _BundleDataAttributesPresent = TRUE;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 4);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 2);
    let tiles = ExecuteCommandInstruction(
        TCMPM16CellTiles(Zeros{6} + 10, Zeros{6} + 11), 32);
    assert tiles == CommandExecution_Executed;
    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
    let destination = _BundleTileBindings[[0]].destination;
    let tile = _Tiles[[destination]];
    assert tile.storage_kind == TileStorage_PredicateCell;
    assert tile.predicate_basis_type == TileDataType_S16;
    assert tile.layout == TileLayout_CUBE_M16;
    assert tile.rows == 16 && tile.columns == 8;
    assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN} + 1;
    assert ReadTileElement(destination, 1, 3) == Zeros{PTO_XLEN};
    assert TileElementDefined(destination, 2, 0);
    assert ReadTileElement(destination, 2, 0) == Zeros{PTO_XLEN} + 1;
    return 0;
end;
