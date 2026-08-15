// PTO-TEST: {"id":"PTO-AVS-TILE-TCMP-DATR-001","source":"asl/tile/elementwise-tile-tile/logical/TCMP.asl","requirements":["PTO-TCMP-CONTRACT-001"],"kind":"boundary","summary":"TCMP admits only comparison mode and predicate padding data attributes","pass_condition":"CMode and PadValue pass while saturation, canonicalization, secondary type, rounding, or layout reject","related_sources":["asl/block/attributes/B.DATR.asl"]}
func main() => integer
begin
    assert TileOperationDATRFieldsLegal(
        12,
        Zeros{3} + 5,
        '01',
        FALSE,
        FALSE,
        Zeros{5},
        Zeros{3},
        Zeros{5});
    assert TileOperationDATRPadUnion(12) == TileDATRPadUnion_PadValue;
    assert !TileOperationDATRFieldsLegal(
        12,
        Zeros{3},
        Zeros{2},
        TRUE,
        FALSE,
        Zeros{5},
        Zeros{3},
        Zeros{5});
    assert !TileOperationDATRFieldsLegal(
        12,
        Zeros{3},
        Zeros{2},
        FALSE,
        FALSE,
        Zeros{5} + 1,
        Zeros{3},
        Zeros{5});
    return 0;
end;
