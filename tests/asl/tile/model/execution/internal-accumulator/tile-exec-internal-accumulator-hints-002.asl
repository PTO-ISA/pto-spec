// PTO-TEST: {"id":"PTO-AVS-TILE-INTERNAL-ACCUMULATOR-HINTS-002","source":"asl/tile/model/execution/internal-accumulator.asl","requirements":["PTO-CUBE-INTERNAL-ACCUMULATOR-001"],"kind":"execution","summary":"InternalAcc prefetch and replacement hints are transparent to architectural Tile state.","pass_condition":"input and output hints, including a request larger than a target cache, preserve descriptors, payload, definedness, faults, and allocation.","related_sources":["asl/block/model/dispatch/cube-tmatmul.asl","asl/tile/model/execution/cube.asl"]}
func main() => integer
begin
    ResetProfileState();
    let source_ready = ConfigureCubeTileForMask(1, 128, 1, 1,
        TileDataType_FP32, TileLayout_CUBE_M16,
        TileLocation_Matrix, '1111');
    let destination_ready = ConfigureCubeTileForMask(2, 128, 1, 1,
        TileDataType_FP32, TileLayout_CUBE_M16,
        TileLocation_Matrix, '1111');
    assert source_ready && destination_ready;
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 0x3f800000);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 0x40000000);
    let source_before = ReadTileElement(1, 0, 0);
    let destination_before = ReadTileElement(2, 0, 0);

    TileProfileInternalAccumulatorPrefetchHint(1, 128);
    TileProfileInternalAccumulatorReplacementHint(2, 262144);

    assert _LastFault == Fault_None;
    assert _Tiles[[1]].allocated && _Tiles[[1]].contents_defined;
    assert _Tiles[[2]].allocated && _Tiles[[2]].contents_defined;
    assert _Tiles[[1]].layout == TileLayout_CUBE_M16;
    assert _Tiles[[2]].layout == TileLayout_CUBE_M16;
    assert _Tiles[[1]].capacity_bytes == 128;
    assert _Tiles[[2]].capacity_bytes == 128;
    assert ReadTileElement(1, 0, 0) == source_before;
    assert ReadTileElement(2, 0, 0) == destination_before;
    return 0;
end;
