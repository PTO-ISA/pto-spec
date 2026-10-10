// PTO-TEST: {"id":"PTO-AVS-TILE-GENERATION-LOCAL64-002","source":"asl/tile/model/execution/generation.asl","requirements":["PTO-TCI-CONTRACT-001","PTO-TTRI-CONTRACT-001"],"kind":"execution","summary":"Local generation helpers preserve full-width integer sequences and binary64 triangular constants","pass_condition":"TCI wraps U64 without narrowing and TTRI emits the exact binary64 positive-one encoding","related_sources":["asl/tile/irregular-and-complex/initialization/TCI.asl","asl/tile/irregular-and-complex/initialization/TTRI.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(0, 128, 1, 2, 1, 2,
        TileDataType_U64, TileLayout_RowMajor);
    TCI(0, Zeros{PTO_XLEN} + 0xffffffffffffffff, FALSE);
    assert ReadTileElement(0, 0, 0) ==
        Zeros{PTO_XLEN} + 0xffffffffffffffff;
    assert ReadTileElement(0, 0, 1) == Zeros{PTO_XLEN};

    ConfigureTile(1, 128, 2, 2, 2, 2,
        TileDataType_FP64, TileLayout_RowMajor);
    TTRI(1, FALSE, 0);
    assert ReadTileElement(1, 0, 0) ==
        Zeros{PTO_XLEN} + 0x3ff0000000000000;
    assert ReadTileElement(1, 0, 1) == Zeros{PTO_XLEN};
    assert ReadTileElement(1, 1, 1) ==
        Zeros{PTO_XLEN} + 0x3ff0000000000000;
    return 0;
end;
