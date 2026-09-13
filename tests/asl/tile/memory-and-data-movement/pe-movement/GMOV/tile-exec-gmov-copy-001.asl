// PTO-TEST: {"id":"PTO-AVS-TILE-GMOV-COPY-001","source":"asl/tile/memory-and-data-movement/pe-movement/GMOV.asl","requirements":["PTO-INST-TILE-GMOV"],"kind":"execution","summary":"GMOV copies one resolved peer fragment for RowMajor and accepted Local M16/M32 layouts without changing source or memory state.","pass_condition":"The destination receives the read-old payload with the selected layout, the source remains defined, and no memory event is emitted.","related_sources":["asl/tile/model/memory/shared-movement.asl"]}
func RunGMOVCube(layout: TileLayout) => boolean
begin
    ResetProfileState();
    let source = ConfigureCubeTile(0, 128, 1, 1, TileDataType_U8, layout);
    let destination = ConfigureCubeTile(1, 128, 1, 1, TileDataType_U8, layout);
    assert source && destination;
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0x31);
    StartMemoryEventCapture(0);
    GMOV(1, 0, Zeros{PTO_XLEN} + 2);
    assert _Tiles[[1]].layout == layout;
    assert ReadTileElement(1, 0, 0) == Zeros{PTO_XLEN} + 0x31;
    assert _MemoryEventCount == 0;
    StopMemoryEventCapture();
    assert _LastFault == Fault_None;
    return TRUE;
end;

func main() => integer
begin
    ResetProfileState();
    ConfigureTile(0, 128, 1, 2, 1, 2, TileDataType_U8,
        TileLayout_RowMajor);
    ConfigureTile(1, 128, 1, 2, 1, 2, TileDataType_U8,
        TileLayout_RowMajor);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0x31);
    WriteTileElement(0, 0, 1, Zeros{PTO_XLEN} + 0x42);

    StartMemoryEventCapture(0);
    GMOV(1, 0, Zeros{PTO_XLEN} + 2);

    assert ReadTileElement(1, 0, 0) == Zeros{PTO_XLEN} + 0x31;
    assert ReadTileElement(1, 0, 1) == Zeros{PTO_XLEN} + 0x42;
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 0x31;
    assert _MemoryEventCount == 0;
    StopMemoryEventCapture();
    let m16 = RunGMOVCube(TileLayout_CUBE_M16);
    let m32 = RunGMOVCube(TileLayout_CUBE_M32);
    assert m16 && m32;
    return 0;
end;
