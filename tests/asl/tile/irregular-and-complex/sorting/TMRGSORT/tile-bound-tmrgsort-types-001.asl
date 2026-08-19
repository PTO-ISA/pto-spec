// PTO-TEST: {"id":"PTO-AVS-TILE-TMRGSORT-TYPES-001","source":"asl/tile/irregular-and-complex/sorting/TMRGSORT.asl","requirements":["PTO-INST-TILE-TMRGSORT"],"kind":"boundary","summary":"TMRGSORT accepts only FP32 or FP16 value streams","pass_condition":"an otherwise legal U64 merge configuration is rejected","related_sources":["asl/tile/model/legality/indexed-layout.asl"]}
func main() => integer
begin
    assert InstructionContractDataTypeLegal_TMRGSORT(TileDataType_FP32);
    assert InstructionContractDataTypeLegal_TMRGSORT(TileDataType_FP16);
    assert !InstructionContractDataTypeLegal_TMRGSORT(TileDataType_BF16);
    assert !InstructionContractDataTypeLegal_TMRGSORT(TileDataType_U16);
    ResetProfileState();
    ConfigureTile(
        30, 256, 1, 1, 1, 1,
        TileDataType_U64,
        TileLayout_RowMajor,
        TileLocation_Any);
    ConfigureTile(
        31, 256, 1, 1, 1, 1,
        TileDataType_U64,
        TileLayout_RowMajor,
        TileLocation_Any);
    ConfigureTile(
        32, 256, 1, 2, 1, 2,
        TileDataType_U64,
        TileLayout_RowMajor,
        TileLocation_Any);
    WriteTileElement(30, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(31, 0, 0, Zeros{PTO_XLEN} + 2);

    assert !TileOperandsLegal_TMRGSORT(32, 30, 31, FALSE);

    ConfigureTile(33, 256, 1, 1, 1, 1, TileDataType_FP16,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(34, 256, 1, 1, 1, 1, TileDataType_FP16,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(35, 256, 1, 2, 1, 2, TileDataType_FP16,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(33, 0, 0, Zeros{PTO_XLEN} + 0x3c00);
    WriteTileElement(34, 0, 0, Zeros{PTO_XLEN} + 0x4000);
    assert TileOperandsLegal_TMRGSORT(35, 33, 34, FALSE);
    return 0;
end;
