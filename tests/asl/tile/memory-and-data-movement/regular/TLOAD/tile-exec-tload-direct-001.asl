// PTO-TEST: {"id":"PTO-AVS-TILE-TLOAD-DIRECT-001","source":"asl/tile/memory-and-data-movement/regular/TLOAD.asl","requirements":["PTO-INST-TILE-TLOAD"],"kind":"execution","summary":"The direct TLOAD handler loads one valid rectangle with a byte row stride.","pass_condition":"A two-by-two U64 destination receives the four values at base plus byte-row offsets.","related_sources":["asl/tile/model/memory/load-store.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(4, 256, 2, 2, 2, 2, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    Store(Zeros{PTO_XLEN} + 0x200, 8, Zeros{PTO_XLEN} + 1);
    Store(Zeros{PTO_XLEN} + 0x208, 8, Zeros{PTO_XLEN} + 2);
    Store(Zeros{PTO_XLEN} + 0x220, 8, Zeros{PTO_XLEN} + 3);
    Store(Zeros{PTO_XLEN} + 0x228, 8, Zeros{PTO_XLEN} + 4);
    TLOAD(4, Zeros{PTO_XLEN} + 0x200, Zeros{PTO_XLEN} + 32);
    assert _LastFault == Fault_None;
    assert ReadTileElement(4, 0, 0) == Zeros{PTO_XLEN} + 1;
    assert ReadTileElement(4, 0, 1) == Zeros{PTO_XLEN} + 2;
    assert ReadTileElement(4, 1, 0) == Zeros{PTO_XLEN} + 3;
    assert ReadTileElement(4, 1, 1) == Zeros{PTO_XLEN} + 4;
    assert _Tiles[[4]].contents_defined;
    return 0;
end;
