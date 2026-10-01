<!-- GENERATED FROM: asl/tile/model/dispatch/matrix-and-matrix-vector.asl -->
# Matrix And Matrix Vector

**Normative ASL source:** `asl/tile/model/dispatch/matrix-and-matrix-vector.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-DISPATCH-MATRIX-AND-MATRIX-VECTOR}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-dispatch-matrix-and-matrix-vector-purpose role=purpose-scope -->
## Purpose and scope

This unit names the matrix and matrix-vector class of Tile operations. It contains no executable ASL. Its content is the `PTO-UNIT` metadata line, whose `depends_on` list names instruction units and Tile model units, and a one-line comment. The operations themselves are defined by their instruction units.

Every operation in the class multiplies matrices or a matrix and a vector on the CUBE engine.

<!-- PTO-READER-BLOCK: tile-model-dispatch-matrix-and-matrix-vector-concepts role=concepts-state -->
## Concepts and visible state

The unit declares no state. The tile-operations catalog places 12 operations in this class. The table groups them by semantic handler, which is the ASL function the generated dispatcher calls.

| Operations | Semantic handler |
| --- | --- |
| `TMATMUL`, `TMATMUL_BIAS`, `TMATMUL_ACC` | one handler of the same name each |
| `TMATMUL_MX`, `TMATMUL_MX_BIAS`, `TMATMUL_MX_ACC` | one handler of the same name each |
| `TGEMV`, `TGEMV_BIAS`, `TGEMV_ACC` | one handler of the same name each |
| `TGEMV_MX`, `TGEMV_MX_BIAS`, `TGEMV_MX_ACC` | one handler of the same name each |

All 12 operations use the CUBE family, and the 12-bit code is the function number. The functions follow a regular pattern: `TMATMUL` is 0, the MX form adds 4, the `TGEMV` form adds 16, `_BIAS` adds 1, and `_ACC` adds 2. Functions 3, 7, 8, 9 through 15, 19, and 23 through 31 are reserved. Each operation has its own `BSTART` command form.

<!-- PTO-READER-BLOCK: tile-model-dispatch-matrix-and-matrix-vector-rules role=rules-interactions -->
## Rules and interactions

Dispatch does not look at the class. Tile execution decodes the bundle descriptor with `DecodeTileOperation(family, code)`, where the family is TEPL, TLSU, or CUBE and the code is 12 bits. A code with no catalog row returns `PTO_TILE_OPERATION_COUNT`. `BundleOperationDescriptorLegal` makes this check when `BSTART` is decoded, so that `BSTART` faults with `Fault_IllegalInstruction` and the bundle is never installed; tile execution repeats the decode and raises the same fault if it is reached with such a code.

Design point: the class is an ownership and navigation grouping, not a decode input. Moving an operation to another class would not change the code that selects it or the handler that runs it.

Design point: every handler of this class has the producer-effect class `AtomicAuxiliary`. The portable-carriers contract says such effects take part in the same transaction as the `B.ASSEMBLE` body, so these operations may be generation writers.

<!-- PTO-READER-BLOCK: tile-model-dispatch-matrix-and-matrix-vector-boundaries role=boundaries -->
## Architectural boundaries

This unit does not decode, check legality, or execute anything. Operand schemas, legality handlers, and execution belong to the instruction units and to these model units:

- [CUBE execution](../execution/cube.md)
- [Matrix shape legality](../legality/matrix-shape.md)

The unit's `depends_on` list names all 12 instruction units that the catalog places in this class. Tile execution sends CUBE matrix bundles to the CUBE matrix path in the block dispatch units, not through the generic stage-2 preparation.

<!-- PTO-READER-BLOCK: tile-model-dispatch-matrix-and-matrix-vector-example role=example-usage -->
## Non-normative reading example

This example illustrates the current ASL owner and does not replace the normative operation.

`TGEMV_MX_ACC` is the `TGEMV` form (16), with MX (4) and accumulation (2), so its function is 16 + 4 + 2 = 22. A CUBE bundle with code 22 decodes to `TGEMV_MX_ACC`. Code 19, which would be 16 + 1 + 2 (bias and accumulation together), has no catalog row and no `BSTART` form produces it; the envelope reserves it, and the generated decoder check asserts that it decodes to `PTO_TILE_OPERATION_COUNT`.

<!-- PTO-READER-BLOCK: tile-model-dispatch-matrix-and-matrix-vector-related role=related-owners-navigation -->
## Related owners

- [Top-level dispatch](top-level.md) lists all seven classes and the catalog envelope.
- [Tile execution](../../../block/model/dispatch/tile-execution.md) decodes the operation and runs its handler.
- [Portable carriers](../../../block/model/operands/portable-carriers.md) owns the producer-effect classes.
- [TMATMUL](../../matrix-and-matrix-vector/matrix-matrix/TMATMUL.md) is one instruction page of this class.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/dispatch/matrix-and-matrix-vector.asl -->
```asl
// PTO-UNIT: {"classification":["model","dispatch","matrix-and-matrix-vector"],"depends_on":["PTO-TILE-MODEL-LEGALITY-MATRIX-SHAPE","PTO-TILE-MODEL-EXECUTION-CUBE","PTO-TILE-TGEMV","PTO-TILE-TGEMV-ACC","PTO-TILE-TGEMV-BIAS","PTO-TILE-TGEMV-MX","PTO-TILE-TGEMV-MX-ACC","PTO-TILE-TGEMV-MX-BIAS","PTO-TILE-TMATMUL","PTO-TILE-TMATMUL-ACC","PTO-TILE-TMATMUL-BIAS","PTO-TILE-TMATMUL-MX","PTO-TILE-TMATMUL-MX-ACC","PTO-TILE-TMATMUL-MX-BIAS"],"id":"PTO-TILE-MODEL-DISPATCH-MATRIX-AND-MATRIX-VECTOR","surface":"tile"}
// Dispatch ownership for the matrix-and-matrix-vector PTO Tile instruction class.
```
<!-- GENERATED-ASL-END: unit -->
