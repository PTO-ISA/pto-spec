// PTO-TEST: {"id":"PTO-AVS-TILE-TTRI-TYPED-001","source":"asl/tile/irregular-and-complex/initialization/TTRI.asl","requirements":["PTO-INST-TILE-TTRI"],"kind":"execution","summary":"TTRI generates exact typed zero and one values inside the selected triangle","pass_condition":"a lower FP16 triangle contains 0x3c00 and zero while physical padding remains undefined","related_sources":["asl/tile/model/execution/generation.asl"]}
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

    TTRI(0, FALSE, 0);

    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 0x3c00;
    assert ReadTileElement(0, 0, 1) == Zeros{PTO_XLEN};
    assert ReadTileElement(0, 1, 0) == Zeros{PTO_XLEN} + 0x3c00;
    assert ReadTileElement(0, 1, 1) == Zeros{PTO_XLEN} + 0x3c00;
    assert ReadTileElement(0, 1, 2) == Zeros{PTO_XLEN};
    let padding = TileLinearIndex(_Tiles[[0]], 0, 3);
    assert _Tiles[[0]].defined_elements[padding] == '0';
    return 0;
end;
