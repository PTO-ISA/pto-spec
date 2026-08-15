// PTO-TEST: {"id":"PTO-AVS-TILE-TCVT-DATR-001","source":"asl/tile/elementwise-tile-tile/format-conversion/TCVT.asl","requirements":["PTO-INST-TILE-TCVT"],"kind":"boundary","summary":"TCVT accepts PadValue with conversion controls and rejects CMode","pass_condition":"PadValue, Sat, Canonicalize, DataType, RMode, and Layout are applicable while nonzero CMode rejects","related_sources":["asl/block/attributes/B.DATR.asl"]}
func main() => integer
begin
    assert TileOperationDATRFieldsLegal(
        23,
        Zeros{3},
        '01',
        TRUE,
        TRUE,
        Zeros{5} + 1,
        Zeros{3} + 1,
        Zeros{5} + 1);
    assert !TileOperationDATRFieldsLegal(
        23,
        Zeros{3} + 1,
        Zeros{2},
        FALSE,
        FALSE,
        Zeros{5},
        Zeros{3},
        Zeros{5});
    assert TileOperationDATRPadUnion(23) == TileDATRPadUnion_PadValue;
    return 0;
end;
