<!-- GENERATED FROM: asl/block/model/schema/dimensions.asl -->
# Dimensions

**Normative ASL source:** `asl/block/model/schema/dimensions.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-SCHEMA-DIMENSIONS}

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/schema/dimensions.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-SCHEMA-DIMENSIONS","surface":"block","classification":["model","schema","dimensions"],"depends_on":["PTO-BLOCK-MODEL-LIFECYCLE-RESET"]}
func SetBundleDimension(index: BundleDimensionIndex, value: Word)
begin
    _BundleDimensions[[index]] = value;
end;
```
<!-- GENERATED-ASL-END: unit -->

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
