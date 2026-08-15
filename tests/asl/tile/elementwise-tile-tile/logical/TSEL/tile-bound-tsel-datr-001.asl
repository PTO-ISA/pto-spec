// PTO-TEST: {"id":"PTO-AVS-TILE-TSEL-DATR-001","source":"asl/tile/elementwise-tile-tile/logical/TSEL.asl","requirements":["PTO-TSEL-CONTRACT-001"],"kind":"boundary","summary":"TSEL admits only numeric destination padding data attributes","pass_condition":"PadValue passes while comparison, saturation, canonicalization, secondary type, rounding, or layout reject","related_sources":["asl/block/attributes/B.DATR.asl"]}
func main() => integer
begin
    assert TileOperationDATRFieldsLegal(
        22,
        Zeros{3},
        '10',
        FALSE,
        FALSE,
        Zeros{5},
        Zeros{3},
        Zeros{5});
    assert TileOperationDATRPadUnion(22) == TileDATRPadUnion_PadValue;
    assert !TileOperationDATRFieldsLegal(
        22,
        Zeros{3} + 1,
        Zeros{2},
        FALSE,
        FALSE,
        Zeros{5},
        Zeros{3},
        Zeros{5});
    assert !TileOperationDATRFieldsLegal(
        22,
        Zeros{3},
        Zeros{2},
        FALSE,
        FALSE,
        Zeros{5},
        Zeros{3} + 1,
        Zeros{5});
    return 0;
end;
