// PTO-TEST: {"id":"PTO-AVS-TILE-TDEQUANT-AFFINE-001","source":"asl/tile/irregular-and-complex/format-conversion/TDEQUANT.asl","requirements":["PTO-INST-TILE-TDEQUANT"],"kind":"execution","summary":"TDEQUANT subtracts the integer zero point before applying the FP32 multiplier","pass_condition":"S8 values one and two dequantize to FP32 values one and two with multiplier one and zero point zero","related_sources":["asl/tile/model/numeric/formats.asl","asl/arch/profile/reference-quantization.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(
        0,
        128,
        16,
        2,
        1,
        2,
        TileDataType_FP32,
        TileLayout_RowMajor,
        TileLocation_Any);
    ConfigureTile(
        1,
        128,
        64,
        2,
        1,
        2,
        TileDataType_S8,
        TileLayout_RowMajor,
        TileLocation_Any);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 2);

    TDEQUANT(
        0,
        1,
        Zeros{PTO_XLEN} + 0x3f800000,
        Zeros{PTO_XLEN},
        DefaultNumericExecutionControl());

    assert ReadTileElement(0, 0, 0) ==
        Zeros{PTO_XLEN} + 0x3f800000;
    assert ReadTileElement(0, 0, 1) ==
        Zeros{PTO_XLEN} + 0x40000000;
    return 0;
end;
