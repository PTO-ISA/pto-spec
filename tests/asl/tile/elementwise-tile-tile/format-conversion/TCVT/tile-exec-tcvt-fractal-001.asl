// PTO-TEST: {"id":"PTO-AVS-TILE-TCVT-FRACTAL-001","source":"asl/tile/elementwise-tile-tile/format-conversion/TCVT.asl","requirements":["PTO-INST-TILE-TCVT"],"kind":"execution","summary":"TCVT fractal layouts have executable DataType-dependent physical indexing","pass_condition":"ZN and NZ use 16-row by 32-byte fractals and packed four-bit formats retain one logical nibble per element","related_sources":["asl/tile/model/definedness/elements.asl","asl/tile/model/state/descriptors.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(
        0,
        2048,
        32,
        64,
        32,
        64,
        TileDataType_U8,
        TileLayout_ZN,
        TileLocation_Any);
    assert TileLinearIndex(_Tiles[[0]], 0, 0) == 0;
    assert TileLinearIndex(_Tiles[[0]], 1, 0) == 1;
    assert TileLinearIndex(_Tiles[[0]], 0, 1) == 16;
    assert TileLinearIndex(_Tiles[[0]], 0, 32) == 512;
    assert TileLinearIndex(_Tiles[[0]], 16, 0) == 1024;

    ConfigureTile(
        1,
        2048,
        32,
        64,
        32,
        64,
        TileDataType_U8,
        TileLayout_NZ,
        TileLocation_Any);
    assert TileLinearIndex(_Tiles[[1]], 0, 0) == 0;
    assert TileLinearIndex(_Tiles[[1]], 0, 1) == 1;
    assert TileLinearIndex(_Tiles[[1]], 1, 0) == 32;
    assert TileLinearIndex(_Tiles[[1]], 0, 32) == 1024;
    assert TileLinearIndex(_Tiles[[1]], 16, 0) == 512;

    ConfigureTile(
        2,
        512,
        16,
        64,
        16,
        64,
        TileDataType_U4X2,
        TileLayout_ZN,
        TileLocation_Any);
    assert TileFractalInnerElements(_Tiles[[2]].data_type) == 64;
    assert TileLinearIndex(_Tiles[[2]], 0, 63) == 1008;
    return 0;
end;
