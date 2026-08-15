// PTO-TEST: {"id":"PTO-AVS-TILE-TCVT-INTEGER-001","source":"asl/tile/elementwise-tile-tile/format-conversion/TCVT.asl","requirements":["PTO-INST-TILE-TCVT"],"kind":"execution","summary":"TCVT integer conversion covers packed signedness, modulo narrowing, and saturation","pass_condition":"S4X2 sign-extends, non-saturating U16-to-U8 narrows modulo 256, and saturating conversion clamps to 255","related_sources":["asl/tile/model/numeric/formats.asl"]}
func main() => integer
begin
    assert TileConvertIntegerValue(
        Zeros{PTO_XLEN} + 0xf,
        TileDataType_S4X2,
        TileDataType_S8,
        FALSE) == Ones{PTO_XLEN};
    assert TileConvertIntegerValue(
        Zeros{PTO_XLEN} + 300,
        TileDataType_U16,
        TileDataType_U8,
        FALSE) == Zeros{PTO_XLEN} + 44;
    assert TileConvertIntegerValue(
        Zeros{PTO_XLEN} + 300,
        TileDataType_U16,
        TileDataType_U8,
        TRUE) == Zeros{PTO_XLEN} + 255;
    assert TileConvertIntegerValue(
        Ones{PTO_XLEN},
        TileDataType_S64,
        TileDataType_U4X2,
        TRUE) == Zeros{PTO_XLEN};
    return 0;
end;
