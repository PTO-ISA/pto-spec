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
