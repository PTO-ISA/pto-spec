// PTO-TEST: {"id":"PTO-AVS-TILE-TQUANT-SAT-001","source":"asl/tile/irregular-and-complex/format-conversion/TQUANT.asl","requirements":["PTO-INST-TILE-TQUANT"],"kind":"execution","summary":"TQUANT distinguishes saturating conversion from modulo conversion","pass_condition":"FP32 two hundred becomes signed eight-bit 127 with Sat and signed eight-bit negative 56 without Sat","related_sources":["asl/arch/profile/reference-quantization.asl","asl/tile/model/numeric/formats.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(
        0,
        128,
        128,
        1,
        1,
        1,
        TileDataType_S8,
        TileLayout_RowMajor,
        TileLocation_Any);
    ConfigureTile(
        1,
        128,
        128,
        1,
        1,
        1,
        TileDataType_S8,
        TileLayout_RowMajor,
        TileLocation_Any);
    ConfigureTile(
        2,
        128,
        32,
        1,
        1,
        1,
        TileDataType_FP32,
        TileLayout_RowMajor,
        TileLocation_Any);
    WriteTileElement(
        2,
        0,
        0,
        Zeros{PTO_XLEN} + 0x43480000);

    var saturating = DefaultNumericExecutionControl();
    saturating.saturating = TRUE;
    TQUANT(
        0,
        2,
        Zeros{PTO_XLEN} + 0x3f800000,
        Zeros{PTO_XLEN},
        saturating);
    TQUANT(
        1,
        2,
        Zeros{PTO_XLEN} + 0x3f800000,
        Zeros{PTO_XLEN},
        DefaultNumericExecutionControl());

    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 127;
    assert ReadTileElement(1, 0, 0) == Ones{PTO_XLEN} - 55;
    return 0;
end;
