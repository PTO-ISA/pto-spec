// PTO-TEST: {"id":"PTO-AVS-TILE-TNEG-DATR-001","source":"asl/tile/elementwise-tile-tile/logical/TNEG.asl","requirements":["PTO-TNEG-CONTRACT-001"],"kind":"boundary","summary":"TNEG accepts only B.DATR PadValue.","pass_condition":"PadValue is applicable while comparison mode and saturation reject for TNEG.","related_sources":["asl/block/model/dispatch/tile-schema.asl"]}
func main() => integer
begin
    assert TileOperationDATRFieldsLegal(
        15, Zeros{3}, '01', FALSE, FALSE,
        Zeros{5}, Zeros{3}, Zeros{5});
    assert !TileOperationDATRFieldsLegal(
        15, Zeros{3} + 1, Zeros{2}, FALSE, FALSE,
        Zeros{5}, Zeros{3}, Zeros{5});
    assert !TileOperationDATRFieldsLegal(
        15, Zeros{3}, Zeros{2}, TRUE, FALSE,
        Zeros{5}, Zeros{3}, Zeros{5});
    return 0;
end;
