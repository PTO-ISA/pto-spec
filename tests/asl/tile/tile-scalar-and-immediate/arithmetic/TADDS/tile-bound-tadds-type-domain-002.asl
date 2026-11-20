// PTO-TEST: {"id":"PTO-AVS-TILE-TADDS-TYPE-DOMAIN-002","source":"asl/tile/tile-scalar-and-immediate/arithmetic/TADDS.asl","requirements":["PTO-INST-TILE-TADDS"],"kind":"boundary","summary":"TADDS discriminates its complete executable helper DataType domain","pass_condition":"all sixteen TileVecArithmetic types pass and representative non-domain carrier, exponent-only, compact, and packed types reject","related_sources":["asl/tile/model/legality/dtype-layout.asl"]}
func main() => integer
begin
    assert TADDSDataTypeLegal(TileDataType_FP64);
    assert TADDSDataTypeLegal(TileDataType_FP32);
    assert TADDSDataTypeLegal(TileDataType_TF32);
    assert TADDSDataTypeLegal(TileDataType_HF32);
    assert TADDSDataTypeLegal(TileDataType_FP16);
    assert TADDSDataTypeLegal(TileDataType_BF16);
    assert TADDSDataTypeLegal(TileDataType_E4M3);
    assert TADDSDataTypeLegal(TileDataType_E5M2);
    assert TADDSDataTypeLegal(TileDataType_S64);
    assert TADDSDataTypeLegal(TileDataType_S32);
    assert TADDSDataTypeLegal(TileDataType_S16);
    assert TADDSDataTypeLegal(TileDataType_S8);
    assert TADDSDataTypeLegal(TileDataType_U64);
    assert TADDSDataTypeLegal(TileDataType_U32);
    assert TADDSDataTypeLegal(TileDataType_U16);
    assert TADDSDataTypeLegal(TileDataType_U8);
    assert !TADDSDataTypeLegal(TileDataType_HiF8);
    assert !TADDSDataTypeLegal(TileDataType_E8M0);
    assert !TADDSDataTypeLegal(TileDataType_E3M2);
    assert !TADDSDataTypeLegal(TileDataType_U4X2);
    return 0;
end;
