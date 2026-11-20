// PTO-TEST: {"id":"PTO-AVS-TILE-TCOLMIN-TYPE-DOMAIN-002","source":"asl/tile/reduce-and-expand/column-reduction/TCOLMIN.asl","requirements":["PTO-INST-TILE-TCOLMIN"],"kind":"boundary","summary":"TCOLMIN discriminates its complete executable helper DataType domain","pass_condition":"all sixteen TileVecArithmetic types pass and representative non-domain carrier, exponent-only, compact, and packed types reject","related_sources":["asl/tile/model/legality/dtype-layout.asl"]}
func main() => integer
begin
    assert TCOLMINDataTypeLegal(TileDataType_FP64);
    assert TCOLMINDataTypeLegal(TileDataType_FP32);
    assert TCOLMINDataTypeLegal(TileDataType_TF32);
    assert TCOLMINDataTypeLegal(TileDataType_HF32);
    assert TCOLMINDataTypeLegal(TileDataType_FP16);
    assert TCOLMINDataTypeLegal(TileDataType_BF16);
    assert TCOLMINDataTypeLegal(TileDataType_E4M3);
    assert TCOLMINDataTypeLegal(TileDataType_E5M2);
    assert TCOLMINDataTypeLegal(TileDataType_S64);
    assert TCOLMINDataTypeLegal(TileDataType_S32);
    assert TCOLMINDataTypeLegal(TileDataType_S16);
    assert TCOLMINDataTypeLegal(TileDataType_S8);
    assert TCOLMINDataTypeLegal(TileDataType_U64);
    assert TCOLMINDataTypeLegal(TileDataType_U32);
    assert TCOLMINDataTypeLegal(TileDataType_U16);
    assert TCOLMINDataTypeLegal(TileDataType_U8);
    assert !TCOLMINDataTypeLegal(TileDataType_HiF8);
    assert !TCOLMINDataTypeLegal(TileDataType_E8M0);
    assert !TCOLMINDataTypeLegal(TileDataType_E3M2);
    assert !TCOLMINDataTypeLegal(TileDataType_U4X2);
    return 0;
end;
