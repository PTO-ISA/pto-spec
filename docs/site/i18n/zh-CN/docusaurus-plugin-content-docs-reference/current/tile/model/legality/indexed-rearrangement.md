<!-- GENERATED FROM: asl/tile/model/legality/indexed-rearrangement.asl -->
# Indexed Rearrangement

**Normative ASL source:** `asl/tile/model/legality/indexed-rearrangement.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-LEGALITY-INDEXED-REARRANGEMENT}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-legality-indexed-rearrangement-purpose role=purpose-scope -->
## 用途与范围

本单元包含两条按行索引的 Tile 指令 `TGATHER` 与 `TSCATTER` 的操作数合法性谓词。`TileOperandsLegal_TGATHER` 与 `TileOperandsLegal_TSCATTER` 是这两条指令的 `legality_handler` 条目，索引重排执行单元中的执行函数在构造目标之前断言它们。

本单元还定义类型规则（`InstructionContractValueDataTypeLegal_TGATHER`、`InstructionContractIndexDataTypeLegal_TGATHER`、`InstructionContractTypePairLegal_TSCATTER`）以及索引译码函数 `TileIndexedRowIsNegative` 与 `TileIndexedRowValue`。执行过程复用 `TileIndexedRowValue` 来确定所选行。

每个谓词都是只读的，并对非法操作数组合返回 FALSE，因此拒绝发生在预检阶段，早于写入任何目标元素。

<!-- PTO-READER-BLOCK: tile-model-legality-indexed-rearrangement-concepts role=concepts-state -->
## 概念与可见状态

索引 Tile 在每个坐标上保存一个行选择值。列从不改变：`TGATHER` 读取 `source[index[r,c], c]`，`TSCATTER` 写入 `destination[index[r,c], c]`。

- 值类型：任何非打包四位类型（`IndexedTLSUTransferDataTypeLegal`）。目标类型必须等于值源类型。
- 索引类型：S16、U16、S32、U32、S64 或 U64。
- 索引译码：有符号索引先检查是否为负值。随后行号取低 16、32 或 64 位的无符号值。

三个操作数都必须通过 `TileDescriptorLegal` 并且是 Numeric Tile。`TileDescriptorLegal` 要求通用索引，而通用索引排除 CUBE 布局，因此这些谓词拒绝 CUBE 布局的操作数。

<!-- PTO-READER-BLOCK: tile-model-legality-indexed-rearrangement-rules role=rules-interactions -->
## 规则与交互

`TileOperandsLegal_TGATHER` 要求：

- 目标有效形状非零，且等于索引有效形状；
- 源有效列数不小于目标有效列数；
- 索引 Tile 在 `TileElementwiseSourceContentsDefined` 与 `TileElementwiseSourceEncodingsValid` 的 ExecutionMask 规则下已定义且编码有效；
- 对每个活动索引坐标，索引不为负，行号小于源有效行数，且该行该列的源元素已定义。

设计要点：源的有效列数可以多于目标，但不能更少。索引保持列不变，因此每个目标列都必须在源中存在。

`TileOperandsLegal_TSCATTER` 要求：

- 源有效形状非零，且等于索引有效形状；
- 目标有效行数非零，目标有效列数等于源有效列数；
- 源与索引 Tile 的内容已定义（`TileSourceContentsDefined`），且索引 Tile 的编码有效；
- 对每个索引坐标，索引不为负，行号小于目标有效行数，且该目标元素没有被其他坐标选中。

设计要点：`TileScatterReferencesLegal` 在位图中记录每个被选中的目标元素，并拒绝第二次选择。每个目标元素最多被写入一次，因此结果不依赖处理源坐标的顺序。

<!-- PTO-READER-BLOCK: tile-model-legality-indexed-rearrangement-boundaries role=boundaries -->
## 架构边界

只有 `TGATHER` 的引用检查会查询 ExecutionMask；它跳过非活动的索引坐标。`TSCATTER` 的引用检查与重复检查访问每个索引坐标。

两个谓词都不检查值元素的数值编码。只检查索引 Tile 的编码。执行过程原样复制值的位，不对其运行任何数值辅助函数。

这些谓词不检查容量、`PE_MASK` 或指令束绑定结构。这些检查由指令束分派负责。

<!-- PTO-READER-BLOCK: tile-model-legality-indexed-rearrangement-example role=example-usage -->
## 非规范阅读示例

考虑值类型为 U16、索引类型为 U16 的 `TGATHER`。源的有效形状为 4 行 2 列。目标与索引的有效形状为 2 乘 2，索引各行为 `[3, 0]` 与 `[1, 1]`。

- 目标 `[0,0]` 读取源 `[3,0]`；目标 `[0,1]` 读取源 `[0,1]`。
- 目标 `[1,0]` 读取源 `[1,0]`；目标 `[1,1]` 读取源 `[1,1]`。
- 任何位置出现索引 4 都使谓词为 FALSE，因为源只有 4 个有效行。

对 `TSCATTER`，若索引第 0 列的值为 `[2, 2]`，两个源元素都会送往目标 `[2,0]`，因此该操作数组合被拒绝。

<!-- PTO-READER-BLOCK: tile-model-legality-indexed-rearrangement-related role=related-owners-navigation -->
## 相关所有者

- [索引重排执行](../execution/indexed-rearrangement.md) 在这些检查之后构造目标。
- [ExecutionMask 源 schema](execution-mask-source-schema.md) 拥有带掩码的索引已定义性与编码检查。
- [描述符形状](descriptor-shape.md) 拥有 `TileDescriptorLegal` 与 `TileSourceContentsDefined`。
- [元素已定义性](../definedness/elements.md) 拥有 `IndexedTLSUTransferDataTypeLegal`。
- [TGATHER](../../irregular-and-complex/layout/TGATHER.md) 与 [TSCATTER](../../irregular-and-complex/layout/TSCATTER.md) 是指令页面。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/legality/indexed-rearrangement.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-LEGALITY-INDEXED-REARRANGEMENT","surface":"tile","classification":["model","legality","indexed-rearrangement"],"depends_on":["PTO-TILE-MODEL-LEGALITY-DTYPE-LAYOUT","PTO-TILE-MODEL-EXECUTION-MASK-STATE","PTO-TILE-MODEL-LEGALITY-EXECUTION-MASK-SOURCE-SCHEMA"]}

pure func InstructionContractValueDataTypeLegal_TGATHER(
    data_type: TileDataType) => boolean
begin
    return IndexedTLSUTransferDataTypeLegal(data_type);
end;

pure func InstructionContractIndexDataTypeLegal_TGATHER(
    data_type: TileDataType) => boolean
begin
    return data_type == TileDataType_S32 ||
           data_type == TileDataType_U32 ||
           data_type == TileDataType_S16 ||
           data_type == TileDataType_U16 ||
           data_type == TileDataType_S64 ||
           data_type == TileDataType_U64;
end;

pure func InstructionContractTypePairLegal_TSCATTER(
    value_type: TileDataType,
    index_type: TileDataType) => boolean
begin
    return IndexedTLSUTransferDataTypeLegal(value_type) &&
           (index_type == TileDataType_S16 ||
            index_type == TileDataType_U16 ||
            index_type == TileDataType_S32 ||
            index_type == TileDataType_U32 ||
            index_type == TileDataType_S64 ||
            index_type == TileDataType_U64);
end;

pure func TileIndexedRowIsNegative(
    value: Word,
    data_type: TileDataType) => boolean
begin
    if data_type == TileDataType_S16 then
        return SInt(value[15:0]) < 0;
    end;
    if data_type == TileDataType_S32 then
        return SInt(value[31:0]) < 0;
    end;
    if data_type == TileDataType_S64 then
        return SInt(value[63:0]) < 0;
    end;
    return FALSE;
end;

pure func TileIndexedRowValue(
    value: Word,
    data_type: TileDataType) => integer
begin
    if data_type == TileDataType_S16 ||
       data_type == TileDataType_U16 then
        return UInt(value[15:0]);
    end;
    if data_type == TileDataType_S32 ||
       data_type == TileDataType_U32 then
        return UInt(value[31:0]);
    end;
    assert data_type == TileDataType_S64 ||
           data_type == TileDataType_U64;
    return UInt(value[63:0]);
end;

readonly func TileGatherReferencesLegal(
    source: TileIndex,
    indices: TileIndex) => boolean
begin
    let source_tile = _Tiles[[source]];
    let index_tile = _Tiles[[indices]];
    for row = 0 to index_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to index_tile.valid_columns - 1 looplimit 65536 do
            if BundleExecutionMaskActiveAt(
                   index_tile.layout, row as integer {0..65535},
                   column as integer {0..65535}) then
            let index_element = TileLogicalLinearIndex(
                index_tile,
                row as integer {0..65535},
                column as integer {0..65535});
            let raw_index = TileReadLogicalElement(index_tile, index_element);
            if TileIndexedRowIsNegative(raw_index, index_tile.data_type) then
                return FALSE;
            end;
            let source_row = TileIndexedRowValue(
                raw_index,
                index_tile.data_type);
            if source_row >= source_tile.valid_rows then
                return FALSE;
            end;
            let source_element = TileLogicalLinearIndex(
                source_tile,
                source_row as integer {0..65535},
                column as integer {0..65535});
            if !TileLogicalElementDefined(source_tile, source_element) then
                return FALSE;
            end;
            end;
        end;
    end;
    return TRUE;
end;

readonly func TileScatterReferencesLegal(
    destination: TileIndex,
    indices: TileIndex) => boolean
begin
    let destination_tile = _Tiles[[destination]];
    let index_tile = _Tiles[[indices]];
    var selected = Zeros{524288};
    for row = 0 to index_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to index_tile.valid_columns - 1 looplimit 65536 do
            let index_element = TileLogicalLinearIndex(
                index_tile,
                row as integer {0..65535},
                column as integer {0..65535});
            let raw_index = TileReadLogicalElement(index_tile, index_element);
            if TileIndexedRowIsNegative(raw_index, index_tile.data_type) then
                return FALSE;
            end;
            let destination_row = TileIndexedRowValue(
                raw_index,
                index_tile.data_type);
            if destination_row >= destination_tile.valid_rows then
                return FALSE;
            end;
            let destination_element = TileLogicalLinearIndex(
                destination_tile,
                destination_row as integer {0..65535},
                column as integer {0..65535});
            if selected[destination_element] == '1' then
                return FALSE;
            end;
            selected[destination_element] = '1';
        end;
    end;
    return TRUE;
end;

readonly func TileOperandsLegal_TGATHER(
    destination: TileIndex,
    source: TileIndex,
    indices: TileIndex) => boolean
begin
    if !TileDescriptorLegal(destination) ||
       !TileDescriptorLegal(source) ||
       !TileDescriptorLegal(indices) then
        return FALSE;
    end;
    let destination_tile = _Tiles[[destination]];
    let source_tile = _Tiles[[source]];
    let index_tile = _Tiles[[indices]];
    if destination_tile.storage_kind != TileStorage_Numeric ||
       source_tile.storage_kind != TileStorage_Numeric ||
       index_tile.storage_kind != TileStorage_Numeric ||
       !InstructionContractValueDataTypeLegal_TGATHER(
           source_tile.data_type) ||
       !InstructionContractIndexDataTypeLegal_TGATHER(
           index_tile.data_type) ||
       destination_tile.data_type != source_tile.data_type ||
       destination_tile.valid_rows == 0 ||
       destination_tile.valid_columns == 0 ||
       destination_tile.valid_rows != index_tile.valid_rows ||
       destination_tile.valid_columns != index_tile.valid_columns ||
       source_tile.valid_columns < destination_tile.valid_columns ||
       !TileElementwiseSourceContentsDefined(indices) ||
       !TileElementwiseSourceEncodingsValid(indices) then
        return FALSE;
    end;
    return TileGatherReferencesLegal(source, indices);
end;

readonly func TileOperandsLegal_TSCATTER(
    destination: TileIndex,
    source: TileIndex,
    indices: TileIndex) => boolean
begin
    if !TileDescriptorLegal(destination) ||
       !TileDescriptorLegal(source) ||
       !TileDescriptorLegal(indices) then
        return FALSE;
    end;
    let destination_tile = _Tiles[[destination]];
    let source_tile = _Tiles[[source]];
    let index_tile = _Tiles[[indices]];
    if destination_tile.storage_kind != TileStorage_Numeric ||
       source_tile.storage_kind != TileStorage_Numeric ||
       index_tile.storage_kind != TileStorage_Numeric ||
       destination_tile.data_type != source_tile.data_type ||
       !InstructionContractTypePairLegal_TSCATTER(
           source_tile.data_type,
           index_tile.data_type) ||
       source_tile.valid_rows == 0 ||
       source_tile.valid_columns == 0 ||
       source_tile.valid_rows != index_tile.valid_rows ||
       source_tile.valid_columns != index_tile.valid_columns ||
       destination_tile.valid_rows == 0 ||
       destination_tile.valid_columns != source_tile.valid_columns ||
       !TileSourceContentsDefined(source) ||
       !TileSourceContentsDefined(indices) ||
       !TileSourceEncodingsValid(indices) then
        return FALSE;
    end;
    return TileScatterReferencesLegal(destination, indices);
end;
```
<!-- GENERATED-ASL-END: unit -->
