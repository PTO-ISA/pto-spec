// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-SCHEMA-DIMENSIONS","surface":"block","classification":["model","schema","dimensions"],"depends_on":["PTO-BLOCK-MODEL-LIFECYCLE-RESET"]}
// NDF-BEGIN: PTO-BUNDLE-DIMENSION-DEFAULT-001
// ndf: kind=contract level=L1 layer=block status=accepted
// Each omitted bundle dimension MUST have effective value one. An explicit
// B.DIM or C.B.DIMI write, including zero, MUST replace that default value.
// Presence state MUST be used only for write-once and recovery bookkeeping;
// operation legality and execution MUST consume the effective dimension value.
// NDF-END: PTO-BUNDLE-DIMENSION-DEFAULT-001
func SetBundleDimension(index: BundleDimensionIndex, value: Word)
begin
    if _BundleDimensionPresent[[index]] then
        SetFault(Fault_BundleControl, ReadTPC());
    else
        _BundleDimensionPresent[[index]] = TRUE;
        _BundleDimensions[[index]] = value;
    end;
end;
