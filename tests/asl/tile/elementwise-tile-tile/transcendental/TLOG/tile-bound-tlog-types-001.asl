// PTO-TEST: {"id":"PTO-AVS-TILE-TLOG-TYPES-001","source":"asl/tile/elementwise-tile-tile/transcendental/TLOG.asl","requirements":["PTO-INST-TILE-TLOG","PTO-TLOG-CONTRACT-001"],"kind":"boundary","summary":"TLOG accepts only its four assigned floating element types","pass_condition":"FP64, FP32, FP16, and BF16 pass while TF32, E4M3, integer, and packed types reject without destination effects","related_sources":["asl/tile/model/execution/unary.asl","asl/tile/model/legality/operand-schema.asl"]}
func main() => integer
begin
    assert InstructionContractDataTypeLegal_TLOG(TileDataType_FP64);
    assert InstructionContractDataTypeLegal_TLOG(TileDataType_FP32);
    assert InstructionContractDataTypeLegal_TLOG(TileDataType_FP16);
    assert InstructionContractDataTypeLegal_TLOG(TileDataType_BF16);
    assert !InstructionContractDataTypeLegal_TLOG(TileDataType_TF32);
    assert !InstructionContractDataTypeLegal_TLOG(TileDataType_E4M3);
    assert !InstructionContractDataTypeLegal_TLOG(TileDataType_U32);
    assert !InstructionContractDataTypeLegal_TLOG(TileDataType_U4X2);

    ResetProfileState();
    ConfigureTile(0, 128, 1, 1, 1, 1, TileDataType_E4M3,
        TileLayout_RowMajor);
    ConfigureTile(1, 128, 1, 1, 1, 1, TileDataType_E4M3,
        TileLayout_RowMajor);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN});
    assert !InstructionContractOperandsLegal_TLOG(1, 0);
    assert !_Tiles[[1]].contents_defined;
    assert NumericStatusFlags() == Zeros{5};
    return 0;
end;
