<!-- GENERATED FROM: asl/block/model/dispatch/cube-accumulator-routing.asl -->
# CUBE Accumulator Routing

**Normative ASL source:** `asl/block/model/dispatch/cube-accumulator-routing.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-CUBE-ACCUMULATOR-ROUTING}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-dispatch-cube-accumulator-routing-purpose role=purpose-scope -->
## Purpose and scope

This unit reads and checks `CCTRL`, the two-bit accumulator control of the CUBE matrix bundles (the `TMATMUL` and `TGEMV` families). `CCTRL` is not a field of its own. It travels in the `PadValueOrByteId` field of `B.DATR`, the data-attribute command, which matrix and CUBE operation schemas read as `CCTRL`.

The unit has five small functions. One reads the field, two split it into its bits, and two decide whether the selected bits are legal for the bundle.

<!-- PTO-READER-BLOCK: block-model-dispatch-cube-accumulator-routing-concepts role=concepts-state -->
## Concepts and visible state

- `BundleTMATMULCCTRL` returns `_BundleDataAttributes.pad_value` when `B.DATR` is present, and `00` when it is absent.
- `BundleTMATMULRawPartialOutput` returns bit 0. When set, the result `D` is the raw accumulator-type product rather than the final post-processed output.
- `BundleTMATMULAccumulatorPrefetchHint` returns bit 1. When set, it asks the implementation to prefetch or reuse the explicit accumulator source `C`.

An accumulating function is one of CUBE Functions 2, 6, 18, and 22 (`TMATMUL_ACC`, `TMATMUL_MX_ACC`, `TGEMV_ACC`, and `TGEMV_MX_ACC`), as defined by `TileMatrixFunctionUsesAccumulator`.

All five functions only read state. None writes state or raises a fault.

<!-- PTO-READER-BLOCK: block-model-dispatch-cube-accumulator-routing-rules role=rules-interactions -->
## Rules and interactions

`BundleTMATMULAccumulatorControlLegal` allows any `CCTRL` for an accumulating function. For every other function it requires bit 1 to be zero, because there is no `C` source to prefetch.

`BundleTMATMULPartialPostProcessLegal` allows anything when bit 0 is clear. When bit 0 is set, the `B.FPATR` fields `pre_quant_mode`, `relu_mode`, and `group_n_code` must be zero, and `row_max_en`, `group_max_en`, and `max_abs_en` must be false. `c_scale_en` is not checked here.

The caller is `ExecuteBundleTMATMULOperation`. It evaluates both legality predicates in one combined check with the type, binding, data-attribute, dimension, and mask checks. A failure raises `Fault_TileLegality`. That check runs before the handler converts M, N, and K for the operation, before it waits for Shared sources, and before any destination is allocated or source is snapshotted.

Design point: omission is not the same as an encoded value. With `B.DATR` absent, the stored `pad_value` still holds its reset default `11`, which selects Null padding for other operations. `BundleTMATMULCCTRL` does not read it in that case and returns `00` instead: final output and no hint. A matrix bundle without `B.DATR` therefore never requests raw partial output by accident.

Design point: a raw partial result must not be post-processed. With bit 0 set, the result is published by `CommitMatrixRawPartial`, which skips `MatrixPostProcessResult` and every auxiliary output. The legality check rejects quantization, ReLU, and the row, group, and max-abs reductions before any effect, so a bundle cannot request post-processing that would silently not happen.

Design point: the cache behavior that the bits request cannot change results. The caller passes them to `TileProfileInternalAccumulatorPrefetchHint` and `TileProfileInternalAccumulatorReplacementHint`, which are implementation-defined and do nothing in the portable model. NDF clause `PTO-CUBE-INTERNAL-ACCUMULATOR-001` requires that cache behavior never change results, faults, allocation, or publication. Bit 0 does change the published type; only the cache use is a hint.

<!-- PTO-READER-BLOCK: block-model-dispatch-cube-accumulator-routing-boundaries role=boundaries -->
## Architectural boundaries

This unit does not decode `B.DATR` or `B.FPATR`, does not perform the product, and does not call the hint hooks. It does not check `CScale`; that is checked by the matrix-scale and TMATMUL owners.

<!-- PTO-READER-BLOCK: block-model-dispatch-cube-accumulator-routing-example role=example-usage -->
## Non-normative reading example

This example illustrates the current ASL owner and does not replace the normative operation.

A `BSTART.TMATMUL.ACC` bundle (Function 2) with FP16 A and B carries a `B.DATR` whose `PadValueOrByteId` field is `11`, and an all-zero `B.FPATR`. Both bits are legal: Function 2 accumulates, and no post-processing is enabled. After preflight, the model may hint a prefetch of `C`. `D` is published as the raw FP32 accumulator result, and a replacement hint may follow.

The same `CCTRL` on a plain `BSTART.TMATMUL` bundle (Function 0) fails, because bit 1 is set for a function with no accumulator. The bundle raises `Fault_TileLegality` and allocates no destination.

<!-- PTO-READER-BLOCK: block-model-dispatch-cube-accumulator-routing-related role=related-owners-navigation -->
## Related owners

- [CUBE TMATMUL](cube-tmatmul.md) calls these predicates and the hint hooks.
- [Internal accumulator](../../../tile/model/execution/internal-accumulator.md) defines the hint hooks and their non-binding contract.
- [Matrix functions](../../../tile/model/legality/matrix-functions.md) defines which functions accumulate.
- [B.DATR](../../attributes/B.DATR.md) and [B.FPATR](../../attributes/B.FPATR.md) carry the fields read here.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/cube-accumulator-routing.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-CUBE-ACCUMULATOR-ROUTING","surface":"block","classification":["model","dispatch","cube-accumulator-routing"],"depends_on":["PTO-BLOCK-B-DATR","PTO-TILE-MODEL-LEGALITY-MATRIX-FUNCTIONS"]}

readonly func BundleTMATMULCCTRL() => bits(2)
begin
    if !_BundleDataAttributesPresent then return Zeros{2}; end;
    return _BundleDataAttributes.pad_value;
end;

pure func BundleTMATMULRawPartialOutput(cctrl: bits(2)) => boolean
begin
    return cctrl[0:0] != Zeros{1};
end;

pure func BundleTMATMULAccumulatorPrefetchHint(cctrl: bits(2)) => boolean
begin
    return cctrl[1:1] != Zeros{1};
end;

readonly func BundleTMATMULAccumulatorControlLegal(
    function: integer {0..31}, cctrl: bits(2)) => boolean
begin
    if TileMatrixFunctionUsesAccumulator(function) then return TRUE; end;
    return !BundleTMATMULAccumulatorPrefetchHint(cctrl);
end;

readonly func BundleTMATMULPartialPostProcessLegal(
    cctrl: bits(2)) => boolean
begin
    if !BundleTMATMULRawPartialOutput(cctrl) then return TRUE; end;
    return UInt(_BundleFixedPointAttributes.pre_quant_mode) == 0 &&
           UInt(_BundleFixedPointAttributes.relu_mode) == 0 &&
           UInt(_BundleFixedPointAttributes.group_n_code) == 0 &&
           !_BundleFixedPointAttributes.row_max_en &&
           !_BundleFixedPointAttributes.group_max_en &&
           !_BundleFixedPointAttributes.max_abs_en;
end;
```
<!-- GENERATED-ASL-END: unit -->
