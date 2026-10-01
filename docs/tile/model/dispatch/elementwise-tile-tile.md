<!-- GENERATED FROM: asl/tile/model/dispatch/elementwise-tile-tile.asl -->
# Elementwise Tile Tile

**Normative ASL source:** `asl/tile/model/dispatch/elementwise-tile-tile.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-DISPATCH-ELEMENTWISE-TILE-TILE}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-dispatch-elementwise-tile-tile-purpose role=purpose-scope -->
## Purpose and scope

This unit names the elementwise tile-tile class of Tile operations. It contains no executable ASL. Its content is the `PTO-UNIT` metadata line, whose `depends_on` list names instruction units and Tile model units, and a one-line comment. The operations themselves are defined by their instruction units.

Every operation in the class combines or transforms Tile elements position by position. Its data sources are Tiles, except that `TSEL` may take its mask from GPRs and `TCMP` may write its result to a GPR.

<!-- PTO-READER-BLOCK: tile-model-dispatch-elementwise-tile-tile-concepts role=concepts-state -->
## Concepts and visible state

The unit declares no state. The tile-operations catalog places 26 operations in this class. The table groups them by semantic handler, which is the ASL function the generated dispatcher calls.

| Operations | Semantic handler |
| --- | --- |
| `TADD`, `TSUB`, `TMUL`, `TDIV`, `TREM`, `TAND`, `TOR`, `TXOR`, `TSHL`, `TSHR`, `TMAX`, `TMIN` | `ExecuteTileBinary` |
| `TCMP` | `ExecuteTileCompare` |
| `TABS`, `TNOT`, `TNEG`, `TEXP`, `TLOG`, `TRECIP`, `TSQRT`, `TRSQRT`, `TRELU` | `ExecuteTileUnary` |
| `TSEL` | `ExecuteTileSelect` |
| `TCVT`, `TFMA` | `TCVT`, `TFMA` |
| `TEXPDIF` | `ExecuteTileExpdif` |

All 26 operations use the TEPL family with mode 0. The selector is `mode * 32 + function`, so the codes run from `0x000` (`TADD`) to `0x01D` (`TEXPDIF`). The codes `0x005`, `0x00E`, `0x018`, `0x019`, `0x01E`, and `0x01F` are reserved. The catalog assigns the SFU engine to `TDIV`, `TREM`, `TEXP`, `TLOG`, `TRECIP`, `TSQRT`, `TRSQRT`, and `TEXPDIF`, and the VEC engine to the rest.

<!-- PTO-READER-BLOCK: tile-model-dispatch-elementwise-tile-tile-rules role=rules-interactions -->
## Rules and interactions

Dispatch does not look at the class. Tile execution decodes the bundle descriptor with `DecodeTileOperation(family, code)`, where the family is TEPL, TLSU, or CUBE and the code is 12 bits. A code with no catalog row returns `PTO_TILE_OPERATION_COUNT`. `BundleOperationDescriptorLegal` makes this check when `BSTART` is decoded, so that `BSTART` faults with `Fault_IllegalInstruction` and the bundle is never installed; tile execution repeats the decode and raises the same fault if it is reached with such a code.

Design point: the class is an ownership and navigation grouping, not a decode input. Moving an operation to another class would not change the code that selects it or the handler that runs it.

Design point: every handler in this class has the producer-effect class `RollbackSafe` in the portable-carriers unit. Any operation of this class may therefore be a writer of a `B.ASSEMBLE` generation, because a failed attempt can be undone.

<!-- PTO-READER-BLOCK: tile-model-dispatch-elementwise-tile-tile-boundaries role=boundaries -->
## Architectural boundaries

This unit does not decode, check legality, or execute anything. Operand schemas, legality handlers, and execution belong to the instruction units and to these model units:

- [Elementwise execution](../execution/elementwise.md)
- [Comparison](../execution/comparison.md)
- [EXPDIF execution](../execution/expdif.md)
- [EXPDIF operand legality](../legality/expdif-operands.md)
- [Matrix shape legality](../legality/matrix-shape.md)
- [Numeric formats](../numeric/formats.md)

The unit's `depends_on` list names all 26 instruction units that the catalog places in this class.

<!-- PTO-READER-BLOCK: tile-model-dispatch-elementwise-tile-tile-example role=example-usage -->
## Non-normative reading example

This example illustrates the current ASL owner and does not replace the normative operation.

`TMAX` has mode 0 and function 11, so its selector is 0 x 32 + 11 = 11, which is `0x00B`. A TEPL bundle with code `0x00B` decodes to `TMAX` and runs `ExecuteTileBinary`. A TEPL bundle with code `0x00E` has no catalog row, so it faults with `Fault_IllegalInstruction` before any operand is read.

<!-- PTO-READER-BLOCK: tile-model-dispatch-elementwise-tile-tile-related role=related-owners-navigation -->
## Related owners

- [Top-level dispatch](top-level.md) lists all seven classes and the catalog envelope.
- [Tile execution](../../../block/model/dispatch/tile-execution.md) decodes the operation and runs its handler.
- [Portable carriers](../../../block/model/operands/portable-carriers.md) owns the producer-effect classes.
- [TADD](../../elementwise-tile-tile/arithmetic/TADD.md) is one instruction page of this class.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/dispatch/elementwise-tile-tile.asl -->
```asl
// PTO-UNIT: {"classification":["model","dispatch","elementwise-tile-tile"],"depends_on":["PTO-TILE-MODEL-EXECUTION-COMPARISON","PTO-TILE-MODEL-EXECUTION-ELEMENTWISE","PTO-TILE-MODEL-EXECUTION-EXPDIF","PTO-TILE-MODEL-LEGALITY-EXPDIF-OPERANDS","PTO-TILE-MODEL-LEGALITY-MATRIX-SHAPE","PTO-TILE-MODEL-NUMERIC-FORMATS","PTO-TILE-TABS","PTO-TILE-TADD","PTO-TILE-TAND","PTO-TILE-TCMP","PTO-TILE-TCVT","PTO-TILE-TDIV","PTO-TILE-TEXP","PTO-TILE-TEXPDIF","PTO-TILE-TFMA","PTO-TILE-TLOG","PTO-TILE-TMAX","PTO-TILE-TMIN","PTO-TILE-TMUL","PTO-TILE-TNEG","PTO-TILE-TNOT","PTO-TILE-TOR","PTO-TILE-TRECIP","PTO-TILE-TRELU","PTO-TILE-TREM","PTO-TILE-TRSQRT","PTO-TILE-TSEL","PTO-TILE-TSHL","PTO-TILE-TSHR","PTO-TILE-TSQRT","PTO-TILE-TSUB","PTO-TILE-TXOR"],"id":"PTO-TILE-MODEL-DISPATCH-ELEMENTWISE-TILE-TILE","surface":"tile"}
// Dispatch ownership for the elementwise-tile-tile PTO Tile instruction class.
```
<!-- GENERATED-ASL-END: unit -->
