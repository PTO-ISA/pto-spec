// PTO-TEST: {"id":"PTO-AVS-TILE-CARRIER-REINTERPRET-BOUND-002","source":"asl/tile/model/legality/dtype-layout.asl","requirements":["PTO-TILE-CARRIER-REINTERPRETATION-001"],"kind":"boundary","summary":"Cross-type carrier reinterpretation is same-width and non-packed","pass_condition":"BF16 and U16 are compatible, width mismatch rejects, exact packed identity remains legal, and distinct packed X2 types reject","related_sources":["asl/arch/data-types/tile-data-types.asl"]}
func main() => integer
begin
    ResetProfileState();
    assert TileCarrierWidthCompatible(
        TileDataType_BF16, TileDataType_U16);
    assert !TileCarrierWidthCompatible(
        TileDataType_BF16, TileDataType_U8);
    assert TileCarrierWidthCompatible(
        TileDataType_E2M1X2, TileDataType_E2M1X2);
    assert !TileCarrierWidthCompatible(
        TileDataType_E2M1X2, TileDataType_E1M2X2);
    assert !TileCarrierWidthCompatible(
        TileDataType_S4X2, TileDataType_U4X2);
    let (direct_valid, direct_type) = ResolveTileCarrierOperationType(
        TileDataType_BF16);
    assert direct_valid && direct_type == TileDataType_BF16;
    _BundleOperation.valid = TRUE;
    let (invalid_bundle_type, -) = ResolveTileCarrierOperationType(
        TileDataType_BF16);
    assert !invalid_bundle_type;
    return 0;
end;
