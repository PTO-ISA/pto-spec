// PTO-TEST: {"id":"PTO-AVS-TILE-TABS-TYPE-DOMAIN-002","source":"asl/tile/elementwise-tile-tile/logical/TABS.asl","requirements":["PTO-INST-TILE-TABS"],"kind":"boundary","summary":"TABS discriminates its complete executable helper DataType domain","pass_condition":"all sixteen TileVecArithmetic types pass and representative non-domain carrier, exponent-only, compact, and packed types reject","related_sources":["asl/tile/model/legality/dtype-layout.asl"]}
func main() => integer
begin
    assert TABSDataTypeLegal(TileDataType_FP64);
    assert TABSDataTypeLegal(TileDataType_FP32);
    assert TABSDataTypeLegal(TileDataType_TF32);
    assert TABSDataTypeLegal(TileDataType_HF32);
    assert TABSDataTypeLegal(TileDataType_FP16);
    assert TABSDataTypeLegal(TileDataType_BF16);
    assert TABSDataTypeLegal(TileDataType_E4M3);
    assert TABSDataTypeLegal(TileDataType_E5M2);
    assert TABSDataTypeLegal(TileDataType_S64);
    assert TABSDataTypeLegal(TileDataType_S32);
    assert TABSDataTypeLegal(TileDataType_S16);
    assert TABSDataTypeLegal(TileDataType_S8);
    assert TABSDataTypeLegal(TileDataType_U64);
    assert TABSDataTypeLegal(TileDataType_U32);
    assert TABSDataTypeLegal(TileDataType_U16);
    assert TABSDataTypeLegal(TileDataType_U8);
    assert !TABSDataTypeLegal(TileDataType_HiF8);
    assert !TABSDataTypeLegal(TileDataType_E8M0);
    assert !TABSDataTypeLegal(TileDataType_E3M2);
    assert !TABSDataTypeLegal(TileDataType_U4X2);
    return 0;
end;
