// PTO-TEST: {"id":"PTO-AVS-TILE-TSORT-TYPES-001","source":"asl/tile/irregular-and-complex/sorting/TSORT.asl","requirements":["PTO-INST-TILE-TSORT"],"kind":"boundary","summary":"TSORT accepts only FP32 or FP16 values with U32 indices","pass_condition":"an otherwise legal U64 value configuration is rejected","related_sources":["asl/tile/model/legality/indexed-layout.asl"]}
func main() => integer
begin
    assert InstructionContractDataTypeLegal_TSORT(TileDataType_FP32);
    assert InstructionContractDataTypeLegal_TSORT(TileDataType_FP16);
    assert InstructionContractDataTypeLegal_TSORT(TileDataType_BF16);
    assert !InstructionContractDataTypeLegal_TSORT(TileDataType_U16);
    ResetProfileState();
    ConfigureTile(
        20, 256, 1, 2, 1, 2,
        TileDataType_U64,
        TileLayout_RowMajor,
        TileLocation_Any);
    ConfigureTile(
        21, 256, 1, 2, 1, 2,
        TileDataType_U32,
        TileLayout_RowMajor,
        TileLocation_Any);
    ConfigureTile(
        22, 256, 1, 2, 1, 2,
        TileDataType_U64,
        TileLayout_RowMajor,
        TileLocation_Any);
    WriteTileElement(22, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(22, 0, 1, Zeros{PTO_XLEN} + 2);

    assert !TileOperandsLegal_TSORT(20, 21, 22, 2, FALSE);

    ConfigureTile(23, 256, 1, 2, 1, 2, TileDataType_BF16,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(24, 256, 1, 2, 1, 2, TileDataType_U32,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(25, 256, 1, 2, 1, 2, TileDataType_BF16,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(23, 0, 0, Zeros{PTO_XLEN} + 0x3f80);
    WriteTileElement(23, 0, 1, Zeros{PTO_XLEN} + 0x4000);
    assert TileOperandsLegal_TSORT(25, 24, 23, 2, FALSE);
    return 0;
end;
