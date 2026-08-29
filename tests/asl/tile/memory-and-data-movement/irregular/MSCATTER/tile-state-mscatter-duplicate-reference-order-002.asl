// PTO-TEST: {"id":"PTO-AVS-TILE-MSCATTER-DUPLICATE-REFERENCE-ORDER-002","source":"asl/tile/memory-and-data-movement/irregular/MSCATTER.asl","requirements":["PTO-REQ-INDEXED-MEMORY-LANE-CHOICE-001","PTO-INST-TILE-MSCATTER"],"kind":"state-transition","summary":"The pto-v0 reference profile commits duplicate-address scatter lanes in logical ascending order.","pass_condition":"Two logical lanes targeting one byte emit two stores in lane order and the later logical lane supplies the final byte.","related_sources":["asl/tile/model/memory/gather-scatter.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(1, 128, 1, 2, 1, 2, TileDataType_U8,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(2, 128, 1, 2, 1, 2, TileDataType_U32,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 0x31);
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 0x72);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(2, 0, 1, Zeros{PTO_XLEN});
    let base = Zeros{PTO_XLEN} + 0x280;

    StartMemoryEventCapture(0);
    MSCATTER(base, 1, 2);

    assert _MemoryEventCount == 2;
    assert _MemoryEvents[[0]].write_value == Zeros{PTO_XLEN} + 0x31;
    assert _MemoryEvents[[1]].write_value == Zeros{PTO_XLEN} + 0x72;
    let observed = LoadUnsigned(base, 1);
    assert observed == Zeros{PTO_XLEN} + 0x72;
    StopMemoryEventCapture();
    return 0;
end;
