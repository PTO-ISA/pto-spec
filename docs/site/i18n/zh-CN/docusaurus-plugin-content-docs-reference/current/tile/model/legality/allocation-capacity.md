<!-- GENERATED FROM: asl/tile/model/legality/allocation-capacity.asl -->
# Allocation Capacity

**Normative ASL source:** `asl/tile/model/legality/allocation-capacity.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-LEGALITY-ALLOCATION-CAPACITY}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-legality-allocation-capacity-purpose role=purpose-scope -->
## 用途与范围

尽管名称如此，本单元并不检查分配容量。它定义四个只读的载荷谓词。每个谓词在预检期间检查源元素的值，并在某个值会使操作非法时返回 FALSE。预检是在操作读取快照或写入任何内容之前运行的检查阶段。

- `TilePayloadNonzero` 检查除数 Tile 中没有零元素。
- `TileBroadcastPayloadNonzero` 检查按行或按列广播的除数。
- `TileIndexPayloadWithin` 检查元素索引小于某个范围。
- `TileByteOffsetPayloadWithin` 检查字节偏移已对齐且在范围内。

<!-- PTO-READER-BLOCK: tile-model-legality-allocation-capacity-concepts role=concepts-state -->
## 概念与可见状态

这些谓词读取 `_Tiles`、元素已定义性状态，`TilePayloadNonzero` 还读取指令束 ExecutionMask `_BundleExecutionMask`。ExecutionMask 是一个按指令束生效的载体，它把有效区域中的每个坐标标记为活动或非活动。

它们遍历有效区域，即 `valid_rows` 乘 `valid_columns`。有效区域之外的元素不会被读取。

当 `IsZero` 对元素的原始位成立时，该元素被视为零。索引与偏移检查用 `UInt` 把每个元素当作无符号整数。

<!-- PTO-READER-BLOCK: tile-model-legality-allocation-capacity-rules role=rules-interactions -->
## 规则与交互

`TilePayloadNonzero` 有两种模式。

- 没有 ExecutionMask 时，源必须满足 `TileSourceContentsDefined`，且每个有效元素都必须已定义且非零。由于 `TileDescriptorLegal` 拒绝 CUBE 布局，CUBE 除数在此分支中总是失败。
- 有 ExecutionMask 时，源必须通过 `TileCubeDescriptorLegal`，并与掩码的布局、`valid_rows` 和 `valid_columns` 一致。随后只检查活动坐标；每个活动坐标都必须已定义且非零。

设计要点：在 ExecutionMask 下，零值检查跳过非活动坐标。除数可以在掩码禁用的坐标上含有零，因为该坐标从不参与除法。非 CUBE 源无法通过 ExecutionMask 分支，因为 `TileCubeDescriptorLegal` 要求 CUBE 布局。

当操作为 `TileBinary_DIV` 或 `TileBinary_REM` 且操作类型为整数类型时，`TileOperandsLegal_ExecuteTileBinary` 对右源调用 `TilePayloadNonzero`。`TDIV` 与 `TREM` 会走到这条路径。结果为 FALSE 时，生成的分派器在 `ExecuteTileBinary` 获取源快照或写入目标之前引发 `Fault_TileLegality`；指令束已分配的目标会被回滚。

设计要点：整数除法辅助函数 `TileIntegerDivRemValue` 断言除数非零，因此零除数必须由合法性检查拒绝，而不能进入执行。浮点类型跳过此检查；浮点零除数由浮点数值辅助函数处理。被拒绝的 `TDIV` 不会留下新的目标分配，因为指令束会将其回滚。

`TileIndexPayloadWithin` 要求内容已定义，且每个有效元素都小于 `extent`。`TileByteOffsetPayloadWithin` 要求每个偏移都是源元素大小的倍数，并且除以该大小后小于源的 `valid_rows` x `valid_columns`。`TileBroadcastPayloadNonzero` 要求两个 Tile 都已定义，对按行广播读取广播 Tile 的第 0 列，对按列广播读取其第 0 行。

<!-- PTO-READER-BLOCK: tile-model-legality-allocation-capacity-boundaries role=boundaries -->
## 架构边界

在 `asl/` 中 grep 找不到 `TileBroadcastPayloadNonzero`、`TileIndexPayloadWithin` 或 `TileByteOffsetPayloadWithin` 的调用者。它们在此定义，但目前不约束任何指令。

这些谓词自身不引发故障。故障由调用者选择。它们也不检查分配容量或 PE 池；这些属于 Local 容量单元。

<!-- PTO-READER-BLOCK: tile-model-legality-allocation-capacity-example role=example-usage -->
## 非规范阅读示例

考虑使用 S32 的 `TDIV`，其除数 Tile 的有效区域为 2 行 3 列，第 0 行的值为 `4 7 0`，第 1 行为 `1 2 3`。

- 不存在 ExecutionMask，因此检查全部 6 个有效元素。
- 第 0 行第 2 列为 0，因此 `TilePayloadNonzero` 返回 FALSE。
- 指令束以 `Fault_TileLegality` 被拒绝；目标从未被写入，其分配被回滚。

若在 CUBE 形式上由 ExecutionMask 使该坐标变为非活动，则只检查 5 个活动元素，检查会通过。

<!-- PTO-READER-BLOCK: tile-model-legality-allocation-capacity-related role=related-owners-navigation -->
## 相关所有者

- [操作数 schema](operand-schema.md) 为整数 `TDIV` 与 `TREM` 调用 `TilePayloadNonzero`。
- [描述符形状](descriptor-shape.md) 负责 `TileSourceContentsDefined` 与 `TileCubeDescriptorLegal`。
- [ExecutionMask 状态](../execution/execution-mask-state.md) 负责活动坐标检查。
- [元素已定义性](../definedness/elements.md) 负责 `TileElementDefined` 与逻辑索引。
- [Local 容量](../capacity/local.md) 负责实际的容量检查。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/legality/allocation-capacity.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-LEGALITY-ALLOCATION-CAPACITY","surface":"tile","classification":["model","legality","allocation-capacity"],"depends_on":["PTO-TILE-MODEL-EXECUTION-MASK-STATE","PTO-TILE-MODEL-LEGALITY-DTYPE-LAYOUT","PTO-TILE-MODEL-LEGALITY-EXECUTION-MASK-SOURCE-SCHEMA"]}
readonly func TilePayloadNonzero(index: TileIndex) => boolean
begin
    let tile = _Tiles[[index]];
    if !_BundleExecutionMask.valid then
        if !TileElementwiseSourceContentsDefined(index) then return FALSE; end;
    elsif !TileCubeDescriptorLegal(tile) ||
          tile.layout != _BundleExecutionMask.layout ||
          tile.valid_rows != _BundleExecutionMask.valid_rows ||
          tile.valid_columns != _BundleExecutionMask.valid_columns then
        return FALSE;
    end;
    for row = 0 to tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to tile.valid_columns - 1 looplimit 65536 do
            if !_BundleExecutionMask.valid ||
               BundleExecutionMaskActiveAt(
                   tile.layout, row as integer {0..65535},
                   column as integer {0..65535}) then
                if !TileElementDefined(index, row as integer {0..65535},
                       column as integer {0..65535}) then
                    return FALSE;
                end;
                let element = TileLogicalLinearIndex(tile,
                    row as integer {0..65535},
                    column as integer {0..65535});
                if IsZero(TileReadLogicalElement(tile, element)) then
                    return FALSE;
                end;
            end;
        end;
    end;
    return TRUE;
end;

readonly func TileBroadcastPayloadNonzero(axis: TileAxis, source: TileIndex,
                                           broadcast: TileIndex) => boolean
begin
    if !TileSourceContentsDefined(source) ||
       !TileSourceContentsDefined(broadcast) then
        return FALSE;
    end;
    let source_tile = _Tiles[[source]];
    let broadcast_tile = _Tiles[[broadcast]];
    for row = 0 to source_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to source_tile.valid_columns - 1 looplimit 65536 do
            let broadcast_row = if axis == TileAxis_Row then row else 0;
            let broadcast_column = if axis == TileAxis_Row then 0 else column;
            let element = TileLogicalLinearIndex(broadcast_tile,
                broadcast_row as integer {0..65535},
                broadcast_column as integer {0..65535});
            if IsZero(TileReadLogicalElement(broadcast_tile, element)) then
                return FALSE;
            end;
        end;
    end;
    return TRUE;
end;

readonly func TileIndexPayloadWithin(index: TileIndex, extent: integer) => boolean
begin
    if !TileSourceContentsDefined(index) then return FALSE; end;
    let tile = _Tiles[[index]];
    for row = 0 to tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to tile.valid_columns - 1 looplimit 65536 do
            let element = TileLogicalLinearIndex(tile,
                row as integer {0..65535},
                column as integer {0..65535});
            if UInt(TileReadLogicalElement(tile, element)) >= extent then
                return FALSE;
            end;
        end;
    end;
    return TRUE;
end;

readonly func TileByteOffsetPayloadWithin(offsets: TileIndex,
                                           source: TileIndex) => boolean
begin
    if !TileSourceContentsDefined(offsets) ||
       !TileSourceContentsDefined(source) then
        return FALSE;
    end;
    let offsets_tile = _Tiles[[offsets]];
    let element_bytes = TileElementBytes(_Tiles[[source]].data_type);
    let source_extent: integer =
        _Tiles[[source]].valid_rows * _Tiles[[source]].valid_columns;
    for row = 0 to offsets_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to offsets_tile.valid_columns - 1 looplimit 65536 do
            let element = TileLogicalLinearIndex(offsets_tile,
                row as integer {0..65535}, column as integer {0..65535});
            let byte_offset = UInt(TileReadLogicalElement(
                offsets_tile, element));
            if byte_offset MOD element_bytes != 0 ||
               byte_offset DIV element_bytes >= source_extent then
                return FALSE;
            end;
        end;
    end;
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: unit -->
