<!-- GENERATED FROM: asl/tile/model/legality/execution-mask-source-schema.asl -->
# Execution Mask Source Schema

**Normative ASL source:** `asl/tile/model/legality/execution-mask-source-schema.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-LEGALITY-EXECUTION-MASK-SOURCE-SCHEMA}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-legality-execution-mask-source-schema-purpose role=purpose-scope -->
## 用途与范围

本单元定义逐元素及相关 Tile 操作在可能存在 ExecutionMask 时使用的源端检查。ExecutionMask 是一个按指令束生效的载体，它把有效区域中的每个坐标标记为活动或非活动。

- `TileElementwiseSourceContentsDefined` 检查源描述符及其已定义性。
- `TileElementwiseSourceEncodingsValidAs` 还按所选操作类型检查元素编码。
- `TileElementwiseSourceEncodingsValid` 按源自身存储的类型检查编码。

本单元还包含 NDF 条款 `PTO-TILE-MODEL-EXECUTION-MASK-APPLICABILITY-001`，它限制 ExecutionMask 可以适用的范围。

<!-- PTO-READER-BLOCK: tile-model-legality-execution-mask-source-schema-concepts role=concepts-state -->
## 概念与可见状态

这些谓词读取 `_Tiles`、逐元素已定义性和 `_BundleExecutionMask`。它们不写任何状态，自身也不引发故障。

当 `TileNumericEncodingValid` 接受某个编码的位时，该编码有效。该函数只对 TF32、HF32、E3M2 与 E2M3 有实际检查，要求某些低位或高位为零。对其他所有类型它返回 TRUE。

NDF 条款规定，ExecutionMask 只适用于操作本已合法的 Local CUBE_M16 或 CUBE_M32 形式，且不增加布局支持。在 92 个已分类助记符中，89 个具有这种形式。TGATHER、TSCATTER 与 TTRI 没有这种形式，其上的 ExecutionMask 载体必须在产生效果之前被拒绝。

<!-- PTO-READER-BLOCK: tile-model-legality-execution-mask-source-schema-rules role=rules-interactions -->
## 规则与交互

`TileElementwiseSourceContentsDefined` 首先检查描述符。CUBE 布局的源必须通过 `TileCubeDescriptorLegal`；其他源必须通过 `TileDescriptorLegal`。然后：

- 没有 ExecutionMask 时，它返回整个 Tile 的 `contents_defined` 标志。
- 有 ExecutionMask 时，源的布局、`valid_rows` 与 `valid_columns` 必须与掩码相同。随后每个活动坐标都必须已定义。

设计要点：在 ExecutionMask 下，只有活动坐标必须已定义。非活动坐标从未写入的源仍然合法，因为计算结果时不读取这些坐标。此时不要求整个 Tile 的标志。

设计要点：掩码与源必须在布局和有效区域上完全一致。掩码查找函数 `BundleExecutionMaskCoordinateBit` 断言布局与掩码布局相同，且行与列位于掩码的有效区域之内；完全一致检查保证本单元访问的每个坐标都满足这些条件，并拒绝任何其他形状，而不是重新解释它。

`TileElementwiseSourceEncodingsValidAs` 要求 `TileElementwiseSourceContentsDefined`，并要求存储类型与操作类型之间满足 `TileCarrierWidthCompatible`。随后它按操作类型检查每个活动有效元素的编码（没有掩码时检查每个有效元素）。`TileElementwiseSourceEncodingsValid` 按存储类型做同样的检查，且没有位宽检查。

合法性谓词在操作读取源快照或写入目标载荷之前调用这些函数。此类谓词返回 FALSE 时，操作被拒绝，指令束已分配的目标会被回滚。部分执行函数（例如 TMOV 与 TSTORE）也会断言这些函数。

<!-- PTO-READER-BLOCK: tile-model-legality-execution-mask-source-schema-boundaries role=boundaries -->
## 架构边界

调用者例如包括 `TileOperandsLegal_ExecuteTileBinary` 及操作数 schema中的其他检查、`TileOperandsLegal_TFMA`、比较与 Tile-标量分派 schema、EXPDIF 操作数检查，以及 load-store 与 Shared 搬运单元。

编码检查不是数值支持检查。`TileNumericEncodingValid` 对 FP32、FP16、整数及大多数其他类型返回 TRUE。之后计算结果的数值函数是否支持该类型，由独立的类型谓词和该函数自身决定。

`TileCubeDescriptorLegal` 把 CUBE_N8 当作 CUBE 布局接受，但 NDF 条款把 ExecutionMask 的使用限制在 CUBE_M16 与 CUBE_M32 形式上。掩码对具体操作的适用性（包括 Local CUBE_M16 或 CUBE_M32 要求）由指令束分派中的 `BundleExecutionMaskDataAttributesLegal` 强制，而不是由本单元强制。

<!-- PTO-READER-BLOCK: tile-model-legality-execution-mask-source-schema-example role=example-usage -->
## 非规范阅读示例

取一个 FP32 CUBE_M16 源，有效区域为 16 乘 8；另有一个布局和有效区域相同的 ExecutionMask，它激活 128 个坐标中的 100 个。

- 描述符通过 `TileCubeDescriptorLegal`。
- 布局与有效区域与掩码一致。
- 只有 100 个活动元素必须已定义；其余 28 个可以未定义。
- 以 FP32 调用 `TileElementwiseSourceEncodingsValidAs` 会检查 100 个编码，每个都通过，因为 FP32 没有编码限制。

若源的有效区域为 16 乘 4，形状比较会失败，操作会被拒绝。

<!-- PTO-READER-BLOCK: tile-model-legality-execution-mask-source-schema-related role=related-owners-navigation -->
## 相关所有者

- [ExecutionMask 状态](../execution/execution-mask-state.md) 负责活动坐标查找。
- [描述符形状](descriptor-shape.md) 负责首先使用的描述符谓词。
- [数据类型与布局](dtype-layout.md) 负责 `TileCarrierWidthCompatible`。
- [操作数 schema](operand-schema.md) 是逐元素操作的主要调用者。
- [ExecutionMask schema](../../../block/model/dispatch/execution-mask-schema.md) 译码指令束 ExecutionMask 载体。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/legality/execution-mask-source-schema.asl -->
```asl
// NDF-BEGIN: PTO-TILE-MODEL-EXECUTION-MASK-APPLICABILITY-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// ExecutionMask MUST apply only to an operation's already-legal Local CUBE_M16 or CUBE_M32 forms and MUST NOT add layout support. Of the 92 semantically classified mnemonics, 89 have an applicable baseline CUBE form; TGATHER and TSCATTER have none under their indexed-operation schemas, and TTRI is RowMajor-only. Any ExecutionMask carrier on those forms MUST reject before operation effects. These three names remain classified with zero applicable forms and retain their existing unpredicated behavior. TEXPDIF is included in the applicable intersection.
// NDF-END: PTO-TILE-MODEL-EXECUTION-MASK-APPLICABILITY-001
// PTO-UNIT: {"id":"PTO-TILE-MODEL-LEGALITY-EXECUTION-MASK-SOURCE-SCHEMA","surface":"tile","classification":["model","legality","execution-mask-source-schema"],"depends_on":["PTO-TILE-MODEL-DEFINEDNESS-ELEMENTS","PTO-TILE-MODEL-EXECUTION-MASK-STATE","PTO-TILE-MODEL-LEGALITY-DESCRIPTOR-SHAPE","PTO-TILE-MODEL-LEGALITY-DTYPE-LAYOUT","PTO-TILE-MODEL-SHAPE-CUBE-CELL"]}
readonly func TileElementwiseSourceContentsDefined(index: TileIndex)
    => boolean
