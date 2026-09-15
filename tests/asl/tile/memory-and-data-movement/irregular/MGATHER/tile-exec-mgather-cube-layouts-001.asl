// PTO-TEST: {"id":"PTO-AVS-TILE-MGATHER-CUBE-LAYOUTS-001","source":"asl/tile/memory-and-data-movement/irregular/MGATHER.asl","requirements":["PTO-MGATHER-BYTE-DISPLACEMENT-001","PTO-ATOM-RED-TYPE-LEGALITY-001","PTO-ATOM-RED-POPC-SEMANTICS-001","PTO-ATOM-RED-ORDERING-001","PTO-ATOM-RED-FAULTS-001"],"kind":"execution","summary":"Indexed gather, scatter, masked gather, compare-and-swap, atomic ADD, reduction ADD, and POPC retain independent CUBE_M16 and CUBE_M32 descriptors while using byte displacements.","pass_condition":"Each CUBE_M16 and CUBE_M32 operation executes its byte-displaced lane, including destination-bearing atomics, value-bearing reductions, and POPC, while preserving ordinary predicate and layout contracts.","related_sources":["asl/tile/model/legality/indexed-layout.asl","asl/tile/model/memory/gather-scatter.asl","asl/tile/model/memory/atomics.asl"]}

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

func CubeAtomicValue(layout: TileLayout, base: Word)
begin
    ResetProfileState();
    let destination_ready = ConfigureCubeTile(0, 128, 1, 1, TileDataType_U32,
        layout, TileLocation_Matrix);
    let index_ready = ConfigureCubeTile(1, 256, 1, 1, TileDataType_S32,
        layout, TileLocation_Matrix);
    let value_ready = ConfigureCubeTile(2, 256, 1, 1, TileDataType_U32,
        layout, TileLocation_Matrix);
    assert destination_ready && index_ready && value_ready;
    assert _Tiles[[0]].capacity_bytes != _Tiles[[1]].capacity_bytes;
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 4);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 5);
    Store(base + 4, 4, Zeros{PTO_XLEN} + 10);
    assert TileOperandsLegal_GM_ATOM_VALUE(
        GMAtomic_ADD, 0, base, 1, 2, TilePad_Null);
    StartMemoryEventCapture(0);
    GM_ATOM_VALUE(GMAtomic_ADD, 0, base, 1, 2, TilePad_Null);
    assert _MemoryEventCount == 1;
    assert _MemoryEvents[[0]].address == base + 4;
    let atom_value = LoadUnsigned(base + 4, 4);
    assert atom_value == Zeros{PTO_XLEN} + 15;
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 10;
    StopMemoryEventCapture();
end;

func CubeReduction(layout: TileLayout, base: Word)
begin
    ResetProfileState();
    let index_ready = ConfigureCubeTile(0, 256, 1, 1, TileDataType_S32,
        layout, TileLocation_Matrix);
    let value_ready = ConfigureCubeTile(1, 128, 1, 1, TileDataType_U32,
        layout, TileLocation_Matrix);
    assert index_ready && value_ready;
    assert _Tiles[[0]].capacity_bytes != _Tiles[[1]].capacity_bytes;
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 4);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 5);
    Store(base + 4, 4, Zeros{PTO_XLEN} + 10);
    StartMemoryEventCapture(0);
    GM_RED_VALUE(GMReduction_ADD, base, 0, 1, TilePad_Null);
    assert _MemoryEventCount == 1;
    assert _MemoryEvents[[0]].address == base + 4;
    let reduction_value = LoadUnsigned(base + 4, 4);
    assert reduction_value == Zeros{PTO_XLEN} + 15;
    StopMemoryEventCapture();
end;

func CubePopc(layout: TileLayout, base: Word)
begin
    ResetProfileState();
    let index_ready = ConfigureCubeTile(0, 256, 1, 1, TileDataType_S32,
        layout, TileLocation_Matrix);
    assert index_ready;
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 4);
    Store(base + 4, 4, Zeros{PTO_XLEN} + 10);
    StartMemoryEventCapture(0);
    GM_RED_POPC(GMReduction_POPC, base, 0);
    assert _MemoryEventCount == 1;
    assert _MemoryEvents[[0]].address == base + 4;
    let popc_value = LoadUnsigned(base + 4, 4);
    assert popc_value == Zeros{PTO_XLEN} + 11;
    StopMemoryEventCapture();
