// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-TILE-TLOAD-EXECUTION-001","source":"asl/tile/memory-and-data-movement/regular/TLOAD.asl","requirements":["PTO-INST-TILE-TLOAD"],"kind":"execution","summary":"migrated independent behavior point for TestTileMemory","pass_condition":"TestTileMemory completes without assertion failure","related_sources":[]}
func ConfigureTwoByTwo(index: TileIndex)
begin
    ConfigureTile(index, 256, 2, 2, 2, 2, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
end;

func TestTileMemory()
begin
    ConfigureTwoByTwo(3);
    ConfigureTwoByTwo(4);
    WriteTileElement(3, 0, 0, Zeros{PTO_XLEN} + 101);
    WriteTileElement(3, 0, 1, Zeros{PTO_XLEN} + 102);
    WriteTileElement(3, 1, 0, Zeros{PTO_XLEN} + 103);
    WriteTileElement(3, 1, 1, Zeros{PTO_XLEN} + 104);
    TSTORE(Zeros{PTO_XLEN} + 64, Zeros{PTO_XLEN} + 2, 3);
    TLOAD(4, Zeros{PTO_XLEN} + 64, Zeros{PTO_XLEN} + 2);
    assert ReadTileElement(4, 0, 0) == Zeros{PTO_XLEN} + 101;
    assert ReadTileElement(4, 1, 1) == Zeros{PTO_XLEN} + 104;

    // PTO-REQ-TLSU-STRIDE-001: TLOAD/TSTORE keep the existing base/stride
    // B.IOR shape. The stride is in elements and is independent of LB2.
    ConfigureTwoByTwo(20);
    Store(Zeros{PTO_XLEN} + 512, 8, Zeros{PTO_XLEN} + 201);
    Store(Zeros{PTO_XLEN} + 520, 8, Zeros{PTO_XLEN} + 202);
    Store(Zeros{PTO_XLEN} + 544, 8, Zeros{PTO_XLEN} + 203);
    Store(Zeros{PTO_XLEN} + 552, 8, Zeros{PTO_XLEN} + 204);
    TLOAD(20, Zeros{PTO_XLEN} + 512, Zeros{PTO_XLEN} + 4);
    assert ReadTileElement(20, 0, 0) == Zeros{PTO_XLEN} + 201;
    assert ReadTileElement(20, 0, 1) == Zeros{PTO_XLEN} + 202;
    assert ReadTileElement(20, 1, 0) == Zeros{PTO_XLEN} + 203;
    assert ReadTileElement(20, 1, 1) == Zeros{PTO_XLEN} + 204;

    WriteTileElement(20, 0, 0, Zeros{PTO_XLEN} + 211);
    WriteTileElement(20, 0, 1, Zeros{PTO_XLEN} + 212);
    WriteTileElement(20, 1, 0, Zeros{PTO_XLEN} + 213);
    WriteTileElement(20, 1, 1, Zeros{PTO_XLEN} + 214);
    TSTORE(Zeros{PTO_XLEN} + 640, Zeros{PTO_XLEN} + 3, 20);
    let stored00 = LoadUnsigned(Zeros{PTO_XLEN} + 640, 8);
    let stored01 = LoadUnsigned(Zeros{PTO_XLEN} + 648, 8);
    let stored10 = LoadUnsigned(Zeros{PTO_XLEN} + 664, 8);
    let stored11 = LoadUnsigned(Zeros{PTO_XLEN} + 672, 8);
    assert stored00 == Zeros{PTO_XLEN} + 211;
    assert stored01 == Zeros{PTO_XLEN} + 212;
    assert stored10 == Zeros{PTO_XLEN} + 213;
    assert stored11 == Zeros{PTO_XLEN} + 214;

    let before_first = ReadTileElement(4, 0, 0);
    let before_last = ReadTileElement(4, 1, 1);
    TPREFETCH(Zeros{PTO_XLEN} + 64, 32);
    assert ReadTileElement(4, 0, 0) == before_first;
    assert ReadTileElement(4, 1, 1) == before_last;

    ConfigureTwoByTwo(24);
    ConfigureTwoByTwo(25);
    WriteTileElement(24, 0, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(24, 0, 1, Zeros{PTO_XLEN} + 1);
    WriteTileElement(24, 1, 0, Zeros{PTO_XLEN} + 0);
    WriteTileElement(24, 1, 1, Zeros{PTO_XLEN} + 2);
    Store(Zeros{PTO_XLEN} + 256, 8, Zeros{PTO_XLEN} + 11);
    Store(Zeros{PTO_XLEN} + 264, 8, Zeros{PTO_XLEN} + 22);
    Store(Zeros{PTO_XLEN} + 272, 8, Zeros{PTO_XLEN} + 33);
    Store(Zeros{PTO_XLEN} + 280, 8, Zeros{PTO_XLEN} + 44);
    MGATHER(25, Zeros{PTO_XLEN} + 256, 24);
    assert ReadTileElement(25, 0, 0) == Zeros{PTO_XLEN} + 44;
    assert ReadTileElement(25, 1, 0) == Zeros{PTO_XLEN} + 11;
    MSCATTER(Zeros{PTO_XLEN} + 320, 25, 24);
    let scattered_first = LoadUnsigned(Zeros{PTO_XLEN} + 320, 8);
    let scattered_last = LoadUnsigned(Zeros{PTO_XLEN} + 344, 8);
    assert scattered_first == Zeros{PTO_XLEN} + 11;
    assert scattered_last == Zeros{PTO_XLEN} + 44;
end;
func main() => integer
begin
    ResetProfileState();
    TestTileMemory();
    return 0;
end;
