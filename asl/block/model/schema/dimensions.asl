// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-SCHEMA-DIMENSIONS","surface":"block","classification":["model","schema","dimensions"],"depends_on":["PTO-BLOCK-MODEL-LIFECYCLE-RESET"]}
func SetBundleDimension(index: BundleDimensionIndex, value: Word)
begin
    _BundleDimensions[[index]] = value;
end;
