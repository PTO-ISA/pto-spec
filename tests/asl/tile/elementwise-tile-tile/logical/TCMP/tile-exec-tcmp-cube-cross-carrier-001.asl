// PTO-TEST: {"id":"PTO-AVS-TILE-TCMP-CUBE-CROSS-CARRIER-001","source":"asl/tile/elementwise-tile-tile/logical/TCMP.asl","requirements":["PTO-TCMP-CONTRACT-001","PTO-TILE-CARRIER-REINTERPRETATION-001"],"kind":"execution","summary":"CUBE_M16 TCMP derives PredicateCell basis from U8 operation type","pass_condition":"E4M3-backed CUBE sources compare under U8 and publish a canonical U8-basis PredicateCell","related_sources":["asl/block/model/dispatch/predicate-destination.asl","asl/tile/model/legality/predicate-carriers.asl","asl/tile/model/execution/comparison.asl"]}
func main() => integer
begin
    ResetProfileState();
    let left_ready = ConfigureCubeTile(10, 128, 1, 2, TileDataType_E4M3,
        TileLayout_CUBE_M16, TileLocation_Matrix);
    let right_ready = ConfigureCubeTile(11, 128, 1, 2, TileDataType_E4M3,
        TileLayout_CUBE_M16, TileLocation_Matrix);
    assert left_ready && right_ready;
    WriteTileElement(10, 0, 0, Zeros{PTO_XLEN} + 0x80);
    WriteTileElement(10, 0, 1, Zeros{PTO_XLEN} + 0x01);
    WriteTileElement(11, 0, 0, Zeros{PTO_XLEN} + 0x80);
    WriteTileElement(11, 0, 1, Zeros{PTO_XLEN} + 0x02);
    MarkTileValidRegionDefined(10);
    MarkTileValidRegionDefined(11);
    let started = ExecuteCommandInstruction(
        Zeros{PTO_XLEN} + 0xd8d19181, 32);
    assert started == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    AddBundleTileBinding(TRUE, 0, 1, '1111', TRUE, TRUE, 10, 11, TRUE);
    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
    let destination = _BundleTileBindings[[0]].destination;
    assert _Tiles[[destination]].predicate_basis_type == TileDataType_U8;
    assert _Tiles[[destination]].layout == TileLayout_CUBE_M16;
    assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN} + 1;
    assert ReadTileElement(destination, 0, 1) == Zeros{PTO_XLEN};
    return 0;
end;
