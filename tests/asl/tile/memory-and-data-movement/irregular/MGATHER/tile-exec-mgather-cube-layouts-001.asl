// PTO-TEST: {"id":"PTO-AVS-TILE-MGATHER-CUBE-LAYOUTS-001","source":"asl/tile/memory-and-data-movement/irregular/MGATHER.asl","requirements":["PTO-MGATHER-BYTE-DISPLACEMENT-001"],"kind":"execution","summary":"Indexed gather, scatter, masked gather, and compare-and-swap retain independent CUBE_M16 and CUBE_M32 descriptors while using byte displacements.","pass_condition":"Each CUBE_M16 and CUBE_M32 operation transfers the byte-displaced lane and preserves the ordinary predicate and atomic contracts.","related_sources":["asl/tile/model/legality/indexed-layout.asl","asl/tile/model/memory/gather-scatter.asl","asl/tile/model/memory/atomics.asl"]}

func CubeGather(layout: TileLayout, base: Word)
begin
    ResetProfileState();
    let destination_ready = ConfigureCubeTile(0, 128, 1, 1, TileDataType_U32,
        layout, TileLocation_Matrix);
    assert destination_ready;
    let index_ready = ConfigureCubeTile(1, 128, 1, 1, TileDataType_S32,
        layout, TileLocation_Matrix);
    assert index_ready;
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 4);
    Store(base + 4, 4, Zeros{PTO_XLEN} + 0x11223344);
    StartMemoryEventCapture(0);
    MGATHER(0, base, 1, TilePad_Zero);
    assert _MemoryEventCount == 1;
    assert _MemoryEvents[[0]].address == base + 4;
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 0x11223344;
    StopMemoryEventCapture();
end;

func CubeScatter(layout: TileLayout, base: Word)
begin
    ResetProfileState();
    let source_ready = ConfigureCubeTile(0, 128, 1, 1, TileDataType_U32,
        layout, TileLocation_Matrix);
    assert source_ready;
    let index_ready = ConfigureCubeTile(1, 128, 1, 1, TileDataType_S32,
        layout, TileLocation_Matrix);
    assert index_ready;
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0xaabbccdd);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 4);
    Store(base + 4, 4, Zeros{PTO_XLEN});
    StartMemoryEventCapture(0);
    MSCATTER(base, 0, 1);
    assert _MemoryEventCount == 1;
    assert _MemoryEvents[[0]].address == base + 4;
    let stored = LoadUnsigned(base + 4, 4);
    assert stored == Zeros{PTO_XLEN} + 0xaabbccdd;
    StopMemoryEventCapture();
end;

func CubeMaskedGather(layout: TileLayout, base: Word)
begin
    ResetProfileState();
    let destination_ready = ConfigureCubeTile(0, 128, 1, 1, TileDataType_U32,
        layout, TileLocation_Matrix);
    assert destination_ready;
    let index_ready = ConfigureCubeTile(1, 128, 1, 1, TileDataType_S32,
        layout, TileLocation_Matrix);
    assert index_ready;
    let mask_ready = ConfigureCubeTile(2, 128, 1, 1, TileDataType_U8,
        layout, TileLocation_Matrix);
    assert mask_ready;
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 4);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 1);
    Store(base + 4, 4, Zeros{PTO_XLEN} + 0x55667788);
    StartMemoryEventCapture(0);
    MGATHER_MASK(0, base, 1, 2, TilePad_Zero);
    assert _MemoryEventCount == 1;
    assert _MemoryEvents[[0]].address == base + 4;
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 0x55667788;
    StopMemoryEventCapture();
end;

func CubeCAS(layout: TileLayout, base: Word)
begin
    ResetProfileState();
    let destination_ready = ConfigureCubeTile(0, 128, 1, 1, TileDataType_U16,
        layout, TileLocation_Matrix);
    assert destination_ready;
    let index_ready = ConfigureCubeTile(1, 128, 1, 1, TileDataType_S32,
        layout, TileLocation_Matrix);
    assert index_ready;
    let expected_ready = ConfigureCubeTile(2, 128, 1, 1, TileDataType_U16,
        layout, TileLocation_Matrix);
    assert expected_ready;
    let replacement_ready = ConfigureCubeTile(3, 128, 1, 1, TileDataType_U16,
        layout, TileLocation_Matrix);
    assert replacement_ready;
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 4);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 7);
    WriteTileElement(3, 0, 0, Zeros{PTO_XLEN} + 9);
    Store(base + 4, 2, Zeros{PTO_XLEN} + 7);
    StartMemoryEventCapture(0);
    MGATHER_CAS(0, base, 1, 2, 3);
    assert _MemoryEventCount == 1;
    assert _MemoryEvents[[0]].address == base + 4;
    let replaced = LoadUnsigned(base + 4, 2);
    assert replaced == Zeros{PTO_XLEN} + 9;
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 7;
    StopMemoryEventCapture();
end;

func main() => integer
begin
    CubeGather(TileLayout_CUBE_M16, Zeros{PTO_XLEN} + 0x800);
    CubeGather(TileLayout_CUBE_M32, Zeros{PTO_XLEN} + 0x900);
    CubeScatter(TileLayout_CUBE_M16, Zeros{PTO_XLEN} + 0xa00);
    CubeScatter(TileLayout_CUBE_M32, Zeros{PTO_XLEN} + 0xb00);
    CubeMaskedGather(TileLayout_CUBE_M16, Zeros{PTO_XLEN} + 0xc00);
    CubeMaskedGather(TileLayout_CUBE_M32, Zeros{PTO_XLEN} + 0xd00);
    CubeCAS(TileLayout_CUBE_M16, Zeros{PTO_XLEN} + 0xe00);
    CubeCAS(TileLayout_CUBE_M32, Zeros{PTO_XLEN} + 0xf00);
    return 0;
end;
