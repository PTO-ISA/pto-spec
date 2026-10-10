// PTO-TEST: {"id":"PTO-AVS-TILE-TLEA-OVERFLOW-ALIAS-EFFECTS-001","source":"asl/tile/tile-scalar-and-immediate/arithmetic/TLEA.asl","requirements":["PTO-TLEA-CONTRACT-001"],"kind":"execution","summary":"TLEA wraps at 64 bits, snapshots legal aliases, and produces no memory or numeric-status effects.","pass_condition":"U64 overflow retains the low 64 bits, direct S64/U64 aliases read old values, memory-event count remains zero, and preexisting numeric flags remain unchanged.","related_sources":["asl/tile/model/execution/lea.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(0, 128, 64, 2, 1, 2,
        TileDataType_U64, TileLayout_RowMajor);
    ConfigureTile(1, 128, 64, 2, 1, 2,
        TileDataType_U64, TileLayout_RowMajor);
    WriteTileElement(0, 0, 0, Ones{PTO_XLEN});
    WriteTileElement(0, 0, 1, Zeros{PTO_XLEN} + 0x8000000000000000);
    RecordNumericStatusFlags(Zeros{5} + 0x15);
    let status_before = NumericStatusFlags();
    StartMemoryEventCapture(0);
    TLEA(1, 0, Zeros{PTO_XLEN} + 64);
    assert ReadTileElement(1, 0, 0) == Zeros{PTO_XLEN} + 0xfffffffffffffff8;
    assert ReadTileElement(1, 0, 1) == Zeros{PTO_XLEN};
    assert _MemoryEventCount == 0;
    assert NumericStatusFlags() == status_before;

    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 5);
    assert TileOperandsLegal_TLEA(1, 1, Zeros{PTO_XLEN} + 16);
    TLEA(1, 1, Zeros{PTO_XLEN} + 16);
    assert ReadTileElement(1, 0, 0) == Zeros{PTO_XLEN} + 6;
    assert ReadTileElement(1, 0, 1) == Zeros{PTO_XLEN} + 10;
    assert _MemoryEventCount == 0;
    assert NumericStatusFlags() == status_before;
    StopMemoryEventCapture();

    ResetProfileState();
    ConfigureTile(0, 128, 64, 2, 1, 2,
        TileDataType_S64, TileLayout_RowMajor);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0xfffffffffffffffe);
    WriteTileElement(0, 0, 1, Zeros{PTO_XLEN} + 7);
    assert TileOperandsLegal_TLEA(0, 0, Zeros{PTO_XLEN} + 32);
    TLEA(0, 0, Zeros{PTO_XLEN} + 32);
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 0xfffffffffffffff8;
    assert ReadTileElement(0, 0, 1) == Zeros{PTO_XLEN} + 28;
    return 0;
end;
