// PTO-TEST: {"id":"PTO-AVS-TILE-TDIVS-TYPE-DOMAIN-002","source":"asl/tile/tile-scalar-and-immediate/arithmetic/TDIVS.asl","requirements":["PTO-INST-TILE-TDIVS"],"kind":"boundary","summary":"TDIVS discriminates its complete executable helper DataType domain","pass_condition":"all sixteen TileVecArithmetic types pass and representative non-domain carrier, exponent-only, compact, and packed types reject","related_sources":["asl/tile/model/legality/dtype-layout.asl"]}
func main() => integer
begin
    assert TDIVSDataTypeLegal(TileDataType_FP64);
    assert TDIVSDataTypeLegal(TileDataType_FP32);
    assert TDIVSDataTypeLegal(TileDataType_TF32);
    assert TDIVSDataTypeLegal(TileDataType_HF32);
    assert TDIVSDataTypeLegal(TileDataType_FP16);
    assert TDIVSDataTypeLegal(TileDataType_BF16);
    assert TDIVSDataTypeLegal(TileDataType_E4M3);
    assert TDIVSDataTypeLegal(TileDataType_E5M2);
    assert TDIVSDataTypeLegal(TileDataType_S64);
    assert TDIVSDataTypeLegal(TileDataType_S32);
    assert TDIVSDataTypeLegal(TileDataType_S16);
    assert TDIVSDataTypeLegal(TileDataType_S8);
    assert TDIVSDataTypeLegal(TileDataType_U64);
    assert TDIVSDataTypeLegal(TileDataType_U32);
    assert TDIVSDataTypeLegal(TileDataType_U16);
    assert TDIVSDataTypeLegal(TileDataType_U8);
    assert !TDIVSDataTypeLegal(TileDataType_HiF8);
    assert !TDIVSDataTypeLegal(TileDataType_E8M0);
    assert !TDIVSDataTypeLegal(TileDataType_E3M2);
    assert !TDIVSDataTypeLegal(TileDataType_U4X2);
    return 0;
end;
