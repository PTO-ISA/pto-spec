// PTO-TEST: {"id":"PTO-AVS-TILE-TQUANT-DEFAULTS-001","source":"asl/tile/irregular-and-complex/format-conversion/TQUANT.asl","requirements":["PTO-INST-TILE-TQUANT"],"kind":"boundary","summary":"TQUANT distinguishes an omitted B.IOR from an explicitly encoded zero multiplier","pass_condition":"omission resolves multiplier one and zero point zero while a present all-zero B.IOR fails raw scalar preflight","related_sources":["asl/block/model/dispatch/tile-schema.asl","asl/block/model/dispatch/scalar-schema.asl"]}
func main() => integer
begin
    ResetProfileState();
    let operation = DecodeTileOperation(
        TileDecode_TEPL,
        Zeros{12} + 0x06a)
        as integer {0..PTO_TILE_OPERATION_COUNT-1};

    let omitted = BundleTileInstructionOperands(operation);
    assert omitted.scalar0 == Zeros{PTO_XLEN} + 0x3f800000;
    assert omitted.scalar1 == Zeros{PTO_XLEN};

    SetBundleScalarBinding(0, 0, 0, 0, 0, 3);
    assert !BundleOperationGPRBindingValuesLegal(operation);
    return 0;
end;
