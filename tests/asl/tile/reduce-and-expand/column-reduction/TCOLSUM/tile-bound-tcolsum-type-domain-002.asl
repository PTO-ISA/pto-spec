// PTO-TEST: {"id":"PTO-AVS-TILE-TCOLSUM-TYPE-DOMAIN-002","source":"asl/tile/reduce-and-expand/column-reduction/TCOLSUM.asl","requirements":["PTO-INST-TILE-TCOLSUM"],"kind":"boundary","summary":"TCOLSUM discriminates its complete executable helper DataType domain","pass_condition":"all sixteen TileVecArithmetic types pass and representative non-domain carrier, exponent-only, compact, and packed types reject","related_sources":["asl/tile/model/legality/dtype-layout.asl"]}
func main() => integer
begin
    assert TCOLSUMDataTypeLegal(TileDataType_FP64);
    assert TCOLSUMDataTypeLegal(TileDataType_FP32);
    assert TCOLSUMDataTypeLegal(TileDataType_TF32);
    assert TCOLSUMDataTypeLegal(TileDataType_HF32);
    assert TCOLSUMDataTypeLegal(TileDataType_FP16);
    assert TCOLSUMDataTypeLegal(TileDataType_BF16);
    assert TCOLSUMDataTypeLegal(TileDataType_E4M3);
    assert TCOLSUMDataTypeLegal(TileDataType_E5M2);
    assert TCOLSUMDataTypeLegal(TileDataType_S64);
    assert TCOLSUMDataTypeLegal(TileDataType_S32);
    assert TCOLSUMDataTypeLegal(TileDataType_S16);
    assert TCOLSUMDataTypeLegal(TileDataType_S8);
    assert TCOLSUMDataTypeLegal(TileDataType_U64);
    assert TCOLSUMDataTypeLegal(TileDataType_U32);
    assert TCOLSUMDataTypeLegal(TileDataType_U16);
    assert TCOLSUMDataTypeLegal(TileDataType_U8);
    assert !TCOLSUMDataTypeLegal(TileDataType_HiF8);
    assert !TCOLSUMDataTypeLegal(TileDataType_E8M0);
    assert !TCOLSUMDataTypeLegal(TileDataType_E3M2);
    assert !TCOLSUMDataTypeLegal(TileDataType_U4X2);
    return 0;
end;
