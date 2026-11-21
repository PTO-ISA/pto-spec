<!-- GENERATED FROM: asl/tile/model/memory/shared-nd-to-cube.asl -->
# Shared Nd To CUBE

**Normative ASL source:** `asl/tile/model/memory/shared-nd-to-cube.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-MEMORY-SHARED-ND-TO-CUBE}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-memory-shared-nd-to-cube-purpose role=purpose-scope -->
## 用途与范围

本单元把选定的行主序 Shared ND 片段物化为一个分离的 Local CUBE 值。

<!-- PTO-READER-BLOCK: tile-model-memory-shared-nd-to-cube-concepts role=concepts-state -->
## 概念与状态

`SharedNDToCubeFragment` 记录起始行、有效区域、物理形状、容量、数据类型和目标 CUBE 布局。空片段被明确标记为无效。

<!-- PTO-READER-BLOCK: tile-model-memory-shared-nd-to-cube-rules role=rules-interactions -->
## 规则与交互

`TMOVSharedNDToCubeToValue` 先把目的物理区域清为未定义零值，再从片段窗口复制每个已定义源坐标，并把有效结果标记为已定义。

<!-- PTO-READER-BLOCK: tile-model-memory-shared-nd-to-cube-boundaries role=boundaries -->
## 架构边界

调用者提供有效片段和匹配的目的描述符。该辅助函数不选择片段、不发布 Shared 状态，也不把填充元素标记为已定义。

<!-- PTO-READER-BLOCK: tile-model-memory-shared-nd-to-cube-example role=example-usage -->
## 非规范阅读示例

如果片段从源第 8 行开始且有四个有效行，它会把源第 8 至 11 行复制到目的第 0 至 3 行，同时保持目的填充未定义。

<!-- PTO-READER-BLOCK: tile-model-memory-shared-nd-to-cube-related role=related-owners-navigation -->
## 相关所有者

- [相关所有者](shared-movement-values.md) 定义相关的 Shared 到 Local 值复制约定和已定义状态处理。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/memory/shared-nd-to-cube.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-MEMORY-SHARED-ND-TO-CUBE","surface":"tile","classification":["model","memory","shared-nd-to-cube"],"depends_on":["PTO-TILE-MODEL-DEFINEDNESS-ELEMENTS","PTO-TILE-MODEL-DEFINEDNESS-PACKED-BOUNDARY","PTO-TILE-MODEL-STATE-SHARED-REGISTERS","PTO-TILE-MODEL-STATE-TYPES"]}

type SharedNDToCubeFragment of record {
    valid: boolean,
    origin_row: integer {0..65535},
    valid_rows: integer {0..65535},
    valid_columns: integer {0..65535},
    physical_rows: integer {0..65535},
    physical_columns: integer {0..65535},
    capacity_bytes: integer {0..262144},
    data_type: TileDataType,
    layout: TileLayout
};

pure func EmptySharedNDToCubeFragment() => SharedNDToCubeFragment
begin
    return SharedNDToCubeFragment {
        valid = FALSE,
        origin_row = 0,
        valid_rows = 0,
        valid_columns = 0,
        physical_rows = 0,
        physical_columns = 0,
        capacity_bytes = 0,
        data_type = TileDataType_U8,
        layout = TileLayout_CUBE_M32
    };
end;

// Read only selected valid coordinates from a published Shared ND source.
// Destination padding is deterministic raw zero and remains undefined.
func TMOVSharedNDToCubeToValue(
    destination: TileInfo,
    shared_tile_id: SharedTileID,
    source_parent: TileInfo,
    fragment: SharedNDToCubeFragment) => TileInfo
begin
    assert fragment.valid && fragment.valid_rows > 0 &&
           fragment.valid_columns > 0 &&
           destination.layout == fragment.layout &&
           destination.data_type == fragment.data_type &&
           destination.capacity_bytes == fragment.capacity_bytes &&
           destination.rows == fragment.physical_rows &&
           destination.columns == fragment.physical_columns &&
           destination.valid_rows == fragment.valid_rows &&
           destination.valid_columns == fragment.valid_columns;
    var result = destination;
    for row = 0 to result.rows - 1 looplimit 65536 do
        for column = 0 to result.columns - 1 looplimit 65536 do
            let element = TileLogicalLinearIndex(result,
                row as integer {0..65535},
                column as integer {0..65535});
            result = TileInfoWithLogicalElementAndDefined(result, element,
                Zeros{PTO_XLEN}, FALSE);
        end;
    end;
    for row = 0 to fragment.valid_rows - 1 looplimit 65536 do
        for column = 0 to fragment.valid_columns - 1 looplimit 65536 do
            let source_element = TileLogicalLinearIndex(source_parent,
                (fragment.origin_row + row) as integer {0..65535},
                column as integer {0..65535});
            assert TileLogicalElementDefined(source_parent, source_element);
            let value = ReadSharedTileWord(shared_tile_id, source_element);
            let destination_element = TileLogicalLinearIndex(result,
                row as integer {0..65535},
                column as integer {0..65535});
            result = TileInfoWithLogicalElementAndDefined(result,
                destination_element, value, TRUE);
        end;
    end;
    result.defined_valid_elements =
        (fragment.valid_rows * fragment.valid_columns)
            as integer {0..524288};
    result.contents_defined = TRUE;
    return result;
end;
```
<!-- GENERATED-ASL-END: unit -->
