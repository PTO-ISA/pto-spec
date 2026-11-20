// PTO-TEST: {"id":"PTO-AVS-TILE-TCMPS-TYPE-DOMAIN-002","source":"asl/tile/tile-scalar-and-immediate/logical/TCMPS.asl","requirements":["PTO-INST-TILE-TCMPS"],"kind":"boundary","summary":"TCMPS discriminates its complete executable helper DataType domain","pass_condition":"all sixteen TileVecArithmetic types pass and representative non-domain carrier, exponent-only, compact, and packed types reject","related_sources":["asl/tile/model/legality/dtype-layout.asl"]}
func main() => integer
begin
    assert TCMPSDataTypeLegal(TileDataType_FP64);
    assert TCMPSDataTypeLegal(TileDataType_FP32);
    assert TCMPSDataTypeLegal(TileDataType_TF32);
    assert TCMPSDataTypeLegal(TileDataType_HF32);
    assert TCMPSDataTypeLegal(TileDataType_FP16);
    assert TCMPSDataTypeLegal(TileDataType_BF16);
    assert TCMPSDataTypeLegal(TileDataType_E4M3);
    assert TCMPSDataTypeLegal(TileDataType_E5M2);
    assert TCMPSDataTypeLegal(TileDataType_S64);
    assert TCMPSDataTypeLegal(TileDataType_S32);
    assert TCMPSDataTypeLegal(TileDataType_S16);
    assert TCMPSDataTypeLegal(TileDataType_S8);
    assert TCMPSDataTypeLegal(TileDataType_U64);
    assert TCMPSDataTypeLegal(TileDataType_U32);
    assert TCMPSDataTypeLegal(TileDataType_U16);
    assert TCMPSDataTypeLegal(TileDataType_U8);
    assert !TCMPSDataTypeLegal(TileDataType_HiF8);
    assert !TCMPSDataTypeLegal(TileDataType_E8M0);
    assert !TCMPSDataTypeLegal(TileDataType_E3M2);
    assert !TCMPSDataTypeLegal(TileDataType_U4X2);
    return 0;
end;
