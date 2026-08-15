// PTO-TEST: {"id":"PTO-AVS-TILE-TNOT-DATR-001","source":"asl/tile/elementwise-tile-tile/logical/TNOT.asl","requirements":["PTO-TNOT-CONTRACT-001"],"kind":"boundary","summary":"TNOT accepts only B.DATR PadValue.","pass_condition":"PadValue is applicable while comparison mode and saturation reject for TNOT.","related_sources":["asl/block/model/dispatch/tile-schema.asl"]}
func main() => integer
begin
    assert TileOperationDATRFieldsLegal(
        14, Zeros{3}, '01', FALSE, FALSE,
        Zeros{5}, Zeros{3}, Zeros{5});
    assert !TileOperationDATRFieldsLegal(
        14, Zeros{3} + 1, Zeros{2}, FALSE, FALSE,
        Zeros{5}, Zeros{3}, Zeros{5});
    assert !TileOperationDATRFieldsLegal(
        14, Zeros{3}, Zeros{2}, TRUE, FALSE,
        Zeros{5}, Zeros{3}, Zeros{5});
    return 0;
end;