end;

func CubeHeterogeneousDescriptors(layout: TileLayout, base: Word)
begin
    ResetProfileState();
    let source_ready = ConfigureCubeTile(0, 256, 1, 1, TileDataType_U16,
        layout, TileLocation_Matrix);
    let index_ready = ConfigureCubeTile(1, 128, 1, 1, TileDataType_S32,
        layout, TileLocation_Matrix);
    assert source_ready && index_ready;
    assert _Tiles[[0]].capacity_bytes != _Tiles[[1]].capacity_bytes;
    assert _Tiles[[0]].columns != _Tiles[[1]].columns;
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0x1234);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 4);
    Store(base + 4, 2, Zeros{PTO_XLEN});
    StartMemoryEventCapture(0);
    MSCATTER(base, 0, 1);
    assert _MemoryEventCount == 1;
    assert _MemoryEvents[[0]].address == base + 4;
    let stored = LoadUnsigned(base + 4, 2);
    assert stored == Zeros{PTO_XLEN} + 0x1234;
    StopMemoryEventCapture();
end;

func LayoutMismatchCUBEM32Index()
begin
    ResetProfileState();
    let destination_ready = ConfigureCubeTile(0, 128, 1, 1,
        TileDataType_U32, TileLayout_CUBE_M16, TileLocation_Matrix);
    let index_ready = ConfigureCubeTile(1, 128, 1, 1,
        TileDataType_S32, TileLayout_CUBE_M32, TileLocation_Matrix);
    let value_ready = ConfigureCubeTile(2, 128, 1, 1,
        TileDataType_U32, TileLayout_CUBE_M16, TileLocation_Matrix);
    let mask_ready = ConfigureCubeTile(3, 128, 1, 1,
        TileDataType_U8, TileLayout_CUBE_M16, TileLocation_Matrix);
    let expected_ready = ConfigureCubeTile(4, 128, 1, 1,
        TileDataType_U32, TileLayout_CUBE_M16, TileLocation_Matrix);
    let replacement_ready = ConfigureCubeTile(5, 128, 1, 1,
        TileDataType_U32, TileLayout_CUBE_M16, TileLocation_Matrix);
    assert destination_ready && index_ready && value_ready && mask_ready &&
           expected_ready && replacement_ready;
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 4);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 5);
    WriteTileElement(3, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(4, 0, 0, Zeros{PTO_XLEN} + 5);
    WriteTileElement(5, 0, 0, Zeros{PTO_XLEN} + 9);
    Store(Zeros{PTO_XLEN} + 0x200, 4, Zeros{PTO_XLEN} + 0x55);
    StartMemoryEventCapture(0);
    assert !TileOperandsLegal_MGATHER(0, Zeros{PTO_XLEN} + 0x200, 1);
    assert !TileOperandsLegal_MSCATTER(Zeros{PTO_XLEN} + 0x200, 0, 1);
    assert !TileOperandsLegal_MGATHER_MASK(0, Zeros{PTO_XLEN} + 0x200,
        1, 3, TilePad_Null);
    assert !TileOperandsLegal_MSCATTER_MASK(
        Zeros{PTO_XLEN} + 0x200, 0, 1, 3);
    assert !TileOperandsLegal_MGATHER_CAS(0, Zeros{PTO_XLEN} + 0x200,
        1, 4, 5, TilePad_Null);
    assert !TileOperandsLegal_GM_ATOM_VALUE(
        GMAtomic_ADD, 0, Zeros{PTO_XLEN} + 0x200, 1, 2, TilePad_Null);
    assert !TileOperandsLegal_GM_ATOM_CAS(
        GMAtomic_CAS, 0, Zeros{PTO_XLEN} + 0x200, 1, 4, 5, TilePad_Null);
    assert _MemoryEventCount == 0;
    let unchanged = LoadUnsigned(Zeros{PTO_XLEN} + 0x200, 4);
    assert unchanged == Zeros{PTO_XLEN} + 0x55;
    StopMemoryEventCapture();
end;

func LayoutMismatchRowMajorData()
begin
    ResetProfileState();
    var destination_ready = TRUE;
    let index_ready = ConfigureCubeTile(1, 128, 1, 1,
        TileDataType_S32, TileLayout_CUBE_M16, TileLocation_Matrix);
    var value_ready = TRUE;
    var mask_ready = TRUE;
    var expected_ready = TRUE;
    var replacement_ready = TRUE;
    ConfigureTile(0, 128, 1, 1, 1, 1,
        TileDataType_U32, TileLayout_RowMajor);
    ConfigureTile(2, 128, 1, 1, 1, 1,
        TileDataType_U32, TileLayout_RowMajor);
    ConfigureTile(3, 128, 1, 1, 1, 1,
        TileDataType_U8, TileLayout_RowMajor);
    ConfigureTile(4, 128, 1, 1, 1, 1,
        TileDataType_U32, TileLayout_RowMajor);
    ConfigureTile(5, 128, 1, 1, 1, 1,
        TileDataType_U32, TileLayout_RowMajor);
    assert destination_ready && index_ready && value_ready && mask_ready &&
           expected_ready && replacement_ready;
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 4);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 5);
    WriteTileElement(3, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(4, 0, 0, Zeros{PTO_XLEN} + 5);
    WriteTileElement(5, 0, 0, Zeros{PTO_XLEN} + 9);
    Store(Zeros{PTO_XLEN} + 0x204, 4, Zeros{PTO_XLEN} + 0x66);
    StartMemoryEventCapture(0);
    assert !TileOperandsLegal_MGATHER(0, Zeros{PTO_XLEN} + 0x200, 1);
    assert !TileOperandsLegal_MSCATTER(Zeros{PTO_XLEN} + 0x200, 0, 1);
    assert !TileOperandsLegal_MGATHER_MASK(0, Zeros{PTO_XLEN} + 0x200,
        1, 3, TilePad_Null);
    assert !TileOperandsLegal_MSCATTER_MASK(
        Zeros{PTO_XLEN} + 0x200, 0, 1, 3);
    assert !TileOperandsLegal_MGATHER_CAS(0, Zeros{PTO_XLEN} + 0x200,
        1, 4, 5, TilePad_Null);
    assert !TileOperandsLegal_GM_ATOM_VALUE(
        GMAtomic_ADD, 0, Zeros{PTO_XLEN} + 0x200, 1, 2, TilePad_Null);
    assert !TileOperandsLegal_GM_ATOM_CAS(
        GMAtomic_CAS, 0, Zeros{PTO_XLEN} + 0x200, 1, 4, 5, TilePad_Null);
    assert _MemoryEventCount == 0;
    let unchanged = LoadUnsigned(Zeros{PTO_XLEN} + 0x204, 4);
    assert unchanged == Zeros{PTO_XLEN} + 0x66;
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
    CubeAtomicValue(TileLayout_CUBE_M16, Zeros{PTO_XLEN} + 0x300);
    CubeAtomicValue(TileLayout_CUBE_M32, Zeros{PTO_XLEN} + 0x340);
    CubeReduction(TileLayout_CUBE_M16, Zeros{PTO_XLEN} + 0x380);
    CubeReduction(TileLayout_CUBE_M32, Zeros{PTO_XLEN} + 0x3c0);
    CubePopc(TileLayout_CUBE_M16, Zeros{PTO_XLEN} + 0x400);
    CubePopc(TileLayout_CUBE_M32, Zeros{PTO_XLEN} + 0x440);
    CubeHeterogeneousDescriptors(TileLayout_CUBE_M16, Zeros{PTO_XLEN} + 0x480);
    CubeHeterogeneousDescriptors(TileLayout_CUBE_M32, Zeros{PTO_XLEN} + 0x4c0);
    LayoutMismatchCUBEM32Index();
    LayoutMismatchRowMajorData();
    return 0;
end;
