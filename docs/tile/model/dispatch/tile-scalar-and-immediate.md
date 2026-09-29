<!-- GENERATED FROM: asl/tile/model/dispatch/tile-scalar-and-immediate.asl -->
# Tile Scalar And Immediate

**Normative ASL source:** `asl/tile/model/dispatch/tile-scalar-and-immediate.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-DISPATCH-TILE-SCALAR-AND-IMMEDIATE}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-dispatch-tile-scalar-and-immediate-purpose role=purpose-scope -->
## Purpose and scope

This unit names the tile-scalar and immediate class of Tile operations. It contains no executable ASL. Its content is the `PTO-UNIT` metadata line, whose `depends_on` list names instruction units and Tile model units, and a one-line comment. The operations themselves are defined by their instruction units.

Every operation in the class combines a Tile with one scalar value, or fills a Tile from a scalar.

<!-- PTO-READER-BLOCK: tile-model-dispatch-tile-scalar-and-immediate-concepts role=concepts-state -->
## Concepts and visible state

The unit declares no state. The tile-operations catalog places 15 operations in this class. The table groups them by semantic handler, which is the ASL function the generated dispatcher calls.

| Operations | Semantic handler |
| --- | --- |
| `TADDS`, `TSUBS`, `TMULS`, `TDIVS`, `TREMS`, `TANDS`, `TORS`, `TXORS`, `TSHLS`, `TSHRS`, `TMAXS`, `TMINS` | `ExecuteTileScalar` |
| `TCMPS` | `ExecuteTileCompareScalar` |
| `TSELS` | `ExecuteTileSelectScalar` |
| `TEXPANDS` | `ExecuteTileFillScalar` |

All 15 operations use the TEPL family with mode 1, so the codes run from `0x020` (`TADDS`) to `0x03B` (`TEXPANDS`). For `TADDS` through `TCMPS` and for `TSELS`, the function number equals the function of the tile-tile form with the same name stem in mode 0. `TEXPANDS` uses function 27, which in mode 0 belongs to `TCVT`, so it has no tile-tile counterpart. The catalog assigns the SFU engine to `TDIVS` and `TREMS` and the VEC engine to the rest.

<!-- PTO-READER-BLOCK: tile-model-dispatch-tile-scalar-and-immediate-rules role=rules-interactions -->
## Rules and interactions

Dispatch does not look at the class. Tile execution decodes the bundle descriptor with `DecodeTileOperation(family, code)`, where the family is TEPL, TLSU, or CUBE and the code is 12 bits. A code with no catalog row returns `PTO_TILE_OPERATION_COUNT`. `BundleOperationDescriptorLegal` makes this check when `BSTART` is decoded, so that `BSTART` faults with `Fault_IllegalInstruction` and the bundle is never installed; tile execution repeats the decode and raises the same fault if it is reached with such a code.

Design point: the class is an ownership and navigation grouping, not a decode input. Moving an operation to another class would not change the code that selects it or the handler that runs it.

Design point: every handler in this class has the producer-effect class `RollbackSafe`. Any operation of this class may therefore be a writer of a `B.ASSEMBLE` generation, because a failed attempt can be undone.

<!-- PTO-READER-BLOCK: tile-model-dispatch-tile-scalar-and-immediate-boundaries role=boundaries -->
## Architectural boundaries

This unit does not decode, check legality, or execute anything. Operand schemas, legality handlers, and execution belong to the instruction units and to these model units:

- [Elementwise execution](../execution/elementwise.md)
- [Comparison](../execution/comparison.md)
- [Generation](../execution/generation.md)
- [Matrix shape legality](../legality/matrix-shape.md)

The unit's `depends_on` list names all 15 instruction units that the catalog places in this class.

<!-- PTO-READER-BLOCK: tile-model-dispatch-tile-scalar-and-immediate-example role=example-usage -->
## Non-normative reading example

This example illustrates the current ASL owner and does not replace the normative operation.

`TMULS` has mode 1 and function 2, so its selector is 1 x 32 + 2 = 34, which is `0x022`. Its tile-tile counterpart `TMUL` has the same function 2 in mode 0, selector `0x002`. The two codes differ only in the mode bits, and they decode to different handlers: `ExecuteTileScalar` and `ExecuteTileBinary`.

<!-- PTO-READER-BLOCK: tile-model-dispatch-tile-scalar-and-immediate-related role=related-owners-navigation -->
## Related owners

- [Top-level dispatch](top-level.md) lists all seven classes and the catalog envelope.
- [Tile execution](../../../block/model/dispatch/tile-execution.md) decodes the operation and runs its handler.
- [Portable carriers](../../../block/model/operands/portable-carriers.md) owns the producer-effect classes.
- [TADDS](../../tile-scalar-and-immediate/arithmetic/TADDS.md) is one instruction page of this class.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/dispatch/tile-scalar-and-immediate.asl -->
```asl
// PTO-UNIT: {"classification":["model","dispatch","tile-scalar-and-immediate"],"depends_on":["PTO-TILE-MODEL-LEGALITY-MATRIX-SHAPE","PTO-TILE-MODEL-EXECUTION-ELEMENTWISE","PTO-TILE-MODEL-EXECUTION-COMPARISON","PTO-TILE-MODEL-EXECUTION-GENERATION","PTO-TILE-TADDS","PTO-TILE-TANDS","PTO-TILE-TCMPS","PTO-TILE-TDIVS","PTO-TILE-TEXPANDS","PTO-TILE-TMAXS","PTO-TILE-TMINS","PTO-TILE-TMULS","PTO-TILE-TORS","PTO-TILE-TREMS","PTO-TILE-TSELS","PTO-TILE-TSHLS","PTO-TILE-TSHRS","PTO-TILE-TSUBS","PTO-TILE-TXORS"],"id":"PTO-TILE-MODEL-DISPATCH-TILE-SCALAR-AND-IMMEDIATE","surface":"tile"}
// Dispatch ownership for the tile-scalar-and-immediate PTO Tile instruction class.
```
<!-- GENERATED-ASL-END: unit -->
