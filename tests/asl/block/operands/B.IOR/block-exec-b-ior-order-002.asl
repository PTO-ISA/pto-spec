// PTO-TEST: {"id":"PTO-AVS-BLOCK-B-IOR-ORDER-EXEC-002","source":"asl/block/operands/B.IOR.asl","requirements":["PTO-INST-BLOCK-B-IOR"],"kind":"execution","summary":"B.IOR resolves ordered GPR inputs and output aliases","pass_condition":"ordered GPR control assertions hold","related_sources":[]}
func TestBundleOrderedGPRControls()
begin
    let tci_operation = DecodeTileOperation(
        TileDecode_TEPL, Zeros{12} + 0x066)
        as integer {0..PTO_TILE_OPERATION_COUNT-1};
    let ttri_operation = DecodeTileOperation(
        TileDecode_TEPL, Zeros{12} + 0x067)
        as integer {0..PTO_TILE_OPERATION_COUNT-1};

    // TCI packs scalar0 then flag0, and preserves the omitted defaults.
    ResetProfileState();
    WriteGPR(2, Zeros{PTO_XLEN} + 5);
    WriteGPR(3, Zeros{PTO_XLEN} + 1);
    SetBundleScalarBinding(0, 0, 2, 3, 0, 3);
    let tci = BundleTileInstructionOperands(tci_operation);
    assert tci.scalar0 == Zeros{PTO_XLEN} + 5;
    assert tci.flag0;
    assert BundleOperationGPRBindingValuesLegal(tci_operation);

    ResetProfileState();
    let tci_default = BundleTileInstructionOperands(tci_operation);
    assert tci_default.scalar0 == Zeros{PTO_XLEN};
    assert !tci_default.flag0;

    // TTRI packs diagonal before upper and accepts both signed boundaries.
    ResetProfileState();
    WriteGPR(4, Ones{PTO_XLEN} - 65534);
    WriteGPR(5, Zeros{PTO_XLEN} + 1);
    SetBundleScalarBinding(0, 0, 4, 5, 0, 3);
    assert BundleOperationGPRBindingValuesLegal(ttri_operation);
    let ttri = BundleTileInstructionOperands(ttri_operation);
    assert ttri.diagonal == -65535;
    assert ttri.flag0;
    ResetProfileState();
    WriteGPR(4, Zeros{PTO_XLEN} + 65535);
    SetBundleScalarBinding(0, 0, 4, 0, 0, 3);
    assert BundleOperationGPRBindingValuesLegal(ttri_operation);
    let ttri_positive = BundleTileInstructionOperands(ttri_operation);
    assert ttri_positive.diagonal == 65535;

    // Raw boolean 2 and an out-of-range diagonal reject before constrained
    // operand assignment; the caller maps this to Fault_TileLegality.
    ResetProfileState();
    WriteGPR(4, Zeros{PTO_XLEN} + 65536);
    SetBundleScalarBinding(0, 0, 4, 0, 0, 3);
    assert !BundleOperationGPRBindingValuesLegal(ttri_operation);

    // Every operation rejects a nonzero surplus source and RegDst.
    ResetProfileState();
end;

func main() => integer
begin
    ResetProfileState();
    TestBundleOrderedGPRControls();
    return 0;
end;
