// PTO-TEST: {"id":"PTO-AVS-TILE-MGATHER-LOGICAL-INDEX-001","source":"asl/tile/memory-and-data-movement/irregular/MGATHER.asl","requirements":["PTO-MGATHER-BYTE-DISPLACEMENT-001","PTO-MSCATTER-BYTE-DISPLACEMENT-001","PTO-INST-TILE-MGATHER","PTO-INST-TILE-MSCATTER"],"kind":"execution","summary":"Indexed TLSU uses logical element indices and scales addresses by the accessed element width.","pass_condition":"U32 index values one and two address the second and third U32 elements for both gather and scatter.","related_sources":["asl/tile/model/memory/addressing.asl","asl/tile/model/memory/gather-scatter.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(0, 128, 1, 2, 1, 2, TileDataType_U32,
        TileLayout_RowMajor);
    ConfigureTile(1, 128, 1, 2, 1, 2, TileDataType_U32,
        TileLayout_RowMajor);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 2);
    Store(Zeros{PTO_XLEN} + 0x200, 4, Zeros{PTO_XLEN} + 0x11111111);
    Store(Zeros{PTO_XLEN} + 0x204, 4, Zeros{PTO_XLEN} + 0x22222222);
    Store(Zeros{PTO_XLEN} + 0x208, 4, Zeros{PTO_XLEN} + 0x33333333);

    StartMemoryEventCapture(0);
    MGATHER(0, Zeros{PTO_XLEN} + 0x200, 1, TilePad_Max);
    assert _MemoryEventCount == 2;
    assert _MemoryEvents[[0]].address == Zeros{PTO_XLEN} + 0x204;
    assert _MemoryEvents[[1]].address == Zeros{PTO_XLEN} + 0x208;
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 0x22222222;
    assert ReadTileElement(0, 0, 1) == Zeros{PTO_XLEN} + 0x33333333;
    StopMemoryEventCapture();

    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0xaaaa0001);
    WriteTileElement(0, 0, 1, Zeros{PTO_XLEN} + 0xaaaa0002);
    Store(Zeros{PTO_XLEN} + 0x300, 4, Zeros{PTO_XLEN} + 0);
    Store(Zeros{PTO_XLEN} + 0x304, 4, Zeros{PTO_XLEN} + 0);
    Store(Zeros{PTO_XLEN} + 0x308, 4, Zeros{PTO_XLEN} + 0);
    StartMemoryEventCapture(0);
    MSCATTER(Zeros{PTO_XLEN} + 0x300, 0, 1);
    assert _MemoryEventCount == 2;
    assert _MemoryEvents[[0]].address == Zeros{PTO_XLEN} + 0x304;
    assert _MemoryEvents[[1]].address == Zeros{PTO_XLEN} + 0x308;
    let stored_first = LoadUnsigned(Zeros{PTO_XLEN} + 0x304, 4);
    let stored_last = LoadUnsigned(Zeros{PTO_XLEN} + 0x308, 4);
    assert stored_first == Zeros{PTO_XLEN} + 0xaaaa0001;
    assert stored_last == Zeros{PTO_XLEN} + 0xaaaa0002;
    StopMemoryEventCapture();
    return 0;
end;
