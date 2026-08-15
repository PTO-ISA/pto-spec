// PTO-TEST: {"id":"PTO-AVS-TILE-TSORT-KERNEL-001","source":"asl/tile/model/execution/sorting.asl","requirements":["PTO-INST-TILE-TSORT"],"kind":"execution","summary":"The TSORT kernel sorts one width-three group and preserves the trailing group","pass_condition":"values and group-local U32 indices are published together","related_sources":[]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(
        40, 128, 8, 4, 1, 4,
        TileDataType_FP32,
        TileLayout_RowMajor,
        TileLocation_Any);
    ConfigureTile(
        41, 128, 8, 4, 1, 4,
        TileDataType_FP32,
        TileLayout_RowMajor,
        TileLocation_Any);
    ConfigureTile(
        42, 128, 8, 4, 1, 4,
        TileDataType_U32,
        TileLayout_RowMajor,
        TileLocation_Any);
    WriteTileElement(40, 0, 0, Zeros{PTO_XLEN} + 0x40400000);
    WriteTileElement(40, 0, 1, Zeros{PTO_XLEN} + 0x3f800000);
    WriteTileElement(40, 0, 2, Zeros{PTO_XLEN} + 0x40000000);
    WriteTileElement(40, 0, 3, Zeros{PTO_XLEN});

    TSORT(41, 42, 40, 3, FALSE);

    assert ReadTileElement(41, 0, 0) == Zeros{PTO_XLEN} + 0x3f800000;
    assert ReadTileElement(41, 0, 2) == Zeros{PTO_XLEN} + 0x40400000;
    assert ReadTileElement(41, 0, 3) == Zeros{PTO_XLEN};
    assert ReadTileElement(42, 0, 0) == Zeros{PTO_XLEN} + 1;
    assert ReadTileElement(42, 0, 1) == Zeros{PTO_XLEN} + 2;
    assert ReadTileElement(42, 0, 2) == Zeros{PTO_XLEN};
    return 0;
end;
