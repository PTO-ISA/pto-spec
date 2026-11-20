// PTO-TEST: {"id":"PTO-AVS-TILE-TEXPDIF-TYPE-PAIRS-001","source":"asl/tile/elementwise-tile-tile/transcendental/TEXPDIF.asl","requirements":["PTO-INST-TILE-TEXPDIF","PTO-TEXPDIF-CONTRACT-001"],"kind":"boundary","summary":"TEXPDIF accepts exactly the six frozen source-operation and destination type pairs","pass_condition":"all six specified pairs pass and representative reverse, mixed-FP64, packed, and integer pairs reject","related_sources":["asl/tile/model/legality/dtype-layout.asl"]}
func main() => integer
begin
    assert SelectTEXPDIFOperation() == TileOperation_TEXPDIF;
    assert TEXPDIFDataTypeLegal(
        TileDataType_FP16, TileDataType_FP16);
    assert TEXPDIFDataTypeLegal(
        TileDataType_BF16, TileDataType_BF16);
    assert TEXPDIFDataTypeLegal(
        TileDataType_FP32, TileDataType_FP32);
    assert TEXPDIFDataTypeLegal(
        TileDataType_FP16, TileDataType_FP32);
    assert TEXPDIFDataTypeLegal(
        TileDataType_BF16, TileDataType_FP32);
    assert !TEXPDIFDataTypeLegal(
        TileDataType_FP32, TileDataType_FP16);
    assert TEXPDIFDataTypeLegal(
        TileDataType_FP64, TileDataType_FP64);
    assert !TEXPDIFDataTypeLegal(
        TileDataType_FP64, TileDataType_FP32);
    assert !TEXPDIFDataTypeLegal(
        TileDataType_FP16, TileDataType_BF16);
    assert !TEXPDIFDataTypeLegal(
        TileDataType_S16, TileDataType_FP16);
    assert !TEXPDIFDataTypeLegal(
        TileDataType_FP16, TileDataType_E2M1X2);
    return 0;
end;
