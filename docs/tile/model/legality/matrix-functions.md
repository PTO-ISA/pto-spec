<!-- GENERATED FROM: asl/tile/model/legality/matrix-functions.asl -->
# Matrix Functions

**Normative ASL source:** `asl/tile/model/legality/matrix-functions.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-LEGALITY-MATRIX-FUNCTIONS}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-legality-matrix-functions-purpose role=purpose-scope -->
## Purpose and scope

This unit owns the CUBE Matrix function table and the MX side-type rules. A Matrix bundle names its operation with a five-bit function selector; this unit says which selectors exist, what each one needs, and how many sources it consumes.

The unit comment states the reason it is one small unit: schema code and execution code both read these tables, so they cannot grow separate function tables.

It contains three groups of pure functions:

- Function-table queries: `TileMatrixFunctionAssigned`, `TileMatrixFunctionUsesBias`, `TileMatrixFunctionUsesAccumulator`, `TileMatrixFunctionUsesMX`, `TileMatrixFunctionIsGEMV`, and `TileMatrixFunctionAllowsCScale`.
- MX type rules: `TileMXInputTypeSupported`, `TileMXInputTypeNeedsScale`, `TileMXScaleGroupSize`, `TileMXScaleCarrierType`, `TileMXScaleGroupCount`, and `TileMXOperandPairLegal`.
- Source counting: the group counts, `TileMatrixMathematicalSourceCount`, `TileMatrixSharedSourceCountLegal`, and `TileMatrixLocalMathematicalSourceCount`.

<!-- PTO-READER-BLOCK: tile-model-legality-matrix-functions-concepts role=concepts-state -->
## Concepts and visible state

Twelve selector values are assigned. The table below lists them with the instruction each one selects.

| Function | Instruction | Bias | Accumulator | MX | GEMV |
| --- | --- | --- | --- | --- | --- |
| 0 | `TMATMUL` | no | no | no | no |
| 1 | `TMATMUL_BIAS` | yes | no | no | no |
| 2 | `TMATMUL_ACC` | no | yes | no | no |
| 4 | `TMATMUL_MX` | no | no | yes | no |
| 5 | `TMATMUL_MX_BIAS` | yes | no | yes | no |
| 6 | `TMATMUL_MX_ACC` | no | yes | yes | no |
| 16, 17, 18, 20, 21, 22 | `TGEMV`, `TGEMV_BIAS`, `TGEMV_ACC`, `TGEMV_MX`, `TGEMV_MX_BIAS`, `TGEMV_MX_ACC` | as 0, 1, 2, 4, 5, 6 | as 0, 1, 2, 4, 5, 6 | as 0, 1, 2, 4, 5, 6 | yes |

The `TGEMV` rows reuse the low bits: 16, 17, 18, 20, 21, and 22 mirror 0, 1, 2, 4, 5, and 6. Values 3, 7, 19, 23, and the rest are unassigned.

`TileMatrixFunctionAllowsCScale` is TRUE only for 2 and 6, the `TMATMUL_ACC` and `TMATMUL_MX_ACC` forms.

An MX input is one of FP16, BF16, E4M3, E5M2, E2M1X2, E1M2X2, or HiF4X2. FP16 and BF16 need no scale. The other five need a scale Tile:

- HiF4X2 uses groups of 64 K elements and a `U32` scale carrier.
- E4M3, E5M2, E2M1X2, and E1M2X2 use groups of 32 K elements and an `E8M0` scale carrier.

`TileMXScaleGroupCount` is K divided by the group size, rounded up.

<!-- PTO-READER-BLOCK: tile-model-legality-matrix-functions-rules role=rules-interactions -->
## Rules and interactions

A left group is A plus its scale, if one is needed; a right group is B plus its scale. Each group therefore counts 1 or 2 sources. `TileMatrixMathematicalSourceCount` adds both groups and one more source for a bias or an accumulator, giving 2 to 5.

`TileMatrixSharedSourceCountLegal` decides how many of those sources may come from Shared Tiles:

- A `TGEMV` form requires 0 Shared sources.
- Otherwise 0 is legal, the right group size is legal, and the size of both groups together is legal.

`TileMatrixLocalMathematicalSourceCount` subtracts the Shared groups and returns what remains Local. The bias or accumulator source always stays Local.

Design point: Shared inputs are counted in whole groups. A Shared stream carries either the complete right group or the complete left group followed by the complete right group. A primary cannot be Shared while its own scale is Local, because no count admits that split.

Design point: among the Matrix input type lists, HiF4X2 appears only in `TileMXInputTypeSupported`. The ordinary Matrix type list in the matrix-shape unit does not contain it, so an ordinary (non-MX) function rejects HiF4X2, as NDF clause `PTO-CUBE-MATRIX-SCALE-001` requires.

<!-- PTO-READER-BLOCK: tile-model-legality-matrix-functions-boundaries role=boundaries -->
## Architectural boundaries

Several functions `assert` on their input instead of returning FALSE. `TileMXInputTypeNeedsScale` asserts an MX input type, and `TileMXScaleGroupSize` and `TileMXScaleCarrierType` assert that a scale is needed. Callers must first establish these preconditions: for example, `ExecuteBundleTMATMULOperation` checks `TileMXOperandPairLegal` for an MX function before it computes any count, and the group-count helpers call `TileMXInputTypeNeedsScale` only when `TileMatrixFunctionUsesMX` holds.

These tables are used in preflight by `ExecuteBundleTMATMULOperation`, by the Local source walk in the matrix-operands unit, and by the Shared Matrix schema in block dispatch. The execution units also use them after preflight: the post-process unit counts sources, and the matrix-scale execution unit maps a K index to its scale group.

This unit does not check descriptors, shapes, or layouts.

<!-- PTO-READER-BLOCK: tile-model-legality-matrix-functions-example role=example-usage -->
## Non-normative reading example

Consider `TMATMUL_MX_ACC` (function 6) with A of type E4M3, B of type HiF4X2, and K = 100.

- A needs a scale: `E8M0`, group 32, so 100 / 32 rounded up gives 4 groups. The left group has 2 sources.
- B needs a scale: `U32`, group 64, so 100 / 64 rounded up gives 2 groups. The right group has 2 sources.
- Function 6 uses an accumulator, so the total is 2 + 2 + 1 = 5 mathematical sources.
- This unit admits Shared counts 0, 2 (right group), and 4 (both groups); with 2 Shared sources the Local count is 2 + 1 = 3: C, A, and A's scale. With K = 100 the bundle must still be all-Local, because `BundleTMATMULDimensionsLegal` requires a power-of-two K when any Shared source is present.

This example illustrates the current ASL owner and does not replace the normative operation.

<!-- PTO-READER-BLOCK: tile-model-legality-matrix-functions-related role=related-owners-navigation -->
## Related owners

- [Matrix operands](matrix-operands.md) walks the Local sources in the order these counts imply.
- [Matrix shape](matrix-shape.md) owns the ordinary Matrix type list and the scale descriptor checks.
- [Matrix scale execution](../execution/matrix-scale.md) uses the group size to apply scales.
- [CUBE TMATMUL dispatch](../../../block/model/dispatch/cube-tmatmul.md) and [Shared CUBE Matrix](../../../block/model/dispatch/shared-cube-matrix.md) consume the function table.
- [Tile data types](../../../arch/data-types/tile-data-types.md) defines the MX element and scale types.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/legality/matrix-functions.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-LEGALITY-MATRIX-FUNCTIONS","surface":"tile","classification":["model","legality","matrix-functions"],"depends_on":["PTO-ARCH-DATA-TYPES-TILE-DATA-TYPES"]}
// The CUBE Matrix selector and MX side-type rules are kept in one small unit
// so schema and execution code cannot grow separate function tables.

// NDF-BEGIN: PTO-CUBE-MATRIX-SCALE-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// Each Matrix-MX primary side MUST independently select group-32 E8M0 scale
// for MX FP8/FP4 carriers or group-64 raw U32 scale for HiF4X2. HiF4X2 MUST
// be accepted only by Matrix-MX input roles; ordinary Matrix MUST not gain it.
// Each Local scale MUST use one-block CUBE_M32 storage with a valid major no
// greater than 32, while each Shared scale MUST remain an independently bound
// ordinary Tile with the corresponding primary location.
// For Shared Matrix-MX, ScaleA has semantic shape [M,G_A] and always uses
// the K-group-major physical shape [M,G_A]; ScaleB has semantic shape
// [G_B,N] and always uses the K-group-major physical shape [N,G_B].
// TransA and TransB affect only the corresponding primary data operand;
// each physical shape is exact while physical columns MAY use legal capacity
// padding.
// NDF-END: PTO-CUBE-MATRIX-SCALE-001

pure func TileMXInputTypeSupported(data_type: TileDataType) => boolean
begin
    return data_type == TileDataType_FP16 ||
           data_type == TileDataType_BF16 ||
           data_type == TileDataType_E4M3 ||
           data_type == TileDataType_E5M2 ||
           data_type == TileDataType_E2M1X2 ||
           data_type == TileDataType_E1M2X2 ||
           data_type == TileDataType_HiF4X2;
end;

pure func TileMXScaleGroupSize(data_type: TileDataType)
    => integer {32,64}
begin
    assert TileMXInputTypeNeedsScale(data_type);
    if data_type == TileDataType_HiF4X2 then return 64; end;
    return 32;
end;

pure func TileMXScaleCarrierType(data_type: TileDataType) => TileDataType
begin
    assert TileMXInputTypeNeedsScale(data_type);
    if data_type == TileDataType_HiF4X2 then return TileDataType_U32; end;
    return TileDataType_E8M0;
end;

pure func TileMXScaleGroupCount(
    k: integer {1..65535}, data_type: TileDataType)
    => integer {1..2048}
begin
    let group_size = TileMXScaleGroupSize(data_type);
    return ((k + (group_size - 1)) DIVRM group_size)
        as integer {1..2048};
end;

pure func TileMXInputTypeNeedsScale(data_type: TileDataType) => boolean
begin
    assert TileMXInputTypeSupported(data_type);
    return data_type != TileDataType_FP16 &&
           data_type != TileDataType_BF16;
end;

pure func TileMXOperandPairLegal(left_type: TileDataType,
                                right_type: TileDataType) => boolean
begin
    return TileMXInputTypeSupported(left_type) &&
           TileMXInputTypeSupported(right_type);
end;

pure func TileMatrixFunctionAssigned(function: integer {0..31}) => boolean
begin
    return function == 0 || function == 1 || function == 2 ||
           function == 4 || function == 5 || function == 6 ||
           function == 16 || function == 17 || function == 18 ||
           function == 20 || function == 21 || function == 22;
end;

pure func TileMatrixFunctionUsesBias(function: integer {0..31}) => boolean
begin
    return function == 1 || function == 5 ||
           function == 17 || function == 21;
end;

pure func TileMatrixFunctionUsesAccumulator(
    function: integer {0..31}) => boolean
begin
    return function == 2 || function == 6 ||
           function == 18 || function == 22;
end;

pure func TileMatrixFunctionUsesMX(function: integer {0..31}) => boolean
begin
    return function == 4 || function == 5 || function == 6 ||
           function == 20 || function == 21 || function == 22;
end;

pure func TileMatrixFunctionIsGEMV(function: integer {0..31}) => boolean
begin
    return function == 16 || function == 17 || function == 18 ||
           function == 20 || function == 21 || function == 22;
end;

pure func TileMatrixFunctionAllowsCScale(
    function: integer {0..31}) => boolean
begin
    return function == 2 || function == 6;
end;

pure func TileMatrixLeftGroupSourceCount(
    function: integer {0..31}, left_type: TileDataType) => integer {1..2}
begin
    if TileMatrixFunctionUsesMX(function) &&
       TileMXInputTypeNeedsScale(left_type) then
        return 2;
    end;
    return 1;
end;

pure func TileMatrixRightGroupSourceCount(
    function: integer {0..31}, right_type: TileDataType) => integer {1..2}
begin
    if TileMatrixFunctionUsesMX(function) &&
       TileMXInputTypeNeedsScale(right_type) then
        return 2;
    end;
    return 1;
end;

pure func TileMatrixMathematicalSourceCount(
    function: integer {0..31}, left_type: TileDataType,
    right_type: TileDataType) => integer {2..5}
begin
    assert TileMatrixFunctionAssigned(function);
    let matrix_sources = TileMatrixLeftGroupSourceCount(
        function, left_type) + TileMatrixRightGroupSourceCount(
        function, right_type);
    let supplementary_source =
        TileMatrixFunctionUsesBias(function) ||
        TileMatrixFunctionUsesAccumulator(function);
    return (matrix_sources + (if supplementary_source then 1 else 0))
        as integer {2..5};
end;

// Shared Matrix inputs are carried in complete operand groups.  A right-only
// stream contains the right matrix and its optional scale.  A both-sides
// stream contains the complete left group followed by the complete right
// group.  TGEMV remains Local-only.
pure func TileMatrixSharedSourceCountLegal(
    function: integer {0..31}, left_type: TileDataType,
    right_type: TileDataType, shared_count: integer {0..4}) => boolean
begin
    assert TileMatrixFunctionAssigned(function);
    if TileMatrixFunctionIsGEMV(function) then
        return shared_count == 0;
    end;
    if shared_count == 0 then
        return TRUE;
    end;
    let right_group = TileMatrixRightGroupSourceCount(
        function, right_type);
    let both_groups = TileMatrixLeftGroupSourceCount(
        function, left_type) + right_group;
    return shared_count == right_group ||
           shared_count == both_groups;
end;

// Local mathematical operands preserve their architectural order after the
// Shared groups are removed.  ACC contributes C first; bias contributes the
// final Local source.  Post-processing sources are not counted here.
pure func TileMatrixLocalMathematicalSourceCount(
    function: integer {0..31}, left_type: TileDataType,
    right_type: TileDataType, shared_count: integer {0..4})
    => integer {0..5}
begin
    assert TileMatrixSharedSourceCountLegal(
        function, left_type, right_type, shared_count);
    let supplementary = if
        TileMatrixFunctionUsesBias(function) ||
        TileMatrixFunctionUsesAccumulator(function)
    then 1 else 0;
    if shared_count == 0 then
        return TileMatrixMathematicalSourceCount(
            function, left_type, right_type) as integer {0..5};
    end;
    let right_group = TileMatrixRightGroupSourceCount(
        function, right_type);
    if shared_count == right_group then
        return (TileMatrixLeftGroupSourceCount(function, left_type) +
                supplementary) as integer {0..5};
    end;
    return supplementary as integer {0..5};
end;
```
<!-- GENERATED-ASL-END: unit -->
