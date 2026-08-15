// PTO-TEST: {"id":"PTO-AVS-TILE-TQUANT-PADDING-001","source":"asl/tile/irregular-and-complex/format-conversion/TQUANT.asl","requirements":["PTO-INST-TILE-TQUANT"],"kind":"state-transition","summary":"TQUANT publishes valid data and Null padding through one prepared destination","pass_condition":"the valid element is defined and every physical padding element is undefined after quantization","related_sources":["asl/tile/model/numeric/formats.asl","asl/tile/model/definedness/elements.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(
        0,
        128,
        64,
        2,
        1,
        1,
        TileDataType_U8,
        TileLayout_RowMajor,
        TileLocation_Any);
    ConfigureTile(
        1,
        128,
        16,
        2,
        1,
        1,
        TileDataType_FP32,
        TileLayout_RowMajor,
        TileLocation_Any);
    WriteTileElement(0, 0, 1, Zeros{PTO_XLEN} + 0xaa);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 0x3f800000);

    TQUANT(
        0,
        1,
        Zeros{PTO_XLEN} + 0x3f800000,
        Zeros{PTO_XLEN},
        DefaultNumericExecutionControl());

    assert TileElementDefined(0, 0, 0);
    assert !TileElementDefined(0, 0, 1);
    return 0;
end;
