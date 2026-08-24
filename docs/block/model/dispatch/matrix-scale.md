<!-- GENERATED FROM: asl/block/model/dispatch/matrix-scale.asl -->
# Matrix Scale

**Normative ASL source:** `asl/block/model/dispatch/matrix-scale.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-MATRIX-SCALE}

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/matrix-scale.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-MATRIX-SCALE","surface":"block","classification":["model","dispatch","matrix-scale"],"depends_on":["PTO-TILE-MODEL-LEGALITY-MATRIX-POSTPROCESS"]}

readonly func BundleMatrixCScaleDestinationIndicesDistinct(
    c_scale_ordinal: integer {0..8}) => boolean
begin
    let c_scale = BundleMatrixArchitecturalSourceAt(c_scale_ordinal);
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if _BundleTileBindings[[binding]].valid &&
           _BundleTileBindings[[binding]].destination_valid &&
           c_scale == UInt(_BundleTileBindings[[binding]].destination_hand) then
            return FALSE;
        end;
    end;
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: unit -->

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
