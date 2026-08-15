// PTO-TEST: {"id":"PTO-AVS-TILE-TQUANT-AFFINE-001","source":"asl/tile/irregular-and-complex/format-conversion/TQUANT.asl","requirements":["PTO-INST-TILE-TQUANT"],"kind":"execution","summary":"TQUANT applies the FP32 multiplier before adding the integer zero point","pass_condition":"FP32 values one and two quantize to S8 values one and two with multiplier one and zero point zero","related_sources":["asl/tile/model/numeric/formats.asl","asl/arch/profile/reference-quantization.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(
        0,
        128,
        64,
        2,
        1,
        2,
        TileDataType_S8,
        TileLayout_RowMajor,
        TileLocation_Any);
    ConfigureTile(
        1,
        128,
        16,
        2,
        1,
        2,
        TileDataType_FP32,
        TileLayout_RowMajor,
        TileLocation_Any);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 0x3f800000);
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 0x40000000);

    TQUANT(
        0,
        1,
        Zeros{PTO_XLEN} + 0x3f800000,
        Zeros{PTO_XLEN},
        DefaultNumericExecutionControl());

    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 1;
    assert ReadTileElement(0, 0, 1) == Zeros{PTO_XLEN} + 2;
    return 0;
end;
