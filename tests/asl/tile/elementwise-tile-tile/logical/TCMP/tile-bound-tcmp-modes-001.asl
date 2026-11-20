// PTO-TEST: {"id":"PTO-AVS-TILE-TCMP-MODES-001","source":"asl/tile/elementwise-tile-tile/logical/TCMP.asl","requirements":["PTO-TCMP-CONTRACT-001"],"kind":"boundary","summary":"TCMP assigns six comparison modes and reserves the remaining codes","pass_condition":"codes zero through five are legal, codes six and seven reject, and each relation maps to the expected truth value","related_sources":["asl/block/model/dispatch/tile-schema.asl","asl/tile/model/execution/comparison.asl"]}
func main() => integer
begin
    assert TCMPComparisonCodeLegal('000');
    assert TCMPComparisonCodeLegal('001');
    assert TCMPComparisonCodeLegal('010');
    assert TCMPComparisonCodeLegal('011');
    assert TCMPComparisonCodeLegal('100');
    assert TCMPComparisonCodeLegal('101');
    assert !TCMPComparisonCodeLegal('110');
    assert !TCMPComparisonCodeLegal('111');

    assert TileCompareBoolean(TileComparison_EQ, FALSE, TRUE);
    assert TileCompareBoolean(TileComparison_NE, FALSE, FALSE);
    assert TileCompareBoolean(TileComparison_LT, TRUE, FALSE);
    assert TileCompareBoolean(TileComparison_GT, FALSE, FALSE);
    assert TileCompareBoolean(TileComparison_LE, FALSE, TRUE);
    assert TileCompareBoolean(TileComparison_GE, FALSE, TRUE);
    return 0;
end;
