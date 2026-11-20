// PTO-TEST: {"id":"PTO-AVS-TILE-TDIV-TYPE-DOMAIN-002","source":"asl/tile/elementwise-tile-tile/transcendental/TDIV.asl","requirements":["PTO-INST-TILE-TDIV"],"kind":"boundary","summary":"TDIV discriminates its complete executable helper DataType domain","pass_condition":"all sixteen TileVecArithmetic types pass and representative non-domain carrier, exponent-only, compact, and packed types reject","related_sources":["asl/tile/model/legality/dtype-layout.asl"]}
func main() => integer
begin
    assert TDIVDataTypeLegal(TileDataType_FP64);
    assert TDIVDataTypeLegal(TileDataType_FP32);
    assert TDIVDataTypeLegal(TileDataType_TF32);
    assert TDIVDataTypeLegal(TileDataType_HF32);
    assert TDIVDataTypeLegal(TileDataType_FP16);
    assert TDIVDataTypeLegal(TileDataType_BF16);
    assert TDIVDataTypeLegal(TileDataType_E4M3);
    assert TDIVDataTypeLegal(TileDataType_E5M2);
    assert TDIVDataTypeLegal(TileDataType_S64);
    assert TDIVDataTypeLegal(TileDataType_S32);
    assert TDIVDataTypeLegal(TileDataType_S16);
    assert TDIVDataTypeLegal(TileDataType_S8);
    assert TDIVDataTypeLegal(TileDataType_U64);
    assert TDIVDataTypeLegal(TileDataType_U32);
    assert TDIVDataTypeLegal(TileDataType_U16);
    assert TDIVDataTypeLegal(TileDataType_U8);
    assert !TDIVDataTypeLegal(TileDataType_HiF8);
    assert !TDIVDataTypeLegal(TileDataType_E8M0);
    assert !TDIVDataTypeLegal(TileDataType_E3M2);
    assert !TDIVDataTypeLegal(TileDataType_U4X2);
    return 0;
end;
