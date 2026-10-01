<!-- GENERATED FROM: asl/block/model/schema/dimensions.asl -->
# Dimensions

**Normative ASL source:** `asl/block/model/schema/dimensions.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-SCHEMA-DIMENSIONS}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-schema-dimensions-purpose role=purpose-scope -->
## Purpose and scope

This unit defines `SetBundleDimension`, the writer for the three bundle-local dimension registers `LB0`, `LB1`, and `LB2`. `B.DIM` and the compressed `C.B.DIMI` both use it.

Its contract, `PTO-BUNDLE-DIMENSION-DEFAULT-001`, also defines the value an omitted dimension has.

<!-- PTO-READER-BLOCK: block-model-schema-dimensions-concepts role=concepts-state -->
## Concepts and visible state

Each dimension has a value in `_BundleDimensions` and a presence bit in `_BundleDimensionPresent`. At the start of each bundle, every value is 1 and every presence bit is false.

`B.DIM` writes the low 16 bits of `GPR[RegSrc] + uimm17`, zero-extended. `C.B.DIMI` writes its zero-extended 8-bit immediate.

<!-- PTO-READER-BLOCK: block-model-schema-dimensions-rules role=rules-interactions -->
## Rules and interactions

A write to a dimension whose presence bit is already set raises `Fault_BundleControl` and keeps the first value. Otherwise the presence bit is set and the value is stored.

The command dispatcher also raises `Fault_BundleControl` for a dimension write outside an active bundle header.

Design point: an omitted dimension has effective value 1, and an explicit write, including 0, replaces it. A bundle can leave unused dimensions unwritten, while a program that writes 0 gets 0, not the default.

Design point: the contract states that presence is for write-once and recovery bookkeeping and that operations consume the effective value. The current Tile schemas also read presence in specific cases: an omitted `LB2` selects the valid column count as the physical column count, and `TCI` and `TEXPDIF` reject an omitted `LB0`. The operation schema units give the exact rule.

Design point: each dimension is write-once per bundle. `B.DIM` and `C.B.DIMI` share one presence bit per register, so a second write by either form is rejected rather than silently overriding the first.

<!-- PTO-READER-BLOCK: block-model-schema-dimensions-boundaries role=boundaries -->
## Architectural boundaries

This unit gives the dimensions no meaning. The completed operation schema decides whether `LB0` is a row count, a column count, or an M, N, or K extent.

Dimension values are cleared at every commit and do not carry over into the next bundle.

<!-- PTO-READER-BLOCK: block-model-schema-dimensions-example role=example-usage -->
## Non-normative reading example

This example illustrates the current ASL owner and does not replace the normative operation.

With `a0 = 0x10010`, `B.DIM a0, 16, ->LB0` computes `0x10020` and keeps the low 16 bits, so `LB0` becomes `0x0020`, which is 32. `LB1` and `LB2` stay at 1. A later `C.B.DIMI` to `LB0` in the same header raises `Fault_BundleControl`.

<!-- PTO-READER-BLOCK: block-model-schema-dimensions-related role=related-owners-navigation -->
## Related owners

- [B.DIM](../../attributes/B.DIM.md) and [C.B.DIMI](../../attributes/C.B.DIMI.md) are the instruction pages.
- [Descriptor state](../state/descriptor-state.md) sets the default of 1.
- [Command dispatch](../dispatch/commands.md) computes the written value and checks placement.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/schema/dimensions.asl -->
```asl
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
```
<!-- GENERATED-ASL-END: unit -->
