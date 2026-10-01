<!-- GENERATED FROM: asl/tile/model/dispatch/irregular-and-complex.asl -->
# Irregular And Complex

**Normative ASL source:** `asl/tile/model/dispatch/irregular-and-complex.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-DISPATCH-IRREGULAR-AND-COMPLEX}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-dispatch-irregular-and-complex-purpose role=purpose-scope -->
## Purpose and scope

This unit names the irregular and complex class of Tile operations. It contains no executable ASL. Its content is the `PTO-UNIT` metadata line, whose `depends_on` list names instruction units and Tile model units, and a one-line comment. The operations themselves are defined by their instruction units.

The class holds generator operations that write an integer sequence or a triangular matrix into a new Tile, and indexed gather and scatter between Tiles.

<!-- PTO-READER-BLOCK: tile-model-dispatch-irregular-and-complex-concepts role=concepts-state -->
## Concepts and visible state

The unit declares no state. The tile-operations catalog places 4 operations in this class. The table groups them by semantic handler, which is the ASL function the generated dispatcher calls.

| Operations | Semantic handler |
| --- | --- |
| `TCI` | `TCI` |
| `TTRI` | `TTRI` |
| `TGATHER` | `TGATHER` |
| `TSCATTER` | `TSCATTER` |

All four operations use the TEPL family with mode 3 and the SFU engine: `TCI` `0x066`, `TTRI` `0x067`, `TGATHER` `0x06F`, and `TSCATTER` `0x070`. The codes between them, `0x068` and `0x06A` through `0x06D`, are rejected review-only codes, and `0x069` and `0x06E` are reserved.

<!-- PTO-READER-BLOCK: tile-model-dispatch-irregular-and-complex-rules role=rules-interactions -->
## Rules and interactions

Dispatch does not look at the class. Tile execution decodes the bundle descriptor with `DecodeTileOperation(family, code)`, where the family is TEPL, TLSU, or CUBE and the code is 12 bits. A code with no catalog row returns `PTO_TILE_OPERATION_COUNT`. `BundleOperationDescriptorLegal` makes this check when `BSTART` is decoded, so that `BSTART` faults with `Fault_IllegalInstruction` and the bundle is never installed; tile execution repeats the decode and raises the same fault if it is reached with such a code.

Design point: the class is an ownership and navigation grouping, not a decode input. Moving an operation to another class would not change the code that selects it or the handler that runs it.

Design point: `TCI`, `TTRI`, and `TGATHER` are `RollbackSafe`, but `TSCATTER` is `NonRollbackAuxiliary`. A `TSCATTER` bundle with a `B.ASSEMBLE` modifier therefore faults with `Fault_TileLegality` before any effect.

<!-- PTO-READER-BLOCK: tile-model-dispatch-irregular-and-complex-boundaries role=boundaries -->
## Architectural boundaries

This unit does not decode, check legality, or execute anything. Operand schemas, legality handlers, and execution belong to the instruction units and to these model units:

- [Generation](../execution/generation.md)
- [Rearrangement](../execution/rearrangement.md)
- [Indexed rearrangement](../execution/indexed-rearrangement.md)
- [Numeric formats](../numeric/formats.md)
- [Matrix shape legality](../legality/matrix-shape.md)

The unit's `depends_on` list names all four instruction units that the catalog places in this class. When the bundle layout is `CUBE_M16` or `CUBE_M32`, tile execution runs `TCI` through a dedicated `TCICube` path instead of the generic handler.

<!-- PTO-READER-BLOCK: tile-model-dispatch-irregular-and-complex-example role=example-usage -->
## Non-normative reading example

This example illustrates the current ASL owner and does not replace the normative operation.

`TSCATTER` has mode 3 and function 16, so its selector is 3 x 32 + 16 = 112, which is `0x070`. A TEPL bundle with code `0x06C` finds no catalog row and faults with `Fault_IllegalInstruction`.

<!-- PTO-READER-BLOCK: tile-model-dispatch-irregular-and-complex-related role=related-owners-navigation -->
## Related owners

- [Top-level dispatch](top-level.md) lists all seven classes and the catalog envelope.
- [Tile execution](../../../block/model/dispatch/tile-execution.md) decodes the operation and runs its handler.
- [Portable carriers](../../../block/model/operands/portable-carriers.md) owns the producer-effect classes.
- [TCI](../../irregular-and-complex/initialization/TCI.md) is one instruction page of this class.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/dispatch/irregular-and-complex.asl -->
```asl
// PTO-UNIT: {"classification":["model","dispatch","irregular-and-complex"],"depends_on":["PTO-TILE-MODEL-LEGALITY-MATRIX-SHAPE","PTO-TILE-MODEL-EXECUTION-GENERATION","PTO-TILE-MODEL-NUMERIC-FORMATS","PTO-TILE-MODEL-EXECUTION-REARRANGEMENT","PTO-TILE-MODEL-EXECUTION-INDEXED-REARRANGEMENT","PTO-TILE-TCI","PTO-TILE-TGATHER","PTO-TILE-TSCATTER","PTO-TILE-TTRI"],"id":"PTO-TILE-MODEL-DISPATCH-IRREGULAR-AND-COMPLEX","surface":"tile"}
// Dispatch ownership for the irregular-and-complex PTO Tile instruction class.
```
<!-- GENERATED-ASL-END: unit -->
