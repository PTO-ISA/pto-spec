// PTO-TEST: {"id":"PTO-AVS-TILE-TRECIP-TYPES-001","source":"asl/tile/elementwise-tile-tile/transcendental/TRECIP.asl","requirements":["PTO-INST-TILE-TRECIP","PTO-TRECIP-CONTRACT-001"],"kind":"boundary","summary":"TRECIP accepts only its four assigned floating element types","pass_condition":"FP64, FP32, FP16, and BF16 pass while TF32, E4M3, integer, and packed types reject without destination effects","related_sources":["asl/tile/model/execution/unary.asl","asl/tile/model/legality/operand-schema.asl"]}
func main() => integer
begin
    assert TRECIPDataTypeLegal(TileDataType_FP64);
    assert TRECIPDataTypeLegal(TileDataType_FP32);
    assert TRECIPDataTypeLegal(TileDataType_FP16);
    assert TRECIPDataTypeLegal(TileDataType_BF16);
    assert !TRECIPDataTypeLegal(TileDataType_TF32);
    assert !TRECIPDataTypeLegal(TileDataType_E4M3);
    assert !TRECIPDataTypeLegal(TileDataType_U32);
    assert !TRECIPDataTypeLegal(TileDataType_U4X2);

    ResetProfileState();
    ConfigureTile(0, 128, 1, 1, 1, 1, TileDataType_E4M3,
        TileLayout_RowMajor);
    ConfigureTile(1, 128, 1, 1, 1, 1, TileDataType_E4M3,
        TileLayout_RowMajor);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN});
    assert !TRECIPOperandsLegal(1, 0);
    assert !_Tiles[[1]].contents_defined;
    assert NumericStatusFlags() == Zeros{5};
    return 0;
end;
