<!-- GENERATED FROM: asl/tile/model/memory/gm-atom-red-values.asl -->
# Gm Atom Red Values

**Normative ASL source:** `asl/tile/model/memory/gm-atom-red-values.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-MEMORY-GM-ATOM-RED-VALUES}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-memory-gm-atom-red-values-purpose role=purpose-scope -->
## 用途与范围

本单元验证全局内存原子比较交换和归约操作的分离输出值。

<!-- PTO-READER-BLOCK: tile-model-memory-gm-atom-red-values-concepts role=concepts-state -->
## 概念与状态

值 Tile 是返回到调用者输出路径的操作数。其描述符必须匹配索引 Tile 和操作数据类型，并且所需元素必须已定义。

<!-- PTO-READER-BLOCK: tile-model-memory-gm-atom-red-values-rules role=rules-interactions -->
## 规则与交互

`TileOperandsLegal_GM_ATOM_CASToValue` 检查比较值、替换值、索引和值的形状。`TileOperandsLegal_GM_ATOM_VALUEToValue` 检查单值归约系列。

<!-- PTO-READER-BLOCK: tile-model-memory-gm-atom-red-values-boundaries role=boundaries -->
## 架构边界

这些谓词不执行内存访问或原子更新。全局内存原子 owner 定义地址翻译、顺序、返回的旧值和事件记录。

<!-- PTO-READER-BLOCK: tile-model-memory-gm-atom-red-values-example role=example-usage -->
## 非规范阅读示例

如果分离值描述符与索引 Tile 使用不同布局，即使两者都已分配，比较交换输出也会被拒绝。

<!-- PTO-READER-BLOCK: tile-model-memory-gm-atom-red-values-related role=related-owners-navigation -->
## 相关所有者

- [相关所有者](gm-atom-red.md) 定义这些分离值检查所保护的原子操作系列和内存效果。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/memory/gm-atom-red-values.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-MEMORY-GM-ATOM-RED-VALUES","surface":"tile","classification":["model","memory","gm-atom-red-values"],"depends_on":["PTO-TILE-MODEL-MEMORY-GM-ATOM-RED","PTO-TILE-MODEL-LEGALITY-MEMORY-SCHEMA","PTO-TILE-MODEL-STATE-TYPES"]}
readonly func TileOperandsLegal_GM_ATOM_CASToValue(
    operation: GMAtomicOperation, destination: TileOutputValueTarget,
    base_address: Word, indices: TileIndex, expected: TileIndex,
    replacement: TileIndex, pad_value: TilePadValue) => boolean
begin
    let tile = destination.value;
    let index = _Tiles[[indices]];
    let expected_tile = _Tiles[[expected]];
    let replacement_tile = _Tiles[[replacement]];
    let data_type = tile.data_type;
    return IndexedTLSUNumericValueDescriptorLegal(tile) &&
           IndexedTLSUExecutionMaskContentsDefined(indices) &&
           IndexedTLSUExecutionMaskContentsDefined(expected) &&
           IndexedTLSUExecutionMaskContentsDefined(replacement) &&
           GMAtomicOperationDataTypeLegal(operation, data_type) &&
           expected_tile.data_type == data_type &&
           replacement_tile.data_type == data_type &&
           tile.valid_rows == index.valid_rows &&
           tile.valid_columns == index.valid_columns &&
           tile.valid_rows == expected_tile.valid_rows &&
           tile.valid_columns == expected_tile.valid_columns &&
           tile.valid_rows == replacement_tile.valid_rows &&
           tile.valid_columns == replacement_tile.valid_columns &&
           IndexedTLSUMemoryIndexDataTypeLegal(index.data_type) &&
           tile.layout == index.layout && tile.layout == expected_tile.layout &&
           tile.layout == replacement_tile.layout;
end;

readonly func TileOperandsLegal_GM_ATOM_VALUEToValue(
    operation: GMAtomicOperation, destination: TileOutputValueTarget,
    base_address: Word, indices: TileIndex, value: TileIndex,
    pad_value: TilePadValue) => boolean
begin
    let tile = destination.value;
    let index = _Tiles[[indices]];
    let value_tile = _Tiles[[value]];
    let data_type = tile.data_type;
    return IndexedTLSUNumericValueDescriptorLegal(tile) &&
           IndexedTLSUExecutionMaskContentsDefined(indices) &&
           IndexedTLSUExecutionMaskContentsDefined(value) &&
           GMAtomicOperationDataTypeLegal(operation, data_type) &&
           value_tile.data_type == data_type &&
           tile.valid_rows == index.valid_rows &&
           tile.valid_columns == index.valid_columns &&
           tile.valid_rows == value_tile.valid_rows &&
           tile.valid_columns == value_tile.valid_columns &&
           IndexedTLSUMemoryIndexDataTypeLegal(index.data_type) &&
           tile.layout == index.layout && tile.layout == value_tile.layout;
end;
```
<!-- GENERATED-ASL-END: unit -->
