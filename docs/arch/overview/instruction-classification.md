<!-- GENERATED FROM: asl/arch/overview/instruction-classification.asl -->
# Instruction Classification

**Normative ASL source:** `asl/arch/overview/instruction-classification.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-OVERVIEW-INSTRUCTION-CLASSIFICATION}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-instruction-class-purpose role=purpose-scope -->
## Purpose and scope

This page explains the declared Tile programming classes, execution-engine categories, and TEPL alias policy. Determine a concrete operation's assignments from its current instruction record rather than treating this guide as catalog-wide proof.

<!-- PTO-READER-BLOCK: arch-instruction-class-concepts role=concepts-state -->
## Classification axes

- Programming classes cover elementwise, Tile-scalar/immediate, reduce/expand, memory/data movement, matrix/matrix-vector, layout/rearrangement, and irregular/complex operations.
- Execution engines are exactly `VEC`, `TLSU`, `CUBE`, and `SFU`.
- Sync and Config is a Tile programming class, but the current direct binary carrier has no direct Tile operation in that class.

<!-- PTO-READER-BLOCK: arch-instruction-class-rules role=rules-interactions -->
## Class and engine rules

The programming-class axis is independent of the execution-engine axis.

`VEC` is restricted to elementwise operations; global-memory and transfer operations use `TLSU`; matrix work uses `CUBE`; specialized complex work uses `SFU`.

`TileEngineHasCanonicalBundleStartAlias` returns true only for `TileEngine_VEC` and `TileEngine_SFU`.

<!-- PTO-READER-BLOCK: arch-instruction-class-boundaries role=boundaries -->
## Alias boundary

`BSTART.VEC` and `BSTART.SFU` reuse the TEPL `Mode` and `Function` carrier. `BSTART.TEPL` remains accepted compatibility input, while canonical assembly and disassembly select the engine-specific spelling and do not render `BSTART.TEPL`.

<!-- PTO-READER-BLOCK: arch-instruction-class-example role=example-usage -->
## Non-normative classification example

Use this example block only as a reading aid: apply the rules above, then confirm the result in the normative ASL owner. It does not add an architectural contract.

<!-- PTO-READER-BLOCK: arch-instruction-class-related role=related-owners-navigation -->
## Related owners

- Packed data types provide type context for classified Tile operations.
- Encoding ownership separates active carriers from reserved roots and deleted names; follow concrete instruction owners for target-profile questions.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/overview/instruction-classification.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-OVERVIEW-INSTRUCTION-CLASSIFICATION","surface":"arch","classification":["overview","instruction-classification"],"depends_on":["PTO-ARCH-DATA-TYPES-PACKED"]}

// NDF-BEGIN: PTO-ARCH-TILE-INSTRUCTION-CLASS-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// Every direct Tile operation MUST belong to exactly one PTO instruction class:
// Elementwise Tile-Tile, Tile-Scalar and Immediate, Reduce and Expand,
// Memory and Data Movement, Matrix and Matrix-Vector, Layout and
// Rearrangement, or Irregular and Complex. Sync and Config is a PTO Tile
// programming class but has no direct Tile operation in the current binary
// carrier. Classification MUST remain independent of execution-engine choice.
// NDF-END: PTO-ARCH-TILE-INSTRUCTION-CLASS-001

// NDF-BEGIN: PTO-ARCH-TILE-EXECUTION-ENGINE-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// Every direct Tile operation MUST select exactly one of VEC, TLSU, CUBE, or
// SFU. VEC MUST execute only elementwise operations. Specialized complex
// operations use SFU, global-memory and data-transfer operations use TLSU, and
// matrix and matrix-vector operations use CUBE.
// NDF-END: PTO-ARCH-TILE-EXECUTION-ENGINE-001

// NDF-BEGIN: PTO-ARCH-TEPL-ALIAS-001
// ndf: kind=contract level=L1 layer=block status=accepted
// BSTART.VEC and BSTART.SFU MUST use the unchanged TEPL Mode/Function carrier.
// BSTART.TEPL remains an accepted compatibility spelling. Canonical assembly
// and disassembly MUST render BSTART.VEC or BSTART.SFU according to the selected
// Tile operation and MUST NOT render BSTART.TEPL.
// NDF-END: PTO-ARCH-TEPL-ALIAS-001

type TileInstructionClass of enumeration {
    TileClass_ElementwiseTileTile,
    TileClass_TileScalarAndImmediate,
    TileClass_ReduceAndExpand,
    TileClass_MemoryAndDataMovement,
    TileClass_MatrixAndMatrixVector,
    TileClass_LayoutAndRearrangement,
    TileClass_IrregularAndComplex
};

type TileExecutionEngine of enumeration {
    TileEngine_VEC,
    TileEngine_TLSU,
    TileEngine_CUBE,
    TileEngine_SFU
};

type TileTEPLAssemblyAlias of enumeration {
    TileTEPLAlias_TEPL,
    TileTEPLAlias_VEC,
    TileTEPLAlias_SFU
};

pure func TileEngineHasCanonicalBundleStartAlias(
    engine: TileExecutionEngine) => boolean
begin
    return engine == TileEngine_VEC || engine == TileEngine_SFU;
end;
```
<!-- GENERATED-ASL-END: unit -->
