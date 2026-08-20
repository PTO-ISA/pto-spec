// PTO-TEST: {"id":"PTO-AVS-TILE-TLOAD-CUBE-WIDTHS-003","source":"asl/tile/model/memory/load-store.asl","requirements":["PTO-CUBE-CELL-TRANSPORT-001"],"kind":"boundary","summary":"TLOAD preserves raw b32 b16 b8 and packed b4 values in CUBE storage","pass_condition":"one representative value for every supported element width reaches the layout-specific storage index without numeric conversion","related_sources":["asl/tile/model/shape/cube-cell.asl","asl/tile/model/memory/addressing.asl"]}
func main() => integer
begin
    ResetProfileState();
    let fp32_configured = ConfigureCubeTile(0, 256, 2, 2,
        TileDataType_FP32, TileLayout_CUBE_M32, TileLocation_Matrix);
    assert fp32_configured;
    Store(Zeros{PTO_XLEN} + 0x100, 4,
        Zeros{PTO_XLEN} + 0x89abcdef);
    TLOAD(0, Zeros{PTO_XLEN} + 0x100, Zeros{PTO_XLEN} + 8);
    let fp32_tile = _Tiles[[0]];
    assert fp32_tile.payload[[TileStorageIndex(fp32_tile, 0, 0)]] ==
        Zeros{PTO_XLEN} + 0x89abcdef;

    ResetProfileState();
    let fp16_configured = ConfigureCubeTile(0, 256, 2, 5,
        TileDataType_FP16, TileLayout_CUBE_M16, TileLocation_Matrix);
    assert fp16_configured;
    Store(Zeros{PTO_XLEN} + 0x212, 2, Zeros{PTO_XLEN} + 0xbeef);
    TLOAD(0, Zeros{PTO_XLEN} + 0x200, Zeros{PTO_XLEN} + 10);
    let fp16_tile = _Tiles[[0]];
    assert fp16_tile.payload[[TileStorageIndex(fp16_tile, 1, 4)]] ==
        Zeros{PTO_XLEN} + 0xbeef;

    ResetProfileState();
    let fp8_configured = ConfigureCubeTile(0, 256, 2, 9,
        TileDataType_E4M3, TileLayout_CUBE_N8, TileLocation_Matrix);
    assert fp8_configured;
    Store(Zeros{PTO_XLEN} + 0x311, 1, Zeros{PTO_XLEN} + 0x7e);
    TLOAD(0, Zeros{PTO_XLEN} + 0x300, Zeros{PTO_XLEN} + 9);
    let fp8_tile = _Tiles[[0]];
    assert fp8_tile.payload[[TileStorageIndex(fp8_tile, 1, 8)]] ==
        Zeros{PTO_XLEN} + 0x7e;

    ResetProfileState();
    let u4_configured = ConfigureCubeTile(0, 256, 2, 9,
        TileDataType_U4X2, TileLayout_CUBE_N8, TileLocation_Matrix);
    assert u4_configured;
    Store(Zeros{PTO_XLEN} + 0x400, 1, Zeros{PTO_XLEN} + 0xba);
    TLOAD(0, Zeros{PTO_XLEN} + 0x400, Zeros{PTO_XLEN} + 5);
    let u4_tile = _Tiles[[0]];
    assert u4_tile.payload[[TileStorageIndex(u4_tile, 0, 0)]] ==
        Zeros{PTO_XLEN} + 0xa;
    assert u4_tile.payload[[TileStorageIndex(u4_tile, 0, 1)]] ==
        Zeros{PTO_XLEN} + 0xb;
    return 0;
end;
