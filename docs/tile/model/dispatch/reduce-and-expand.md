<!-- GENERATED FROM: asl/tile/model/dispatch/reduce-and-expand.asl -->
# Reduce And Expand

**Normative ASL source:** `asl/tile/model/dispatch/reduce-and-expand.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-DISPATCH-REDUCE-AND-EXPAND}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-dispatch-reduce-and-expand-purpose role=purpose-scope -->
## Purpose and scope

This unit names the reduce and expand class of Tile operations. It contains no executable ASL. Its content is the `PTO-UNIT` metadata line, whose `depends_on` list names instruction units and Tile model units, and a one-line comment. The operations themselves are defined by their instruction units.

Every operation in the class either reduces each row or column of a Tile to one value, or expands a per-row or per-column value across a Tile.

<!-- PTO-READER-BLOCK: tile-model-dispatch-reduce-and-expand-concepts role=concepts-state -->
## Concepts and visible state

The unit declares no state. The tile-operations catalog places 28 operations in this class. The table groups them by semantic handler, which is the ASL function the generated dispatcher calls.

| Operations | Semantic handler |
| --- | --- |
| `TROWSUM`, `TROWMAX`, `TROWMIN`, `TROWPROD`, `TROWARGMAX`, `TROWARGMIN` | `ExecuteTileReduction` |
| `TCOLSUM`, `TCOLMAX`, `TCOLMIN`, `TCOLPROD`, `TCOLARGMAX`, `TCOLARGMIN` | `ExecuteTileReduction` |
| `TROWEXPAND`, `TROWEXPANDADD`, `TROWEXPANDSUB`, `TROWEXPANDMUL`, `TROWEXPANDDIV`, `TROWEXPANDMAX`, `TROWEXPANDMIN`, `TROWEXPANDEXPDIF` | `ExecuteTileExpand` |
| `TCOLEXPAND`, `TCOLEXPANDADD`, `TCOLEXPANDSUB`, `TCOLEXPANDMUL`, `TCOLEXPANDDIV`, `TCOLEXPANDMAX`, `TCOLEXPANDMIN`, `TCOLEXPANDEXPDIF` | `ExecuteTileExpand` |

All 28 operations use the TEPL family with mode 2 and the SFU engine. Row forms use functions 0 through 13 (codes `0x040` to `0x04D`). Each column form uses its row form's function plus 16, so column codes run from `0x050` to `0x05D`. The codes `0x04E`, `0x04F`, `0x05E`, and `0x05F` are reserved.

<!-- PTO-READER-BLOCK: tile-model-dispatch-reduce-and-expand-rules role=rules-interactions -->
## Rules and interactions

Dispatch does not look at the class. Tile execution decodes the bundle descriptor with `DecodeTileOperation(family, code)`, where the family is TEPL, TLSU, or CUBE and the code is 12 bits. A code with no catalog row returns `PTO_TILE_OPERATION_COUNT`. `BundleOperationDescriptorLegal` makes this check when `BSTART` is decoded, so that `BSTART` faults with `Fault_IllegalInstruction` and the bundle is never installed; tile execution repeats the decode and raises the same fault if it is reached with such a code.

Design point: the class is an ownership and navigation grouping, not a decode input. Moving an operation to another class would not change the code that selects it or the handler that runs it.

Design point: both handlers of this class have the producer-effect class `RollbackSafe`. Any operation of this class may therefore be a writer of a `B.ASSEMBLE` generation, because a failed attempt can be undone.

<!-- PTO-READER-BLOCK: tile-model-dispatch-reduce-and-expand-boundaries role=boundaries -->
## Architectural boundaries

This unit does not decode, check legality, or execute anything. Operand schemas, legality handlers, and execution belong to the instruction units and to these model units:

- [Reduction](../execution/reduction.md)
- [Expansion](../execution/expansion.md)
- [Matrix shape legality](../legality/matrix-shape.md)

The unit's `depends_on` list names all 28 instruction units that the catalog places in this class.

<!-- PTO-READER-BLOCK: tile-model-dispatch-reduce-and-expand-example role=example-usage -->
## Non-normative reading example

This example illustrates the current ASL owner and does not replace the normative operation.

`TROWMAX` has function 1, so its code is 2 x 32 + 1 = 65, which is `0x041`. `TCOLMAX` has function 1 + 16 = 17, so its code is 2 x 32 + 17 = 81, which is `0x051`. Both decode to `ExecuteTileReduction`. The catalog arguments, not the class, select the axis: the dispatcher passes `TileAxis_Row` for `TROWMAX` and `TileAxis_Column` for `TCOLMAX`.

<!-- PTO-READER-BLOCK: tile-model-dispatch-reduce-and-expand-related role=related-owners-navigation -->
## Related owners

- [Top-level dispatch](top-level.md) lists all seven classes and the catalog envelope.
- [Tile execution](../../../block/model/dispatch/tile-execution.md) decodes the operation and runs its handler.
- [Portable carriers](../../../block/model/operands/portable-carriers.md) owns the producer-effect classes.
- [TROWSUM](../../reduce-and-expand/row-reduction/TROWSUM.md) is one instruction page of this class.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/dispatch/reduce-and-expand.asl -->
```asl
// PTO-UNIT: {"classification":["model","dispatch","reduce-and-expand"],"depends_on":["PTO-TILE-MODEL-LEGALITY-MATRIX-SHAPE","PTO-TILE-MODEL-EXECUTION-REDUCTION","PTO-TILE-MODEL-EXECUTION-EXPANSION","PTO-TILE-TCOLARGMAX","PTO-TILE-TCOLARGMIN","PTO-TILE-TCOLEXPAND","PTO-TILE-TCOLEXPANDADD","PTO-TILE-TCOLEXPANDDIV","PTO-TILE-TCOLEXPANDEXPDIF","PTO-TILE-TCOLEXPANDMAX","PTO-TILE-TCOLEXPANDMIN","PTO-TILE-TCOLEXPANDMUL","PTO-TILE-TCOLEXPANDSUB","PTO-TILE-TCOLMAX","PTO-TILE-TCOLMIN","PTO-TILE-TCOLPROD","PTO-TILE-TCOLSUM","PTO-TILE-TROWARGMAX","PTO-TILE-TROWARGMIN","PTO-TILE-TROWEXPAND","PTO-TILE-TROWEXPANDADD","PTO-TILE-TROWEXPANDDIV","PTO-TILE-TROWEXPANDEXPDIF","PTO-TILE-TROWEXPANDMAX","PTO-TILE-TROWEXPANDMIN","PTO-TILE-TROWEXPANDMUL","PTO-TILE-TROWEXPANDSUB","PTO-TILE-TROWMAX","PTO-TILE-TROWMIN","PTO-TILE-TROWPROD","PTO-TILE-TROWSUM"],"id":"PTO-TILE-MODEL-DISPATCH-REDUCE-AND-EXPAND","surface":"tile"}
// Dispatch ownership for the reduce-and-expand PTO Tile instruction class.
```
<!-- GENERATED-ASL-END: unit -->
