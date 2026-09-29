<!-- GENERATED FROM: asl/tile/model/legality/matrix-functions.asl -->
# Matrix Functions

**Normative ASL source:** `asl/tile/model/legality/matrix-functions.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-LEGALITY-MATRIX-FUNCTIONS}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-legality-matrix-functions-purpose role=purpose-scope -->
## 用途与范围

本单元负责 CUBE Matrix 函数表与 MX 侧类型规则。Matrix 指令束用一个五位函数选择器命名其操作；本单元规定哪些选择器存在、每个选择器需要什么，以及它消耗多少个源。

单元注释说明了它为何是一个小单元：schema 代码与执行代码都读取这些表，因此两者不会各自形成独立的函数表。

它包含三组纯函数：

- 函数表查询：`TileMatrixFunctionAssigned`、`TileMatrixFunctionUsesBias`、`TileMatrixFunctionUsesAccumulator`、`TileMatrixFunctionUsesMX`、`TileMatrixFunctionIsGEMV` 与 `TileMatrixFunctionAllowsCScale`。
- MX 类型规则：`TileMXInputTypeSupported`、`TileMXInputTypeNeedsScale`、`TileMXScaleGroupSize`、`TileMXScaleCarrierType`、`TileMXScaleGroupCount` 与 `TileMXOperandPairLegal`。
- 源计数：各组计数、`TileMatrixMathematicalSourceCount`、`TileMatrixSharedSourceCountLegal` 与 `TileMatrixLocalMathematicalSourceCount`。

<!-- PTO-READER-BLOCK: tile-model-legality-matrix-functions-concepts role=concepts-state -->
## 概念与可见状态

共有十二个已分配的选择器值。下表列出它们及各自选中的指令。

| Function | 指令 | Bias | 累加器 | MX | GEMV |
| --- | --- | --- | --- | --- | --- |
| 0 | `TMATMUL` | 否 | 否 | 否 | 否 |
| 1 | `TMATMUL_BIAS` | 是 | 否 | 否 | 否 |
| 2 | `TMATMUL_ACC` | 否 | 是 | 否 | 否 |
| 4 | `TMATMUL_MX` | 否 | 否 | 是 | 否 |
| 5 | `TMATMUL_MX_BIAS` | 是 | 否 | 是 | 否 |
| 6 | `TMATMUL_MX_ACC` | 否 | 是 | 是 | 否 |
| 16, 17, 18, 20, 21, 22 | `TGEMV`、`TGEMV_BIAS`、`TGEMV_ACC`、`TGEMV_MX`、`TGEMV_MX_BIAS`、`TGEMV_MX_ACC` | 同 0, 1, 2, 4, 5, 6 | 同 0, 1, 2, 4, 5, 6 | 同 0, 1, 2, 4, 5, 6 | 是 |

`TGEMV` 各行复用低位：16、17、18、20、21 与 22 分别对应 0、1、2、4、5 与 6。值 3、7、19、23 及其余值均未分配。

`TileMatrixFunctionAllowsCScale` 只对 2 和 6 为 TRUE，即 `TMATMUL_ACC` 与 `TMATMUL_MX_ACC` 形式。

MX 输入是 FP16、BF16、E4M3、E5M2、E2M1X2、E1M2X2 或 HiF4X2 之一。FP16 与 BF16 不需要缩放。其余五种需要一个缩放 Tile：

- HiF4X2 以 64 个 K 元素为一组，使用 `U32` 缩放载体。
- E4M3、E5M2、E2M1X2 与 E1M2X2 以 32 个 K 元素为一组，使用 `E8M0` 缩放载体。

`TileMXScaleGroupCount` 等于 K 除以组大小并向上取整。

<!-- PTO-READER-BLOCK: tile-model-legality-matrix-functions-rules role=rules-interactions -->
## 规则与交互

左组是 A 加上其缩放（如需要）；右组是 B 加上其缩放。因此每组计 1 或 2 个源。`TileMatrixMathematicalSourceCount` 把两组相加，并为 bias 或累加器再加一个源，结果为 2 到 5。

`TileMatrixSharedSourceCountLegal` 决定其中多少个源可以来自 Shared Tile：

- `TGEMV` 形式要求 Shared 源数为 0。
- 否则，0 合法，右组大小合法，两组大小之和也合法。

`TileMatrixLocalMathematicalSourceCount` 减去 Shared 组，返回剩余的 Local 源数。bias 或累加器源始终保持 Local。

设计要点：Shared 输入按完整组计数。Shared 流要么携带完整的右组，要么携带完整的左组再接完整的右组。主操作数不能是 Shared 而其自身缩放是 Local，因为没有任何计数允许这种拆分。

设计要点：在各 Matrix 输入类型列表中，HiF4X2 只出现在 `TileMXInputTypeSupported` 中。matrix-shape 单元中的普通 Matrix 类型列表不包含它，因此普通（非 MX）函数拒绝 HiF4X2，这符合 NDF 条款 `PTO-CUBE-MATRIX-SCALE-001` 的要求。

<!-- PTO-READER-BLOCK: tile-model-legality-matrix-functions-boundaries role=boundaries -->
## 架构边界

有几个函数对输入使用 `assert`，而不是返回 FALSE。`TileMXInputTypeNeedsScale` 断言输入是 MX 类型，`TileMXScaleGroupSize` 与 `TileMXScaleCarrierType` 断言需要缩放。调用者必须先建立这些前提：例如，`ExecuteBundleTMATMULOperation` 对 MX 函数先检查 `TileMXOperandPairLegal`，再计算任何计数；各组计数辅助函数也只在 `TileMatrixFunctionUsesMX` 成立时调用 `TileMXInputTypeNeedsScale`。

这些表在预检中被 `ExecuteBundleTMATMULOperation`、matrix-operands 单元中的 Local 源遍历以及块派发中的 Shared Matrix schema使用。执行单元在预检之后也使用它们：后处理单元用于计数源，matrix-scale 执行单元用于把 K 索引映射到其缩放组。

本单元不检查描述符、形状或布局。

<!-- PTO-READER-BLOCK: tile-model-legality-matrix-functions-example role=example-usage -->
## 非规范阅读示例

考虑 `TMATMUL_MX_ACC`（函数 6），A 类型为 E4M3，B 类型为 HiF4X2，K = 100。

- A 需要缩放：`E8M0`，组大小 32，因此 100 / 32 向上取整得到 4 组。左组有 2 个源。
- B 需要缩放：`U32`，组大小 64，因此 100 / 64 向上取整得到 2 组。右组有 2 个源。
- 函数 6 使用累加器，因此总计 2 + 2 + 1 = 5 个数学源。
- 本单元接受的 Shared 数为 0、2（右组）与 4（两组）；有 2 个 Shared 源时，Local 数为 2 + 1 = 3：C、A 与 A 的缩放。在 K = 100 时指令束仍必须全为 Local，因为只要存在 Shared 源，`BundleTMATMULDimensionsLegal` 就要求 K 为 2 的幂。

本示例只用于演示当前 ASL 所有者，不替代规范操作。

<!-- PTO-READER-BLOCK: tile-model-legality-matrix-functions-related role=related-owners-navigation -->
## 相关所有者

- [Matrix 操作数](matrix-operands.md) 按这些计数所隐含的顺序遍历 Local 源。
- [Matrix 形状](matrix-shape.md) 负责普通 Matrix 类型列表与缩放描述符检查。
- [Matrix 缩放执行](../execution/matrix-scale.md) 使用组大小来应用缩放。
- [CUBE TMATMUL 派发](../../../block/model/dispatch/cube-tmatmul.md) 与 [Shared CUBE Matrix](../../../block/model/dispatch/shared-cube-matrix.md) 使用函数表。
- [Tile 数据类型](../../../arch/data-types/tile-data-types.md) 定义 MX 元素类型与缩放类型。
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
