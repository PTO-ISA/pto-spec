<!-- GENERATED FROM: asl/tile/model/memory/shared-cube-to-nd.asl -->
# Shared CUBE To Nd

**Normative ASL source:** `asl/tile/model/memory/shared-cube-to-nd.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-MEMORY-SHARED-CUBE-TO-ND}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-memory-shared-cube-to-nd-purpose role=purpose-scope -->
## 用途与范围

本单元把一个完整的 Local CUBE writer 片段转换成 Shared assemble 使用的行主序 ND 载荷。

<!-- PTO-READER-BLOCK: tile-model-memory-shared-cube-to-nd-concepts role=concepts-state -->
## 概念与状态

源的数据类型、容量、逻辑列数、有效区域和元素值保持不变。结果清除 CUBE repeat 与 CELL 元数据，并按行主序坐标重建已定义状态。

<!-- PTO-READER-BLOCK: tile-model-memory-shared-cube-to-nd-rules role=rules-interactions -->
## 规则与交互

`SharedTileFromLocalCubeToND` 验证源描述符和 writer 容量，复制每个已定义的有效坐标，并记录复制的有效元素数。

<!-- PTO-READER-BLOCK: tile-model-memory-shared-cube-to-nd-boundaries role=boundaries -->
## 架构边界

调用者在进入前执行可故障的模式检查。该辅助函数只接受 `CUBE_M16` 或 `CUBE_M32`，不发布 Shared parent，也不推断缺失的源元素。

<!-- PTO-READER-BLOCK: tile-model-memory-shared-cube-to-nd-example role=example-usage -->
## 非规范阅读示例

一个具有 16 行、8 个有效列的 `CUBE_M16` 片段会成为行主序片段，保留相同的 128 个逻辑值和 writer 容量。

<!-- PTO-READER-BLOCK: tile-model-memory-shared-cube-to-nd-related role=related-owners-navigation -->
## 相关所有者

- [相关所有者](../shape/cube-cell.md) 定义转换源坐标时使用的 CUBE CELL 几何。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/memory/shared-cube-to-nd.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-MEMORY-SHARED-CUBE-TO-ND","surface":"tile","classification":["model","memory","shared-cube-to-nd"],"depends_on":["PTO-TILE-MODEL-DEFINEDNESS-ELEMENTS","PTO-TILE-MODEL-DEFINEDNESS-PACKED-BOUNDARY","PTO-TILE-MODEL-LEGALITY-DESCRIPTOR-SHAPE","PTO-TILE-MODEL-SHAPE-CUBE-CELL","PTO-TILE-MODEL-SHAPE-CUBE-DOUBLE-CELL","PTO-TILE-MODEL-SHAPE-ROWS-COLUMNS"]}
// Convert a complete Local CUBE writer fragment into the ND payload geometry
// used by Shared B.ASSEMBLE.  The caller performs faulting schema checks first.
func SharedTileFromLocalCubeToND(source: TileIndex,
    writer_capacity_bytes: integer {128,256,512,1024,2048,4096,8192,
                                    16384,32768,65536,131072,262144})
    => TileInfo
begin
    let source_tile = _Tiles[[source]];
    assert source_tile.contents_defined && TileCubeDescriptorLegal(source_tile);
    assert source_tile.capacity_bytes == writer_capacity_bytes;
    assert source_tile.layout == TileLayout_CUBE_M16 ||
           source_tile.layout == TileLayout_CUBE_M32;
    assert source_tile.columns == TileCubePhysicalColumnsFromCapacity(
        writer_capacity_bytes, source_tile.layout, source_tile.data_type);
    assert source_tile.rows == DerivedTileRows(writer_capacity_bytes,
        source_tile.columns, source_tile.data_type);
    var result = source_tile;
    result.layout = TileLayout_RowMajor;
    result.capacity_bytes = writer_capacity_bytes;
    result.rows = DerivedTileRows(writer_capacity_bytes, result.columns,
        result.data_type);
    result.cube_k_repeat = 0;
    result.cube_n_repeat = 0;
    result.cube_cell_count = 0;
    result.cube_storage_bytes = 0;
    result.contents_defined = FALSE;
    result.defined_elements = Zeros{PTO_MODEL_TILE_ELEMENTS};
    result.defined_valid_elements = 0;
    result.packed_defined_elements = ZeroPackedTileDefinedElements();
    var zero_payload: TilePayload;
    for index = 0 to PTO_MODEL_TILE_ELEMENTS - 1 looplimit 524288 do
        zero_payload[[index as ModelTileElementIndex]] = Zeros{PTO_XLEN};
    end;
    result.payload = zero_payload;
    for row = 0 to source_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to source_tile.valid_columns - 1 looplimit 65536 do
            let source_element = TileLogicalLinearIndex(source_tile,
                row as integer {0..65535}, column as integer {0..65535});
            let destination_element = TileLogicalLinearIndex(result,
                row as integer {0..65535}, column as integer {0..65535});
            assert TileLogicalElementDefined(source_tile, source_element);
            result = TileInfoWithLogicalElement(result, destination_element,
                TileReadLogicalElement(source_tile, source_element));
        end;
    end;
    result.defined_valid_elements =
        (source_tile.valid_rows * source_tile.valid_columns)
            as integer {0..524288};
    result.contents_defined = TRUE;
    return result;
end;
```
<!-- GENERATED-ASL-END: unit -->
