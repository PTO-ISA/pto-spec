<!-- GENERATED FROM: asl/block/model/dispatch/tlsu-gmov-helpers.asl -->
# TLSU Gmov Helpers

**Normative ASL source:** `asl/block/model/dispatch/tlsu-gmov-helpers.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-TLSU-GMOV-HELPERS}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-gmov-helpers-purpose role=purpose-scope -->
## 用途与范围

本单元提供 GMOV 在 PE 间传送 Tile 值时使用的 descriptor 检查，防止 destination 接收可见 shape 或 CUBE metadata 不同的 source。

<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-gmov-helpers-concepts role=concepts-state -->
## Source 与 destination 视图

CUBE source 必须具有合法 CUBE descriptor 和已定义内容。其他 layout 使用通用 Tile descriptor 检查。destination matching 比较 allocation、numeric storage、shape、valid region、data type 与 layout。

<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-gmov-helpers-rules role=rules-interactions -->
## 匹配规则

两个 source descriptor 只有在 capacity、physical/valid shape、data type、layout、storage kind、CUBE repeat、cell count 与 CUBE storage bytes 全部一致时才匹配。

<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-gmov-helpers-boundaries role=boundaries -->
## 边界

这些 helper 只比较 descriptor state，不选择 source PE、不预留 destination、不传送 payload byte，也不建立 source completion。

<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-gmov-helpers-example role=example-usage -->
## 示例

两个 CUBE_M32 source 即使 rows 和 columns 相同，只要 CUBE cell count 不同，exact-source match 仍失败。

<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-gmov-helpers-related role=related-owners-navigation -->
## 相关 owner

- [GMOV dispatch](tlsu-gmov.md) 选择 PE source 与 destination。
- [Descriptor legality](descriptor-legality.md) 拥有通用 Tile descriptor 检查。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/tlsu-gmov-helpers.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-TLSU-GMOV-HELPERS","surface":"block","classification":["model","dispatch","tlsu-gmov-helpers"],"depends_on":["PTO-TILE-MODEL-LEGALITY-DESCRIPTOR-SHAPE","PTO-TILE-MODEL-LEGALITY-DTYPE-LAYOUT","PTO-TILE-MODEL-LEGALITY-MATRIX-INFO-DESCRIPTOR","PTO-TILE-MODEL-STATE-TYPES"]}
readonly func BundleGMOVPESourceTileReady(tile: TileInfo) => boolean
begin
    if TileLayoutIsCube(tile.layout) then
        return TileCubeDescriptorLegal(tile) && tile.contents_defined;
    end;
    return TileInfoDescriptorLegal(tile);
end;

readonly func BundleGMOVDestinationValueMatches(
    destination: TileInfo, source: TileInfo) => boolean
begin
    return destination.allocated &&
           destination.storage_kind == TileStorage_Numeric &&
           TileCubeDescriptorLegal(destination) &&
           TileElementwiseLayoutSupported(destination.layout) &&
           TileCarrierOrPackedBaselineDataTypeSupported(source.data_type) &&
           destination.rows == source.rows &&
           destination.columns == source.columns &&
           destination.valid_rows == source.valid_rows &&
           destination.valid_columns == source.valid_columns &&
           destination.data_type == source.data_type &&
           destination.layout == source.layout;
end;

readonly func BundleGMOVSourceDescriptorsMatch(left: TileInfo,
                                                right: TileInfo) => boolean
begin
    return left.capacity_bytes == right.capacity_bytes &&
           left.rows == right.rows && left.columns == right.columns &&
           left.valid_rows == right.valid_rows &&
           left.valid_columns == right.valid_columns &&
           left.data_type == right.data_type &&
           left.layout == right.layout &&
           left.storage_kind == right.storage_kind &&
           left.cube_k_repeat == right.cube_k_repeat &&
           left.cube_n_repeat == right.cube_n_repeat &&
           left.cube_cell_count == right.cube_cell_count &&
           left.cube_storage_bytes == right.cube_storage_bytes;
end;
```
<!-- GENERATED-ASL-END: unit -->
