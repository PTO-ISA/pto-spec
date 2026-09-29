<!-- GENERATED FROM: asl/tile/model/dispatch/layout-and-rearrangement.asl -->
# Layout And Rearrangement

**Normative ASL source:** `asl/tile/model/dispatch/layout-and-rearrangement.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-DISPATCH-LAYOUT-AND-REARRANGEMENT}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-dispatch-layout-and-rearrangement-purpose role=purpose-scope -->
## Purpose and scope

This unit names the layout and rearrangement class of Tile operations. It contains no executable ASL. Its content is the `PTO-UNIT` metadata line, whose `depends_on` list names instruction units and Tile model units, and a one-line comment. The operations themselves are defined by their instruction units.

Every operation in the class moves or reorders Tile elements without numeric computation, or builds a Tile from scalar registers.

<!-- PTO-READER-BLOCK: tile-model-dispatch-layout-and-rearrangement-concepts role=concepts-state -->
## Concepts and visible state

The unit declares no state. The tile-operations catalog places 6 operations in this class. The table groups them by semantic handler, which is the ASL function the generated dispatcher calls.

| Operations | Semantic handler |
| --- | --- |
| `TMOV` | `TMOV` |
| `TPERMUTE`, `TSHUF` | `TPERMUTE`, `TSHUF` |
| `TPACK`, `TUNPACK` | `TPACK`, `TUNPACK` |
| `TGPR2T` | `TGPR2T` |

The class spans two families. `TMOV` is TLSU function 2 with its own `BSTART.TMOV` form and the TLSU engine. The other five use the TEPL family with mode 3 and the SFU engine: `TPERMUTE` `0x075`, `TSHUF` `0x076`, `TPACK` `0x077`, `TUNPACK` `0x078`, and `TGPR2T` `0x07E`. Mode 3 is shared with the irregular-and-complex class.

<!-- PTO-READER-BLOCK: tile-model-dispatch-layout-and-rearrangement-rules role=rules-interactions -->
## Rules and interactions

Dispatch does not look at the class. Tile execution decodes the bundle descriptor with `DecodeTileOperation(family, code)`, where the family is TEPL, TLSU, or CUBE and the code is 12 bits. A code with no catalog row returns `PTO_TILE_OPERATION_COUNT`. `BundleOperationDescriptorLegal` makes this check when `BSTART` is decoded, so that `BSTART` faults with `Fault_IllegalInstruction` and the bundle is never installed; tile execution repeats the decode and raises the same fault if it is reached with such a code.

Design point: the class is an ownership and navigation grouping, not a decode input. Moving an operation to another class would not change the code that selects it or the handler that runs it.

Design point: every handler of this class has the producer-effect class `RollbackSafe`. Any operation of this class may therefore be a writer of a `B.ASSEMBLE` generation, because a failed attempt can be undone.

<!-- PTO-READER-BLOCK: tile-model-dispatch-layout-and-rearrangement-boundaries role=boundaries -->
## Architectural boundaries

This unit does not decode, check legality, or execute anything. Operand schemas, legality handlers, and execution belong to the instruction units and to these model units:

- [Rearrangement](../execution/rearrangement.md)
- [Generation](../execution/generation.md)
- [Matrix shape legality](../legality/matrix-shape.md)

The unit's `depends_on` list names `TMOV`, `TPERMUTE`, `TSHUF`, `TPACK`, and `TUNPACK`. It does not list `TGPR2T`, although the catalog places `TGPR2T` in this class.

<!-- PTO-READER-BLOCK: tile-model-dispatch-layout-and-rearrangement-example role=example-usage -->
## Non-normative reading example

This example illustrates the current ASL owner and does not replace the normative operation.

`TPACK` has mode 3 and function 23, so its selector is 3 x 32 + 23 = 119, which is `0x077`. `TMOV` is not in TEPL at all: a TLSU bundle with code 2 decodes to `TMOV`. The same code 2 in the TEPL family would decode to `TMUL`, because the family is part of the decode key.

<!-- PTO-READER-BLOCK: tile-model-dispatch-layout-and-rearrangement-related role=related-owners-navigation -->
## Related owners

- [Top-level dispatch](top-level.md) lists all seven classes and the catalog envelope.
- [Tile execution](../../../block/model/dispatch/tile-execution.md) decodes the operation and runs its handler.
- [Portable carriers](../../../block/model/operands/portable-carriers.md) owns the producer-effect classes.
- [TMOV](../../layout-and-rearrangement/layout/TMOV.md) is one instruction page of this class.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/dispatch/layout-and-rearrangement.asl -->
```asl
// PTO-UNIT: {"classification":["model","dispatch","layout-and-rearrangement"],"depends_on":["PTO-TILE-MODEL-LEGALITY-MATRIX-SHAPE","PTO-TILE-MODEL-EXECUTION-GENERATION","PTO-TILE-MODEL-EXECUTION-REARRANGEMENT","PTO-TILE-TMOV","PTO-TILE-TPERMUTE","PTO-TILE-TSHUF","PTO-TILE-TPACK","PTO-TILE-TUNPACK"],"id":"PTO-TILE-MODEL-DISPATCH-LAYOUT-AND-REARRANGEMENT","surface":"tile"}
// Dispatch ownership for the layout-and-rearrangement PTO Tile instruction class.
```
<!-- GENERATED-ASL-END: unit -->
