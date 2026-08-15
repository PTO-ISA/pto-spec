// PTO-TEST: {"id":"PTO-AVS-TILE-TTRI-EDGE-001","source":"asl/tile/irregular-and-complex/initialization/TTRI.asl","requirements":["PTO-INST-TILE-TTRI"],"kind":"execution","summary":"TTRI diagonal comparisons do not wrap at Tile boundaries","pass_condition":"diagonal minus 65535 produces an all-zero lower triangle and an all-one upper triangle","related_sources":["asl/tile/model/execution/generation.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(
        0,
        128,
        16,
        4,
        2,
        3,
        TileDataType_FP16,
        TileLayout_RowMajor,
        TileLocation_Any);
    ConfigureTile(
        1,
        128,
        16,
        4,
        2,
        3,
        TileDataType_FP16,
        TileLayout_RowMajor,
        TileLocation_Any);

    TTRI(0, FALSE, -65535);
    TTRI(1, TRUE, -65535);

    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN};
    assert ReadTileElement(0, 1, 2) == Zeros{PTO_XLEN};
    assert ReadTileElement(1, 0, 0) == Zeros{PTO_XLEN} + 0x3c00;
    assert ReadTileElement(1, 1, 2) == Zeros{PTO_XLEN} + 0x3c00;
    return 0;
end;
