<!-- GENERATED FROM: asl/block/model/state/binding-state.asl -->
# Binding State

**Normative ASL source:** `asl/block/model/state/binding-state.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-STATE-BINDING-STATE}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-state-binding-state-purpose role=purpose-scope -->
## Purpose and scope

This unit names the bundle binding-state concept. It contains no executable ASL of its own. Its only content is a dependency on the descriptor-state unit, so the actual binding state is defined by the units it depends on.

Read this page as a map of where binding state lives.

<!-- PTO-READER-BLOCK: block-model-state-binding-state-concepts role=concepts-state -->
## Concepts and visible state

A binding connects an operand role of the bundle's operation to an architectural register or Tile. The bundle holds three binding arrays:

- `_BundleScalarBindings`: 32 entries, filled by `B.IOR`. Each entry names a destination GPR and up to three source GPRs.
- `_BundleTileBindings`: 16 entries, filled by `B.IOT`. Each entry names up to two source Tiles, an optional destination hand with a size code, a PE mask, and a `last` flag.
- `_BundleSharedBindings`: 4 entries, filled by `B.IOS`. Each entry names a Shared Tile, a size code, and a PE mask.

The record types are in [state types](types.md), and the variables are members of [control state](control-state.md).

<!-- PTO-READER-BLOCK: block-model-state-binding-state-rules role=rules-interactions -->
## Rules and interactions

`B.IOT` appends each entry to the first free Tile binding slot. After an entry with `last` set, the sequence is closed and a further `B.IOT` raises `Fault_BundleControl`. A 17th entry raises `Fault_TileLegality`.

Design point: Tile bindings are kept in command order. The operation schema reads the ordered sequence to assign sources and destinations to operand roles, so the order in which the program writes `B.IOT` commands is the order in which operands are consumed. The `last` flag marks where the sequence ends.

Design point: bindings only record choices. Destination allocation is deferred to commit, after the operation schema has checked the complete binding set. A binding that turns out to be illegal therefore has not yet allocated a Tile.

<!-- PTO-READER-BLOCK: block-model-state-binding-state-boundaries role=boundaries -->
## Architectural boundaries

All three binding arrays are cleared by `ClearBundleHeaderState` at the start of each bundle and after commit. They never carry over into another bundle.

This page does not define which operand roles an operation needs. The dispatch schema units do.

<!-- PTO-READER-BLOCK: block-model-state-binding-state-example role=example-usage -->
## Non-normative reading example

This example illustrates the current ASL owner and does not replace the normative operation.

A binary Tile operation uses one `B.IOT` entry with two sources, a destination hand `T`, and `last` set. The entry lands in Tile binding slot 0 and closes the sequence. At commit, the schema reads slot 0 for both sources and the destination.

<!-- PTO-READER-BLOCK: block-model-state-binding-state-related role=related-owners-navigation -->
## Related owners

- [Tile bindings](../operands/tile-bindings.md), [scalar bindings](../operands/scalar-bindings.md), and [Shared bindings](../operands/shared-bindings.md) define the writers.
- [Descriptor state](descriptor-state.md) defines the clear.
- [B.IOT](../../operands/B.IOT.md), [B.IOR](../../operands/B.IOR.md), and [B.IOS](../../operands/B.IOS.md) are the binding commands.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/state/binding-state.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-STATE-BINDING-STATE","surface":"block","classification":["model","state","binding-state"],"depends_on":["PTO-BLOCK-MODEL-STATE-DESCRIPTOR-STATE"]}
// This unit owns the named block-model concept; executable state is defined by its dependencies.
```
<!-- GENERATED-ASL-END: unit -->
