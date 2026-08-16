// PTO-TEST: {"id":"PTO-AVS-TILE-MGATHER-CAS-RMW-001","source":"asl/tile/memory-and-data-movement/irregular/MGATHER_CAS.asl","requirements":["PTO-INST-TILE-MGATHER-CAS"],"kind":"atomicity","summary":"MGATHER_CAS performs one atomic compare-and-swap per indexed lane and returns each old value.","pass_condition":"The matching lane stores its replacement, the mismatching lane preserves memory, both old values reach the destination, and two atomic events are recorded.","related_sources":["asl/tile/model/memory/atomics.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(0, 128, 1, 2, 1, 2, TileDataType_U8,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(1, 128, 1, 2, 1, 2, TileDataType_U16,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(2, 128, 1, 2, 1, 2, TileDataType_U8,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(3, 128, 1, 2, 1, 2, TileDataType_U8,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 1);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 5);
    WriteTileElement(2, 0, 1, Zeros{PTO_XLEN} + 7);
    WriteTileElement(3, 0, 0, Zeros{PTO_XLEN} + 9);
    WriteTileElement(3, 0, 1, Zeros{PTO_XLEN} + 10);
    Store(Zeros{PTO_XLEN} + 0x300, 1, Zeros{PTO_XLEN} + 5);
    Store(Zeros{PTO_XLEN} + 0x301, 1, Zeros{PTO_XLEN} + 6);

    StartMemoryEventCapture(0);
    MGATHER_CAS(0, Zeros{PTO_XLEN} + 0x300, 1, 2, 3);

    assert _MemoryEventCount == 2;
    let replaced = LoadUnsigned(Zeros{PTO_XLEN} + 0x300, 1);
    let preserved = LoadUnsigned(Zeros{PTO_XLEN} + 0x301, 1);
    assert replaced == Zeros{PTO_XLEN} + 9;
    assert preserved == Zeros{PTO_XLEN} + 6;
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 5;
    assert ReadTileElement(0, 0, 1) == Zeros{PTO_XLEN} + 6;
    assert _MemoryEvents[[0]].kind == MemoryEvent_Atomic;
    assert _MemoryEvents[[1]].kind == MemoryEvent_Atomic;
    StopMemoryEventCapture();
    return 0;
end;