begin
    let tile = _Tiles[[index]];
    if TileLayoutIsCube(tile.layout) then
        if !TileCubeDescriptorLegal(tile) then return FALSE; end;
    elsif !TileDescriptorLegal(index) then
        return FALSE;
    end;
    if !_BundleExecutionMask.valid then return tile.contents_defined; end;
    if tile.layout != _BundleExecutionMask.layout ||
       tile.valid_rows != _BundleExecutionMask.valid_rows ||
       tile.valid_columns != _BundleExecutionMask.valid_columns then
        return FALSE;
    end;
    for row = 0 to tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to tile.valid_columns - 1 looplimit 65536 do
            if BundleExecutionMaskActiveAt(
                   tile.layout, row as integer {0..65535},
                   column as integer {0..65535}) &&
               !TileElementDefined(index, row as integer {0..65535},
                   column as integer {0..65535}) then
                return FALSE;
            end;
        end;
    end;
    return TRUE;
end;

readonly func TileElementwiseSourceEncodingsValidAs(
    index: TileIndex, operation_type: TileDataType) => boolean
begin
    if !TileElementwiseSourceContentsDefined(index) ||
       !TileCarrierWidthCompatible(
           _Tiles[[index]].data_type, operation_type) then
        return FALSE;
    end;
    let tile = _Tiles[[index]];
    for row = 0 to tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to tile.valid_columns - 1 looplimit 65536 do
            if !_BundleExecutionMask.valid ||
               BundleExecutionMaskActiveAt(
                   tile.layout, row as integer {0..65535},
                   column as integer {0..65535}) then
                let element = TileLogicalLinearIndex(tile,
                    row as integer {0..65535},
                    column as integer {0..65535});
                if !TileNumericEncodingValid(
                       operation_type,
                       TileReadLogicalElement(tile, element)) then
                    return FALSE;
                end;
            end;
        end;
    end;
    return TRUE;
end;

readonly func TileElementwiseSourceEncodingsValid(index: TileIndex)
    => boolean
begin
    if !TileElementwiseSourceContentsDefined(index) then return FALSE; end;
    let tile = _Tiles[[index]];
    for row = 0 to tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to tile.valid_columns - 1 looplimit 65536 do
            if !_BundleExecutionMask.valid ||
               BundleExecutionMaskActiveAt(
                   tile.layout, row as integer {0..65535},
                   column as integer {0..65535}) then
                let element = TileLogicalLinearIndex(tile,
                    row as integer {0..65535},
                    column as integer {0..65535});
                if !TileNumericEncodingValid(
                       tile.data_type,
                       TileReadLogicalElement(tile, element)) then
                    return FALSE;
                end;
            end;
        end;
    end;
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: unit -->
