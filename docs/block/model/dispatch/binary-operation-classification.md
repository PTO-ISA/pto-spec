<!-- GENERATED FROM: asl/block/model/dispatch/binary-operation-classification.asl -->
# Binary Operation Classification

**Normative ASL source:** `asl/block/model/dispatch/binary-operation-classification.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-BINARY-OP-CLASSIFICATION}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-dispatch-binary-operation-classification-purpose role=purpose-scope -->
## Purpose and scope

This unit answers one question for bundle dispatch: does a decoded Tile operation use the closed binary schema? A schema, in this model, is the exact set of bundle commands and operand bindings that an operation accepts. A closed schema lists every legal shape, so any binding outside the list is rejected.

The unit contains a single pure predicate, `TileOperationUsesClosedBinarySchema`. It takes a decoded operation index and returns true for exactly eight operations: `TADD`, `TSUB`, `TMUL`, `TDIV`, `TREM`, `TMAX`, `TMIN`, and `TEXPDIF`.

<!-- PTO-READER-BLOCK: block-model-dispatch-binary-operation-classification-concepts role=concepts-state -->
## Concepts and visible state

The predicate converts the index with `TileOperationOfIndex` and compares the result against the eight operation names. It is declared `pure`, so it reads no architectural state and writes none.

All eight operations read two Local source Tiles and write one Local destination Tile. That shared operand shape is what the classification groups together. The arithmetic data types, the layouts, and the element results are owned elsewhere.

<!-- PTO-READER-BLOCK: block-model-dispatch-binary-operation-classification-rules role=rules-interactions -->
## Rules and interactions

The predicate has two callers in the dispatch model.

- `SelectedBundleClosedBinarySchemaLegal` in the Tile schema unit returns true at once when the predicate is false. When it is true, the caller requires one terminating `B.IOT` binding with two sources and a destination (or two bindings when a predicate-Tile execution mask is in force), no Shared bindings, and dimensions in 1..65535. For the seven operations other than `TEXPDIF`, it also requires `TileVecArithmeticDataTypeSupported` for the operation type and an elementwise layout.
- `ResolveBundleTileDestinationsForOperation` uses it, with the other closed-schema predicates, to choose destination resolution. For the seven operations other than `TEXPDIF`, which has an earlier branch of its own, the destination shape then comes from `LB0`, `LB1`, and `LB2` rather than from the generic path.

Both callers run in the Tile execution owner before any source snapshot or payload write. A bundle whose Tile operand count is wrong is first rejected by `BundleOperationBindingsComplete` with `Fault_BundleControl`; the closed binary schema check then runs before destination resolution, which is the step that allocates the destination, so an operation in this class that fails the schema raises `Fault_TileLegality` before any destination is allocated.

Design point: `TEXPDIF` is in this class even though it is a transcendental operation on the `SFU` engine and has its own type rules. The class describes operand structure, not arithmetic. `TEXPDIF` takes two sources and one destination, so it shares the binding checks, and the schema check then adds its own rules: `LB0` must be present, the source and destination types are checked with `SelectedBundleExponentialDifferenceTypes`, and the layout and sources are checked with `TileElementwiseLayoutSupported` and `TileExpdifSourcesLegal`.

<!-- PTO-READER-BLOCK: block-model-dispatch-binary-operation-classification-boundaries role=boundaries -->
## Architectural boundaries

This unit does not check types, layouts, dimensions, or bindings. It does not raise a fault. It classifies only.

Row and column expansion forms such as `TROWEXPANDEXPDIF` are not in this class. They use the expansion schema. Tile-scalar forms such as `TADDS` are also outside it; they use the Tile-scalar schema.

<!-- PTO-READER-BLOCK: block-model-dispatch-binary-operation-classification-example role=example-usage -->
## Non-normative reading example

This example illustrates the current ASL owner and does not replace the normative operation.

Consider this Tile macro.

```text
TADD <Row=8, Col=64, FP32>, T#1, T#2, ->T<2KB>
```

Dispatch decodes the operation as `TADD`, and the predicate returns true. The Tile schema check then requires a single `B.IOT` binding with the left source `T#1`, the right source `T#2`, and one destination, marked last. `LB0` supplies `ValidCol=64`. The destination is resolved with that explicit shape. A `TABS` bundle, by contrast, gets false here and is checked by the unary schema instead.

<!-- PTO-READER-BLOCK: block-model-dispatch-binary-operation-classification-related role=related-owners-navigation -->
## Related owners

- [Tile schema](tile-schema.md) owns `SelectedBundleClosedBinarySchemaLegal`, the binding checks for this class.
- [Destination operation](destination-operation.md) routes destination resolution by operation class.
- [Exponential-difference schema](expdif-schema.md) resolves the `TEXPDIF` source and destination types.
- [TADD](../../../tile/elementwise-tile-tile/arithmetic/TADD.md) is a representative member instruction.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/binary-operation-classification.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-BINARY-OP-CLASSIFICATION","surface":"block","classification":["model","dispatch","binary-operation-classification"],"depends_on":[]}
pure func TileOperationUsesClosedBinarySchema(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    let decoded = TileOperationOfIndex(operation);
    return decoded == TileOperation_TADD ||
           decoded == TileOperation_TSUB ||
           decoded == TileOperation_TMUL ||
           decoded == TileOperation_TDIV ||
           decoded == TileOperation_TREM ||
           decoded == TileOperation_TMAX ||
           decoded == TileOperation_TMIN ||
           decoded == TileOperation_TEXPDIF;
end;
```
<!-- GENERATED-ASL-END: unit -->
