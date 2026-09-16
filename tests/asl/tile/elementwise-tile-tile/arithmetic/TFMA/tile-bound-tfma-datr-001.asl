// PTO-TEST: {"id":"PTO-AVS-TILE-TFMA-DATR-001","source":"asl/tile/elementwise-tile-tile/arithmetic/TFMA.asl","requirements":["PTO-TFMA-CONTRACT-001"],"kind":"boundary","summary":"TFMA accepts the PadValue and Layout members of B.DATR.","pass_condition":"PadValue and layout are applicable while rounding, saturation, canonicalization, comparison, and secondary type are not.","related_sources":["asl/block/model/schema/attributes.asl"]}
func main() => integer
begin
    assert TileOperationDATRFieldApplicable(
        24, TileDATRField_PadValueOrByteId);
    assert !TileOperationDATRFieldApplicable(24, TileDATRField_CMode);
    assert !TileOperationDATRFieldApplicable(24, TileDATRField_Sat);
    assert !TileOperationDATRFieldApplicable(24, TileDATRField_Canonicalize);
    assert !TileOperationDATRFieldApplicable(24, TileDATRField_DataType);
    assert !TileOperationDATRFieldApplicable(24, TileDATRField_RMode);
    assert TileOperationDATRFieldApplicable(24, TileDATRField_Layout);
    assert TileOperationDATRPadUnion(24) == TileDATRPadUnion_PadValue;
    return 0;
end;
