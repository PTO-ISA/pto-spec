<!-- GENERATED FROM: asl/tile/model/legality/matrix-operands.asl -->
# Matrix Operands

**Normative ASL source:** `asl/tile/model/legality/matrix-operands.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-LEGALITY-MATRIX-OPERANDS}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-legality-matrix-operands-purpose role=purpose-scope -->
## 用途与范围

本单元在获取任何源快照之前，按流顺序检查 CUBE Matrix 指令束的 Local 数学源。数学源是乘积本身的操作数：累加器 C、A 及其缩放、B 及其缩放、bias，以及可选的 CScale Tile。后处理源由 matrix-postprocess 单元检查。

入口是 `BundleMatrixLocalMathematicalSourcesLegal`。它唯一的调用者是 `ExecuteBundleTMATMULOperation`，后者对通过了更早指令束检查的每种 `TMATMUL` 与 `TGEMV` 形式调用它。本单元还为每个辅助角色定义一个描述符谓词：

- `TileMatrixLocalAScaleSchemaLegal` 与 `TileMatrixLocalBScaleSchemaLegal` 用于 MX 缩放。
- `TileMatrixLocalBiasSchemaLegal` 用于 bias。
- `TileMatrixLocalCScaleSchemaLegal` 用于 CScale。

另外两个谓词 `TileMatrixLocalOperandSchemaLegal`（RowMajor 操作数）与 `TileMatrixInfoAccumulatorSchemaLegal` 在当前 ASL 中没有调用者。

<!-- PTO-READER-BLOCK: tile-model-legality-matrix-operands-concepts role=concepts-state -->
## 概念与可见状态

本单元读取 `_Tiles`、经 `BundleMatrixSourceAt` 读取指令束 Tile 绑定，以及 `_BundleFixedPointAttributes` 的两个字段：`pre_quant_mode` 与 `c_scale_en`。它不写任何状态。

`BundleMatrixSourceAt(n)` 返回所有 Tile 绑定中第 n 个有效源，在每个绑定内 `source0` 先于 `source1` 计数。若某个源带有已物化的子视图，则返回物化后的 Tile。

每个辅助角色有固定的描述符：

| 角色 | 有效形状 | 类型 | 布局 |
| --- | --- | --- | --- |
| A 缩放 | [M, 组数] | A 的缩放载体 | `CUBE_M32` |
| B 缩放 | [N, 组数] | B 的缩放载体 | `CUBE_M32` |
| Bias | [1, N] | 结果类型 | `CUBE_N8` |
| CScale | [M, 1] | `U8` | `CUBE_M32` |

每个角色还要求 `contents_defined` 与 `TileCubeDescriptorLegal`。缩放载体为 `E8M0` 或 `U32`，由 matrix-functions 单元定义。

<!-- PTO-READER-BLOCK: tile-model-legality-matrix-operands-rules role=rules-interactions -->
## 规则与交互

`BundleMatrixLocalMathematicalSourcesLegal` 从 0 开始推进序号，并在第一次失败时停止：

1. 对累加器形式，用 `TileMatrixLocalCubeAccumulatorSchemaLegal` 按 [M, N]、结果类型、M 布局与 D 容量检查 C。
2. 若 A 为 Local（Shared 数为 0 或等于右组大小），用 `TileMatrixLocalMOperandSchemaLegal` 检查 A；若函数为 MX 且 A 的类型需要缩放，再检查其缩放。
3. 若 Shared 数为 0，用 `TileMatrixLocalNOperandSchemaLegal` 检查 B，如需要再检查其缩放。
4. 对 bias 形式，检查 bias。
5. 若设置了 `c_scale_en`，下一个源是 CScale。函数必须允许 CScale，结果类型必须为 FP32，且 CScale 描述符必须合法。

当 A 为 Local 时，C 必须匹配的布局是 Local A 的布局；否则取 C 自身的布局，因此本遍历不约束 C 的布局，`BundleMatrixCooperativeMLayout` 随后要求解析出的布局通过 `TileMatrixMLayoutLegal`。

设计要点：源按位置而不是按名称识别。之后为执行取操作数时使用同一流顺序，因此预检所检查的正是操作将要读取的 Tile。

设计要点：CScale 要求 FP32 结果类型。执行辅助函数 `TileProfileMatrixCScale` 把每个 C 元素按 FP32 分类，并将其除以 2 的 `U8` 指数次幂，因此预检只对该辅助函数所读取的类型接受 CScale。

<!-- PTO-READER-BLOCK: tile-model-legality-matrix-operands-boundaries role=boundaries -->
## 架构边界

此检查在预检阶段运行，位于 Shared schema 检查之后，并在后处理检查、目标分配与源快照之前。结果为 FALSE 时 `ExecuteBundleTMATMULOperation` 引发 `Fault_TileLegality`，因此不分配 D，也不获取源快照。

存在 CScale 时，CUBE 执行单元中的执行辅助函数也会 `assert` 断言 `TileMatrixLocalCScaleSchemaLegal`。

源数量本身不在此处检查。块派发中的 `BundleMatrixDynamicBindingsComplete` 先要求 Local 源数等于数学源数加后处理源数。

<!-- PTO-READER-BLOCK: tile-model-legality-matrix-operands-example role=example-usage -->
## 非规范阅读示例

考虑一个全 Local 的 `TMATMUL_ACC`，A 与 B 为 FP16，M = 16，N = 32，K = 64，并设置了 `c_scale_en`。结果类型为 FP32。

- 序号 0 是 C：有效形状 [16, 32]、FP32、与 A 相同的布局；除非 `pre_quant_mode` 非零，其容量必须等于 D 的容量。
- 序号 1 是 A：[16, 64]、FP16、`CUBE_M16` 或 `CUBE_M32`。
- 序号 2 是 B：[64, 32]、FP16、`CUBE_N8`。
- 序号 3 是 CScale：[16, 1]、`U8`、`CUBE_M32`。函数 2 允许 CScale 且结果为 FP32，因此通过。

若改用 `TMATMUL`（函数 0），`c_scale_en` 会引发 `Fault_TileLegality`，因为函数 0 不允许 CScale；`ExecuteBundleTMATMULOperation` 在调用本遍历之前就拒绝它。

本示例只用于演示当前 ASL 所有者，不替代规范操作。

<!-- PTO-READER-BLOCK: tile-model-legality-matrix-operands-related role=related-owners-navigation -->
## 相关所有者

- [Matrix CUBE 主操作数](matrix-cube-primary.md) 负责 A、B 与 C 的描述符检查。
- [Matrix 函数](matrix-functions.md) 负责函数表、缩放载体与组计数。
- [Matrix 后处理](matrix-postprocess.md) 检查排在这些源之后的源。
- [CUBE TMATMUL 派发](../../../block/model/dispatch/cube-tmatmul.md) 调用此检查。
- [Matrix 缩放执行](../execution/matrix-scale.md) 应用 CScale 与 MX 缩放。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/legality/matrix-operands.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-LEGALITY-MATRIX-OPERANDS","surface":"tile","classification":["model","legality","matrix-operands"],"depends_on":["PTO-TILE-MODEL-LEGALITY-MATRIX-CUBE-PRIMARY","PTO-TILE-MODEL-LEGALITY-MATRIX-POSTPROCESS"]}
// PTO-REQ-CUBE-OPERANDS-001: every Local matrix source descriptor is checked
// in stream order before any Local or Shared payload is snapshotted.

readonly func TileMatrixLocalOperandSchemaLegal(
    source: TileIndex,
    valid_rows: integer {1..65535},
    valid_columns: integer {1..65535},
    data_type: TileDataType) => boolean
begin
    let tile = _Tiles[[source]];
    return TileElementwiseSourceContentsDefined(source) &&
           IsNonzeroPowerOfTwo(tile.rows) &&
           IsNonzeroPowerOfTwo(tile.columns) &&
           tile.valid_rows == valid_rows &&
           tile.valid_columns == valid_columns &&
           tile.data_type == data_type &&
           tile.layout == TileLayout_RowMajor;
end;

readonly func TileMatrixLocalAScaleSchemaLegal(
    source: TileIndex,
    valid_rows: integer {1..65535},
    valid_columns: integer {1..65535},
    primary_type: TileDataType) => boolean
begin
    let tile = _Tiles[[source]];
    return tile.contents_defined && TileCubeDescriptorLegal(tile) &&
           tile.valid_rows == valid_rows &&
           tile.valid_columns == valid_columns &&
           tile.data_type == TileMXScaleCarrierType(primary_type) &&
           tile.layout == TileLayout_CUBE_M32;
end;

readonly func TileMatrixLocalBScaleSchemaLegal(
    source: TileIndex,
    groups: integer {1..65535},
    n: integer {1..65535},
    primary_type: TileDataType) => boolean
begin
    let tile = _Tiles[[source]];
    return tile.contents_defined && TileCubeDescriptorLegal(tile) &&
           tile.valid_rows == n &&
           tile.valid_columns == groups &&
           tile.data_type == TileMXScaleCarrierType(primary_type) &&
           tile.layout == TileLayout_CUBE_M32;
end;

readonly func TileMatrixLocalBiasSchemaLegal(
    source: TileIndex,
    n: integer {1..65535},
    accumulator_type: TileDataType) => boolean
begin
    let tile = _Tiles[[source]];
    return tile.contents_defined && TileCubeDescriptorLegal(tile) &&
           tile.valid_rows == 1 &&
           tile.valid_columns == n &&
           tile.data_type == accumulator_type &&
           tile.layout == TileLayout_CUBE_N8;
end;

readonly func TileMatrixLocalCScaleSchemaLegal(
    source: TileIndex,
    m: integer {1..65535}) => boolean
begin
    let tile = _Tiles[[source]];
    return tile.contents_defined && TileCubeDescriptorLegal(tile) &&
           tile.valid_rows == m && tile.valid_columns == 1 &&
           tile.data_type == TileDataType_U8 &&
           tile.layout == TileLayout_CUBE_M32;
end;

readonly func TileMatrixInfoAccumulatorSchemaLegal(
    accumulator: TileIndex,
    m: integer {1..65535},
    n: integer {1..65535},
    result_type: TileDataType,
    destination_capacity: integer {0..262144}) => boolean
begin
    let tile = _Tiles[[accumulator]];
    let output_converted =
        UInt(_BundleFixedPointAttributes.pre_quant_mode) != 0;
    return TileSourceContentsDefined(accumulator) &&
           TileInfoDescriptorLegal(tile) &&
           tile.valid_rows == m &&
           tile.valid_columns == n &&
           tile.data_type == result_type &&
           (tile.layout == TileLayout_CUBE_M16 ||
            tile.layout == TileLayout_CUBE_M32) &&
           (output_converted ||
            tile.capacity_bytes == destination_capacity);
end;

readonly func BundleMatrixLocalMathematicalSourcesLegal(
    function: integer {0..31},
    left_type: TileDataType,
    right_type: TileDataType,
    m: integer {1..65535},
    n: integer {1..65535},
    k: integer {1..65535},
    shared_count: integer {0..4},
    accumulator_type: TileDataType,
    destination_capacity: integer {0..262144}) => boolean
begin
    let left_scale_present = TileMatrixFunctionUsesMX(function) &&
        TileMXInputTypeNeedsScale(left_type);
    let right_scale_present = TileMatrixFunctionUsesMX(function) &&
        TileMXInputTypeNeedsScale(right_type);
    let left_scale_groups = if left_scale_present then
        TileMXScaleGroupCount(k, left_type) else 1;
    let right_scale_groups = if right_scale_present then
        TileMXScaleGroupCount(k, right_type) else 1;
    var ordinal: integer {0..6} = 0;
    let right_group = TileMatrixRightGroupSourceCount(
        function, right_type);
    let local_left_present = shared_count == 0 ||
        shared_count == right_group;
    let left_ordinal = if TileMatrixFunctionUsesAccumulator(function)
        then 1 else 0;
    let local_m_layout = if local_left_present then
        _Tiles[[BundleMatrixSourceAt(
            left_ordinal as integer {0..8})]].layout
        else if TileMatrixFunctionUsesAccumulator(function) then
            _Tiles[[BundleMatrixSourceAt(0)]].layout
        else if m <= 16 then TileLayout_CUBE_M16
        else if m <= 32 then TileLayout_CUBE_M32
        // Defensive default only: no legal bias or accumulator bundle can
        // reach this fallback, because those schemas require the resolved
        // ML to be CUBE_M16/CUBE_M32.
        else TileLayout_RowMajor;

    if TileMatrixFunctionUsesAccumulator(function) then
        let accumulator = BundleMatrixSourceAt(
            ordinal as integer {0..8});
        let accumulator_legal = TileMatrixLocalCubeAccumulatorSchemaLegal(
            accumulator, m, n, accumulator_type,
            local_m_layout, destination_capacity);
        if !accumulator_legal then
            return FALSE;
        end;
        ordinal = (ordinal + 1) as integer {0..6};
    end;

    if shared_count == 0 || shared_count == right_group then
        let left = BundleMatrixSourceAt(
            ordinal as integer {0..8});
        let left_legal = TileMatrixLocalMOperandSchemaLegal(
            left, m, k, left_type);
        if !left_legal then
            return FALSE;
        end;
        ordinal = (ordinal + 1) as integer {0..6};
        if left_scale_present then
            let left_scale = BundleMatrixSourceAt(
                ordinal as integer {0..8});
            if !TileMatrixLocalAScaleSchemaLegal(
                   left_scale, m, left_scale_groups, left_type) then
                return FALSE;
            end;
            ordinal = (ordinal + 1) as integer {0..6};
        end;
    end;

    if shared_count == 0 then
        let right = BundleMatrixSourceAt(
            ordinal as integer {0..8});
        let right_legal = TileMatrixLocalNOperandSchemaLegal(
            right, k, n, right_type);
        if !right_legal then
            return FALSE;
        end;
        ordinal = (ordinal + 1) as integer {0..6};
        if right_scale_present then
            let right_scale = BundleMatrixSourceAt(
                ordinal as integer {0..8});
            if !TileMatrixLocalBScaleSchemaLegal(
                   right_scale, right_scale_groups, n, right_type) then
                return FALSE;
            end;
            ordinal = (ordinal + 1) as integer {0..6};
        end;
    end;

    if TileMatrixFunctionUsesBias(function) then
        let bias = BundleMatrixSourceAt(
            ordinal as integer {0..8});
        if !TileMatrixLocalBiasSchemaLegal(
               bias, n, accumulator_type) then
            return FALSE;
        end;
        ordinal = (ordinal + 1) as integer {0..6};
    end;

    if _BundleFixedPointAttributes.c_scale_en then
        let c_scale = BundleMatrixSourceAt(
            ordinal as integer {0..8});
        if !TileMatrixFunctionAllowsCScale(function) ||
           accumulator_type != TileDataType_FP32 ||
           !TileMatrixLocalCScaleSchemaLegal(c_scale, m) then
            return FALSE;
        end;
    end;
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: unit -->
