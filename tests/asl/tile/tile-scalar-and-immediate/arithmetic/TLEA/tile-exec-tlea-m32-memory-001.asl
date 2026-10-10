// PTO-TEST: {"id":"PTO-AVS-TILE-TLEA-M32-MEMORY-001","source":"asl/tile/tile-scalar-and-immediate/arithmetic/TLEA.asl","requirements":["PTO-TLEA-CONTRACT-001","PTO-CUBE-M32-B64-DOUBLE-CELL-001","PTO-TILE-MODEL-EXECUTION-MASK-APPLICABILITY-001","PTO-MGATHER-BYTE-DISPLACEMENT-001","PTO-MSCATTER-BYTE-DISPLACEMENT-001"],"kind":"execution","summary":"M32 TLEA byte offsets feed raw B64 gather/scatter with preserved high and low words.","pass_condition":"Signed indices -1 and two become byte offsets -8 and sixteen, and FP64 NaN payload/negative-zero bits survive memory round trips with no second scaling.","related_sources":["asl/block/model/dispatch/lea-schema.asl","asl/block/model/dispatch/execution-mask-schema.asl","asl/block/model/dispatch/destination-operation.asl"]}
func main() => integer
begin
    ResetProfileState();
    let index_ready = ConfigureCubeTile(0, 256, 1, 2, TileDataType_S32, TileLayout_CUBE_M32);
    let offset_ready = ConfigureCubeTile(1, 512, 1, 2, TileDataType_S64, TileLayout_CUBE_M32);
    let data_ready = ConfigureCubeTile(2, 512, 1, 2, TileDataType_FP64, TileLayout_CUBE_M32);
    assert index_ready && offset_ready && data_ready;
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0xffffffff);
    WriteTileElement(0, 0, 1, Zeros{PTO_XLEN} + 2);
    Store(Zeros{PTO_XLEN} + 0x5f8, 8, Zeros{PTO_XLEN} + 0x7ff80000abcd1234);
    Store(Zeros{PTO_XLEN} + 0x610, 8, Zeros{PTO_XLEN} + 0x8000000000000000);
    StartMemoryEventCapture(0);
    TLEA(1, 0, Zeros{PTO_XLEN} + 64);
    assert _MemoryEventCount == 0;
    assert ReadTileElement(1, 0, 0) == Ones{PTO_XLEN} - 7;
    assert ReadTileElement(1, 0, 1) == Zeros{PTO_XLEN} + 16;
    MGATHER(2, Zeros{PTO_XLEN} + 0x600, 1);
    assert ReadTileElement(2, 0, 0) == Zeros{PTO_XLEN} + 0x7ff80000abcd1234;
    assert ReadTileElement(2, 0, 1) == Zeros{PTO_XLEN} + 0x8000000000000000;
    MSCATTER(Zeros{PTO_XLEN} + 0x800, 2, 1);
    assert _MemoryEventCount == 4;
    StopMemoryEventCapture();
    let first = LoadUnsigned(Zeros{PTO_XLEN} + 0x7f8, 8);
    let last = LoadUnsigned(Zeros{PTO_XLEN} + 0x810, 8);
    assert first == Zeros{PTO_XLEN} + 0x7ff80000abcd1234;
    assert last == Zeros{PTO_XLEN} + 0x8000000000000000;
    return 0;
end;
