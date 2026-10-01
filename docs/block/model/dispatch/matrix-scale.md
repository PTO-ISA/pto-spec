<!-- GENERATED FROM: asl/block/model/dispatch/matrix-scale.asl -->
# Matrix Scale

**Normative ASL source:** `asl/block/model/dispatch/matrix-scale.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-MATRIX-SCALE}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-dispatch-matrix-scale-purpose role=purpose-scope -->
## Purpose and scope

This unit holds one alias check for the CUBE matrix bundles that use `CScale`. `CScale` is an optional extra source of an accumulating matrix product: a `U8` Tile with one value per result row. It is enabled by the `CScaleEn` field of `B.FPATR`.

The function `BundleMatrixCScaleDestinationIndicesDistinct` returns true when the `CScale` source does not share its index with the hand of any destination in the bundle. A hand is the two-bit `DstTile` value that a `B.IOT` destination names.

<!-- PTO-READER-BLOCK: block-model-dispatch-matrix-scale-concepts role=concepts-state -->
## Concepts and visible state

The function takes an ordinal: the position of the `CScale` source in the ordered list of Local source slots. Source slots are counted binding by binding, `source0` before `source1`.

It reads two kinds of bundle state and writes none.

- `BundleMatrixArchitecturalSourceAt(ordinal)` returns the `CScale` source index. For a subview source it returns the parent Tile, so the check is made on the architectural Tile.
- For each valid `B.IOT` binding with a destination, it reads `_BundleTileBindings[[binding]].destination_hand`.

The function returns false as soon as one destination hand equals the `CScale` index, and true otherwise. It raises no fault itself.

<!-- PTO-READER-BLOCK: block-model-dispatch-matrix-scale-rules role=rules-interactions -->
## Rules and interactions

The only caller is `ExecuteBundleTMATMULOperation`, and only when `c_scale_en` is set. By then the caller has already required that the function is 2 or 6 (`TMATMUL_ACC` or `TMATMUL_MX_ACC`) and that the result type is `FP32`.

The caller passes the last mathematical source ordinal: the count of Local mathematical sources, including `CScale`, minus one. `CScale` is therefore the final mathematical source, after the accumulator, the left and right matrices, and any MX scales.

The caller runs this check right after the matching check for the accumulator, `BundleMatrixAccumulatorDestinationIndicesDistinct`. If the check fails, it raises `Fault_TileLegality`. Both checks run after `PrepareSelectedBundleStage2` and before the destination group is allocated and before any source is snapshotted.

Design point: the check compares against every destination hand, not only the primary result `D`. A bundle can also publish `RowMaxOut` and `GroupMaxOut` destinations, and the loop visits each valid binding that has a destination. The accumulator check, by contrast, compares only with the primary destination hand.

Design point: the check is a preflight rejection. It runs with the other alias, layout, and shape checks, before allocation. A bundle that fails it has allocated no destination and changed no source.

<!-- PTO-READER-BLOCK: block-model-dispatch-matrix-scale-boundaries role=boundaries -->
## Architectural boundaries

This unit does not check that `CScale` is enabled, that the function allows it, or that the source is a legal `U8` `CUBE_M32` Tile of shape M by 1. `ExecuteBundleTMATMULOperation` and the matrix source legality owners do that. It does not apply the scale; the matrix execution owner does.

The comparison uses the value that `BundleMatrixArchitecturalSourceAt` returns at the time of the call, which is after `PrepareSelectedBundleStage2` has resolved relative source selectors.

<!-- PTO-READER-BLOCK: block-model-dispatch-matrix-scale-example role=example-usage -->
## Non-normative reading example

This example illustrates the current ASL owner and does not replace the normative operation.

```text
TMATMUL_ACC <M=16, N=16, K=16, FP16, CScale>, T#1, T#2, T#3, T#4, ->T<1KB>
```

The accumulator `C` is `T#1`, the left matrix is `T#2`, the right matrix is `T#3`, and the `CScale` source is `T#4`. There are four mathematical sources, so the caller passes ordinal 3. The bundle has one destination, `D`. The function compares the architectural index of the fourth source slot with that destination's hand. If they differ, preflight continues. If they are equal, the bundle raises `Fault_TileLegality` and publishes nothing.

<!-- PTO-READER-BLOCK: block-model-dispatch-matrix-scale-related role=related-owners-navigation -->
## Related owners

- [CUBE TMATMUL](cube-tmatmul.md) calls this check and owns the accumulator alias check.
- [Matrix postprocess legality](../../../tile/model/legality/matrix-postprocess.md) defines `BundleMatrixArchitecturalSourceAt`.
- [Tile bindings](../operands/tile-bindings.md) records the destination hand of each binding.
- [B.FPATR](../../attributes/B.FPATR.md) carries the `CScaleEn` field.
<!-- SUPPLEMENTARY-END -->

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
