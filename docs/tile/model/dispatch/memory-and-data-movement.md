<!-- GENERATED FROM: asl/tile/model/dispatch/memory-and-data-movement.asl -->
# Memory And Data Movement

**Normative ASL source:** `asl/tile/model/dispatch/memory-and-data-movement.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-DISPATCH-MEMORY-AND-DATA-MOVEMENT}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-dispatch-memory-and-data-movement-purpose role=purpose-scope -->
## Purpose and scope

This unit names the memory and data movement class of Tile operations. It contains no executable ASL. Its content is the `PTO-UNIT` metadata line, whose `depends_on` list names instruction units and Tile model units, and a one-line comment. The operations themselves are defined by their instruction units.

Every operation in the class accesses Global Memory (GM) by loading, storing, prefetching, or indexed and atomic access, except `GMOV`, which copies Local fragments between peer PEs.

<!-- PTO-READER-BLOCK: tile-model-dispatch-memory-and-data-movement-concepts role=concepts-state -->
## Concepts and visible state

The unit declares no state. The tile-operations catalog places 27 operations in this class. The table groups them by semantic handler, which is the ASL function the generated dispatcher calls.

| Operations | Semantic handler |
| --- | --- |
| `TLOAD`, `TSTORE`, `TPREFETCH` | `TLOAD`, `TSTORE`, `TPREFETCH` |
| `MGATHER`, `MGATHER_MASK`, `MSCATTER`, `MSCATTER_MASK`, `GMOV` | one handler of the same name each |
| `MGATHER_CAS` | `GM_ATOM_CAS` |
| `MGATHER_EXCH`, `MGATHER_MAX`, `MGATHER_MIN`, `MGATHER_ADD`, `MGATHER_INC`, `MGATHER_DEC`, `MGATHER_AND`, `MGATHER_OR`, `MGATHER_XOR` | `GM_ATOM_VALUE` |
| `MSCATTER_MAX`, `MSCATTER_MIN`, `MSCATTER_ADD`, `MSCATTER_INC`, `MSCATTER_DEC`, `MSCATTER_AND`, `MSCATTER_OR`, `MSCATTER_XOR` | `GM_RED_VALUE` |
| `MSCATTER_POPC` | `GM_RED_POPC` |

All 27 operations use the TLSU family and the TLSU engine. For TLSU the 12-bit code is the function number itself. The functions are 0, 1, and 3 through 27; function 2 is `TMOV`, which belongs to the layout class, and functions 28 through 31 are reserved. Each operation has its own `BSTART` command form, such as `BSTART.TLOAD` or `BSTART.MGATHER.ADD`.

<!-- PTO-READER-BLOCK: tile-model-dispatch-memory-and-data-movement-rules role=rules-interactions -->
## Rules and interactions

Dispatch does not look at the class. Tile execution decodes the bundle descriptor with `DecodeTileOperation(family, code)`, where the family is TEPL, TLSU, or CUBE and the code is 12 bits. A code with no catalog row returns `PTO_TILE_OPERATION_COUNT`. `BundleOperationDescriptorLegal` makes this check when `BSTART` is decoded, so that `BSTART` faults with `Fault_IllegalInstruction` and the bundle is never installed; tile execution repeats the decode and raises the same fault if it is reached with such a code.

Design point: the class is an ownership and navigation grouping, not a decode input. Moving an operation to another class would not change the code that selects it or the handler that runs it.

Design point: this class mixes producer-effect classes. `TLOAD`, `MGATHER`, `MGATHER_MASK`, and `GMOV` are `RollbackSafe`. `TSTORE`, `TPREFETCH`, `MSCATTER`, `MSCATTER_MASK`, and the four GM atomic and reduction handlers are `NonRollbackAuxiliary`. A bundle whose Local Tile binding carries a `B.ASSEMBLE` modifier and that selects one of the latter faults with `Fault_TileLegality` in `BundleProducerEffectEligible`, before any body or auxiliary effect.

<!-- PTO-READER-BLOCK: tile-model-dispatch-memory-and-data-movement-boundaries role=boundaries -->
## Architectural boundaries

This unit does not decode, check legality, or execute anything. Operand schemas, legality handlers, and execution belong to the instruction units and to these model units:

- [Memory restart](../memory/restart.md)
- [Matrix shape legality](../legality/matrix-shape.md)

The unit's `depends_on` list names only 9 instruction units: `GMOV`, `MGATHER`, `MGATHER_CAS`, `MGATHER_MASK`, `MSCATTER`, `MSCATTER_MASK`, `TLOAD`, `TPREFETCH`, and `TSTORE`. The 18 atomic and reduction units that the catalog also places in this class are not listed. `BSTART.TIMG2COL` uses TLSU function 28 but is not a catalog operation; tile execution recognizes it by its exact command form and skips the generic decode.

<!-- PTO-READER-BLOCK: tile-model-dispatch-memory-and-data-movement-example role=example-usage -->
## Non-normative reading example

This example illustrates the current ASL owner and does not replace the normative operation.

`MGATHER_ADD` has TLSU function 12, so its code is `0x00C`. It decodes to `GM_ATOM_VALUE` with the constant `GMAtomic_ADD`. If the same bundle also carried a `B.ASSEMBLE` modifier, the effect-eligibility check would reject it with `Fault_TileLegality` before any GM access.

<!-- PTO-READER-BLOCK: tile-model-dispatch-memory-and-data-movement-related role=related-owners-navigation -->
## Related owners

- [Top-level dispatch](top-level.md) lists all seven classes and the catalog envelope.
- [Tile execution](../../../block/model/dispatch/tile-execution.md) decodes the operation and runs its handler.
- [Portable carriers](../../../block/model/operands/portable-carriers.md) owns the producer-effect classes.
- [TLOAD](../../memory-and-data-movement/regular/TLOAD.md) is one instruction page of this class.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/dispatch/memory-and-data-movement.asl -->
```asl
// PTO-UNIT: {"classification":["model","dispatch","memory-and-data-movement"],"depends_on":["PTO-TILE-MODEL-LEGALITY-MATRIX-SHAPE","PTO-TILE-MODEL-MEMORY-RESTART","PTO-TILE-GMOV","PTO-TILE-MGATHER","PTO-TILE-MGATHER-CAS","PTO-TILE-MGATHER-MASK","PTO-TILE-MSCATTER","PTO-TILE-MSCATTER-MASK","PTO-TILE-TLOAD","PTO-TILE-TPREFETCH","PTO-TILE-TSTORE"],"id":"PTO-TILE-MODEL-DISPATCH-MEMORY-AND-DATA-MOVEMENT","surface":"tile"}
// Dispatch ownership for the memory-and-data-movement PTO Tile instruction class.
```
<!-- GENERATED-ASL-END: unit -->
