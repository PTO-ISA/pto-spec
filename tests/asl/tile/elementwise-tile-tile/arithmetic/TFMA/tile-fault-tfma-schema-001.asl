// PTO-TEST: {"id":"PTO-AVS-TILE-TFMA-SCHEMA-001","source":"asl/tile/elementwise-tile-tile/arithmetic/TFMA.asl","requirements":["PTO-TFMA-CONTRACT-001"],"kind":"fault","summary":"TFMA uses exactly two ordered Local B.IOT bindings and no scalar binding.","pass_condition":"The accepted two-binding tuple passes and an added B.IOR binding rejects.","related_sources":["asl/block/model/dispatch/tile-schema.asl"]}
func ConfigureTFMASchema()
begin
    _BundleOperation.valid = TRUE;
    _BundleOperation.operation_class = BundleOperation_TileElement;
    _BundleOperation.data_type_valid = TRUE;
    _BundleOperation.data_type = Zeros{5} + 24;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    AddBundleTileBinding(
        FALSE, 0, 0, '1111', TRUE, TRUE, 1, 2, FALSE);
    AddBundleTileBinding(
        TRUE, 0, 1, '1111', TRUE, FALSE, 3, 0, TRUE);
end;

func main() => integer
begin
    ResetProfileState();
    ConfigureTFMASchema();
    assert SelectedBundleClosedTFMASchemaLegal(24);
    _BundleScalarBindings[[0]].valid = TRUE;
    assert !SelectedBundleClosedTFMASchemaLegal(24);
    return 0;
end;
