<!-- GENERATED FROM: asl/block/model/schema/header.asl -->
# Header

**Normative ASL source:** `asl/block/model/schema/header.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-SCHEMA-HEADER}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-schema-header-purpose role=purpose-scope -->
## Purpose and scope

This unit names the bundle-header schema concept. It contains no executable ASL. Its only content is a dependency on the Tile-bindings operand unit, so the header schema is defined by the units it depends on.

Read this page as a guide to what a bundle header is.

<!-- PTO-READER-BLOCK: block-model-schema-header-concepts role=concepts-state -->
## Concepts and visible state

The header is the part of a bundle between `BSTART` and the first body instruction. While `_BundleActive` is true and `_BundleBodyActive` is false, header commands write the per-bundle configuration:

- dimensions through `B.DIM` and `C.B.DIMI`;
- attributes through `B.CATR`, `B.DATR`, `B.FPATR`, and `B.HINT`;
- bindings through `B.IOR`, `B.IOT`, and `B.IOS`, with range modifiers such as `B.SUBVIEW` and `B.ASSEMBLE`.

<!-- PTO-READER-BLOCK: block-model-schema-header-rules role=rules-interactions -->
## Rules and interactions

The first scalar instruction in the bundle enters the body. After that, a header command raises `Fault_BundleControl`, except that a zero-participation `B.IOT` or `B.IOS` is a no-op.

Design point: configuration is collected first and applied at commit. Header commands only record values and bindings, and the selected operation reads the complete set once, at commit. Operation schema checks therefore see the whole header, and they run before any destination Tile is allocated.

Design point: most header records are write-once per bundle, and a second write faults. A header cannot quietly change a value that an earlier command set.

<!-- PTO-READER-BLOCK: block-model-schema-header-boundaries role=boundaries -->
## Architectural boundaries

This unit defines no legality. Placement is checked in command dispatch, operand structure in the Tile-bindings and schema units, and operation legality at commit.

The whole header is cleared at commit, so no header value leaks into the next bundle.

<!-- PTO-READER-BLOCK: block-model-schema-header-example role=example-usage -->
## Non-normative reading example

This example illustrates the current ASL owner and does not replace the normative operation.

A header of `BSTART.VEC TADD, FP32`, `B.DIM a0, 0, ->LB0`, and one `B.IOT` with two sources, a destination, and `last` set is complete. The following `BSTOP` commits it. Placing `B.DIM` after a scalar body instruction instead would raise `Fault_BundleControl`.

<!-- PTO-READER-BLOCK: block-model-schema-header-related role=related-owners-navigation -->
## Related owners

- [Tile bindings](../operands/tile-bindings.md) is the dependency of this unit.
- [Command dispatch](../dispatch/commands.md) enforces header placement.
- [Dimensions](dimensions.md) and [attributes](attributes.md) define header writers.
- [Enter and stop](../lifecycle/enter-stop.md) defines body entry.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/schema/header.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-SCHEMA-HEADER","surface":"block","classification":["model","schema","header"],"depends_on":["PTO-BLOCK-MODEL-OPERANDS-TILE-BINDINGS"]}
// This unit owns the named block-model concept; executable state is defined by its dependencies.
```
<!-- GENERATED-ASL-END: unit -->
