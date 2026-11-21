// PTO-TEST: {"id":"PTO-AVS-TILE-TCVT-TYPES-001","source":"asl/tile/elementwise-tile-tile/format-conversion/TCVT.asl","requirements":["PTO-INST-TILE-TCVT"],"kind":"boundary","summary":"TCVT excludes private HiF4X2 while recognizing the assigned E6M2 and RCPE6M2 identities","pass_condition":"the TCVT contract rejects HiF4X2 and accepts the two newly assigned data type identities as contract-level types","related_sources":["asl/arch/data-types/tile-data-types.asl"]}
func main() => integer
begin
    assert TCVTDataTypeLegal(TileDataType_FP64);
    assert TCVTDataTypeLegal(TileDataType_FP32);
    assert TCVTDataTypeLegal(TileDataType_TF32);
    assert TCVTDataTypeLegal(TileDataType_HF32);
    assert TCVTDataTypeLegal(TileDataType_FP16);
    assert TCVTDataTypeLegal(TileDataType_BF16);
    assert TCVTDataTypeLegal(TileDataType_HiF8);
    assert TCVTDataTypeLegal(TileDataType_E4M3);
    assert TCVTDataTypeLegal(TileDataType_E5M2);
    assert TCVTDataTypeLegal(TileDataType_E3M2);
    assert TCVTDataTypeLegal(TileDataType_E2M3);
    assert TCVTDataTypeLegal(TileDataType_E2M1X2);
    assert TCVTDataTypeLegal(TileDataType_E1M2X2);
    assert TCVTDataTypeLegal(TileDataType_E8M0);
    assert !TCVTDataTypeLegal(TileDataType_HiF4X2);
    assert TCVTDataTypeLegal(TileDataType_E6M2);
    assert TCVTDataTypeLegal(TileDataType_RCPE6M2);
    assert TCVTDataTypeLegal(TileDataType_S64);
    assert TCVTDataTypeLegal(TileDataType_S32);
    assert TCVTDataTypeLegal(TileDataType_S16);
    assert TCVTDataTypeLegal(TileDataType_S8);
    assert TCVTDataTypeLegal(TileDataType_S4X2);
    assert TCVTDataTypeLegal(TileDataType_U64);
    assert TCVTDataTypeLegal(TileDataType_U32);
    assert TCVTDataTypeLegal(TileDataType_U16);
    assert TCVTDataTypeLegal(TileDataType_U8);
    assert TCVTDataTypeLegal(TileDataType_U4X2);
    return 0;
end;
