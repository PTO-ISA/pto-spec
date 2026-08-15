// PTO-TEST: {"id":"PTO-AVS-TILE-TCI-WRAP-001","source":"asl/tile/irregular-and-complex/initialization/TCI.asl","requirements":["PTO-INST-TILE-TCI"],"kind":"execution","summary":"TCI sequence arithmetic wraps at the selected element width","pass_condition":"ascending U16 wraps 65535 to zero and descending U16 decrements from 65535","related_sources":["asl/tile/model/execution/generation.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(
        0,
        128,
        32,
        2,
        1,
        2,
        TileDataType_U16,
        TileLayout_RowMajor,
        TileLocation_Any);
    ConfigureTile(
        1,
        128,
        32,
        2,
        1,
        2,
        TileDataType_U16,
        TileLayout_RowMajor,
        TileLocation_Any);

    TCI(0, Ones{PTO_XLEN}, FALSE);
    TCI(1, Ones{PTO_XLEN}, TRUE);

    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 0xffff;
    assert ReadTileElement(0, 0, 1) == Zeros{PTO_XLEN};
    assert ReadTileElement(1, 0, 0) == Zeros{PTO_XLEN} + 0xffff;
    assert ReadTileElement(1, 0, 1) == Zeros{PTO_XLEN} + 0xfffe;
    return 0;
end;
