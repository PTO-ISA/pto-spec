// PTO-TEST: {"id":"PTO-AVS-TILE-TCOLMAX-TYPE-DOMAIN-002","source":"asl/tile/reduce-and-expand/column-reduction/TCOLMAX.asl","requirements":["PTO-INST-TILE-TCOLMAX"],"kind":"boundary","summary":"TCOLMAX discriminates its complete executable helper DataType domain","pass_condition":"all sixteen TileVecArithmetic types pass and representative non-domain carrier, exponent-only, compact, and packed types reject","related_sources":["asl/tile/model/legality/dtype-layout.asl"]}
func main() => integer
begin
    assert TCOLMAXDataTypeLegal(TileDataType_FP64);
    assert TCOLMAXDataTypeLegal(TileDataType_FP32);
    assert TCOLMAXDataTypeLegal(TileDataType_TF32);
    assert TCOLMAXDataTypeLegal(TileDataType_HF32);
    assert TCOLMAXDataTypeLegal(TileDataType_FP16);
    assert TCOLMAXDataTypeLegal(TileDataType_BF16);
    assert TCOLMAXDataTypeLegal(TileDataType_E4M3);
    assert TCOLMAXDataTypeLegal(TileDataType_E5M2);
    assert TCOLMAXDataTypeLegal(TileDataType_S64);
    assert TCOLMAXDataTypeLegal(TileDataType_S32);
    assert TCOLMAXDataTypeLegal(TileDataType_S16);
    assert TCOLMAXDataTypeLegal(TileDataType_S8);
    assert TCOLMAXDataTypeLegal(TileDataType_U64);
    assert TCOLMAXDataTypeLegal(TileDataType_U32);
    assert TCOLMAXDataTypeLegal(TileDataType_U16);
    assert TCOLMAXDataTypeLegal(TileDataType_U8);
    assert !TCOLMAXDataTypeLegal(TileDataType_HiF8);
    assert !TCOLMAXDataTypeLegal(TileDataType_E8M0);
    assert !TCOLMAXDataTypeLegal(TileDataType_E3M2);
    assert !TCOLMAXDataTypeLegal(TileDataType_U4X2);
    return 0;
end;
