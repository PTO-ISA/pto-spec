<!-- GENERATED FROM: asl/tile/model/legality/layout-rearrangement.asl -->
# Layout Rearrangement

**Normative ASL source:** `asl/tile/model/legality/layout-rearrangement.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-LEGALITY-LAYOUT-REARRANGEMENT}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-legality-layout-rearrangement-purpose role=purpose-scope -->
## 用途与范围

本单元包含四条 CUBE 单元重排指令的操作数合法性谓词：`TileOperandsLegal_TPERMUTE`、`TileOperandsLegal_TSHUF`、`TileOperandsLegal_TPACK` 与 `TileOperandsLegal_TUNPACK`。每条指令的 `InstructionContractOperandsLegal_*` 返回对应谓词，其目录记录也把该谓词列为 `legality_handler`。

合法性谓词是只读检查。它检查描述符、类型、控制字段与元素已定义性，并以返回 FALSE 代替修改状态。重排执行单元中的模型执行函数在构造结果之前断言同一谓词，因此未通过该谓词的操作数组合不会写入任何目标字节。

本单元还拥有执行单元复用的字节级辅助函数，例如 `TileReadCellByte`、`TileCellRearrangementRowBytes` 与 `TileCellRearrangementWordsPerRow`。

<!-- PTO-READER-BLOCK: tile-model-legality-layout-rearrangement-concepts role=concepts-state -->
## 概念与可见状态

CUBE 布局以单元（cell）存储 Tile。这些指令只接受 `CUBE_M16` 与 `CUBE_M32`（`TileCellRearrangementLayoutLegal`）。`TileCellRearrangementDescriptorLegal` 还要求 `TileCubeDescriptorLegal`，因此记录的单元几何必须与形状一致。

- 单元行字节数：`TileCellRearrangementRowBytes` 对 `CUBE_M16` 为 8，对 `CUBE_M32` 为 4。
- 一行的有效字节数：`valid_columns` 乘以元素位宽，向上取整到整字节。
- 一行的原始字数：有效字节数向上取整到完整的 32 位字。
- 字节已定义性：只有位于有效列内、且为其提供位的每个元素都已定义时，该字节才已定义。对四位类型，当字节的两个半字节都在有效列内时，两者都要检查。

`TSHUF`、`TPACK` 与 `TUNPACK` 读取的标量控制字必须满足位 `[63:32]` 全为零（`TileRearrangementControlWordLegal`）。

<!-- PTO-READER-BLOCK: tile-model-legality-layout-rearrangement-rules role=rules-interactions -->
## 规则与交互

`TPERMUTE` 检查四个 Tile：目标、`source0`、`source1` 以及一个 U8 索引 Tile。它们使用同一布局。数据 Tile 共享同一类型与同一有效形状，且该类型不是 64 位。索引 Tile 的有效行数相同，每个有效目标字节对应一列，单元数也相同。对每个活动目标字节，索引字节必须已定义且小于单元行字节数的两倍。小于单元行字节数的索引选择 `source0`，否则选择 `source1`，被选中的源字节必须已定义。

设计要点：索引在同一行、同一单元行段内选择字节，因为源字节等于段基址加所选偏移。因此字节不能移动到另一行或另一段，且在 `CUBE_M16` 下 16 或更大的索引是非法的，而不是回绕。

`TSHUF` 检查一个数据源、一个 U32 控制 Tile 与控制字。位 `[7:0]` 是模式（0 到 3），位 `[15:8]` 是段编码（0 到 4，对应宽度 2、4、8、16、32），位 `[23:16]` 是边界标志（0 或 1）。段编码 4 仅对 `CUBE_M32` 合法。对每个活动元素，起控制作用的 U32 字必须已定义，实际将被读取的源元素也必须已定义。

`TPACK` 与 `TUNPACK` 需要位宽为 8、16 或 32 位的数值源，以及类型为 U8、U16 或 U32 的目标。目标有效列数必须等于原始字数乘以每字目标元素数。`TPACK` 从每个源的每个字中取 1 到 3 个低字节，总数最多 4。`TUNPACK` 取字节偏移 0 到 3、长度 1 到 4 且在第 4 字节前结束的字段。

设计要点：已定义性只对操作将读取的字节检查。没有被任何索引或控制选中的未定义字节不会使操作非法。

<!-- PTO-READER-BLOCK: tile-model-legality-layout-rearrangement-boundaries role=boundaries -->
## 架构边界

存在 ExecutionMask 时，逐字节与逐元素检查只在活动坐标上运行。`TPACK` 与 `TUNPACK` 在 `(row, word_index)` 处查询掩码。一个例外：`TUNPACK` 的跨度规则（偏移加长度必须落在每个字的有效字节内）对每个字都检查，无论是否活动。

目标必须与每个数据源是不同的寄存器，`TSHUF` 还要求它与控制 Tile 不同。`TPERMUTE` 要求索引 Tile 与两个数据源都不同，但 `source0` 与 `source1` 可以是同一个 Tile。

指令束分派会更早应用部分规则。`ResolveBundleCellRearrangementDestination` 检查源描述符以及 `TPACK`/`TUNPACK` 的源类型，并在分配目标之前引发 `Fault_TileLegality`。

`TileCellRearrangementValidRegionDefined` 定义于此，但在 `asl/` 中搜索找不到调用者。

<!-- PTO-READER-BLOCK: tile-model-legality-layout-rearrangement-example role=example-usage -->
## 非规范阅读示例

考虑 `CUBE_M16` 中 U8 数据的 `TPERMUTE`，有效形状为 16 行 8 列。

- 每行有 8 个有效字节，单元行字节数为 8，因此索引 Tile 需要 8 个有效列。
- 合法索引值为 0 到 15。
- 目标第 5 行第 2 字节的索引为 3 时，读取 `source0` 第 5 行的第 3 字节。
- 同一位置的索引为 11 时，读取 `source1` 第 5 行的第 3 字节。
- 任何活动索引为 16 都使谓词为 FALSE，且不写入任何目标字节。

<!-- PTO-READER-BLOCK: tile-model-legality-layout-rearrangement-related role=related-owners-navigation -->
## 相关所有者

- [重排执行](../execution/rearrangement.md) 在这些检查之后运行四个操作。
- [CUBE 单元几何](../shape/cube-cell.md) 拥有单元行数、单元列数与单元数。
- [描述符形状](descriptor-shape.md) 拥有 `TileCubeDescriptorLegal`。
- [单元重排 schema](../../../block/model/dispatch/cell-rearrangement-schema.md) 拥有指令束侧的目标检查。
- [TPERMUTE](../../layout-and-rearrangement/layout/TPERMUTE.md)、[TSHUF](../../layout-and-rearrangement/layout/TSHUF.md)、[TPACK](../../layout-and-rearrangement/layout/TPACK.md) 与 [TUNPACK](../../layout-and-rearrangement/layout/TUNPACK.md) 是指令页面。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/legality/layout-rearrangement.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-LEGALITY-LAYOUT-REARRANGEMENT","surface":"tile","classification":["model","legality","layout-rearrangement"],"depends_on":["PTO-TILE-MODEL-EXECUTION-MASK-STATE","PTO-TILE-MODEL-LEGALITY-DTYPE-LAYOUT"]}

pure func TileCellRearrangementLayoutLegal(layout: TileLayout) => boolean
begin
    return layout == TileLayout_CUBE_M16 ||
           layout == TileLayout_CUBE_M32;
end;

readonly func TileCellRearrangementDescriptorLegal(index: TileIndex)
    => boolean
begin
    return TileCubeDescriptorLegal(_Tiles[[index]]) &&
           TileCellRearrangementLayoutLegal(_Tiles[[index]].layout);
end;

pure func TileCellRearrangementRowBytes(layout: TileLayout) => integer {4,8}
begin
    return if layout == TileLayout_CUBE_M32 then 4 else 8;
end;

pure func TileRearrangementControlWordLegal(control: Word) => boolean
begin
    return control[63:32] == Zeros{32};
end;

readonly func TileCellRearrangementValidBytes(tile: TileInfo)
    => integer {0..262144}
begin
    return ((tile.valid_columns * TileElementBits(tile.data_type) + 7) DIVRM 8)
        as integer {0..262144};
end;

readonly func TileCellRearrangementWordsPerRow(tile: TileInfo)
    => integer {0..65536}
begin
    return ((TileCellRearrangementValidBytes(tile) + 3) DIVRM 4)
        as integer {0..65536};
end;

readonly func TileCellRearrangementByteDefined(
    tile: TileInfo, row: integer {0..65535},
    byte_index: integer {0..262143}) => boolean
begin
    let element_bits = TileElementBits(tile.data_type);
    if element_bits == 4 then
        assert byte_index <= 32767;
        let first_byte_index = byte_index as integer {0..32767};
        let first_nibble = (first_byte_index * 2) as integer {0..65535};
        if first_nibble >= tile.valid_columns then return FALSE; end;
        let first_element = TileLogicalLinearIndex(tile, row,
            first_nibble as integer {0..65535});
        if !TileLogicalElementDefined(tile, first_element) then
            return FALSE;
        end;
        if first_nibble + 1 < tile.valid_columns then
            let second_element = TileLogicalLinearIndex(tile, row,
                (first_nibble + 1) as integer {0..65535});
            return TileLogicalElementDefined(tile, second_element);
        end;
        return TRUE;
    end;
    let element_bytes = TileElementBytes(tile.data_type);
    let element_column = (byte_index DIVRM element_bytes)
        as integer {0..65535};
    if element_column >= tile.valid_columns then return FALSE; end;
    let element = TileLogicalLinearIndex(tile, row,
        element_column as integer {0..65535});
    return TileLogicalElementDefined(tile, element);
end;

readonly func TileReadCellByte(tile: TileInfo,
                               row: integer {0..65535},
                               byte_index: integer {0..262143}) => Byte
begin
    let element_bits = TileElementBits(tile.data_type);
    if element_bits == 4 then
        assert byte_index <= 32767;
        let first_byte_index = byte_index as integer {0..32767};
        let first_nibble = (first_byte_index * 2) as integer {0..65535};
        let first_element = TileLogicalLinearIndex(tile, row,
            first_nibble as integer {0..65535});
        var result = Zeros{8};
        result[3:0] = TileReadLogicalElement(tile, first_element)[3:0];
        if first_nibble + 1 < tile.valid_columns then
            let second_element = TileLogicalLinearIndex(tile, row,
                (first_nibble + 1) as integer {0..65535});
            result[7:4] = TileReadLogicalElement(tile,
                second_element)[3:0];
        end;
        return result;
    end;
    let element_bytes = TileElementBytes(tile.data_type);
    let element_column = (byte_index DIVRM element_bytes)
        as integer {0..65535};
    let byte_in_element = (byte_index MOD element_bytes) as integer {0..7};
    let element = TileLogicalLinearIndex(tile, row,
        element_column as integer {0..65535});
    return TileReadLogicalElement(tile, element)[(byte_in_element * 8) +: 8];
end;

readonly func TileCellRearrangementValidRegionDefined(tile: TileInfo)
    => boolean
begin
    let valid_bytes = TileCellRearrangementValidBytes(tile);
    for row = 0 to tile.valid_rows - 1 looplimit 65536 do
        for byte_index = 0 to valid_bytes - 1 looplimit 262144 do
            if !TileCellRearrangementByteDefined(tile,
                row as integer {0..65535}, byte_index) then
                return FALSE;
            end;
        end;
    end;
    return TRUE;
end;

readonly func TileCellRearrangementByteHasActiveCoordinate(
    tile: TileInfo, row: integer {0..65535},
    byte_index: integer {0..262143}) => boolean
begin
    let element_bits = TileElementBits(tile.data_type);
    if element_bits == 4 then
        let first_column = (byte_index * 2) as integer {0..65535};
        if first_column < tile.valid_columns &&
           BundleExecutionMaskActiveAt(tile.layout, row, first_column) then
            return TRUE;
        end;
        return first_column + 1 < tile.valid_columns &&
               BundleExecutionMaskActiveAt(
                   tile.layout, row,
                   (first_column + 1) as integer {0..65535});
    end;
    let element_column = (byte_index DIVRM
        TileElementBytes(tile.data_type)) as integer {0..65535};
    return element_column < tile.valid_columns &&
           BundleExecutionMaskActiveAt(tile.layout, row, element_column);
end;

pure func TileCellRearrangementElementWordIndex(
    data_type: TileDataType, column: integer {0..65535})
    => integer {0..65535}
begin
    return ((column * TileElementBits(data_type)) DIVRM 32)
        as integer {0..65535};
end;

readonly func TileOperandsLegal_TPERMUTE(
    destination: TileIndex, source0: TileIndex,
    source1: TileIndex, indices: TileIndex) => boolean
begin
    if !TileCellRearrangementDescriptorLegal(destination) ||
       !TileCellRearrangementDescriptorLegal(source0) ||
       !TileCellRearrangementDescriptorLegal(source1) ||
       !TileCellRearrangementDescriptorLegal(indices) || destination == source0 ||
       destination == source1 || indices == source0 || indices == source1 then
        return FALSE;
    end;
    let destination_tile = _Tiles[[destination]];
    let left = _Tiles[[source0]];
    let right = _Tiles[[source1]];
    let index_tile = _Tiles[[indices]];
    if destination_tile.storage_kind != TileStorage_Numeric ||
       left.storage_kind != TileStorage_Numeric ||
       right.storage_kind != TileStorage_Numeric ||
       index_tile.storage_kind != TileStorage_Numeric ||
       !TileCellRearrangementLayoutLegal(destination_tile.layout) ||
       destination_tile.layout != left.layout ||
       destination_tile.layout != right.layout ||
       destination_tile.data_type != left.data_type ||
       destination_tile.data_type != right.data_type ||
       !TileCubeDataTypeSupported(destination_tile.data_type) ||
       TileElementBits(destination_tile.data_type) == 64 ||
       index_tile.data_type != TileDataType_U8 ||
       index_tile.layout != destination_tile.layout ||
       destination_tile.valid_rows != left.valid_rows ||
       destination_tile.valid_rows != right.valid_rows ||
       destination_tile.valid_columns != left.valid_columns ||
       destination_tile.valid_columns != right.valid_columns ||
       index_tile.valid_rows != destination_tile.valid_rows ||
       index_tile.valid_columns !=
           TileCellRearrangementValidBytes(destination_tile) ||
       index_tile.cube_cell_count != destination_tile.cube_cell_count then
        return FALSE;
    end;
    let row_bytes = TileCellRearrangementRowBytes(destination_tile.layout);
    let valid_bytes = TileCellRearrangementValidBytes(destination_tile);
    if valid_bytes > row_bytes * destination_tile.cube_cell_count then
        return FALSE;
    end;
    for row = 0 to destination_tile.valid_rows - 1 looplimit 65536 do
        for byte_index = 0 to valid_bytes - 1 looplimit 262144 do
            if TileCellRearrangementByteHasActiveCoordinate(
                   destination_tile, row as integer {0..65535}, byte_index) then
                if !TileCellRearrangementByteDefined(index_tile,
                    row as integer {0..65535}, byte_index) then
                    return FALSE;
                end;
                let index_element = TileLogicalLinearIndex(index_tile,
                    row as integer {0..65535},
                    byte_index as integer {0..65535});
                let index_value = UInt(TileReadLogicalElement(
                    index_tile, index_element));
                if index_value >= row_bytes * 2 then return FALSE; end;
                let cell_base = (byte_index DIVRM row_bytes) * row_bytes;
                let selected_byte = if index_value < row_bytes then
                    index_value else index_value - row_bytes;
                let source_byte = cell_base + selected_byte;
                let selected_source = if index_value < row_bytes then
                    left else right;
                if !TileCellRearrangementByteDefined(selected_source,
                    row as integer {0..65535},
                    source_byte as integer {0..262143}) then
                    return FALSE;
                end;
            end;
        end;
    end;
    return TRUE;
end;

readonly func TileOperandsLegal_TSHUF(
    destination: TileIndex, source: TileIndex,
    controls: TileIndex, control: Word) => boolean
begin
    if !TileCellRearrangementDescriptorLegal(destination) ||
       !TileCellRearrangementDescriptorLegal(source) ||
       !TileCellRearrangementDescriptorLegal(controls) || destination == source ||
       destination == controls then return FALSE; end;
    let destination_tile = _Tiles[[destination]];
    let source_tile = _Tiles[[source]];
    let control_tile = _Tiles[[controls]];
    let mode = UInt(control[7:0]);
    let segment_code = UInt(control[15:8]);
    let boundary = UInt(control[23:16]);
    if destination_tile.storage_kind != TileStorage_Numeric ||
       source_tile.storage_kind != TileStorage_Numeric ||
       control_tile.storage_kind != TileStorage_Numeric ||
       !TileCellRearrangementLayoutLegal(destination_tile.layout) ||
       destination_tile.layout != source_tile.layout ||
       destination_tile.layout != control_tile.layout ||
       destination_tile.data_type != source_tile.data_type ||
       control_tile.data_type != TileDataType_U32 ||
       destination_tile.valid_rows != source_tile.valid_rows ||
       destination_tile.valid_columns != source_tile.valid_columns ||
       control_tile.valid_rows != source_tile.valid_rows ||
       control_tile.valid_columns !=
           TileCellRearrangementWordsPerRow(source_tile) ||
       control_tile.cube_cell_count != source_tile.cube_cell_count ||
       mode > 3 || boundary > 1 || segment_code > 4 ||
       (segment_code == 4 &&
        destination_tile.layout != TileLayout_CUBE_M32) ||
       (destination_tile.layout == TileLayout_CUBE_M16 &&
        segment_code == 4) || !TileRearrangementControlWordLegal(control) ||
       !TileCubeDataTypeSupported(destination_tile.data_type) ||
       TileElementBits(destination_tile.data_type) == 64 then
        return FALSE;
    end;
    let segment_width = if segment_code == 0 then 2
        else if segment_code == 1 then 4
        else if segment_code == 2 then 8
        else if segment_code == 3 then 16
        else 32;
    let cell_rows = if destination_tile.layout == TileLayout_CUBE_M32 then 32
        else 16;
    for row = 0 to source_tile.valid_rows - 1 looplimit 65536 do
        let lane = (row MOD cell_rows) as integer {0..31};
        let segment_base = ((lane DIVRM segment_width) * segment_width)
            as integer {0..31};
        let local_lane = (lane - segment_base) as integer {0..31};
        for column = 0 to source_tile.valid_columns - 1 looplimit 65536 do
            if BundleExecutionMaskActiveAt(
                   source_tile.layout, row as integer {0..65535},
                   column as integer {0..65535}) then
                let word_index = TileCellRearrangementElementWordIndex(
                    source_tile.data_type,
                    column as integer {0..65535});
                let control_element = TileLogicalLinearIndex(
                    control_tile, row as integer {0..65535}, word_index);
                if !TileLogicalElementDefined(
                       control_tile, control_element) then return FALSE; end;
                let control_word = TileReadLogicalElement(
                    control_tile, control_element);
                let b = UInt(control_word[4:0]);
                var candidate_valid = TRUE;
                var candidate_lane: integer {0..31} = lane;
                if mode == 0 then
                    if b > lane - segment_base then candidate_valid = FALSE;
                    else candidate_lane = (lane - b) as integer {0..31}; end;
                elsif mode == 1 then
                    if (lane - segment_base) + b >= segment_width then
                        candidate_valid = FALSE;
                    else candidate_lane = (lane + b) as integer {0..31}; end;
                elsif mode == 2 then
                    candidate_lane = (segment_base +
                        UInt(((Zeros{5} + local_lane) as bits(5)) XOR
                             ((Zeros{5} + b) as bits(5))))
                        as integer {0..31};
                    if candidate_lane >= segment_base + segment_width then
                        candidate_valid = FALSE;
                    end;
                else
                    candidate_lane = (segment_base +
                        (b MOD segment_width)) as integer {0..31};
                end;
                let candidate_row = (row - lane) + candidate_lane;
                var source_row: integer {0..65535} =
                    row as integer {0..65535};
                var source_required = boundary == 0;
                if candidate_valid &&
                   candidate_row < source_tile.valid_rows then
                    source_row = candidate_row as integer {0..65535};
                    source_required = TRUE;
                end;
                if source_required then
                    let source_element = TileLogicalLinearIndex(
                        source_tile, source_row,
                        column as integer {0..65535});
                    if !TileLogicalElementDefined(
                           source_tile, source_element) then return FALSE; end;
                end;
            end;
        end;
    end;
    return TRUE;
end;

pure func TileCellRearrangementDataTypeLegal(
    data_type: TileDataType) => boolean
begin
    return TileCubeDataTypeSupported(data_type) &&
           (TileElementBits(data_type) == 8 ||
            TileElementBits(data_type) == 16 ||
            TileElementBits(data_type) == 32);
end;

readonly func TileCellRearrangementSelectedBytesDefined(
    tile: TileInfo, row: integer {0..65535},
    byte_offset: integer {0..262143},
    byte_count: integer {0..4}) => boolean
begin
    for byte_index = 0 to byte_count - 1 looplimit 4 do
        if !TileCellRearrangementByteDefined(
            tile, row, (byte_offset + byte_index) as integer {0..262143}) then
            return FALSE;
        end;
    end;
    return TRUE;
end;

readonly func TileOperandsLegal_TPACK(
    destination: TileIndex, source0: TileIndex,
    source1: TileIndex, control: Word) => boolean
begin
    if !TileCellRearrangementDescriptorLegal(destination) ||
       !TileCellRearrangementDescriptorLegal(source0) ||
       !TileCellRearrangementDescriptorLegal(source1) || destination == source0 ||
       destination == source1 then return FALSE; end;
    let destination_tile = _Tiles[[destination]];
    let left = _Tiles[[source0]];
    let right = _Tiles[[source1]];
    let left_bytes = UInt(control[7:0]);
    let right_bytes = UInt(control[15:8]);
    if left.storage_kind != TileStorage_Numeric ||
       right.storage_kind != TileStorage_Numeric ||
       !TileCellRearrangementDataTypeLegal(left.data_type) ||
       !TileCellRearrangementDataTypeLegal(right.data_type) then
        return FALSE;
    end;
    let words = TileCellRearrangementWordsPerRow(left);
    let destination_elements_per_word =
        if destination_tile.data_type == TileDataType_U8 then 4
        else if destination_tile.data_type == TileDataType_U16 then 2
        else if destination_tile.data_type == TileDataType_U32 then 1
        else 0;
    if destination_tile.storage_kind != TileStorage_Numeric ||
       left.storage_kind != TileStorage_Numeric ||
       right.storage_kind != TileStorage_Numeric ||
       !TileCellRearrangementDataTypeLegal(left.data_type) ||
       !TileCellRearrangementDataTypeLegal(right.data_type) ||
       destination_elements_per_word == 0 ||
       destination_tile.layout != left.layout ||
       destination_tile.layout != right.layout ||
       destination_tile.valid_rows != left.valid_rows ||
       destination_tile.valid_rows != right.valid_rows ||
       TileCellRearrangementWordsPerRow(right) != words ||
       destination_tile.valid_columns !=
           words * destination_elements_per_word ||
       left_bytes < 1 || left_bytes > 3 ||
       right_bytes < 1 || right_bytes > 3 ||
       left_bytes + right_bytes > 4 ||
       !TileRearrangementControlWordLegal(control) then
        return FALSE;
    end;
    for row = 0 to left.valid_rows - 1 looplimit 65536 do
        for word_index = 0 to words - 1 looplimit 65536 do
            let word_start = (word_index * 4) as integer {0..262143};
            if !_BundleExecutionMask.valid ||
               BundleExecutionMaskActiveAt(
                   left.layout, row as integer {0..65535},
                   word_index as integer {0..65535}) then
                if !TileCellRearrangementSelectedBytesDefined(
                    left, row as integer {0..65535}, word_start,
                    left_bytes as integer {0..4}) ||
                   !TileCellRearrangementSelectedBytesDefined(
                    right, row as integer {0..65535}, word_start,
                    right_bytes as integer {0..4}) then
                    return FALSE;
                end;
            end;
        end;
    end;
    return TRUE;
end;

readonly func TileOperandsLegal_TUNPACK(
    destination: TileIndex, source: TileIndex, control: Word) => boolean
begin
    if !TileCellRearrangementDescriptorLegal(destination) ||
       !TileCellRearrangementDescriptorLegal(source) || destination == source then
        return FALSE;
    end;
    let destination_tile = _Tiles[[destination]];
    let source_tile = _Tiles[[source]];
    let offset = UInt(control[7:0]);
    let count = UInt(control[15:8]);
    if source_tile.storage_kind != TileStorage_Numeric ||
       !TileCellRearrangementDataTypeLegal(source_tile.data_type) then
        return FALSE;
    end;
    let words = TileCellRearrangementWordsPerRow(source_tile);
    let destination_elements_per_word =
        if destination_tile.data_type == TileDataType_U8 then 4
        else if destination_tile.data_type == TileDataType_U16 then 2
        else if destination_tile.data_type == TileDataType_U32 then 1
        else 0;
    if destination_tile.storage_kind != TileStorage_Numeric ||
       source_tile.storage_kind != TileStorage_Numeric ||
       !TileCellRearrangementDataTypeLegal(source_tile.data_type) ||
       destination_elements_per_word == 0 ||
       destination_tile.layout != source_tile.layout ||
       destination_tile.valid_rows != source_tile.valid_rows ||
       destination_tile.valid_columns !=
           words * destination_elements_per_word ||
       offset > 3 || count < 1 || count > 4 || offset + count > 4 ||
       !TileRearrangementControlWordLegal(control) then
        return FALSE;
    end;
    let valid_bytes = TileCellRearrangementValidBytes(source_tile);
    for row = 0 to source_tile.valid_rows - 1 looplimit 65536 do
        for word_index = 0 to words - 1 looplimit 65536 do
            let word_start = (word_index * 4) as integer {0..262143};
            let word_valid = if valid_bytes > word_start then
                (if valid_bytes - word_start > 4 then 4
                 else valid_bytes - word_start)
            else 0;
            if offset + count > word_valid then
                return FALSE;
            end;
            if (!_BundleExecutionMask.valid ||
                BundleExecutionMaskActiveAt(
                    source_tile.layout, row as integer {0..65535},
                    word_index as integer {0..65535})) &&
               !TileCellRearrangementSelectedBytesDefined(
                   source_tile, row as integer {0..65535},
                   (word_start + offset) as integer {0..262143},
                   count as integer {0..4}) then
                return FALSE;
            end;
        end;
    end;
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: unit -->
