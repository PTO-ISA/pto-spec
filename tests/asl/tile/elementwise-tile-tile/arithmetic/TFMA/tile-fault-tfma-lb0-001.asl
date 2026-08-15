// PTO-TEST: {"id":"PTO-AVS-TILE-TFMA-LB0-001","source":"asl/tile/elementwise-tile-tile/arithmetic/TFMA.asl","requirements":["PTO-TFMA-CONTRACT-001"],"kind":"fault","summary":"TFMA requires an explicit nonzero LB0 ValidCol.","pass_condition":"The otherwise complete TFMA binding tuple rejects when LB0 is absent.","related_sources":["asl/block/model/dispatch/tile-schema.asl"]}
func main() => integer
begin
    ResetProfileState();
    _BundleOperation.valid = TRUE;
    _BundleOperation.operation_class = BundleOperation_TileElement;
    _BundleOperation.data_type_valid = TRUE;
    _BundleOperation.data_type = Zeros{5} + 24;
    AddBundleTileBinding(
        FALSE, 0, 0, '1111', TRUE, TRUE, 1, 2, FALSE);
    AddBundleTileBinding(
        TRUE, 0, 1, '1111', TRUE, FALSE, 3, 0, TRUE);
    assert !SelectedBundleClosedTFMASchemaLegal(24);
    return 0;
end;
