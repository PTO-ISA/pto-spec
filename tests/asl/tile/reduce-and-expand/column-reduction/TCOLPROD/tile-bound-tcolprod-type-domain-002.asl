// PTO-TEST: {"id":"PTO-AVS-TILE-TCOLPROD-TYPE-DOMAIN-002","source":"asl/tile/reduce-and-expand/column-reduction/TCOLPROD.asl","requirements":["PTO-INST-TILE-TCOLPROD"],"kind":"boundary","summary":"TCOLPROD discriminates its complete executable helper DataType domain","pass_condition":"all sixteen TileVecArithmetic types pass and representative non-domain carrier, exponent-only, compact, and packed types reject","related_sources":["asl/tile/model/legality/dtype-layout.asl"]}
func main() => integer
begin
    assert TCOLPRODDataTypeLegal(TileDataType_FP64);
    assert TCOLPRODDataTypeLegal(TileDataType_FP32);
    assert TCOLPRODDataTypeLegal(TileDataType_TF32);
    assert TCOLPRODDataTypeLegal(TileDataType_HF32);
    assert TCOLPRODDataTypeLegal(TileDataType_FP16);
    assert TCOLPRODDataTypeLegal(TileDataType_BF16);
    assert TCOLPRODDataTypeLegal(TileDataType_E4M3);
    assert TCOLPRODDataTypeLegal(TileDataType_E5M2);
    assert TCOLPRODDataTypeLegal(TileDataType_S64);
    assert TCOLPRODDataTypeLegal(TileDataType_S32);
    assert TCOLPRODDataTypeLegal(TileDataType_S16);
    assert TCOLPRODDataTypeLegal(TileDataType_S8);
    assert TCOLPRODDataTypeLegal(TileDataType_U64);
    assert TCOLPRODDataTypeLegal(TileDataType_U32);
    assert TCOLPRODDataTypeLegal(TileDataType_U16);
    assert TCOLPRODDataTypeLegal(TileDataType_U8);
    assert !TCOLPRODDataTypeLegal(TileDataType_HiF8);
    assert !TCOLPRODDataTypeLegal(TileDataType_E8M0);
    assert !TCOLPRODDataTypeLegal(TileDataType_E3M2);
    assert !TCOLPRODDataTypeLegal(TileDataType_U4X2);
    return 0;
end;
