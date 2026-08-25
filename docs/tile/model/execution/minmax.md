<!-- GENERATED FROM: asl/tile/model/execution/minmax.asl -->
# Minmax

**Normative ASL source:** `asl/tile/model/execution/minmax.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-EXECUTION-MINMAX}

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/execution/minmax.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-EXECUTION-MINMAX","surface":"tile","classification":["model","execution","minmax"],"depends_on":["PTO-ARCH-FEATURES-MINMAX-PROFILE","PTO-TILE-MODEL-STATE-TYPES"]}
pure func TileFloatingMinMaxValue(
    operation: TileBinaryOperation,
    data_type: TileDataType,
    left: Word,
    right: Word) => (Word, boolean)
begin
    assert operation == TileBinary_MIN || operation == TileBinary_MAX;
    let maximum = operation == TileBinary_MAX;
    let (available, result, invalid) =
        HardwareNumericFloatingMinMax(
            maximum,
            data_type,
            left,
            right);
    assert available;
    return (result, invalid);
end;
```
<!-- GENERATED-ASL-END: unit -->
