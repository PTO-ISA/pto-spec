<!-- GENERATED FROM: asl/arch/overview/instruction-classification.asl -->
# Instruction Classification

**Normative ASL source:** `asl/arch/overview/instruction-classification.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-OVERVIEW-INSTRUCTION-CLASSIFICATION}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-instruction-class-purpose role=purpose-scope -->
## 用途与范围

本页解释已声明的 Tile 编程类别、执行引擎类别与 TEPL 别名策略。具体操作的归类应从其当前指令记录中确定，不要把本指南当作目录级证明。

<!-- PTO-READER-BLOCK: arch-instruction-class-concepts role=concepts-state -->
## 分类维度

- 编程类别覆盖逐元素、Tile-标量/立即数、归约/扩展、内存/数据搬运、矩阵/矩阵-向量、布局/重排与非规则/复杂操作。
- 执行引擎恰好是 `VEC`、`TLSU`、`CUBE` 与 `SFU`。
- 同步与配置是 Tile 编程类别，但当前直接二进制载体中没有该类直接 Tile 操作。

<!-- PTO-READER-BLOCK: arch-instruction-class-rules role=rules-interactions -->
## 类别与引擎规则

编程类别维度独立于执行引擎维度。

`VEC` 只用于逐元素操作；全局内存与传输操作使用 `TLSU`；矩阵操作使用 `CUBE`；专用复杂操作使用 `SFU`。

`TileEngineHasCanonicalBundleStartAlias` 只对 `TileEngine_VEC` 和 `TileEngine_SFU` 返回真。

<!-- PTO-READER-BLOCK: arch-instruction-class-boundaries role=boundaries -->
## 别名边界

`BSTART.VEC` 与 `BSTART.SFU` 复用 TEPL 的 `Mode` 和 `Function` 载体。`BSTART.TEPL` 仍是可接受的兼容输入，而规范汇编与反汇编选择引擎专用拼写，不输出 `BSTART.TEPL`。

<!-- PTO-READER-BLOCK: arch-instruction-class-example role=example-usage -->
## 非规范分类示例

本示例块只用于帮助阅读：先应用上文规则，再到规范 ASL 所有者中确认结果。它不会增加任何架构契约。

<!-- PTO-READER-BLOCK: arch-instruction-class-related role=related-owners-navigation -->
## 相关所有者

- 紧凑数据类型为已分类的 Tile 操作提供类型上下文。
- 编码所有权把活动载体与保留根、已删除名称分开；目标配置档问题应继续前往具体指令所有者。
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
