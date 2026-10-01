<!-- GENERATED FROM: asl/tile/model/execution/indexed-rearrangement.asl -->
# Indexed Rearrangement

**Normative ASL source:** `asl/tile/model/execution/indexed-rearrangement.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-EXECUTION-INDEXED-REARRANGEMENT}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-execution-indexed-rearrangement-purpose role=purpose-scope -->
## 用途与范围

本单元定义 Local Tile 存储内部两种由索引驱动的行移动。`TGATHER` 为每个目标元素读取由索引 Tile 选定的源行。`TSCATTER` 把每个源元素写入由索引 Tile 选定的目标行。两者的列都保持不变。

TGATHER 和 TSCATTER 指令在[索引重排合法性](../legality/indexed-rearrangement.md)中的操作数检查通过后调用这些辅助函数。

<!-- PTO-READER-BLOCK: tile-model-execution-indexed-rearrangement-concepts role=concepts-state -->
## 概念与可见状态

索引 Tile 的每个元素保存一个行选择子。`TileIndexedRowValue` 按索引类型（S16、U16、S32、U32、S64 或 U64）从低 16、32 或 64 位把它读为无符号整数。

数值以原始载体位移动。两个辅助函数都不做数值转换，也不会因为浮点编码特殊而拒绝某个值。

每个辅助函数在入口处复制源和索引的 `TileInfo` 记录，在局部副本中构建结果，并对 `_Tiles` 赋值一次。写入之前，它清除目标的 `defined_elements`、`packed_defined_elements`、`defined_valid_elements` 和 `contents_defined`。

<!-- PTO-READER-BLOCK: tile-model-execution-indexed-rearrangement-rules role=rules-interactions -->
## 规则与交互

`TGATHER` 访问每个有效目标坐标 (row, column)。在活动坐标处，它读取同一坐标处的索引，并复制源元素 (索引值, column)；非活动坐标取 ExecutionMask 值。它设置 `contents_defined` 和完整的有效区域计数，并以 `TilePad_Null` 填充，因此有效区域之外的物理元素为零且未定义。

`TSCATTER` 先向每个物理目标元素写入零，这同时把每个元素标记为已定义。然后它访问每个有效源坐标，把源元素写到目标 (索引值, column)。它把已定义计数设为有效区域大小，不调用填充辅助函数。

设计要点：每个索引都在任何写入之前检查。`TileGatherReferencesLegal` 拒绝负值、越界和未定义的源引用。`TileScatterReferencesLegal` 拒绝负值、越界和重复的目标坐标。错误索引产生故障，不会留下部分结果。

设计要点：重复的 scatter 目标是非法的，而不是按顺序处理。由于两个源元素不能指向同一目标元素，结果与访问顺序无关。

设计要点：`TSCATTER` 把整个物理目标填零。没有被任何索引选中的目标行读出为零，并且是已定义的。

<!-- PTO-READER-BLOCK: tile-model-execution-indexed-rearrangement-boundaries role=boundaries -->
## 架构边界

`TGATHER` 要求目标 Tile 和索引 Tile 具有相同的有效形状，且源的有效列数不少于目标。`TSCATTER` 要求源 Tile 和索引 Tile 具有相同的有效形状，且目标的有效列数与之相同。

`TGATHER` 对每个坐标测试 `BundleExecutionMaskActiveAt`，对非活动坐标使用 `BundleExecutionMaskDestinationValue`。`TSCATTER` 不查询掩码。[ExecutionMask 源 schema](../legality/execution-mask-source-schema.md)的 NDF 规定这两个操作都没有适用的 ExecutionMask 形式，其上的掩码载体必须在产生效果之前被拒绝。但可执行列表 `TileOperationExecutionMaskEligible` 仍然列出这两个操作，因此本页按原样描述 `TGATHER` 的非活动分支，而不声称它不可达。

两个辅助函数都以对其合法性谓词的 `assert` 开始，因此它们只描述已经通过该谓词的请求。

<!-- PTO-READER-BLOCK: tile-model-execution-indexed-rearrangement-example role=example-usage -->
## 非规范阅读示例

一个 `TGATHER` 源有 3 个有效行和 2 个有效列：第 0 行为 10、11；第 1 行为 20、21；第 2 行为 30、31。U32 索引 Tile 有 2 行 2 列：第 0 行为 2、0；第 1 行为 1、1。

1. 目标 (0, 0) 读取源 (2, 0)，即 30。
2. 目标 (0, 1) 读取源 (0, 1)，即 11。
3. 目标第 1 行读取源 (1, 0) 和 (1, 1)，即 20 和 21。

一个 `TSCATTER` 源第 0 行为 5、6，第 1 行为 7、8，索引行为 2、0 和 0、1。目标有 3 个有效行和 2 个有效列。第 0 列在第 2 行得到 5，在第 0 行得到 7。第 1 列在第 0 行得到 6，在第 1 行得到 8。结果各行依次为 7、6；0、8；5、0。

<!-- PTO-READER-BLOCK: tile-model-execution-indexed-rearrangement-related role=related-owners-navigation -->
## 相关所有者

- [TGATHER](../../irregular-and-complex/layout/TGATHER.md)和[TSCATTER](../../irregular-and-complex/layout/TSCATTER.md)拥有指令契约。
- [索引重排合法性](../legality/indexed-rearrangement.md)拥有索引解码和引用检查。
- [不规则与复杂操作分派](../dispatch/irregular-and-complex.md)命名包含 TGATHER 和 TSCATTER 的指令类别；它没有可执行 ASL。
- [元素已定义性](../definedness/elements.md)拥有填充和已定义性辅助函数。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/execution/indexed-rearrangement.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-EXECUTION-INDEXED-REARRANGEMENT","surface":"tile","classification":["model","execution","indexed-rearrangement"],"depends_on":["PTO-TILE-MODEL-LEGALITY-INDEXED-REARRANGEMENT","PTO-TILE-MODEL-EXECUTION-MASK-STATE"]}

func TGATHER(
    destination: TileIndex,
    source: TileIndex,
    indices: TileIndex)
begin
    let zero_packed_tile_elements = ZeroPackedTileDefinedElements();
    assert TileOperandsLegal_TGATHER(destination, source, indices);
    let source_tile = _Tiles[[source]];
    let index_tile = _Tiles[[indices]];
    var result = _Tiles[[destination]];
    result.contents_defined = FALSE;
    result.defined_elements = Zeros{PTO_MODEL_TILE_ELEMENTS};
    result.defined_valid_elements = 0;
    result.packed_defined_elements = zero_packed_tile_elements;
    for row = 0 to result.valid_rows - 1 looplimit 65536 do
        for column = 0 to result.valid_columns - 1 looplimit 65536 do
            let destination_element = TileLogicalLinearIndex(
                result,
                row as integer {0..65535},
                column as integer {0..65535});
            if BundleExecutionMaskActiveAt(
                   result.layout, row as integer {0..65535},
                   column as integer {0..65535}) then
                let index_element = TileLogicalLinearIndex(
                    index_tile, row as integer {0..65535},
                    column as integer {0..65535});
                let source_row = TileIndexedRowValue(
                    TileReadLogicalElement(index_tile, index_element),
                    index_tile.data_type);
                let source_element = TileLogicalLinearIndex(
                    source_tile, source_row as integer {0..65535},
                    column as integer {0..65535});
                result = TileInfoWithLogicalElementAndDefined(
                    result, destination_element,
                    TileReadLogicalElement(source_tile, source_element), TRUE);
            else
                result = TileInfoWithLogicalElementAndDefined(
                    result, destination_element,
                    BundleExecutionMaskDestinationValue(
                        result.layout, row as integer {0..65535},
                        column as integer {0..65535}, Zeros{PTO_XLEN}), TRUE);
            end;
        end;
    end;
    result.defined_valid_elements =
        (result.valid_rows * result.valid_columns)
            as integer {0..524288};
    result.contents_defined = TRUE;
    result = TileWithPadding(result, TilePad_Null);
    _Tiles[[destination]] = result;
end;

func TSCATTER(
    destination: TileIndex,
    source: TileIndex,
    indices: TileIndex)
begin
    let zero_packed_tile_elements = ZeroPackedTileDefinedElements();
    assert TileOperandsLegal_TSCATTER(destination, source, indices);
    let source_tile = _Tiles[[source]];
    let index_tile = _Tiles[[indices]];
    var result = _Tiles[[destination]];
    result.contents_defined = FALSE;
    result.defined_elements = Zeros{PTO_MODEL_TILE_ELEMENTS};
    result.defined_valid_elements = 0;
    result.packed_defined_elements = zero_packed_tile_elements;
    for row = 0 to result.rows - 1 looplimit 65536 do
        for column = 0 to result.columns - 1 looplimit 65536 do
            let destination_element = TileLogicalLinearIndex(
                result,
                row as integer {0..65535},
                column as integer {0..65535});
            result = TileInfoWithLogicalElement(result, destination_element,
                Zeros{PTO_XLEN});
        end;
    end;
    for row = 0 to source_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to source_tile.valid_columns - 1 looplimit 65536 do
            let source_element = TileLogicalLinearIndex(
                source_tile,
                row as integer {0..65535},
                column as integer {0..65535});
            let index_element = TileLogicalLinearIndex(
                index_tile,
                row as integer {0..65535},
                column as integer {0..65535});
            let destination_row = TileIndexedRowValue(
                TileReadLogicalElement(index_tile, index_element),
                index_tile.data_type);
            let destination_element = TileLogicalLinearIndex(
                result,
                destination_row as integer {0..65535},
                column as integer {0..65535});
            result = TileInfoWithLogicalElement(result, destination_element,
                TileReadLogicalElement(source_tile, source_element));
        end;
    end;
    result.defined_valid_elements =
        (result.valid_rows * result.valid_columns)
            as integer {0..524288};
    result.contents_defined = TRUE;
    _Tiles[[destination]] = result;
end;
```
<!-- GENERATED-ASL-END: unit -->
