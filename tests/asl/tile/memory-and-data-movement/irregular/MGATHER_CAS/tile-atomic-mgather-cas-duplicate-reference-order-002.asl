// PTO-TEST: {"id":"PTO-AVS-TILE-MGATHER-CAS-DUPLICATE-REFERENCE-ORDER-002","source":"asl/tile/memory-and-data-movement/irregular/MGATHER_CAS.asl","requirements":["PTO-REQ-INDEXED-MEMORY-LANE-CHOICE-001","PTO-INST-TILE-MGATHER-CAS"],"kind":"atomicity","summary":"The pto-v0 reference profile serializes duplicate-address gather-CAS lanes in logical ascending order.","pass_condition":"Lane zero succeeds first, lane one observes its replacement and fails, destination old values and atomic events preserve that order, and memory retains lane zero's replacement.","related_sources":["asl/tile/model/memory/atomics.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(0, 128, 1, 2, 1, 2, TileDataType_U8,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(1, 128, 1, 2, 1, 2, TileDataType_U32,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(2, 128, 1, 2, 1, 2, TileDataType_U8,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(3, 128, 1, 2, 1, 2, TileDataType_U8,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN});
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 0x11);
    WriteTileElement(2, 0, 1, Zeros{PTO_XLEN} + 0x11);
    WriteTileElement(3, 0, 0, Zeros{PTO_XLEN} + 0x22);
    WriteTileElement(3, 0, 1, Zeros{PTO_XLEN} + 0x33);
    let base = Zeros{PTO_XLEN} + 0x300;
    Store(base, 1, Zeros{PTO_XLEN} + 0x11);

    StartMemoryEventCapture(0);
    MGATHER_CAS(0, base, 1, 2, 3);

    assert _MemoryEventCount == 2;
    assert _MemoryEvents[[0]].write_performed;
    assert !_MemoryEvents[[1]].write_performed;
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 0x11;
    assert ReadTileElement(0, 0, 1) == Zeros{PTO_XLEN} + 0x22;
    let observed = LoadUnsigned(base, 1);
    assert observed == Zeros{PTO_XLEN} + 0x22;
    StopMemoryEventCapture();
    return 0;
end;
